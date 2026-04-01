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

///|
test "toggle_power_node flips connected camera" {
  let game = @types.new_game()
  let cam = @types.new_camera(8, 5)
  game.level.cameras = [cam]
  // Power node with camera connection (offset 1000 + index)
  let pn = @types.new_power_node(5, 5, 10, [1000])
  game.level.power_nodes = [pn]
  // Camera starts powered
  inspect(cam.powered, content="true")
  // Toggle power node off
  @hacking.toggle_power_node(game, 0)
  inspect(pn.powered, content="false")
  inspect(cam.powered, content="false")
  // Toggle back on
  @hacking.toggle_power_node(game, 0)
  inspect(pn.powered, content="true")
  inspect(cam.powered, content="true")
}

///|
test "toggle_power_node flips door laser and camera together" {
  let game = @types.new_game()
  let door = @types.new_door(7, 5, 20)
  let laser = @types.new_laser(9, 5, 30, true, 2)
  let cam = @types.new_camera(6, 5)
  game.level.doors = [door]
  game.level.lasers = [laser]
  game.level.cameras = [cam]
  // Power node connected to all three via their power_ids
  let pn = @types.new_power_node(5, 5, 10, [20, 30, 1000])
  game.level.power_nodes = [pn]
  // Initial state: powered, door closed/locked, laser active, camera on
  inspect(door.open, content="false")
  inspect(door.locked, content="true")
  inspect(laser.active, content="true")
  inspect(cam.powered, content="true")
  // Toggle off
  @hacking.toggle_power_node(game, 0)
  inspect(door.open, content="true")
  inspect(door.locked, content="false")
  inspect(laser.active, content="false")
  inspect(cam.powered, content="false")
  // Toggle on again
  @hacking.toggle_power_node(game, 0)
  inspect(door.open, content="false")
  inspect(door.locked, content="true")
  inspect(laser.active, content="true")
  inspect(cam.powered, content="true")
}

///|
test "toggle_power_node emits correct sounds" {
  let game = @types.new_game()
  let door = @types.new_door(7, 5, 20)
  let laser = @types.new_laser(9, 5, 30, true, 2)
  game.level.doors = [door]
  game.level.lasers = [laser]
  let pn = @types.new_power_node(5, 5, 10, [20, 30])
  game.level.power_nodes = [pn]
  game.sound_queue = []
  // Toggle off: should emit Hack + DoorOpen + LaserOff
  @hacking.toggle_power_node(game, 0)
  inspect(game.sound_queue.length(), content="3")
  inspect(game.sound_queue[0], content="Hack")
  inspect(game.sound_queue[1], content="DoorOpen")
  inspect(game.sound_queue[2], content="LaserOff")
}

///|
test "toggle_power_node with no connections" {
  let game = @types.new_game()
  let pn = @types.new_power_node(5, 5, 10, [])
  game.level.power_nodes = [pn]
  inspect(pn.powered, content="true")
  @hacking.toggle_power_node(game, 0)
  inspect(pn.powered, content="false")
  inspect(game.message, content="Power node deactivated")
  @hacking.toggle_power_node(game, 0)
  inspect(pn.powered, content="true")
  inspect(game.message, content="Power node activated")
}
