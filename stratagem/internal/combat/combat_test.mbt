///|
test "type advantage infantry beats artillery" {
  inspect(@combat.type_advantage(Infantry, Artillery), content="2")
}

///|
test "type advantage cavalry beats infantry" {
  inspect(@combat.type_advantage(Cavalry, Infantry), content="2")
}

///|
test "type advantage artillery beats cavalry" {
  inspect(@combat.type_advantage(Artillery, Cavalry), content="2")
}

///|
test "type disadvantage" {
  inspect(@combat.type_advantage(Artillery, Infantry), content="-1")
  inspect(@combat.type_advantage(Infantry, Cavalry), content="-1")
  inspect(@combat.type_advantage(Cavalry, Artillery), content="-1")
}

///|
test "type advantage same kind is zero" {
  inspect(@combat.type_advantage(Infantry, Infantry), content="0")
  inspect(@combat.type_advantage(Cavalry, Cavalry), content="0")
  inspect(@combat.type_advantage(Artillery, Artillery), content="0")
}

///|
test "calc_damage basic" {
  let b = @types.new_battle()
  let attacker = @types.new_unit(0, Infantry, Player, 1, 1)
  let defender = @types.new_unit(1, Infantry, Enemy, 2, 1)
  let _ = @types.place_unit_on_map(b, attacker)
  let _ = @types.place_unit_on_map(b, defender)
  b.units = [attacker, defender]
  // Make tiles visible
  let idx1 = @types.hex_index(@types.hex(1, 1), b.map.width)
  b.map.tiles[idx1].fog_player = Visible
  let idx2 = @types.hex_index(@types.hex(2, 1), b.map.width)
  b.map.tiles[idx2].fog_player = Visible
  let dmg = @combat.calc_damage(b, attacker, defender)
  // Infantry ATK=2, no type bonus (same kind=0), no terrain bonus
  inspect(dmg, content="2")
}

///|
test "calc_damage with type advantage" {
  let b = @types.new_battle()
  let attacker = @types.new_unit(0, Infantry, Player, 1, 1)
  let defender = @types.new_unit(1, Artillery, Enemy, 2, 1)
  let _ = @types.place_unit_on_map(b, attacker)
  let _ = @types.place_unit_on_map(b, defender)
  b.units = [attacker, defender]
  let dmg = @combat.calc_damage(b, attacker, defender)
  // Infantry ATK=2 + type bonus 2 = 4
  inspect(dmg, content="4")
}

///|
test "calc_damage with forest defense" {
  let b = @types.new_battle()
  // Put defender in forest
  let def_idx = @types.hex_index(@types.hex(2, 1), b.map.width)
  b.map.tiles[def_idx].terrain = Forest
  let attacker = @types.new_unit(0, Cavalry, Player, 1, 1)
  let defender = @types.new_unit(1, Infantry, Enemy, 2, 1)
  let _ = @types.place_unit_on_map(b, attacker)
  let _ = @types.place_unit_on_map(b, defender)
  b.units = [attacker, defender]
  let dmg = @combat.calc_damage(b, attacker, defender)
  // Cavalry ATK=3, type advantage +2, defender in forest -2 DEF (infantry) = 3
  inspect(dmg, content="3")
}

///|
test "resolve attack kills unit" {
  let b = @types.new_battle()
  let attacker = @types.new_unit(0, Infantry, Player, 1, 1)
  let defender = @types.new_unit(1, Artillery, Enemy, 2, 1)
  defender.hp = 1
  let _ = @types.place_unit_on_map(b, attacker)
  let _ = @types.place_unit_on_map(b, defender)
  b.units = [attacker, defender]
  let (dmg, killed) = @combat.resolve_attack(b, 0, 1)
  inspect(dmg > 0, content="true")
  inspect(killed, content="true")
  inspect(defender.active, content="false")
}

///|
test "compute_move_range infantry" {
  let b = @types.new_battle()
  let u = @types.new_unit(0, Infantry, Player, 5, 4)
  let _ = @types.place_unit_on_map(b, u)
  b.units = [u]
  let moves = @combat.compute_move_range(b, u)
  // Infantry has move range 2, should have some valid hexes
  inspect(moves.length() > 0, content="true")
  // All moves should be within distance 2
  for i in 0..<moves.length() {
    let d = @types.hex_distance(u.pos, moves[i])
    inspect(d <= 2, content="true")
  }
}

///|
test "compute_move_range cavalry has more" {
  let b = @types.new_battle()
  let inf = @types.new_unit(0, Infantry, Player, 5, 4)
  let cav = @types.new_unit(1, Cavalry, Player, 5, 4)
  let _ = @types.place_unit_on_map(b, inf)
  b.units = [inf]
  let inf_moves = @combat.compute_move_range(b, inf)
  let _ = @types.remove_unit_from_map(b, inf)
  let _ = @types.place_unit_on_map(b, cav)
  b.units = [cav]
  let cav_moves = @combat.compute_move_range(b, cav)
  inspect(cav_moves.length() > inf_moves.length(), content="true")
}

///|
test "move_unit valid" {
  let b = @types.new_battle()
  let u = @types.new_unit(0, Infantry, Player, 5, 4)
  let _ = @types.place_unit_on_map(b, u)
  b.units = [u]
  let moves = @combat.compute_move_range(b, u)
  if moves.length() > 0 {
    let target = moves[0]
    let ok = @combat.move_unit(b, 0, target)
    inspect(ok, content="true")
    inspect(u.moved, content="true")
    inspect(u.pos.col == target.col, content="true")
    inspect(u.pos.row == target.row, content="true")
  }
}

///|
test "cannot move through water" {
  let b = @types.new_battle()
  // Fill some tiles with water
  for col in 3..<7 {
    let idx = @types.hex_index(@types.hex(col, 4), b.map.width)
    b.map.tiles[idx].terrain = Water
  }
  let u = @types.new_unit(0, Infantry, Player, 2, 4)
  let _ = @types.place_unit_on_map(b, u)
  b.units = [u]
  let moves = @combat.compute_move_range(b, u)
  // None of the moves should be on water
  for i in 0..<moves.length() {
    let idx = @types.hex_index(moves[i], b.map.width)
    inspect(b.map.tiles[idx].terrain != Water, content="true")
  }
}

///|
test "check_victory eliminate all" {
  let b = @types.new_battle()
  b.victory_condition = EliminateAll
  let u1 = @types.new_unit(0, Infantry, Player, 1, 1)
  let u2 = @types.new_unit(1, Infantry, Enemy, 8, 8)
  b.units = [u1, u2]
  inspect(@combat.check_victory(b), content="Ongoing")
  u2.active = false
  inspect(@combat.check_victory(b), content="Victory")
}

///|
test "check_victory player defeated" {
  let b = @types.new_battle()
  b.victory_condition = EliminateAll
  let u1 = @types.new_unit(0, Infantry, Player, 1, 1)
  let u2 = @types.new_unit(1, Infantry, Enemy, 8, 8)
  b.units = [u1, u2]
  u1.active = false
  inspect(@combat.check_victory(b), content="Defeat")
}

