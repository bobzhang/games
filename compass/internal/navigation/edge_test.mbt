///|
test "move_east_to_boundary" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 11, y: 5 }
  state.data.grid[5][11] = Ocean
  @navigation.try_move(state, East)
  // Should not move - out of bounds
  inspect(state.ship.pos.x, content="11")
}

///|
test "move_west_to_boundary" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 0, y: 5 }
  @navigation.try_move(state, West)
  inspect(state.ship.pos.x, content="0")
}

///|
test "move_south_to_boundary" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 5, y: 9 }
  state.data.grid[9][5] = Ocean
  @navigation.try_move(state, South)
  inspect(state.ship.pos.y, content="9")
}

///|
test "current_does_not_push_into_land" {
  let state = @levels.init_level(0)
  // Set up current that would push into land
  state.data.grid[5][5] = Current(East)
  state.data.grid[5][6] = Land
  state.ship.pos = { x: 4, y: 5 }
  @navigation.try_move(state, East)
  // Ship should be on the current tile but not pushed into land
  inspect(state.ship.pos.x, content="5")
  inspect(state.ship.pos.y, content="5")
}

///|
test "current_pushes_onto_lighthouse" {
  let state = @levels.init_level(0)
  // Level 1 lighthouse is at (10,8)
  // Place current west of it, ship west of current
  state.data.grid[8][9] = Current(East)
  state.ship.pos = { x: 8, y: 8 }
  @navigation.try_move(state, East)
  // Should be pushed onto lighthouse at (10,8)
  inspect(state.phase, content="LevelComplete")
}

///|
test "current_pushes_onto_reef" {
  let state = @levels.init_level(0)
  state.data.grid[5][5] = Current(East)
  state.data.grid[5][6] = Reef
  state.ship.pos = { x: 4, y: 5 }
  state.ship.hp = 2
  @navigation.try_move(state, East)
  inspect(state.ship.hp, content="1")
  inspect(state.ship.pos.x, content="6")
}

///|
test "current_pushes_onto_landmark" {
  let state = @levels.init_level(0)
  state.data.grid[5][5] = Current(East)
  state.data.grid[5][6] = Landmark
  state.revealed[5][6] = false
  state.ship.pos = { x: 4, y: 5 }
  let before = state.ship.landmarks_found
  @navigation.try_move(state, East)
  inspect(state.ship.landmarks_found, content="\{before + 1}")
  // Area around landmark should be revealed
  inspect(state.revealed[5][6], content="true")
}

///|
test "current_at_boundary_does_not_crash" {
  let state = @levels.init_level(0)
  // Current at edge pushing out of bounds
  state.data.grid[0][11] = Current(East)
  state.ship.pos = { x: 10, y: 0 }
  // Should just land on current tile without crashing
  @navigation.try_move(state, East)
  inspect(state.ship.pos.x, content="11")
  inspect(state.ship.pos.y, content="0")
}

///|
test "message_timer_set_on_event" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 0, y: 0 }
  @navigation.try_move(state, North)
  // Should have set a message about edge
  assert_true(state.message_timer > 0.0)
  assert_true(state.message.length() > 0)
}

///|
test "compass_beep_near_land" {
  let state = @levels.init_level(0)
  // Position ship adjacent to land
  // Level 1 has land at (3,0)
  state.ship.pos = { x: 2, y: 1 }
  state.data.grid[1][3] = Ocean
  // Move east to be at (3,1), adjacent to land at (3,0)
  state.data.grid[0][3] = Land
  @navigation.try_move(state, East)
  // Now at (3,1), land at (3,0) is north
  inspect(state.compass_beep, content="true")
}

///|
test "star_rating_edge_exact_par" {
  let state = @levels.init_level(0)
  state.phase = LevelComplete
  state.ship.steps = state.data.par_steps
  state.ship.landmarks_found = 0
  let rating = @navigation.compute_star_rating(state)
  // Exactly at par, but not all landmarks => Two
  inspect(rating, content="Two")
}

///|
test "star_rating_one_over_par" {
  let state = @levels.init_level(0)
  state.phase = LevelComplete
  state.ship.steps = state.data.par_steps + 1
  state.ship.landmarks_found = state.data.landmark_count
  let rating = @navigation.compute_star_rating(state)
  // Over par => One star regardless of landmarks
  inspect(rating, content="One")
}
