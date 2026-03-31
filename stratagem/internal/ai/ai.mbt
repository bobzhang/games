///|
pub(all) struct AiAction {
  unit_id : Int
  move_to : @types.HexCoord?
  attack_target : Int
  score : Int
}

///|
fn evaluate_attack(
  battle : @types.Battle,
  unit : @types.GameUnit,
  target : @types.GameUnit
) -> Int {
  let type_bonus = @combat.type_advantage(unit.kind, target.kind)
  let damage = @combat.calc_damage(battle, unit, target)
  let kill_bonus = if target.hp <= damage { 50 } else { 0 }
  let base = damage * 10 + type_bonus * 15 + kill_bonus
  base
}

///|
fn find_best_actions(
  battle : @types.Battle,
  unit : @types.GameUnit,
  difficulty : @types.Difficulty
) -> Array[AiAction] {
  let actions : Array[AiAction] = []
  // Option 1: Attack from current position
  if !(unit.attacked) {
    let targets = @combat.compute_attack_targets(battle, unit)
    for t in 0..<targets.length() {
      match @types.get_unit_at(battle, targets[t]) {
        Some(target) => {
          let score = evaluate_attack(battle, unit, target)
          actions.push(
            { unit_id: unit.id, move_to: None, attack_target: target.id, score },
          )
        }
        None => ()
      }
    }
  }
  // Option 2: Move then attack
  if !(unit.moved) {
    let moves = @combat.compute_move_range(battle, unit)
    for m in 0..<moves.length() {
      let move_hex = moves[m]
      // Temporarily move unit for evaluation
      let old_pos = unit.pos
      let old_idx = @types.hex_index(old_pos, battle.map.width)
      let new_idx = @types.hex_index(move_hex, battle.map.width)
      unit.pos = move_hex
      battle.map.tiles[old_idx].unit_id = -1
      battle.map.tiles[new_idx].unit_id = unit.id
      // Check attacks from new position
      let atk_range = @types.effective_attack_range(battle, unit)
      let w = battle.map.width
      let h = battle.map.height
      for row in 0..<h {
        for col in 0..<w {
          let c = @types.hex(col, row)
          let dist = @types.hex_distance(move_hex, c)
          if dist >= 1 && dist <= atk_range {
            match @types.get_unit_at(battle, c) {
              Some(target) =>
                if target.team == Player && target.active {
                  if @combat.can_attack(battle, unit, target) {
                    let score = evaluate_attack(battle, unit, target) - 5
                    actions.push(
                      {
                        unit_id: unit.id,
                        move_to: Some(move_hex),
                        attack_target: target.id,
                        score,
                      },
                    )
                  }
                }
              None => ()
            }
          }
        }
      }
      // Restore position
      unit.pos = old_pos
      battle.map.tiles[new_idx].unit_id = -1
      battle.map.tiles[old_idx].unit_id = unit.id
    }
  }
  // Option 3: Move toward nearest enemy
  if !(unit.moved) && actions.length() == 0 {
    let moves = @combat.compute_move_range(battle, unit)
    let mut best_move : @types.HexCoord? = None
    let mut best_dist = 999
    for m in 0..<moves.length() {
      let move_hex = moves[m]
      // Find distance to nearest player unit
      for u in 0..<battle.units.length() {
        let pu = battle.units[u]
        if pu.active && pu.team == Player {
          let d = @types.hex_distance(move_hex, pu.pos)
          if d < best_dist {
            best_dist = d
            best_move = Some(move_hex)
          }
        }
      }
    }
    match best_move {
      Some(target) =>
        actions.push(
          { unit_id: unit.id, move_to: Some(target), attack_target: -1, score: 5 },
        )
      None => ()
    }
  }
  // Option 4: Retreat if low HP
  if !(unit.moved) && unit.hp == 1 {
    let moves = @combat.compute_move_range(battle, unit)
    let mut best_move : @types.HexCoord? = None
    let mut best_dist = 0
    for m in 0..<moves.length() {
      let move_hex = moves[m]
      let mut min_enemy_dist = 999
      for u in 0..<battle.units.length() {
        let pu = battle.units[u]
        if pu.active && pu.team == Player {
          let d = @types.hex_distance(move_hex, pu.pos)
          if d < min_enemy_dist {
            min_enemy_dist = d
          }
        }
      }
      if min_enemy_dist > best_dist {
        best_dist = min_enemy_dist
        best_move = Some(move_hex)
      }
    }
    match best_move {
      Some(target) =>
        actions.push(
          { unit_id: unit.id, move_to: Some(target), attack_target: -1, score: 3 },
        )
      None => ()
    }
  }
  // Sort by score descending
  sort_actions(actions)
  // Difficulty filter
  match difficulty {
    Easy =>
      if actions.length() > 3 {
        // Pick random from top 3
        let pick = @types.rng_int(3)
        let chosen = actions[pick]
        let result : Array[AiAction] = [chosen]
        result
      } else {
        actions
      }
    Normal => actions
    Hard => actions
  }
}

///|
fn sort_actions(actions : Array[AiAction]) -> Unit {
  // Simple bubble sort (small arrays)
  let n = actions.length()
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n - 1 - i; j = j + 1 {
      if actions[j].score < actions[j + 1].score {
        let tmp = actions[j]
        actions[j] = actions[j + 1]
        actions[j + 1] = tmp
      }
    }
  }
}

///|
pub fn execute_ai_turn(
  battle : @types.Battle,
  difficulty : @types.Difficulty
) -> Array[String] {
  let messages : Array[String] = []
  let unit_count = battle.units.length()
  for i = 0; i < unit_count; i = i + 1 {
    let unit = battle.units[i]
    if !(unit.active) || unit.team != Enemy {
      continue
    }
    if unit.moved && unit.attacked {
      continue
    }
    let actions = find_best_actions(battle, unit, difficulty)
    if actions.length() > 0 {
      let action = actions[0]
      // Execute move
      match action.move_to {
        Some(target) => {
          let _ = @combat.move_unit(battle, unit.id, target)
          messages.push(
            @types.unit_kind_name(unit.kind) + " moves to " + target.col.to_string() + "," + target.row.to_string(),
          )
        }
        None => ()
      }
      // Execute attack
      if action.attack_target >= 0 {
        let (dmg, killed) = @combat.resolve_attack(
          battle, unit.id, action.attack_target,
        )
        if dmg > 0 {
          match @types.get_unit(battle, action.attack_target) {
            Some(target) => {
              let msg = @types.unit_kind_name(unit.kind) + " attacks " + @types.unit_kind_name(
                  target.kind,
                ) + " for " + dmg.to_string() + " dmg"
              let final_msg = if killed { msg + " - DESTROYED!" } else { msg }
              messages.push(final_msg)
            }
            None =>
              messages.push(
                @types.unit_kind_name(unit.kind) + " attacks for " + dmg.to_string() + " dmg - DESTROYED!",
              )
          }
        }
      }
      // Mark done if no specific action was taken
      if action.move_to == None && action.attack_target < 0 {
        unit.moved = true
        unit.attacked = true
      }
    } else {
      unit.moved = true
      unit.attacked = true
    }
  }
  messages
}
