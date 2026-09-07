// commands.mbt - Player command execution.
// Each mech class has unique attack patterns.
// Commands: Move, Attack(ability_id, tx, ty), Overclock(ability_id), Wait, Push(tx, ty, dir)

///|
/// Execute a single player command for the mech at `mech_idx` in the player roster.
pub fn execute_player_command(
  battle : @types.BattleState,
  mech_idx : Int,
  command : @types.Command,
) -> Unit {
  // Find the mech_idx-th player unit
  let unit_id = find_player_unit_id(battle, mech_idx)
  if unit_id < 0 {
    return
  }
  let u = battle.units[unit_id]
  if !u.active || u.hp <= 0 {
    return
  }
  if u.stunned {
    let name = get_unit_name(battle, unit_id)
    battle.turn_log.push("\{name} is stunned and cannot act!")
    return
  }
  match command {
    Move(tx, ty) => execute_move(battle, unit_id, tx, ty)
    Attack(ability_id, tx, ty) =>
      execute_attack(battle, unit_id, ability_id, tx, ty)
    Overclock(ability_id) => execute_overclock(battle, unit_id, ability_id)
    Wait => execute_wait(battle, unit_id)
    Push(tx, ty, dir) => execute_push_command(battle, unit_id, tx, ty, dir)
  }
}

///|
/// Find the ID of the nth player unit (0-indexed).
fn find_player_unit_id(battle : @types.BattleState, idx : Int) -> Int {
  let mut count = 0
  for i = 0; i < battle.units.length(); i = i + 1 {
    if battle.units[i].team == Player {
      if count == idx {
        return i
      }
      count += 1
    }
  }
  -1
}

///|
/// Move command: validate and move the unit to target tile.
fn execute_move(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  // Check immobilized
  if is_immobilized(u) {
    battle.turn_log.push("\{name} is immobilized and cannot move!")
    return
  }
  let stats = @content.get_augmented_mech_stats(u.mech_class, battle.augments)
  // Validate range
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > stats.move_range {
    battle.turn_log.push(
      "\{name} cannot move that far (range \{stats.move_range})",
    )
    return
  }
  // Validate target is walkable
  if !is_walkable(battle, tx, ty) {
    battle.turn_log.push("\{name} cannot move to (\{tx}, \{ty})")
    return
  }
  move_unit_to(battle, unit_id, tx, ty)
  u.moved_this_turn = true
  battle.turn_log.push("\{name} moves to (\{tx}, \{ty})")
  // Check hazard at destination
  check_hazard_on_tile(battle, unit_id, tx, ty)
}

///|
/// Attack command: dispatch to the correct ability based on mech class.
fn execute_attack(
  battle : @types.BattleState,
  unit_id : Int,
  ability_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  // Terrain manipulation abilities (shared across classes)
  if ability_id == 6 {
    ability_barricade(battle, unit_id, tx, ty)
    u.acted_this_turn = true
    return
  }
  if ability_id == 7 {
    ability_detonate(battle, unit_id, tx, ty)
    u.acted_this_turn = true
    return
  }
  if ability_id == 8 {
    ability_deploy_mine(battle, unit_id, tx, ty)
    u.acted_this_turn = true
    return
  }
  // Upgrade special abilities
  if ability_id == 10 {
    // Vanguard Fortress Mode (tier 2): skip move, gain 3 shield
    ability_fortress_mode(battle, unit_id)
    u.acted_this_turn = true
    return
  }
  if ability_id == 11 {
    // Vanguard Gravity Well (tier 3): pull all adjacent enemies
    ability_gravity_well(battle, unit_id)
    u.acted_this_turn = true
    return
  }
  if ability_id == 12 {
    // Sentinel Orbital Strike (tier 3)
    ability_orbital_strike(battle, unit_id, tx, ty)
    u.acted_this_turn = true
    return
  }
  match u.mech_class {
    Vanguard =>
      if ability_id == 0 {
        attack_vanguard_ram(battle, unit_id, tx, ty)
      } else {
        attack_vanguard_tractor(battle, unit_id, tx, ty)
      }
    Striker =>
      if ability_id == 0 {
        attack_striker_blade(battle, unit_id, tx, ty)
      } else {
        attack_striker_dash(battle, unit_id, tx, ty)
      }
    Sentinel =>
      if ability_id == 0 {
        attack_sentinel_cannon(battle, unit_id, tx, ty)
      } else {
        attack_sentinel_artillery(battle, unit_id, tx, ty)
      }
  }
  u.acted_this_turn = true
}

///|
/// Vanguard ability 0: Ram - move 1 tile toward target, push target 2 tiles, deal 2 damage.
fn attack_vanguard_ram(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  // Find target at (tx, ty)
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    battle.turn_log.push("\{name} rams at empty space!")
    return
  }
  let target = battle.units[target_id]
  // Validate range (ability range 3, +1 with ExtendedBarrel)
  let range_bonus = if @types.battle_has_augment(battle, ExtendedBarrel) {
    1
  } else {
    0
  }
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 3 + range_bonus {
    battle.turn_log.push("\{name} target out of range for Ram!")
    return
  }
  // Move 1 tile toward target
  let (sdx, sdy) = step_toward(u.x, u.y, target.x, target.y)
  let step_x = u.x + sdx
  let step_y = u.y + sdy
  if is_walkable(battle, step_x, step_y) {
    move_unit_to(battle, unit_id, step_x, step_y)
  }
  // Compute push direction from mech to target
  let pdx = sign(target.x - u.x)
  let pdy = sign(target.y - u.y)
  // Deal 2 damage
  let _ = apply_damage_from(battle, target_id, 2, unit_id)
  let target_name = get_unit_name(battle, target_id)
  battle.turn_log.push("\{name} rams \{target_name} for 2 damage!")
  // ChainLightning augment
  if @types.battle_has_augment(battle, ChainLightning) {
    apply_chain_lightning(battle, target_id, unit_id)
  }
  // Push target: base 2 tiles, +1 with Vanguard tier >= 1
  let push_dist = 2 + (if u.upgrade_tier >= 1 { 1 } else { 0 })
  if target.active && target.hp > 0 {
    try_push(battle, target_id, pdx, pdy, push_dist)
    battle.turn_log.push("\{name} pushes \{target_name} \{push_dist} tiles!")
  }
}

///|
/// Vanguard ability 1: Tractor Beam - pull target 2 tiles toward self.
fn attack_vanguard_tractor(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    battle.turn_log.push("\{name} tractor beam hits nothing!")
    return
  }
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 4 {
    battle.turn_log.push("\{name} target out of range for Tractor Beam!")
    return
  }
  let target_name = get_unit_name(battle, target_id)
  battle.turn_log.push("\{name} pulls \{target_name} with Tractor Beam!")
  try_pull(battle, target_id, u.x, u.y, 2)
}

///|
/// Striker ability 0: Blade - 4 damage to adjacent target.
/// Tier 3 Execute: double damage to targets below 25% HP.
fn attack_striker_blade(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    battle.turn_log.push("\{name} blade strikes empty air!")
    return
  }
  // Must be adjacent
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 1 {
    battle.turn_log.push("\{name} target not adjacent for Blade!")
    return
  }
  let target = battle.units[target_id]
  let target_name = get_unit_name(battle, target_id)
  // Striker T1: +1 damage
  let mut dmg = 4 + (if u.upgrade_tier >= 1 { 1 } else { 0 })
  // Execute upgrade (tier 3): double damage to targets below 25% HP
  if u.upgrade_tier >= 3 && target.hp > 0 {
    let threshold = if target.max_hp / 4 > 0 { target.max_hp / 4 } else { 1 }
    if target.hp <= threshold {
      dmg = dmg * 2
      battle.turn_log.push("EXECUTE! Double damage!")
    }
  }
  let _ = apply_damage_from(battle, target_id, dmg, unit_id)
  battle.turn_log.push("\{name} slashes \{target_name} for \{dmg} damage!")
  // ChainLightning augment
  if @types.battle_has_augment(battle, ChainLightning) {
    apply_chain_lightning(battle, target_id, unit_id)
  }
}

///|
/// Striker ability 1: Dash Strike - move up to 3 tiles, deal 3 damage at destination.
/// Tier 2 Phase Dash: dash passes through enemies, dealing damage to each.
fn attack_striker_dash(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  // Target is where we want to dash to; enemy should be adjacent to destination
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 3 {
    battle.turn_log.push("\{name} dash target too far!")
    return
  }
  // Striker T1: +1 damage
  let dash_dmg = 3 + (if u.upgrade_tier >= 1 { 1 } else { 0 })
  let phase_dash = u.upgrade_tier >= 2
  if phase_dash {
    // Phase Dash: pass through all enemies along the path, damaging each
    let (sdx, sdy) = step_toward(u.x, u.y, tx, ty)
    let mut cx = u.x + sdx
    let mut cy = u.y + sdy
    let mut steps = 0
    battle.turn_log.push("\{name} Phase Dashes!")
    while steps < dist {
      if !battle.grid.in_bounds(cx, cy) {
        break
      }
      let tile = battle.grid.get(cx, cy)
      if tile.kind == Wall {
        break
      }
      // Hit enemy in path: deal damage but keep moving
      let hit_id = unit_at(battle, cx, cy)
      if hit_id >= 0 && hit_id != unit_id {
        let hit_unit = battle.units[hit_id]
        if hit_unit.team == Enemy && hit_unit.active && hit_unit.hp > 0 {
          let hit_name = get_unit_name(battle, hit_id)
          let _ = apply_damage(battle, hit_id, dash_dmg)
          battle.turn_log.push(
            "  \{name} phases through \{hit_name} for \{dash_dmg} damage!",
          )
        }
      } else if is_walkable(battle, cx, cy) {
        // Move to empty tile (keep going)
        move_unit_to(battle, unit_id, cx, cy)
      }
      cx += sdx
      cy += sdy
      steps += 1
    }
    // Final position: move to last valid empty tile near target
    if is_walkable(battle, tx, ty) {
      move_unit_to(battle, unit_id, tx, ty)
    }
  } else {
    // Normal Dash Strike
    // Check if there's a unit at the target (we strike them)
    let target_id = unit_at(battle, tx, ty)
    if target_id >= 0 {
      // Can't move onto occupied tile; move to tile just before the target
      let (sdx, sdy) = step_toward(u.x, u.y, tx, ty)
      let stop_x = tx - sdx
      let stop_y = ty - sdy
      if (stop_x != u.x || stop_y != u.y) && is_walkable(battle, stop_x, stop_y) {
        move_unit_to(battle, unit_id, stop_x, stop_y)
      }
      let target_name = get_unit_name(battle, target_id)
      let _ = apply_damage(battle, target_id, dash_dmg)
      battle.turn_log.push(
        "\{name} dash-strikes \{target_name} for \{dash_dmg} damage!",
      )
    } else if is_walkable(battle, tx, ty) {
      // Just dash to the empty tile
      move_unit_to(battle, unit_id, tx, ty)
      battle.turn_log.push("\{name} dashes to (\{tx}, \{ty})")
      // Check for adjacent enemies to hit at destination
      let adj_target = find_adjacent_enemy(battle, unit_id, tx, ty)
      if adj_target >= 0 {
        let adj_name = get_unit_name(battle, adj_target)
        let _ = apply_damage(battle, adj_target, dash_dmg)
        battle.turn_log.push(
          "\{name} strikes \{adj_name} for \{dash_dmg} damage!",
        )
      }
    } else {
      battle.turn_log.push("\{name} cannot dash there!")
    }
  }
}

///|
/// Sentinel ability 0: Cannon - 3 damage at range 4, requires line of sight.
fn attack_sentinel_cannon(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    battle.turn_log.push("\{name} cannon fires at nothing!")
    return
  }
  let range_bonus = if @types.battle_has_augment(battle, ExtendedBarrel) {
    1
  } else {
    0
  }
  // Sentinel T1: +1 range
  let tier_range = if u.upgrade_tier >= 1 { 1 } else { 0 }
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 4 + range_bonus + tier_range {
    battle.turn_log.push("\{name} target out of cannon range!")
    return
  }
  if !has_line_of_sight(battle, u.x, u.y, tx, ty) {
    battle.turn_log.push("\{name} no line of sight for cannon!")
    return
  }
  let target_name = get_unit_name(battle, target_id)
  let _ = apply_damage_from(battle, target_id, 3, unit_id)
  battle.turn_log.push("\{name} fires cannon at \{target_name} for 3 damage!")
  // ChainLightning augment
  if @types.battle_has_augment(battle, ChainLightning) {
    apply_chain_lightning(battle, target_id, unit_id)
  }
}

///|
/// Sentinel ability 1: Artillery - 2 damage in 3x3 area, ignores LOS.
fn attack_sentinel_artillery(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let name = get_unit_name(battle, unit_id)
  let u = battle.units[unit_id]
  let range_bonus = if @types.battle_has_augment(battle, ExtendedBarrel) {
    1
  } else {
    0
  }
  // Sentinel T1: +1 range
  let tier_range = if u.upgrade_tier >= 1 { 1 } else { 0 }
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 5 + range_bonus + tier_range {
    battle.turn_log.push("\{name} target out of artillery range!")
    return
  }
  battle.turn_log.push("\{name} fires artillery at (\{tx}, \{ty})!")
  // 3x3 area centered on target (Sentinel T1 also gives +1 radius)
  let art_radius = 1 + (if u.upgrade_tier >= 1 { 1 } else { 0 })
  for dy = -art_radius; dy <= art_radius; dy = dy + 1 {
    for dx = -art_radius; dx <= art_radius; dx = dx + 1 {
      let ax = tx + dx
      let ay = ty + dy
      if battle.grid.in_bounds(ax, ay) {
        let hit_id = unit_at(battle, ax, ay)
        if hit_id >= 0 && hit_id != unit_id {
          let hit_name = get_unit_name(battle, hit_id)
          let _ = apply_damage_from(battle, hit_id, 2, unit_id)
          battle.turn_log.push("  Artillery hits \{hit_name} for 2 damage!")
        }
      }
    }
  }
}

///|
/// Overclock: repeat the previous ability at heat cost.
fn execute_overclock(
  battle : @types.BattleState,
  unit_id : Int,
  ability_id : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let heat_cost = @types.overclock_heat_cost
  if u.heat + heat_cost > u.max_heat {
    battle.turn_log.push("\{name} too much heat to overclock!")
    return
  }
  apply_heat(battle, unit_id, heat_cost)
  battle.turn_log.push(
    "\{name} overclocks! (+\{heat_cost} heat, now \{u.heat})",
  )
  // Overclock FX: hitstop + blue flash + ring + tint + text
  @types.emit_hitstop(battle, 0.1)
  @types.emit_flash(battle, 80, 140, 255, 100)
  @types.emit_tint(battle, 40, 80, 200, 40, 0.4)
  @types.emit_ring(battle, u.x, u.y, 50.0, 0.5, 80, 180, 255)
  @types.emit_float_text(
    battle,
    u.x,
    u.y,
    "OVERCLOCK!",
    80,
    180,
    255,
    1.5,
    true,
  )
  // Re-execute the ability targeting the nearest enemy
  let target_id = find_nearest_unit(battle, u.x, u.y, Enemy)
  if target_id >= 0 {
    let target = battle.units[target_id]
    execute_attack(battle, unit_id, ability_id, target.x, target.y)
  } else {
    battle.turn_log.push("\{name} overclocks but no target!")
  }
}

///|
/// Wait: do nothing, cool down heat by 1.
fn execute_wait(battle : @types.BattleState, unit_id : Int) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  if u.heat > 0 {
    u.heat -= 1
    battle.turn_log.push("\{name} waits. Heat cools to \{u.heat}.")
  } else {
    battle.turn_log.push("\{name} waits.")
  }
}

///|
/// Push command: push an adjacent unit in a direction.
fn execute_push_command(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
  dir : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  // Must be adjacent to target
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 1 {
    battle.turn_log.push("\{name} cannot push - target not adjacent!")
    return
  }
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    battle.turn_log.push("\{name} pushes at nothing!")
    return
  }
  let target_name = get_unit_name(battle, target_id)
  // Decode direction from int (0=N, 1=S, 2=E, 3=W)
  let (dx, dy) = decode_direction(dir)
  battle.turn_log.push("\{name} pushes \{target_name}!")
  try_push(battle, target_id, dx, dy, 2)
}

///|
/// Decode an integer direction to (dx, dy).
fn decode_direction(dir : Int) -> (Int, Int) {
  match dir {
    0 => (0, -1) // North
    1 => (0, 1) // South
    2 => (1, 0) // East
    _ => (-1, 0) // West
  }
}

///|
/// Find an adjacent enemy to a position (for dash strike).
fn find_adjacent_enemy(
  battle : @types.BattleState,
  self_id : Int,
  x : Int,
  y : Int,
) -> Int {
  let dx_arr = [0, 0, 1, -1]
  let dy_arr = [-1, 1, 0, 0]
  for d = 0; d < 4; d = d + 1 {
    let nx = x + dx_arr[d]
    let ny = y + dy_arr[d]
    let uid = unit_at(battle, nx, ny)
    if uid >= 0 && uid != self_id {
      let other = battle.units[uid]
      if other.team != battle.units[self_id].team &&
        other.active &&
        other.hp > 0 {
        return uid
      }
    }
  }
  -1
}

///|
/// Check if a unit stepped onto a hazard tile and apply its effect.
fn check_hazard_on_tile(
  battle : @types.BattleState,
  unit_id : Int,
  x : Int,
  y : Int,
) -> Unit {
  if !battle.grid.in_bounds(x, y) {
    return
  }
  let tile = battle.grid.get(x, y)
  let name = get_unit_name(battle, unit_id)
  match tile.hazard {
    Fire => {
      let _ = apply_damage(battle, unit_id, 1)
      battle.turn_log.push("\{name} takes 1 fire damage!")
    }
    Acid => {
      let _ = apply_damage(battle, unit_id, 2)
      battle.turn_log.push("\{name} takes 2 acid damage!")
    }
    Mine => {
      let _ = apply_damage(battle, unit_id, 3)
      battle.turn_log.push("\{name} triggers a mine for 3 damage!")
      // Mine is consumed
      battle.grid.set(x, y, { ..tile, hazard: None, })
    }
    Smoke => battle.turn_log.push("\{name} enters smoke.")
    None => ()
  }
}

// ============================================================================
// Terrain manipulation abilities
// ============================================================================

///|
/// Vanguard ability 6: Barricade - place a wall tile adjacent to self.
fn ability_barricade(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist != 1 {
    battle.turn_log.push("\{name} must place barricade on adjacent tile!")
    return
  }
  if !battle.grid.in_bounds(tx, ty) {
    battle.turn_log.push("\{name} cannot place barricade there!")
    return
  }
  let tile = battle.grid.get(tx, ty)
  if tile.kind != Floor || tile.occupied_by >= 0 {
    battle.turn_log.push("\{name} can only place barricade on empty floor!")
    return
  }
  battle.grid.set(tx, ty, { kind: Wall, hazard: None, occupied_by: -1, })
  battle.turn_log.push("\{name} places a barricade at (\{tx}, \{ty})!")
}

///|
/// Striker ability 7: Detonate - destroy a wall tile, dealing 2 damage to adjacent units.
fn ability_detonate(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 3 {
    battle.turn_log.push("\{name} target too far for Detonate!")
    return
  }
  if !battle.grid.in_bounds(tx, ty) {
    return
  }
  let tile = battle.grid.get(tx, ty)
  if tile.kind != Wall {
    battle.turn_log.push("\{name} can only detonate walls!")
    return
  }
  // Destroy the wall
  battle.grid.set(tx, ty, { kind: Floor, hazard: None, occupied_by: -1, })
  battle.turn_log.push("\{name} detonates the wall at (\{tx}, \{ty})!")
  // Deal 2 damage to all adjacent units
  let dx_arr = [0, 0, 1, -1]
  let dy_arr = [-1, 1, 0, 0]
  let mut hit_count = 0
  for d = 0; d < 4; d = d + 1 {
    let ax = tx + dx_arr[d]
    let ay = ty + dy_arr[d]
    let hit_id = unit_at(battle, ax, ay)
    if hit_id >= 0 && hit_id != unit_id {
      let hit_name = get_unit_name(battle, hit_id)
      let _ = apply_damage_from(battle, hit_id, 2, unit_id)
      battle.turn_log.push("  Detonation hits \{hit_name} for 2 damage!")
      hit_count += 1
    }
  }
  // Collateral combo: hitting 2+ enemies with detonation
  if hit_count >= 2 {
    add_combo_score(battle, 150, "COLLATERAL!")
  }
}

///|
/// Sentinel ability 8: Deploy Mine - place mine hazard on empty floor tile.
fn ability_deploy_mine(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 4 {
    battle.turn_log.push("\{name} target too far for Deploy Mine!")
    return
  }
  if !battle.grid.in_bounds(tx, ty) {
    return
  }
  let tile = battle.grid.get(tx, ty)
  if tile.kind == Wall || tile.kind == Chasm {
    battle.turn_log.push("\{name} cannot place mine there!")
    return
  }
  if tile.hazard != None {
    battle.turn_log.push("\{name} tile already has a hazard!")
    return
  }
  place_hazard(battle, tx, ty, Mine)
  battle.turn_log.push("\{name} deploys a mine at (\{tx}, \{ty})!")
}

// ============================================================================
// Upgrade special abilities
// ============================================================================

///|
/// Vanguard Tier 2: Fortress Mode - skip move, gain 3 shield.
fn ability_fortress_mode(battle : @types.BattleState, unit_id : Int) -> Unit {
  let name = get_unit_name(battle, unit_id)
  apply_shield(battle, unit_id, 3)
  battle.turn_log.push("\{name} enters Fortress Mode! +3 Shield!")
}

///|
/// Vanguard Tier 3: Gravity Well - pull ALL adjacent enemies 1 tile toward self.
fn ability_gravity_well(battle : @types.BattleState, unit_id : Int) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  battle.turn_log.push("\{name} activates Gravity Well!")
  // Check all tiles within range 2
  for i = 0; i < battle.units.length(); i = i + 1 {
    let other = battle.units[i]
    if other.active && other.hp > 0 && other.team == Enemy {
      let dist = @types.manhattan(u.x, u.y, other.x, other.y)
      if dist <= 2 && dist > 0 {
        let other_name = get_unit_name(battle, i)
        battle.turn_log.push("  \{other_name} is pulled toward Vanguard!")
        try_pull(battle, i, u.x, u.y, 1)
      }
    }
  }
}

///|
/// Sentinel Tier 3: Orbital Strike - once per mission, deal 5 damage in 5x5 area.
fn ability_orbital_strike(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  if u.orbital_used {
    battle.turn_log.push("\{name} already used Orbital Strike this mission!")
    return
  }
  u.orbital_used = true
  battle.turn_log.push("\{name} calls Orbital Strike on (\{tx}, \{ty})!")
  // 5x5 area centered on target
  let mut hit_count = 0
  for dy = -2; dy <= 2; dy = dy + 1 {
    for dx = -2; dx <= 2; dx = dx + 1 {
      let ax = tx + dx
      let ay = ty + dy
      if battle.grid.in_bounds(ax, ay) {
        let hit_id = unit_at(battle, ax, ay)
        if hit_id >= 0 && hit_id != unit_id {
          let hit_name = get_unit_name(battle, hit_id)
          let _ = apply_damage_from(battle, hit_id, 5, unit_id)
          battle.turn_log.push(
            "  Orbital Strike hits \{hit_name} for 5 damage!",
          )
          hit_count += 1
        }
      }
    }
  }
  if hit_count >= 2 {
    add_combo_score(battle, 150, "COLLATERAL!")
  }
}
