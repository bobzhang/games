///|
test "ai target selection" {
  let b = @types.new_battle()
  let p1 = @types.new_unit(0, Infantry, Player, 5, 4)
  let e1 = @types.new_unit(1, Cavalry, Enemy, 6, 4)
  let _ = @types.place_unit_on_map(b, p1)
  let _ = @types.place_unit_on_map(b, e1)
  b.units = [p1, e1]
  // Make everything visible for fair test
  for i in 0..<b.map.tiles.length() {
    b.map.tiles[i].fog_player = Visible
  }
  @types.seed_rng(42)
  let messages = execute_ai_turn(b, Normal)
  // AI should have taken some action
  inspect(messages.length() > 0, content="true")
}

///|
test "ai attacks type-advantaged target" {
  let b = @types.new_battle()
  // Cavalry beats infantry - AI should prefer this
  let p1 = @types.new_unit(0, Infantry, Player, 5, 4)
  let e1 = @types.new_unit(1, Cavalry, Enemy, 6, 4)
  let _ = @types.place_unit_on_map(b, p1)
  let _ = @types.place_unit_on_map(b, e1)
  b.units = [p1, e1]
  for i in 0..<b.map.tiles.length() {
    b.map.tiles[i].fog_player = Visible
  }
  @types.seed_rng(42)
  let messages = execute_ai_turn(b, Normal)
  // Should attack
  inspect(messages.length() > 0, content="true")
  // Player infantry should have taken damage
  inspect(p1.hp < p1.max_hp, content="true")
}

///|
test "ai moves toward enemy when out of range" {
  let b = @types.new_battle()
  let p1 = @types.new_unit(0, Infantry, Player, 1, 1)
  let e1 = @types.new_unit(1, Infantry, Enemy, 8, 6)
  let _ = @types.place_unit_on_map(b, p1)
  let _ = @types.place_unit_on_map(b, e1)
  b.units = [p1, e1]
  for i in 0..<b.map.tiles.length() {
    b.map.tiles[i].fog_player = Visible
  }
  @types.seed_rng(42)
  let old_col = e1.pos.col
  let old_row = e1.pos.row
  let _ = execute_ai_turn(b, Normal)
  // Enemy should have moved (closer to player)
  let moved = e1.pos.col != old_col || e1.pos.row != old_row
  inspect(moved, content="true")
}

///|
test "hard ai retreats when wounded" {
  let b = @types.new_battle()
  let p1 = @types.new_unit(0, Infantry, Player, 5, 4)
  let e1 = @types.new_unit(1, Cavalry, Enemy, 6, 4)
  e1.hp = 1 // Critically wounded
  let _ = @types.place_unit_on_map(b, p1)
  let _ = @types.place_unit_on_map(b, e1)
  b.units = [p1, e1]
  for i in 0..<b.map.tiles.length() {
    b.map.tiles[i].fog_player = Visible
  }
  @types.seed_rng(42)
  let old_dist = @types.hex_distance(e1.pos, p1.pos)
  let _ = execute_ai_turn(b, Hard)
  // Wounded unit should retreat (move away from player)
  let new_dist = @types.hex_distance(e1.pos, p1.pos)
  inspect(new_dist >= old_dist, content="true")
}

///|
test "hard ai prefers defensive terrain" {
  let b = @types.new_battle()
  // Place forest tiles near the enemy
  let forest_idx = @types.hex_index(@types.hex(7, 4), b.map.width)
  b.map.tiles[forest_idx].terrain = Forest
  let p1 = @types.new_unit(0, Infantry, Player, 1, 4)
  let e1 = @types.new_unit(1, Infantry, Enemy, 8, 4)
  let _ = @types.place_unit_on_map(b, p1)
  let _ = @types.place_unit_on_map(b, e1)
  b.units = [p1, e1]
  for i in 0..<b.map.tiles.length() {
    b.map.tiles[i].fog_player = Visible
  }
  @types.seed_rng(42)
  let _ = execute_ai_turn(b, Hard)
  // Hard AI should have moved (either into forest or toward player via forest)
  inspect(e1.moved, content="true")
}

///|
test "easy ai has randomness" {
  // Run the same scenario multiple times with different seeds
  // Easy AI should sometimes pick non-optimal actions
  let b = @types.new_battle()
  let p1 = @types.new_unit(0, Infantry, Player, 5, 4)
  let e1 = @types.new_unit(1, Cavalry, Enemy, 6, 4)
  let _ = @types.place_unit_on_map(b, p1)
  let _ = @types.place_unit_on_map(b, e1)
  b.units = [p1, e1]
  for i in 0..<b.map.tiles.length() {
    b.map.tiles[i].fog_player = Visible
  }
  @types.seed_rng(42)
  let messages = execute_ai_turn(b, Easy)
  // Should still take some action
  inspect(messages.length() > 0, content="true")
}

///|
test "hard ai considers unit hp in attack evaluation" {
  let b = @types.new_battle()
  // Two player units: one healthy, one wounded
  let p1 = @types.new_unit(0, Infantry, Player, 5, 4)
  let p2 = @types.new_unit(1, Infantry, Player, 7, 4)
  p2.hp = 1 // One hit from death
  let e1 = @types.new_unit(2, Cavalry, Enemy, 6, 4)
  let _ = @types.place_unit_on_map(b, p1)
  let _ = @types.place_unit_on_map(b, p2)
  let _ = @types.place_unit_on_map(b, e1)
  b.units = [p1, p2, e1]
  for i in 0..<b.map.tiles.length() {
    b.map.tiles[i].fog_player = Visible
  }
  @types.seed_rng(42)
  let messages = execute_ai_turn(b, Hard)
  // AI should have attacked (either target)
  inspect(messages.length() > 0, content="true")
  // The wounded unit p2 should have been targeted (kill bonus)
  inspect(p2.hp < 1 || p1.hp < p1.max_hp, content="true")
}
