///|
pub fn type_advantage(
  attacker : @types.UnitKind,
  defender : @types.UnitKind,
) -> Int {
  match (attacker, defender) {
    (Infantry, Artillery) => 2
    (Cavalry, Infantry) => 2
    (Artillery, Cavalry) => 2
    (Artillery, Infantry) => -1
    (Infantry, Cavalry) => -1
    (Cavalry, Artillery) => -1
    _ => 0
  }
}

///|
pub fn calc_damage(
  battle : @types.Battle,
  attacker : @types.GameUnit,
  defender : @types.GameUnit,
) -> Int {
  let base_atk = attacker.atk
  let type_bonus = type_advantage(attacker.kind, defender.kind)
  // Terrain bonuses
  let atk_terrain_idx = @types.hex_index(attacker.pos, battle.map.width)
  let def_terrain_idx = @types.hex_index(defender.pos, battle.map.width)
  let atk_terrain = battle.map.tiles[atk_terrain_idx].terrain
  let def_terrain = battle.map.tiles[def_terrain_idx].terrain
  let terrain_atk = @types.terrain_atk_bonus(atk_terrain, def_terrain)
  let terrain_def = @types.terrain_def_bonus(def_terrain, defender.kind)
  let unit_def = defender.def
  let total = base_atk + type_bonus + terrain_atk - terrain_def - unit_def
  @types.maxi(1, total)
}

///|
pub fn can_attack(
  battle : @types.Battle,
  attacker : @types.GameUnit,
  defender : @types.GameUnit,
) -> Bool {
  if attacker.attacked {
    return false
  }
  if attacker.team == defender.team {
    return false
  }
  if !defender.active {
    return false
  }
  let dist = @types.hex_distance(attacker.pos, defender.pos)
  let range = @types.effective_attack_range(battle, attacker)
  if dist > range || dist == 0 {
    return false
  }
  // Artillery needs line of sight
  if attacker.kind == Artillery && range > 1 {
    return @types.has_line_of_sight(battle.map, attacker.pos, defender.pos)
  }
  true
}

///|
pub fn resolve_attack(
  battle : @types.Battle,
  attacker_id : Int,
  defender_id : Int,
) -> (Int, Bool) {
  // Returns (damage_dealt, defender_killed)
  let attacker = match @types.get_unit(battle, attacker_id) {
    Some(u) => u
    None => return (0, false)
  }
  let defender = match @types.get_unit(battle, defender_id) {
    Some(u) => u
    None => return (0, false)
  }
  if !can_attack(battle, attacker, defender) {
    return (0, false)
  }
  let damage = calc_damage(battle, attacker, defender)
  defender.hp = defender.hp - damage
  attacker.attacked = true
  if defender.hp <= 0 {
    defender.active = false
    let idx = @types.hex_index(defender.pos, battle.map.width)
    if battle.map.tiles[idx].unit_id == defender.id {
      battle.map.tiles[idx].unit_id = -1
    }
    (damage, true)
  } else {
    (damage, false)
  }
}

// Movement - BFS for reachable hexes

///|
pub fn compute_move_range(
  battle : @types.Battle,
  unit : @types.GameUnit,
) -> Array[@types.HexCoord] {
  let result : Array[@types.HexCoord] = []
  let max_move = @types.effective_move_range(battle, unit)
  let w = battle.map.width
  let h = battle.map.height
  // BFS
  let total = w * h
  let costs : Array[Int] = Array::new(capacity=total)
  for _i in 0..<total {
    costs.push(999)
  }
  let start_idx = @types.hex_index(unit.pos, w)
  costs[start_idx] = 0
  let queue : Array[@types.HexCoord] = [@types.hex(unit.pos.col, unit.pos.row)]
  let mut qi = 0
  while qi < queue.length() {
    let cur = queue[qi]
    qi = qi + 1
    let cur_idx = @types.hex_index(cur, w)
    let cur_cost = costs[cur_idx]
    if cur_cost >= max_move {
      continue
    }
    let neighbors = @types.hex_neighbors(cur)
    for n in 0..<neighbors.length() {
      let nb = neighbors[n]
      if @types.hex_valid(nb, w, h) {
        let nb_idx = @types.hex_index(nb, w)
        let terrain = battle.map.tiles[nb_idx].terrain
        if terrain == Water {
          continue
        }
        let move_cost = @types.terrain_move_cost(terrain)
        let new_cost = cur_cost + move_cost
        if new_cost <= max_move && new_cost < costs[nb_idx] {
          // Check if tile is occupied by enemy
          let occupant = battle.map.tiles[nb_idx].unit_id
          if occupant >= 0 {
            match @types.get_unit(battle, occupant) {
              Some(occ) => if occ.team != unit.team { continue }
              None => ()
            }
          }
          costs[nb_idx] = new_cost
          queue.push(nb)
        }
      }
    }
  }
  // Collect reachable (exclude occupied by friendly and start)
  for row in 0..<h {
    for col in 0..<w {
      let c = @types.hex(col, row)
      let idx = @types.hex_index(c, w)
      if costs[idx] <= max_move && (col != unit.pos.col || row != unit.pos.row) {
        let occupant = battle.map.tiles[idx].unit_id
        if occupant < 0 {
          result.push(c)
        }
      }
    }
  }
  result
}

// Compute hexes that unit can attack from its current position

///|
pub fn compute_attack_targets(
  battle : @types.Battle,
  unit : @types.GameUnit,
) -> Array[@types.HexCoord] {
  let result : Array[@types.HexCoord] = []
  let range = @types.effective_attack_range(battle, unit)
  let w = battle.map.width
  let h = battle.map.height
  for row in 0..<h {
    for col in 0..<w {
      let c = @types.hex(col, row)
      let dist = @types.hex_distance(unit.pos, c)
      if dist >= 1 && dist <= range {
        match @types.get_unit_at(battle, c) {
          Some(target) =>
            if target.team != unit.team && target.active {
              if can_attack(battle, unit, target) {
                result.push(c)
              }
            }
          None => ()
        }
      }
    }
  }
  result
}

// Move a unit to a new position

///|
pub fn move_unit(
  battle : @types.Battle,
  unit_id : Int,
  target : @types.HexCoord,
) -> Bool {
  let unit = match @types.get_unit(battle, unit_id) {
    Some(u) => u
    None => return false
  }
  if unit.moved {
    return false
  }
  // Validate target is in move range
  let moves = compute_move_range(battle, unit)
  let mut valid = false
  for i in 0..<moves.length() {
    if moves[i].col == target.col && moves[i].row == target.row {
      valid = true
      break
    }
  }
  if !valid {
    return false
  }
  // Remove from old position
  let old_idx = @types.hex_index(unit.pos, battle.map.width)
  if battle.map.tiles[old_idx].unit_id == unit.id {
    battle.map.tiles[old_idx].unit_id = -1
  }
  // Move to new position
  unit.pos = target
  let new_idx = @types.hex_index(target, battle.map.width)
  battle.map.tiles[new_idx].unit_id = unit.id
  unit.moved = true
  true
}

// Check victory conditions

///|
pub fn check_victory(battle : @types.Battle) -> @types.GameResult {
  let player_count = @types.count_team_units(battle, Player)
  let enemy_count = @types.count_team_units(battle, Enemy)
  if player_count == 0 {
    return Defeat
  }
  if enemy_count == 0 {
    return Victory
  }
  match battle.victory_condition {
    EliminateAll => Ongoing
    CaptureFlag(fc, fr) => {
      let idx = @types.hex_index(@types.hex(fc, fr), battle.map.width)
      let uid = battle.map.tiles[idx].unit_id
      if uid >= 0 {
        match @types.get_unit(battle, uid) {
          Some(u) => if u.team == Player { Victory } else { Ongoing }
          None => Ongoing
        }
      } else {
        Ongoing
      }
    }
  }
}

// Calculate score for a battle

///|
pub fn calc_score(battle : @types.Battle, was_victory : Bool) -> Int {
  if !was_victory {
    return 0
  }
  let base = 1000
  let unit_bonus = @types.count_team_units(battle, Player) * 100
  let turn_bonus = @types.maxi(0, 500 - battle.turn * 20)
  base + unit_bonus + turn_bonus
}
