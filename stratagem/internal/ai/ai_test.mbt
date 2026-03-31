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
