// boss.mbt - Boss set-piece logic: phase transitions, arena changes, and per-turn effects.
// Siege Engine (mission 4) and Hivemind (mission 8) have 3-phase scripted encounters.

///|
/// Check if a boss phase transition should occur based on HP thresholds.
/// Called at the start of each turn before enemy intents resolve.
pub fn check_boss_phase_transition(battle : @types.BattleState) -> Unit {
  if !@content.is_boss_mission(battle.mission_id) {
    return
  }
  let boss_id = find_boss_unit(battle)
  if boss_id < 0 {
    return
  }
  let boss = battle.units[boss_id]
  let hp_pct = boss.hp * 100 / boss.max_hp
  let old_phase = battle.boss_phase
  let new_phase = if battle.mission_id == 4 {
    // Siege Engine thresholds: 60%, 30%
    if hp_pct <= 30 {
      3
    } else if hp_pct <= 60 {
      2
    } else {
      1
    }
    // Hivemind thresholds: 50%, 25%
  } else if hp_pct <= 25 {
    3
  } else if hp_pct <= 50 {
    2
  } else {
    1
  }
  if new_phase != old_phase && new_phase > old_phase {
    battle.boss_phase = new_phase
    apply_phase_transition(battle, boss_id, new_phase)
  }
}

///|
/// Apply visual and mechanical effects when a boss changes phase.
fn apply_phase_transition(
  battle : @types.BattleState,
  boss_id : Int,
  new_phase : Int,
) -> Unit {
  // Screen effects: large shake + white flash + hitstop + ring
  @types.emit_shake(battle, 12.0)
  @types.emit_flash(battle, 255, 255, 255, 200)
  @types.emit_hitstop(battle, 0.15)
  let boss = battle.units[boss_id]
  @types.emit_ring(battle, boss.x, boss.y, 80.0, 0.8, 255, 80, 40)
  @types.emit_float_text(
    battle,
    boss.x,
    boss.y,
    "PHASE \{new_phase}!",
    255,
    200,
    40,
    1.5,
    true,
  )
  // Set narrative text
  if battle.mission_id == 4 {
    apply_siege_engine_transition(battle, boss_id, new_phase)
  } else if battle.mission_id == 8 {
    apply_hivemind_transition(battle, boss_id, new_phase)
  }
}

///|
/// Siege Engine phase transition effects.
fn apply_siege_engine_transition(
  battle : @types.BattleState,
  boss_id : Int,
  new_phase : Int,
) -> Unit {
  match new_phase {
    2 => {
      // "Fortify Mode": boss stops moving, gains 3 shield, deploys walls
      battle.boss_narrative_text = "SIEGE ENGINE ENTERING DEFENSE MODE"
      battle.boss_narrative_timer = 2.0
      battle.turn_log.push("!! SIEGE ENGINE ENTERING DEFENSE MODE !!")
      apply_shield(battle, boss_id, 3)
      // Deploy 2 initial wall tiles near the boss
      let boss = battle.units[boss_id]
      deploy_wall(battle, boss.x - 1, boss.y - 1)
      deploy_wall(battle, boss.x - 1, boss.y + 1)
    }
    3 => {
      // "Overload": all deployed walls explode (2 damage to adjacent units)
      battle.boss_narrative_text = "CRITICAL OVERLOAD - ALL SYSTEMS UNSTABLE"
      battle.boss_narrative_timer = 2.0
      battle.turn_log.push("!! CRITICAL OVERLOAD - ALL SYSTEMS UNSTABLE !!")
      explode_deployed_walls(battle)
      // Spawn initial lava hazards
      let boss = battle.units[boss_id]
      spawn_lava_hazard(battle, boss.x - 2, boss.y)
      spawn_lava_hazard(battle, boss.x, boss.y - 2)
      spawn_lava_hazard(battle, boss.x, boss.y + 2)
    }
    _ => ()
  }
}

///|
/// Hivemind phase transition effects.
fn apply_hivemind_transition(
  battle : @types.BattleState,
  boss_id : Int,
  new_phase : Int,
) -> Unit {
  match new_phase {
    2 => {
      // "Direct Control": stun all surviving minions for 1 turn
      battle.boss_narrative_text = "HIVEMIND SEVERING MINION LINKS - DIRECT ASSAULT"
      battle.boss_narrative_timer = 2.0
      battle.turn_log.push(
        "!! HIVEMIND SEVERING MINION LINKS - DIRECT ASSAULT !!",
      )
      // Stun all enemy minions
      for i = 0; i < battle.units.length(); i = i + 1 {
        let u = battle.units[i]
        if u.active && u.hp > 0 && u.team == Enemy && u.enemy_type != Boss {
          u.stunned = true
          let name = get_unit_name(battle, i)
          battle.turn_log.push("  \{name} is stunned by link severance!")
        }
      }
      // Spawn acid around Hivemind
      let boss = battle.units[boss_id]
      place_hazard(battle, boss.x - 1, boss.y, Acid)
      place_hazard(battle, boss.x + 1, boss.y, Acid)
      place_hazard(battle, boss.x, boss.y - 1, Acid)
      place_hazard(battle, boss.x, boss.y + 1, Acid)
    }
    3 => {
      // "Last Stand": absorb all remaining minions
      battle.boss_narrative_text = "EMERGENCY PROTOCOL - TOTAL ANNIHILATION SEQUENCE"
      battle.boss_narrative_timer = 2.0
      battle.turn_log.push(
        "!! EMERGENCY PROTOCOL - TOTAL ANNIHILATION SEQUENCE !!",
      )
      absorb_minions(battle, boss_id)
    }
    _ => ()
  }
}

///|
/// Find the boss unit in the battle. Returns -1 if not found.
fn find_boss_unit(battle : @types.BattleState) -> Int {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == Enemy && u.enemy_type == Boss {
      return i
    }
  }
  -1
}

///|
/// Deploy a wall tile at the given position, tracking it for later explosion.
fn deploy_wall(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  if battle.grid.in_bounds(x, y) {
    let tile = battle.grid.get(x, y)
    if tile.kind == Floor && tile.occupied_by < 0 {
      battle.grid.set(x, y, { kind: Wall, hazard: None, occupied_by: -1 })
      battle.boss_walls_deployed.push((x, y))
      battle.turn_log.push("  Wall deployed at (\{x}, \{y})")
    }
  }
}

///|
/// Explode all walls deployed by the boss, dealing 2 damage to adjacent units.
fn explode_deployed_walls(battle : @types.BattleState) -> Unit {
  let walls = battle.boss_walls_deployed
  for w = 0; w < walls.length(); w = w + 1 {
    let (wx, wy) = walls[w]
    if battle.grid.in_bounds(wx, wy) {
      // Destroy the wall
      battle.grid.set(wx, wy, { kind: Floor, hazard: Fire, occupied_by: -1 })
      battle.turn_log.push("  Wall at (\{wx}, \{wy}) EXPLODES!")
      // Damage adjacent units
      let dx_arr = [0, 0, 1, -1]
      let dy_arr = [-1, 1, 0, 0]
      for d = 0; d < 4; d = d + 1 {
        let ax = wx + dx_arr[d]
        let ay = wy + dy_arr[d]
        let hit_id = unit_at(battle, ax, ay)
        if hit_id >= 0 {
          let hit = battle.units[hit_id]
          if hit.active && hit.hp > 0 {
            let name = get_unit_name(battle, hit_id)
            let _ = apply_damage(battle, hit_id, 2)
            battle.turn_log.push(
              "  \{name} takes 2 explosion damage from wall!",
            )
          }
        }
      }
    }
  }
  battle.boss_walls_deployed = []
}

///|
/// Spawn a lava tile at the given position.
fn spawn_lava_hazard(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  if battle.grid.in_bounds(x, y) {
    let tile = battle.grid.get(x, y)
    if tile.kind != Wall && tile.kind != Chasm {
      battle.grid.set(x, y, {
        kind: Lava,
        hazard: Fire,
        occupied_by: tile.occupied_by,
      })
      battle.turn_log.push("  Lava erupts at (\{x}, \{y})!")
    }
  }
}

///|
/// Hivemind absorbs all remaining minions: gains their HP, kills them.
fn absorb_minions(battle : @types.BattleState, boss_id : Int) -> Unit {
  let boss = battle.units[boss_id]
  let mut absorbed_hp = 0
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == Enemy && i != boss_id {
      let name = get_unit_name(battle, i)
      absorbed_hp += u.hp
      battle.turn_log.push("  Hivemind absorbs \{name} (+\{u.hp} HP)")
      kill_unit(battle, i)
    }
  }
  if absorbed_hp > 0 {
    boss.hp += absorbed_hp
    if boss.hp > boss.max_hp {
      boss.max_hp = boss.hp
    }
    battle.turn_log.push("  Hivemind absorbed \{absorbed_hp} total HP!")
  }
}

///|
/// Resolve boss-specific per-turn effects after intents resolve.
/// Handles reinforcement spawning, wall deployment, hazard spreading, etc.
pub fn resolve_boss_turn_effects(battle : @types.BattleState) -> Unit {
  if !@content.is_boss_mission(battle.mission_id) {
    return
  }
  let boss_id = find_boss_unit(battle)
  if boss_id < 0 {
    return
  }
  if battle.mission_id == 4 {
    resolve_siege_turn_effects(battle, boss_id)
  } else if battle.mission_id == 8 {
    resolve_hivemind_turn_effects(battle, boss_id)
  }
}

///|
/// Siege Engine per-turn effects based on phase.
fn resolve_siege_turn_effects(
  battle : @types.BattleState,
  boss_id : Int,
) -> Unit {
  let boss = battle.units[boss_id]
  match battle.boss_phase {
    1 =>
      // Phase 1: summon Rammer every 3 turns
      if battle.turn % 3 == 0 {
        spawn_boss_minion(battle, boss.x - 1, boss.y + 1, Rammer)
      }
    2 => {
      // Phase 2: deploy 2 wall tiles per turn, fire beam (handled by intent)
      let wall_x1 = boss.x - 1
      let wall_y1 = boss.y + battle.turn % 3 - 1
      let wall_x2 = boss.x + 1
      let wall_y2 = boss.y - battle.turn % 3 + 1
      deploy_wall(battle, wall_x1, wall_y1)
      deploy_wall(battle, wall_x2, wall_y2)
      // Regenerate 1 shield per turn in fortify mode
      apply_shield(battle, boss_id, 1)
    }
    3 => {
      // Phase 3: spawn lava on pseudo-random tiles
      let lx = (battle.turn * 5 + 2) % @types.grid_w
      let ly = (battle.turn * 3 + 1) % @types.grid_h
      spawn_lava_hazard(battle, lx, ly)
      // Fire in all 4 cardinal directions (extra beams beyond the intent)
      resolve_cardinal_fire(battle, boss_id, 2)
    }
    _ => ()
  }
}

///|
/// Hivemind per-turn effects based on phase.
fn resolve_hivemind_turn_effects(
  battle : @types.BattleState,
  boss_id : Int,
) -> Unit {
  let boss = battle.units[boss_id]
  match battle.boss_phase {
    1 =>
      // Phase 1: summon minions. Alternate Rammer and Splitter.
      if battle.turn % 2 == 0 {
        spawn_boss_minion(battle, boss.x - 1, boss.y - 1, Rammer)
        spawn_boss_minion(battle, boss.x - 1, boss.y + 1, Splitter)
      }
    2 => {
      // Phase 2: spread acid from Hivemind's position each turn
      let dx_arr = [1, -1, 0, 0]
      let dy_arr = [0, 0, 1, -1]
      let dir = battle.turn % 4
      let ax = boss.x + dx_arr[dir]
      let ay = boss.y + dy_arr[dir]
      if battle.grid.in_bounds(ax, ay) {
        place_hazard(battle, ax, ay, Acid)
        battle.turn_log.push("  Acid spreads to (\{ax}, \{ay})")
      }
    }
    3 => {
      // Phase 3: spawn mines on pseudo-random tiles
      let mx1 = (battle.turn * 7 + 3) % @types.grid_w
      let my1 = (battle.turn * 11 + 1) % @types.grid_h
      let mx2 = (battle.turn * 13 + 5) % @types.grid_w
      let my2 = (battle.turn * 3 + 7) % @types.grid_h
      if battle.grid.in_bounds(mx1, my1) {
        let t1 = battle.grid.get(mx1, my1)
        if t1.kind == Floor && t1.hazard == None {
          place_hazard(battle, mx1, my1, Mine)
          battle.turn_log.push("  Mine spawns at (\{mx1}, \{my1})")
        }
      }
      if battle.grid.in_bounds(mx2, my2) {
        let t2 = battle.grid.get(mx2, my2)
        if t2.kind == Floor && t2.hazard == None {
          place_hazard(battle, mx2, my2, Mine)
          battle.turn_log.push("  Mine spawns at (\{mx2}, \{my2})")
        }
      }
    }
    _ => ()
  }
}

///|
/// Fire beams in all 4 cardinal directions from a unit, dealing damage.
fn resolve_cardinal_fire(
  battle : @types.BattleState,
  unit_id : Int,
  damage : Int,
) -> Unit {
  let u = battle.units[unit_id]
  let name = get_unit_name(battle, unit_id)
  let dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)]
  for d = 0; d < dirs.length(); d = d + 1 {
    let (dx, dy) = dirs[d]
    let mut cx = u.x + dx
    let mut cy = u.y + dy
    let mut steps = 0
    while steps < @types.grid_w && battle.grid.in_bounds(cx, cy) {
      let tile = battle.grid.get(cx, cy)
      if tile.kind == Wall {
        break
      }
      if tile.occupied_by >= 0 {
        let hit_id = tile.occupied_by
        let hit = battle.units[hit_id]
        if hit.active && hit.hp > 0 && hit.team == Player {
          let hit_name = get_unit_name(battle, hit_id)
          let _ = apply_damage(battle, hit_id, damage)
          battle.turn_log.push(
            "  \{name} overload beam hits \{hit_name} for \{damage} damage!",
          )
        }
      }
      cx += dx
      cy += dy
      steps += 1
    }
  }
}

///|
/// Spawn a minion enemy unit adjacent to the boss.
fn spawn_boss_minion(
  battle : @types.BattleState,
  x : Int,
  y : Int,
  etype : @types.EnemyType,
) -> Unit {
  // Find a free tile near the requested position
  let mut sx = x
  let mut sy = y
  if !is_walkable(battle, sx, sy) {
    let dx_arr = [0, 1, -1, 0, 0, 1, -1, 1, -1]
    let dy_arr = [0, 0, 0, 1, -1, 1, -1, -1, 1]
    let mut found = false
    for d = 0; d < 9; d = d + 1 {
      let nx = x + dx_arr[d]
      let ny = y + dy_arr[d]
      if is_walkable(battle, nx, ny) {
        sx = nx
        sy = ny
        found = true
        break
      }
    }
    if !found {
      return // No free tile available
    }
  }
  let eid = battle.units.length()
  let ehp = @content.get_enemy_hp(etype)
  let eu : @types.CombatUnit = {
    id: eid,
    active: true,
    team: Enemy,
    x: sx,
    y: sy,
    hp: ehp,
    max_hp: ehp,
    shield: 0,
    heat: 0,
    max_heat: 0,
    stunned: false,
    moved_this_turn: false,
    acted_this_turn: false,
    mech_class: Vanguard,
    enemy_type: etype,
    intent: March(sx, sy),
    statuses: [],
    upgrade_tier: 0,
    orbital_used: false,
  }
  battle.units.push(eu)
  if battle.grid.in_bounds(sx, sy) {
    battle.grid.set(sx, sy, { ..battle.grid.get(sx, sy), occupied_by: eu.id })
  }
  let etype_name = @content.get_enemy_name(etype)
  battle.turn_log.push("  Boss summons \{etype_name} at (\{sx}, \{sy})!")
}

///|
/// Check if the Hivemind has living minions (used for damage halving in phase 1).
pub fn hivemind_has_minions(battle : @types.BattleState) -> Bool {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == Enemy && u.enemy_type != Boss {
      return true
    }
  }
  false
}
