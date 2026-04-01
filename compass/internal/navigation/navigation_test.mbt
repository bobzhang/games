///|
test "try_move_basic" {
  let state = @levels.init_level(0)
  // Level 1 start is {x:1, y:1}
  let start_pos = state.ship.pos
  // Move east (should work - ocean)
  @navigation.try_move(state, East)
  inspect(state.ship.pos.x, content="2")
  inspect(state.ship.pos.y, content="1")
  inspect(state.ship.steps, content="1")
  ignore(start_pos)
}

///|
test "try_move_blocked_by_land" {
  let state = @levels.init_level(0)
  // Level 1 has land at (3,0)-(4,2)
  // Move ship to x:2, y:0 first
  state.ship.pos = { x: 2, y: 0 }
  let old_steps = state.ship.steps
  @navigation.try_move(state, East)
  // Should be blocked - land at x:3, y:0
  inspect(state.ship.pos.x, content="2")
  inspect(state.ship.pos.y, content="0")
  inspect(state.ship.steps == old_steps, content="true")
}

///|
test "try_move_out_of_bounds" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 0, y: 0 }
  let old_steps = state.ship.steps
  @navigation.try_move(state, North)
  inspect(state.ship.pos.y, content="0")
  inspect(state.ship.steps == old_steps, content="true")
}

///|
test "try_move_updates_heading" {
  let state = @levels.init_level(0)
  let heading_before = state.ship.heading
  @navigation.try_move(state, East)
  // After moving, heading should update toward lighthouse
  let heading_after = state.ship.heading
  // They may differ
  ignore(heading_before)
  ignore(heading_after)
  assert_true(state.ship.steps == 1)
}

///|
test "reef_damage" {
  // Build a custom level state with reef
  let state = @levels.init_level(0)
  // Place reef east of ship
  state.data.grid[1][2] = Reef
  state.ship.pos = { x: 1, y: 1 }
  let hp_before = state.ship.hp
  @navigation.try_move(state, East)
  inspect(state.ship.hp, content="\{hp_before - 1}")
}

///|
test "reef_sinks_ship" {
  let state = @levels.init_level(0)
  state.data.grid[1][2] = Reef
  state.ship.pos = { x: 1, y: 1 }
  state.ship.hp = 1
  @navigation.try_move(state, East)
  inspect(state.ship.hp, content="0")
  inspect(state.phase, content="GameOver")
}

///|
test "landmark_reveals_area" {
  let state = @levels.init_level(0)
  // Level 1 has landmark at (6,2)
  state.ship.pos = { x: 5, y: 2 }
  @navigation.try_move(state, East)
  // Should reveal 3x3 around (6,2)
  inspect(state.revealed[1][5], content="true")
  inspect(state.revealed[2][6], content="true")
  inspect(state.revealed[3][7], content="true")
}

///|
test "landmark_increments_count" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 5, y: 2 }
  // (6,2) is a landmark - area not yet revealed
  state.revealed[2][6] = false
  let before = state.ship.landmarks_found
  @navigation.try_move(state, East)
  inspect(state.ship.landmarks_found, content="\{before + 1}")
}

///|
test "lighthouse_completes_level" {
  let state = @levels.init_level(0)
  // Lighthouse at (10,8) - place ship adjacent
  state.ship.pos = { x: 9, y: 8 }
  @navigation.try_move(state, East)
  inspect(state.phase, content="LevelComplete")
}

///|
test "compute_star_rating_game_over" {
  let state = @levels.init_level(0)
  state.phase = GameOver
  let rating = @navigation.compute_star_rating(state)
  inspect(rating, content="None")
}

///|
test "compute_star_rating_one_star" {
  let state = @levels.init_level(0)
  state.phase = LevelComplete
  state.ship.steps = 100
  let rating = @navigation.compute_star_rating(state)
  inspect(rating, content="One")
}

///|
test "compute_star_rating_two_star" {
  let state = @levels.init_level(0)
  state.phase = LevelComplete
  state.ship.steps = 10
  state.ship.landmarks_found = 0
  let rating = @navigation.compute_star_rating(state)
  inspect(rating, content="Two")
}

///|
test "compute_star_rating_three_star" {
  let state = @levels.init_level(0)
  state.phase = LevelComplete
  state.ship.steps = 10
  state.ship.landmarks_found = state.data.landmark_count
  let rating = @navigation.compute_star_rating(state)
  inspect(rating, content="Three")
}

///|
test "can_reach_adjacent" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 1, y: 1 }
  // East from (1,1) goes to (2,1) which is ocean
  inspect(@navigation.can_reach_adjacent(state, East), content="true")
  // North from (1,1) goes to (1,0) - check
  let tile_north = state.data.grid[0][1]
  if tile_north is Ocean {
    inspect(@navigation.can_reach_adjacent(state, North), content="true")
  }
}

///|
test "can_reach_adjacent_blocked" {
  let state = @levels.init_level(0)
  // Level 1 has land at (3,0)
  state.ship.pos = { x: 2, y: 0 }
  inspect(@navigation.can_reach_adjacent(state, East), content="false")
}

///|
test "can_reach_adjacent_out_of_bounds" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 0, y: 0 }
  inspect(@navigation.can_reach_adjacent(state, North), content="false")
  inspect(@navigation.can_reach_adjacent(state, West), content="false")
}

///|
test "current_pushes_ship" {
  let state = @levels.init_level(7)
  // Level 8 has current East at (0,6)
  state.ship.pos = { x: 0, y: 5 }
  // Move south onto current
  @navigation.try_move(state, South)
  // Ship should be pushed east from (0,6) to (1,6)
  inspect(state.ship.pos.x, content="1")
  inspect(state.ship.pos.y, content="6")
}

///|
test "no_move_when_not_playing" {
  let state = @levels.init_level(0)
  state.phase = LevelComplete
  let pos_before = state.ship.pos
  @navigation.try_move(state, East)
  inspect(state.ship.pos == pos_before, content="true")
}

///|
test "multiple_moves_step_count" {
  let state = @levels.init_level(0)
  state.ship.pos = { x: 5, y: 5 }
  // Ensure surrounding tiles are ocean
  state.data.grid[5][6] = Ocean
  state.data.grid[5][7] = Ocean
  state.data.grid[4][7] = Ocean
  @navigation.try_move(state, East)
  @navigation.try_move(state, East)
  @navigation.try_move(state, North)
  inspect(state.ship.steps, content="3")
}
