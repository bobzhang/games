///|
test "toggle_power_node flips connected subsystems" {
  let game = @types.new_game()
  // Setup: power node connected to a door and laser
  // connected_ids holds the power_ids of the connected subsystems
  let pn = @types.new_power_node(5, 5, 10, [20, 30])
  game.level.power_nodes = [pn]
  // Door's power_id must match what's in connected_ids
  let door = @types.new_door(7, 5, 20)
  // door.power_id is already 20 from constructor
  game.level.doors = [door]
  // Laser's power_id must match what's in connected_ids
  let laser = @types.new_laser(9, 5, 30, true, 2)
  // laser.power_id is already 30 from constructor
  game.level.lasers = [laser]
  // Initially powered
  inspect(pn.powered, content="true")
  inspect(laser.active, content="true")
  // Toggle off
  @hacking.toggle_power_node(game, 0)
  inspect(pn.powered, content="false")
  inspect(laser.active, content="false")
  // Door should open when power is off
  inspect(door.open, content="true")
  // Toggle back on
  @hacking.toggle_power_node(game, 0)
  inspect(pn.powered, content="true")
  inspect(laser.active, content="true")
  inspect(door.open, content="false")
}

///|
test "all_terminals_hacked checks correctly" {
  let game = @types.new_game()
  let t1 = @types.new_terminal(3, 3, false, 1)
  let t2 = @types.new_terminal(5, 5, false, 2)
  game.level.terminals = [t1, t2]
  inspect(@hacking.all_terminals_hacked(game), content="false")
  t1.hacked = true
  inspect(@hacking.all_terminals_hacked(game), content="false")
  t2.hacked = true
  inspect(@hacking.all_terminals_hacked(game), content="true")
}

///|
test "hacked_data_value sums hacked terminals" {
  let game = @types.new_game()
  let t1 = @types.new_terminal(3, 3, false, 1)
  t1.data_value = 100
  let t2 = @types.new_terminal(5, 5, false, 2)
  t2.data_value = 200
  game.level.terminals = [t1, t2]
  inspect(@hacking.hacked_data_value(game), content="0")
  t1.hacked = true
  inspect(@hacking.hacked_data_value(game), content="100")
  t2.hacked = true
  inspect(@hacking.hacked_data_value(game), content="300")
}

///|
test "complete_hack marks terminal and increments count" {
  let game = @types.new_game()
  let t = @types.new_terminal(3, 3, false, 1)
  game.level.terminals = [t]
  inspect(t.hacked, content="false")
  inspect(game.player.hacked_terminals, content="0")
  @hacking.complete_hack(game, 0)
  inspect(t.hacked, content="true")
  inspect(game.player.hacked_terminals, content="1")
}
