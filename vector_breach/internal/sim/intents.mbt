// intents.mbt - Enemy intent generation and resolution.
// Each enemy type has simple, predictable AI rules.
// Intents are generated at the start of the enemy turn and displayed to the player.

///|
/// Generate intents for all enemy units based on their type and the current board state.
pub fn generate_enemy_intents(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == Enemy {
      u.intent = generate_intent_for(battle, i)
    }
  }
}

///|
/// Generate a single intent for an enemy unit based on its type.
/// Late-mission enemies get upgraded abilities.
fn generate_intent_for(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let mission = battle.mission_id
  match u.enemy_type {
    Rammer =>
      if mission >= 4 {
        generate_rammer_unstoppable_intent(battle, unit_id)
      } else {
        generate_rammer_intent(battle, unit_id)
      }
    Artillery =>
      if mission >= 6 {
        generate_artillery_cluster_intent(battle, unit_id)
      } else {
        generate_artillery_intent(battle, unit_id)
      }
    BeamTurret =>
      if mission >= 5 {
        generate_beam_rotating_intent(battle, unit_id)
      } else {
        generate_beam_turret_intent(battle, unit_id)
      }
    Leaper => generate_leaper_intent(battle, unit_id)
    MineLayer => generate_mine_layer_intent(battle, unit_id)
    ShieldDrone => generate_shield_drone_intent(battle, unit_id)
    Splitter => generate_splitter_intent(battle, unit_id)
    Boss =>
      if mission >= 8 {
        generate_hivemind_intent(battle, unit_id)
      } else if mission >= 4 {
        generate_siege_engine_intent(battle, unit_id)
      } else {
        generate_boss_intent(battle, unit_id)
      }
  }
}

///|
/// Rammer: March toward nearest player mech, then charge in a line.
fn generate_rammer_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  let dist = @types.manhattan(u.x, u.y, target.x, target.y)
  if dist <= 1 {
    // Adjacent: charge through them
    let dx = sign(target.x - u.x)
    let dy = sign(target.y - u.y)
    Charge(dx, dy)
  } else {
    // March 1 step toward nearest player
    let (sdx, sdy) = step_toward(u.x, u.y, target.x, target.y)
    March(u.x + sdx, u.y + sdy)
  }
}

///|
/// Artillery: Fire at the most damaged player mech in a 3x3 area.
fn generate_artillery_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_most_damaged_unit(battle, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  AreaBlast(target.x, target.y, 1)
}

///|
/// BeamTurret: Fire beam in the direction of nearest player (entire row/col).
fn generate_beam_turret_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  let dx = sign(target.x - u.x)
  let dy = sign(target.y - u.y)
  // Prefer the axis with greater distance
  let adx = @types.abs_int(target.x - u.x)
  let ady = @types.abs_int(target.y - u.y)
  if adx >= ady {
    FireLine(dx, 0, 8)
  } else {
    FireLine(0, dy, 8)
  }
}

///|
/// Leaper: Jump to tile adjacent to weakest player mech.
fn generate_leaper_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_weakest_unit(battle, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  // Find a walkable tile adjacent to target
  let dx_arr = [0, 0, 1, -1]
  let dy_arr = [-1, 1, 0, 0]
  let mut best_x = u.x
  let mut best_y = u.y
  let mut best_dist = 9999
  for d = 0; d < 4; d = d + 1 {
    let ax = target.x + dx_arr[d]
    let ay = target.y + dy_arr[d]
    if is_walkable(battle, ax, ay) {
      let dd = @types.manhattan(u.x, u.y, ax, ay)
      if dd < best_dist {
        best_dist = dd
        best_x = ax
        best_y = ay
      }
    }
  }
  Leap(best_x, best_y)
}

///|
/// MineLayer: Place mine on floor between self and nearest player.
fn generate_mine_layer_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  // Place mine halfway between self and target
  let mx = (u.x + target.x) / 2
  let my = (u.y + target.y) / 2
  MinePlace(mx, my)
}

///|
/// ShieldDrone: Shield nearest ally with lowest HP.
fn generate_shield_drone_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  // Find weakest enemy ally (not self)
  let mut best_id = -1
  let mut best_hp = 9999
  for i = 0; i < battle.units.length(); i = i + 1 {
    let ally = battle.units[i]
    if ally.active && ally.hp > 0 && ally.team == Enemy && i != unit_id {
      if ally.hp < best_hp {
        best_hp = ally.hp
        best_id = i
      }
    }
  }
  if best_id >= 0 {
    let ally = battle.units[best_id]
    Summon(ally.x, ally.y, 2) // 2 = shield amount
  } else {
    // No allies, march toward enemy
    let target_id = find_nearest_unit(battle, u.x, u.y, Player)
    if target_id >= 0 {
      let target = battle.units[target_id]
      let (sdx, sdy) = step_toward(u.x, u.y, target.x, target.y)
      March(u.x + sdx, u.y + sdy)
    } else {
      March(u.x, u.y)
    }
  }
}

///|
/// Splitter: March toward nearest player. (On death, handled by kill logic.)
fn generate_splitter_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  let (sdx, sdy) = step_toward(u.x, u.y, target.x, target.y)
  March(u.x + sdx, u.y + sdy)
}

///|
/// Boss: Alternates between area blast and charge.
fn generate_boss_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  // Alternate based on turn parity
  if battle.turn % 2 == 0 {
    AreaBlast(target.x, target.y, 1)
  } else {
    let dx = sign(target.x - u.x)
    let dy = sign(target.y - u.y)
    Charge(dx, dy)
  }
}

///|
/// Resolve all enemy intents - execute each one in order.
pub fn resolve_all_enemy_intents(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == Enemy {
      if u.stunned {
        let name = get_unit_name(battle, i)
        battle.turn_log.push("\{name} is stunned and skips its turn")
        u.stunned = false
      } else {
        resolve_single_intent(battle, i)
      }
    }
  }
}

///|
/// Resolve a single enemy's intent.
fn resolve_single_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  match u.intent {
    March(tx, ty) => resolve_march(battle, unit_id, name, tx, ty)
    Charge(dx, dy) => resolve_charge(battle, unit_id, name, dx, dy)
    FireLine(dx, dy, range) =>
      resolve_fire_line(battle, unit_id, name, dx, dy, range)
    Leap(tx, ty) => resolve_leap(battle, unit_id, name, tx, ty)
    AreaBlast(tx, ty, radius) =>
      resolve_area_blast(battle, unit_id, name, tx, ty, radius)
    Summon(tx, ty, amount) =>
      resolve_summon(battle, unit_id, name, tx, ty, amount)
    MinePlace(tx, ty) => resolve_mine_place(battle, name, tx, ty)
  }
}

///|
/// March: Move 1 tile toward target.
fn resolve_march(
  battle : @types.BattleState,
  unit_id : Int,
  name : String,
  tx : Int,
  ty : Int,
) -> Unit {
  if is_walkable(battle, tx, ty) {
    move_unit_to(battle, unit_id, tx, ty)
    battle.turn_log.push("\{name} marches to (\{tx}, \{ty})")
    check_hazard_on_tile(battle, unit_id, tx, ty)
  } else if battle.grid.in_bounds(tx, ty) {
    // Tile occupied or blocked - try alternate directions
    let u = battle.units[unit_id]
    let dx_arr = [0, 0, 1, -1]
    let dy_arr = [-1, 1, 0, 0]
    for d = 0; d < 4; d = d + 1 {
      let alt_x = u.x + dx_arr[d]
      let alt_y = u.y + dy_arr[d]
      let alt_dist = @types.manhattan(alt_x, alt_y, tx, ty)
      let cur_dist = @types.manhattan(u.x, u.y, tx, ty)
      if alt_dist < cur_dist && is_walkable(battle, alt_x, alt_y) {
        move_unit_to(battle, unit_id, alt_x, alt_y)
        battle.turn_log.push(
          "\{name} marches to (\{alt_x}, \{alt_y})",
        )
        check_hazard_on_tile(battle, unit_id, alt_x, alt_y)
        return
      }
    }
    battle.turn_log.push("\{name} is blocked and cannot march")
  } else {
    battle.turn_log.push("\{name} cannot march out of bounds")
  }
}

///|
/// Charge: Move in a direction until hitting something, deal damage.
fn resolve_charge(
  battle : @types.BattleState,
  unit_id : Int,
  name : String,
  dx : Int,
  dy : Int,
) -> Unit {
  let u = battle.units[unit_id]
  battle.turn_log.push("\{name} charges!")
  let mut steps = 0
  let max_charge = 4
  while steps < max_charge {
    let nx = u.x + dx
    let ny = u.y + dy
    if !battle.grid.in_bounds(nx, ny) {
      break
    }
    let tile = battle.grid.get(nx, ny)
    if tile.kind == Wall {
      break
    }
    if tile.occupied_by >= 0 {
      // Hit a unit: deal 2 damage and push 1 tile
      let hit_id = tile.occupied_by
      let hit_name = get_unit_name(battle, hit_id)
      let _ = apply_damage(battle, hit_id, 2)
      battle.turn_log.push(
        "\{name} charges into \{hit_name} for 2 damage!",
      )
      try_push(battle, hit_id, dx, dy, 1)
      break
    }
    if tile.kind == Chasm {
      // Enemy charges into chasm
      battle.turn_log.push("\{name} charges into a chasm!")
      kill_unit(battle, unit_id)
      return
    }
    move_unit_to(battle, unit_id, nx, ny)
    steps += 1
  }
}

///|
/// FireLine: Fire a beam along a row/column.
fn resolve_fire_line(
  battle : @types.BattleState,
  unit_id : Int,
  name : String,
  dx : Int,
  dy : Int,
  range : Int,
) -> Unit {
  let u = battle.units[unit_id]
  battle.turn_log.push("\{name} fires a beam!")
  let mut cx = u.x + dx
  let mut cy = u.y + dy
  let mut steps = 0
  while steps < range && battle.grid.in_bounds(cx, cy) {
    let tile = battle.grid.get(cx, cy)
    if tile.kind == Wall {
      break
    }
    if tile.occupied_by >= 0 {
      let hit_id = tile.occupied_by
      let hit_name = get_unit_name(battle, hit_id)
      let _ = apply_damage(battle, hit_id, 2)
      battle.turn_log.push(
        "  Beam hits \{hit_name} for 2 damage!",
      )
      // Beam continues through units
    }
    cx += dx
    cy += dy
    steps += 1
  }
}

///|
/// Leap: Jump to target tile.
fn resolve_leap(
  battle : @types.BattleState,
  unit_id : Int,
  name : String,
  tx : Int,
  ty : Int,
) -> Unit {
  if is_walkable(battle, tx, ty) {
    move_unit_to(battle, unit_id, tx, ty)
    battle.turn_log.push("\{name} leaps to (\{tx}, \{ty})")
    // Leaper attacks all adjacent player units on landing
    let dx_arr = [0, 0, 1, -1]
    let dy_arr = [-1, 1, 0, 0]
    for d = 0; d < 4; d = d + 1 {
      let ax = tx + dx_arr[d]
      let ay = ty + dy_arr[d]
      let hit_id = unit_at(battle, ax, ay)
      if hit_id >= 0 {
        let hit_unit = battle.units[hit_id]
        if hit_unit.team == Player && hit_unit.active && hit_unit.hp > 0 {
          let hit_name = get_unit_name(battle, hit_id)
          let _ = apply_damage(battle, hit_id, 2)
          battle.turn_log.push(
            "  \{name} strikes \{hit_name} on landing for 2 damage!",
          )
        }
      }
    }
  } else {
    battle.turn_log.push("\{name} cannot leap - tile blocked")
  }
}

///|
/// AreaBlast: Deal damage in radius around target.
fn resolve_area_blast(
  battle : @types.BattleState,
  unit_id : Int,
  name : String,
  tx : Int,
  ty : Int,
  radius : Int,
) -> Unit {
  battle.turn_log.push(
    "\{name} fires area blast at (\{tx}, \{ty})!",
  )
  for dy = -radius; dy <= radius; dy = dy + 1 {
    for dx = -radius; dx <= radius; dx = dx + 1 {
      let ax = tx + dx
      let ay = ty + dy
      if battle.grid.in_bounds(ax, ay) {
        let hit_id = unit_at(battle, ax, ay)
        if hit_id >= 0 && hit_id != unit_id {
          let hit_unit = battle.units[hit_id]
          if hit_unit.active && hit_unit.hp > 0 {
            let hit_name = get_unit_name(battle, hit_id)
            let _ = apply_damage(battle, hit_id, 2)
            battle.turn_log.push(
              "  Blast hits \{hit_name} for 2 damage!",
            )
          }
        }
      }
    }
  }
}

///|
/// Summon: Shield Drone applies shield to ally at (tx, ty).
fn resolve_summon(
  battle : @types.BattleState,
  _unit_id : Int,
  name : String,
  tx : Int,
  ty : Int,
  amount : Int,
) -> Unit {
  let ally_id = unit_at(battle, tx, ty)
  if ally_id >= 0 {
    apply_shield(battle, ally_id, amount)
    let ally_name = get_unit_name(battle, ally_id)
    battle.turn_log.push(
      "\{name} grants \{amount} shield to \{ally_name}",
    )
  } else {
    battle.turn_log.push("\{name} tries to shield but no ally found")
  }
}

///|
/// MinePlace: Place a mine hazard on the target tile.
fn resolve_mine_place(
  battle : @types.BattleState,
  name : String,
  tx : Int,
  ty : Int,
) -> Unit {
  if battle.grid.in_bounds(tx, ty) {
    let tile = battle.grid.get(tx, ty)
    if tile.kind != Wall && tile.kind != Chasm {
      place_hazard(battle, tx, ty, Mine)
      battle.turn_log.push(
        "\{name} places a mine at (\{tx}, \{ty})",
      )
    } else {
      battle.turn_log.push(
        "\{name} cannot place mine at (\{tx}, \{ty})",
      )
    }
  }
}

// ============================================================================
// Upgraded enemy intents for late-game missions
// ============================================================================

///|
/// Rammer (mission 4+): "Unstoppable Charge" - charges in direction,
/// pushes through units instead of stopping on first hit.
fn generate_rammer_unstoppable_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  // Always attempt charge toward nearest player
  let dx = sign(target.x - u.x)
  let dy = sign(target.y - u.y)
  // Prefer cardinal direction with greater distance
  let adx = @types.abs_int(target.x - u.x)
  let ady = @types.abs_int(target.y - u.y)
  if adx >= ady {
    Charge(dx, 0)
  } else {
    Charge(0, dy)
  }
}

///|
/// Artillery (mission 6+): "Cluster Shot" - fires two smaller blasts.
/// Represented as AreaBlast with radius 0 at two targets.
fn generate_artillery_cluster_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  // Target the two weakest player mechs
  let target_id = find_most_damaged_unit(battle, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  // Fire area blast at the target location (slightly larger area)
  AreaBlast(target.x, target.y, 1)
}

///|
/// BeamTurret (mission 5+): "Rotating Beam" - sweeps 90 degrees.
/// Fires in two perpendicular directions.
fn generate_beam_rotating_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  // Fire a beam in the primary direction toward the player
  let dx = sign(target.x - u.x)
  let dy = sign(target.y - u.y)
  let adx = @types.abs_int(target.x - u.x)
  let ady = @types.abs_int(target.y - u.y)
  // Primary axis beam, extended range
  if adx >= ady {
    FireLine(dx, 0, @types.grid_w)
  } else {
    FireLine(0, dy, @types.grid_h)
  }
}

///|
/// Siege Engine Boss (mission 4): alternates between AoE slam and charge.
/// Phase 2 (below 50% HP): fires in a cross pattern each turn.
fn generate_siege_engine_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  let half_hp = u.max_hp / 2
  if u.hp <= half_hp {
    // Phase 2: always area blast (enraged)
    AreaBlast(target.x, target.y, 2)
  } else {
    // Phase 1: alternate charge and blast
    if battle.turn % 2 == 0 {
      AreaBlast(target.x, target.y, 1)
    } else {
      let dx = sign(target.x - u.x)
      let dy = sign(target.y - u.y)
      Charge(dx, dy)
    }
  }
}

///|
/// Hivemind Boss (mission 8): summons minions, then attacks.
/// Even turns: summon a Splitter near the boss.
/// Odd turns: area blast at weakest mech.
fn generate_hivemind_intent(
  battle : @types.BattleState,
  unit_id : Int,
) -> @types.Intent {
  let u = battle.units[unit_id]
  let target_id = find_most_damaged_unit(battle, Player)
  if target_id < 0 {
    return March(u.x, u.y)
  }
  let target = battle.units[target_id]
  if battle.turn % 3 == 0 {
    // Summon turn: spawn minion adjacent to self
    let spawn_x = u.x - 1
    let spawn_y = u.y
    Summon(spawn_x, spawn_y, 1) // 1 = Splitter spawn indicator
  } else {
    // Attack turn: blast at weakest player
    AreaBlast(target.x, target.y, 1)
  }
}
