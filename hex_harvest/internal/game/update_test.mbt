///|
test "execute_turn_water_then_grow_then_harvest" {
  // Simulate a full turn cycle: place crop, water flows, crop grows, harvest
  let game = @types.new_game()
  game.level = @levels.load_level(0)
  game.turn = 0
  game.yield_collected = 0
  game.goals_collected = 0
  // Place a wheat seed on a tile adjacent to water source that should get watered
  // Valley 1: water source at (1,1) height 2, adjacent dirt at (0,1) height 1
  let tile = game.level.grid.tiles[1][0]
  assert_eq(tile.kind, Dirt)
  tile.crop = Some(Wheat)
  tile.crop_state = Seed
  tile.crop_turns = 0
  // Execute first turn - water should flow, seed should start growing
  @game.execute_turn(game)
  assert_eq(game.turn, 1)
  // The tile should be watered now (adjacent to water source, lower height)
  assert_true(tile.watered)
  // Seed should advance to Growing
  assert_eq(tile.crop_state, Growing)
}

///|
test "execute_turn_wheat_matures_after_grow_time" {
  let game = @types.new_game()
  game.level = @levels.load_level(0)
  game.turn = 0
  game.yield_collected = 0
  game.goals_collected = 0
  // Place wheat on a tile near the water source
  // (0,1) is dirt at height 1 - will get watered on first flow
  let tile = game.level.grid.tiles[1][0]
  tile.crop = Some(Wheat)
  tile.crop_state = Seed
  tile.crop_turns = 0
  // Wheat grow time is 2
  // Turn 1: water flows -> seed becomes Growing (turn 1)
  @game.execute_turn(game)
  assert_eq(tile.crop_state, Growing)
  // Turn 2: crop_turns increments to 2 >= grow_time(2) -> Mature -> auto-harvest
  @game.execute_turn(game)
  // Should be harvested now (auto-harvest happens same turn as maturity)
  assert_eq(tile.crop_state, Harvested)
  assert_true(game.yield_collected >= 1)
}

///|
test "calculate_score_zero_stars_below_target" {
  let game = @types.new_game()
  game.level = @levels.load_level(0)
  game.yield_collected = 0
  game.turn = 5
  let score = @game.calculate_score(game)
  assert_eq(score.stars, 0)
}

///|
test "calculate_score_one_star_at_target" {
  let game = @types.new_game()
  game.level = @levels.load_level(0) // target_yield=3, par_turns=5
  game.yield_collected = 3
  game.turn = 7 // above par
  let score = @game.calculate_score(game)
  assert_eq(score.stars, 1)
}

///|
test "calculate_score_two_stars_within_par" {
  let game = @types.new_game()
  // Valley 8 (index 7) has goals - so can get 2 stars without 3
  game.level = @levels.load_level(7) // has goals at (5,1) and (5,3)
  game.yield_collected = game.level.target_yield
  game.turn = game.level.par_turns // within par
  game.goals_collected = 0 // goals NOT collected -> only 2 stars
  let score = @game.calculate_score(game)
  assert_eq(score.stars, 2)
}

///|
test "calculate_score_three_stars_all_goals" {
  let game = @types.new_game()
  // Valley 8 (index 7) has 2 goals at (5,1) and (5,3)
  game.level = @levels.load_level(7)
  game.yield_collected = game.level.target_yield
  game.turn = game.level.par_turns
  // Mark all goals as collected
  game.goals_collected = game.level.goals.length()
  let score = @game.calculate_score(game)
  assert_eq(score.stars, 3)
}

///|
test "calculate_score_three_stars_no_goals_level" {
  let game = @types.new_game()
  // Valley 1 (index 0) has no goals
  game.level = @levels.load_level(0)
  game.yield_collected = game.level.target_yield
  game.turn = game.level.par_turns
  // No goals means star 3 is automatic if star 2 achieved
  let score = @game.calculate_score(game)
  assert_eq(score.stars, 3)
}

///|
test "save_undo_and_restore" {
  let game = @types.new_game()
  game.level = @levels.load_level(0)
  game.turn = 0
  game.yield_collected = 0
  // Save undo state
  @game.save_undo(game)
  assert_eq(game.undo_stack.length(), 1)
  // Modify game state
  game.turn = 3
  game.yield_collected = 5
  game.level.grid.tiles[0][0].crop = Some(Wheat)
  // Undo
  @game.undo(game)
  assert_eq(game.turn, 0)
  assert_eq(game.yield_collected, 0)
  assert_true(game.level.grid.tiles[0][0].crop is None)
  assert_eq(game.undo_stack.length(), 0)
}

///|
test "undo_on_empty_stack_shows_message" {
  let game = @types.new_game()
  game.level = @levels.load_level(0)
  @game.undo(game)
  assert_eq(game.message, "Nothing to undo")
}

///|
test "undo_stack_limit" {
  let game = @types.new_game()
  game.level = @levels.load_level(0)
  // Push 35 undo states (limit is 30)
  for _ in 0..<35 {
    @game.save_undo(game)
  }
  assert_true(game.undo_stack.length() <= 30)
}

///|
test "start_level_resets_state" {
  let game = @types.new_game()
  // Mess up game state
  game.turn = 99
  game.yield_collected = 99
  game.goals_collected = 99
  game.undo_stack.push(
    {
      tiles: @types.clone_grid_tiles(game.level.grid),
      turn: 0,
      yield_collected: 0,
      goals_collected: 0,
    },
  )
  // Start level
  @game.start_level(game, 0)
  assert_eq(game.turn, 0)
  assert_eq(game.yield_collected, 0)
  assert_eq(game.goals_collected, 0)
  assert_eq(game.undo_stack.length(), 0)
  assert_eq(game.screen, Playing)
  assert_eq(game.level.name, "First Sprout")
}

///|
test "check_goals_counts_harvested_on_goal_tiles" {
  let game = @types.new_game()
  // Valley 8 (index 7) has goals at (5,1) and (5,3)
  game.level = @levels.load_level(7)
  game.goals_collected = 0
  // Place a harvested crop on the first goal tile
  let goal = game.level.goals[0]
  let tile = game.level.grid.tiles[goal.row][goal.col]
  tile.crop = Some(Wheat)
  tile.crop_state = Harvested
  @game.check_goals(game)
  assert_eq(game.goals_collected, 1)
  // Place on second goal
  let goal2 = game.level.goals[1]
  let tile2 = game.level.grid.tiles[goal2.row][goal2.col]
  tile2.crop = Some(Corn)
  tile2.crop_state = Harvested
  @game.check_goals(game)
  assert_eq(game.goals_collected, 2)
}

///|
test "check_goals_ignores_non_harvested" {
  let game = @types.new_game()
  game.level = @levels.load_level(7)
  game.goals_collected = 0
  // Place a growing crop (not harvested) on goal
  let goal = game.level.goals[0]
  let tile = game.level.grid.tiles[goal.row][goal.col]
  tile.crop = Some(Wheat)
  tile.crop_state = Growing
  @game.check_goals(game)
  assert_eq(game.goals_collected, 0)
}

///|
test "execute_turn_ends_game_when_target_reached" {
  let game = @types.new_game()
  game.level = @levels.load_level(0) // target_yield = 3
  game.yield_collected = 2
  game.turn = 0
  // Set up a tile that will be harvested this turn
  // We need: watered tile with a mature crop
  let tile = game.level.grid.tiles[0][1] // (1,0) near water source
  tile.crop = Some(Wheat)
  tile.crop_state = Mature
  tile.watered = true
  @game.execute_turn(game)
  // Wheat base yield = 1, so total = 2 + 1 = 3 >= target(3)
  assert_true(game.yield_collected >= 3)
  assert_eq(game.screen, Results)
  assert_true(game.level_complete)
}

///|
test "execute_turn_ends_game_when_out_of_turns" {
  let game = @types.new_game()
  game.level = @levels.load_level(0) // turn_budget = 8
  game.yield_collected = 0
  game.turn = 7 // next turn will be 8 = budget
  @game.execute_turn(game)
  assert_eq(game.turn, 8)
  assert_eq(game.screen, Results)
  assert_false(game.level_complete)
}

///|
test "multiple_undo_restores_correctly" {
  let game = @types.new_game()
  game.level = @levels.load_level(0)
  game.turn = 0
  game.yield_collected = 0
  // Save state at turn 0
  @game.save_undo(game)
  game.turn = 1
  game.yield_collected = 1
  // Save state at turn 1
  @game.save_undo(game)
  game.turn = 2
  game.yield_collected = 3
  // Undo to turn 1
  @game.undo(game)
  assert_eq(game.turn, 1)
  assert_eq(game.yield_collected, 1)
  // Undo to turn 0
  @game.undo(game)
  assert_eq(game.turn, 0)
  assert_eq(game.yield_collected, 0)
}

///|
test "turn_resolution_stages_water_before_grow" {
  // Verify that water flows BEFORE crops grow in the same turn
  // This means a crop planted on an unwatered tile adjacent to water
  // should get watered and start growing in the same turn
  let game = @types.new_game()
  game.level = @levels.load_level(0) // Water source at (1,1) height 2
  game.turn = 0
  game.yield_collected = 0
  game.goals_collected = 0
  // Place seed on tile that is NOT yet watered but will be after flow
  let tile = game.level.grid.tiles[0][1] // (1,0) height 1, adjacent to source
  tile.watered = false // ensure not watered yet
  tile.crop = Some(Wheat)
  tile.crop_state = Seed
  tile.crop_turns = 0
  @game.execute_turn(game)
  // Should be watered after flow step
  assert_true(tile.watered)
  // Should have advanced from Seed -> Growing (because water arrived before grow step)
  assert_eq(tile.crop_state, Growing)
}
