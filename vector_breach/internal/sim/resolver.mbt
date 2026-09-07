// resolver.mbt - Deterministic turn resolver.
// This is the core of Vector Breach. Every mechanic flows through here.
//
// Turn resolution order:
//   1. Player commands resolve (move, attack, overclock, push)
//   2. Enemy intents resolve (AI actions)
//   3. Hazard damage applied
//   4. Status cleanup (stun expires, heat cools)
//   5. Victory/defeat conditions checked

///|
/// Main entry point: simulate a full turn given the current battle state
/// and the player's commands. Returns a log of everything that happened.
pub fn simulate_turn(
  state : @types.BattleState,
  commands : Array[@types.Command],
) -> Array[String] {
  state.turn_log = []
  state.turn_log.push("=== Turn \{state.turn} ===")

  // Track damage for "no damage" combo
  state.damage_taken_this_turn = false

  // Phase 1: Execute player commands
  state.turn_log.push("-- Player Phase --")
  for i = 0; i < commands.length(); i = i + 1 {
    execute_player_command(state, i, commands[i])
  }

  // Phase 1.5: Check boss phase transitions before enemy acts
  check_boss_phase_transition(state)

  // Phase 2: Resolve enemy intents
  state.turn_log.push("-- Enemy Phase --")
  resolve_all_enemy_intents(state)

  // Phase 2.25: Boss per-turn effects (reinforcements, hazards, wall deploys)
  resolve_boss_turn_effects(state)

  // Phase 2.5: Sentinel Overwatch (tier >= 2)
  resolve_overwatch(state)

  // Phase 3: Apply hazard damage to all units
  state.turn_log.push("-- Hazard Phase --")
  apply_hazard_damage(state)

  // Phase 4: End-of-turn cleanup
  cleanup_turn(state)

  // Phase 4.5: No Damage Turn combo
  if !state.damage_taken_this_turn {
    add_combo_score(state, 100, "FLAWLESS!")
  }

  // Phase 5: Check conditions
  check_battle_conditions(state)

  // Phase 5.5: Process status effects (fire DoT, immobilize decay)
  // Placed after intent resolution so that Immobilized applied this turn
  // is checked during the NEXT intent generation before it expires.
  process_statuses(state)

  // Generate enemy intents for next turn (visible to player)
  generate_enemy_intents(state)

  // Advance turn counter
  state.turn += 1

  state.turn_log
}

///|
/// Resolve only enemy intents (called separately by the game loop).
/// Kept for backward compatibility with the existing game/update.mbt code.
pub fn resolve_enemy_intents(state : @types.BattleState) -> Array[String] {
  let prev_log = state.turn_log
  state.turn_log = []

  resolve_all_enemy_intents(state)
  apply_hazard_damage(state)
  cleanup_turn(state)
  check_battle_conditions(state)
  generate_enemy_intents(state)

  let result = state.turn_log
  state.turn_log = prev_log
  result
}

///|
/// Apply hazard damage to all units standing on hazard tiles.
fn apply_hazard_damage(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && battle.grid.in_bounds(u.x, u.y) {
      let tile = battle.grid.get(u.x, u.y)
      let name = get_unit_name(battle, i)
      match tile.hazard {
        Fire => {
          let _ = apply_damage(battle, i, 1)
          battle.turn_log.push(
            "\{name} takes 1 fire damage from standing in flames",
          )
        }
        Acid => {
          let _ = apply_damage(battle, i, 1)
          battle.turn_log.push(
            "\{name} takes 1 acid damage from corrosive pool",
          )
        }
        Mine => {
          let _ = apply_damage(battle, i, 3)
          battle.turn_log.push("\{name} triggers a mine for 3 damage!")
          // Mine is consumed
          battle.grid.set(u.x, u.y, { ..tile, hazard: None, })
        }
        Smoke | None => ()
      }
      // Lava tiles
      if tile.kind == Lava {
        let _ = apply_damage(battle, i, 2)
        battle.turn_log.push("\{name} takes 2 lava damage!")
      }
      // Water tiles slow (no damage, but note for future)
    }
  }
}

///|
/// End-of-turn cleanup: clear stun after skipping, cool heat, reset flags.
/// Also applies end-of-turn augment effects.
fn cleanup_turn(battle : @types.BattleState) -> Unit {
  let has_emergency_repair = @types.battle_has_augment(battle, EmergencyRepair)
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if !u.active {
      continue
    }
    // Cool heat by 1 each turn for player units
    if u.team == Player && u.heat > 0 {
      u.heat -= 1
    }
    // EmergencyRepair augment: auto-heal 1 HP when below 25%
    if u.team == Player && u.active && u.hp > 0 && has_emergency_repair {
      check_emergency_repair(battle, i)
    }
    // Reset per-turn flags
    u.moved_this_turn = false
    u.acted_this_turn = false
  }
}

///|
/// Check victory and defeat conditions based on objective.
fn check_battle_conditions(battle : @types.BattleState) -> Unit {
  let players_alive = count_active(battle, Player)
  let enemies_alive = count_active(battle, Enemy)

  // Defeat: all player mechs destroyed
  if players_alive == 0 {
    battle.phase = GameOver
    battle.turn_log.push("DEFEAT - All mechs destroyed!")
    return
  }

  // Victory conditions depend on objective
  match battle.objective {
    DefendGrid(turns) =>
      if enemies_alive == 0 {
        // Objective bonus: turns remaining * 300
        let turns_left = turns - battle.turn
        if turns_left > 0 {
          add_combo_score(battle, turns_left * 300, "EARLY VICTORY!")
        }
        battle.phase = Victory
        battle.turn_log.push("VICTORY - All enemies eliminated!")
      } else if battle.turn >= turns {
        battle.phase = Victory
        battle.turn_log.push("VICTORY - Grid defended for \{turns} turns!")
      }
    Survive(turns) =>
      if battle.turn >= turns {
        battle.phase = Victory
        battle.turn_log.push("VICTORY - Survived \{turns} turns!")
      }
    Assassinate(target_id) =>
      // Check if the specific target unit is dead
      if target_id >= 0 && target_id < battle.units.length() {
        if !battle.units[target_id].active || battle.units[target_id].hp <= 0 {
          battle.phase = Victory
          battle.turn_log.push("VICTORY - Target eliminated!")
        }
        // Fallback: clear all enemies if target_id is invalid
      } else if enemies_alive == 0 {
        battle.phase = Victory
        battle.turn_log.push("VICTORY - All enemies eliminated!")
      }
    CapturePoints(needed) => {
      // Count how many control points are occupied by player units
      let mut captured = 0
      for i = 0; i < battle.units.length(); i = i + 1 {
        let u = battle.units[i]
        if u.active && u.hp > 0 && u.team == Player {
          if battle.grid.in_bounds(u.x, u.y) {
            let tile = battle.grid.get(u.x, u.y)
            if tile.kind == ControlPoint {
              captured += 1
            }
          }
        }
      }
      battle.objective_progress = captured
      if captured >= needed {
        battle.phase = Victory
        battle.turn_log.push("VICTORY - \{captured} control points captured!")
      }
    }
    Escort(_target_id, dest_x) => {
      // Check if escort target has reached destination column
      let mut escorted = false
      for i = 0; i < battle.units.length(); i = i + 1 {
        let u = battle.units[i]
        if u.active && u.hp > 0 && u.team == Player && u.x >= dest_x {
          escorted = true
          break
        }
      }
      if escorted {
        battle.phase = Victory
        battle.turn_log.push("VICTORY - Escort reached destination!")
      }
    }
  }
}

///|
/// Sentinel Overwatch (tier >= 2): after enemy intents resolve, any Sentinel
/// with upgrade_tier >= 2 that hasn't acted this turn auto-attacks the first
/// enemy within cannon range (4 tiles, line of sight required).
fn resolve_overwatch(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active &&
      u.hp > 0 &&
      u.team == Player &&
      u.mech_class == Sentinel &&
      u.upgrade_tier >= 2 &&
      !u.acted_this_turn {
      // Find first enemy in cannon range with LOS
      let mut target_id = -1
      for j = 0; j < battle.units.length(); j = j + 1 {
        let e = battle.units[j]
        if e.active && e.hp > 0 && e.team == Enemy {
          let dist = @types.manhattan(u.x, u.y, e.x, e.y)
          if dist <= 4 && has_line_of_sight(battle, u.x, u.y, e.x, e.y) {
            target_id = j
            break
          }
        }
      }
      if target_id >= 0 {
        let name = get_unit_name(battle, i)
        let target_name = get_unit_name(battle, target_id)
        let _ = apply_damage_from(battle, target_id, 2, i)
        battle.turn_log.push(
          "\{name} Overwatch! Auto-fires at \{target_name} for 2 damage!",
        )
      }
    }
  }
}

///|
/// Count active units on a team.
fn count_active(battle : @types.BattleState, team : @types.UnitTeam) -> Int {
  let mut n = 0
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == team {
      n += 1
    }
  }
  n
}
