///|
test "are_adjacent" {
  let c1 = @types.new_component(Gear(Small), 2, 2)
  let c2 = @types.new_component(Gear(Medium), 3, 2)
  inspect(@gears.are_adjacent(c1, c2), content="true")
  let c3 = @types.new_component(Gear(Small), 4, 2)
  inspect(@gears.are_adjacent(c1, c3), content="false")
  // Same position
  let c4 = @types.new_component(Gear(Small), 2, 2)
  inspect(@gears.are_adjacent(c1, c4), content="false")
  // Diagonal
  let c5 = @types.new_component(Gear(Small), 3, 3)
  inspect(@gears.are_adjacent(c1, c5), content="true")
}

///|
test "gears_can_mesh" {
  let g1 = @types.new_component(Gear(Small), 2, 2)
  let g2 = @types.new_component(Gear(Medium), 3, 2)
  inspect(@gears.gears_can_mesh(g1, g2), content="true")
  let cam = @types.new_component(Cam, 3, 2)
  inspect(@gears.gears_can_mesh(g1, cam), content="false")
  let g3 = @types.new_component(Gear(Large), 5, 5)
  inspect(@gears.gears_can_mesh(g1, g3), content="false")
}

///|
test "gear_mesh_ratio" {
  let small = @types.new_component(Gear(Small), 0, 0)
  let medium = @types.new_component(Gear(Medium), 1, 0)
  let ratio = @gears.gear_mesh_ratio(small, medium)
  // 8 teeth / 12 teeth = 0.666...
  inspect(ratio > 0.66 && ratio < 0.67, content="true")
  let large = @types.new_component(Gear(Large), 2, 0)
  let ratio2 = @gears.gear_mesh_ratio(small, large)
  // 8 / 16 = 0.5
  inspect(ratio2, content="0.5")
}

///|
test "build_connections simple chain" {
  let game = @types.new_game()
  let g1 = @types.new_component(Gear(Small), 0, 0)
  let g2 = @types.new_component(Gear(Medium), 1, 0)
  game.components.push(g1)
  game.components.push(g2)
  @gears.build_connections(game)
  inspect(g1.connected_to.length(), content="1")
  inspect(g1.connected_to[0], content="1")
  inspect(g2.connected_to.length(), content="1")
  inspect(g2.connected_to[0], content="0")
}

///|
test "build_connections gear to cam" {
  let game = @types.new_game()
  let g = @types.new_component(Gear(Small), 2, 2)
  let cam = @types.new_component(Cam, 3, 2)
  game.components.push(g)
  game.components.push(cam)
  @gears.build_connections(game)
  inspect(g.connected_to.length(), content="1")
  inspect(cam.connected_to.length(), content="1")
}

///|
test "build_connections no connection for far components" {
  let game = @types.new_game()
  let g1 = @types.new_component(Gear(Small), 0, 0)
  let g2 = @types.new_component(Gear(Small), 5, 5)
  game.components.push(g1)
  game.components.push(g2)
  @gears.build_connections(game)
  inspect(g1.connected_to.length(), content="0")
  inspect(g2.connected_to.length(), content="0")
}

///|
test "propagate_rotation simple" {
  let game = @types.new_game()
  let g1 = @types.new_component(Gear(Medium), 0, 0)
  let g2 = @types.new_component(Gear(Medium), 1, 0)
  game.components.push(g1)
  game.components.push(g2)
  @gears.build_connections(game)
  let visited : Array[Bool] = Array::make(2, false)
  @gears.propagate_rotation(game, 0, 1.0, true, visited)
  inspect(g1.rotation_speed, content="1")
  inspect(g1.clockwise, content="true")
  inspect(g2.rotation_speed, content="1")
  inspect(g2.clockwise, content="false")
}

///|
test "propagate_rotation gear ratio" {
  let game = @types.new_game()
  let small = @types.new_component(Gear(Small), 0, 0)
  let large = @types.new_component(Gear(Large), 1, 0)
  game.components.push(small)
  game.components.push(large)
  @gears.build_connections(game)
  let visited : Array[Bool] = Array::make(2, false)
  @gears.propagate_rotation(game, 0, 2.0, true, visited)
  inspect(small.rotation_speed, content="2")
  // 8/16 = 0.5 ratio, so large gear gets 2.0 * 0.5 = 1.0
  inspect(large.rotation_speed, content="1")
}

///|
test "calculate_stars no completion" {
  let game = @types.new_game()
  game.sim.state = Failed
  inspect(@gears.calculate_stars(game), content="0")
}

///|
test "calculate_stars one star" {
  let game = @types.new_game()
  game.sim.state = Complete
  game.sim.bells_rung = [5]
  game.level_def.bell_targets = [5]
  game.level_def.par_components = 1
  // Add 3 player-placed components so we exceed par
  let c1 = @types.new_component(Gear(Small), 0, 0)
  let c2 = @types.new_component(Gear(Small), 1, 0)
  let c3 = @types.new_component(Gear(Small), 2, 0)
  game.components.push(c1)
  game.components.push(c2)
  game.components.push(c3)
  inspect(@gears.calculate_stars(game), content="1")
}

///|
test "calculate_stars three stars" {
  let game = @types.new_game()
  game.sim.state = Complete
  game.sim.bells_rung = [5, 10]
  game.level_def.bell_targets = [5, 10]
  game.level_def.par_components = 2
  // Add exactly 2 player-placed components (at par)
  let c1 = @types.new_component(Gear(Small), 0, 0)
  let c2 = @types.new_component(Gear(Small), 1, 0)
  game.components.push(c1)
  game.components.push(c2)
  inspect(@gears.calculate_stars(game), content="3")
}
