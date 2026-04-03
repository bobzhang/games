///|
test "new_game_defaults" {
  let g = @types.new_game()
  assert_eq(g.screen, Title)
  assert_eq(g.level_index, 0)
  assert_eq(g.total_value, 0)
  assert_eq(g.planning_season, 0)
}

///|
test "game_grid_dimensions" {
  let g = @types.new_game()
  assert_eq(g.grid.length(), @types.grid_rows)
  assert_eq(g.grid[0].length(), @types.grid_cols)
}

///|
test "game_plans_initialized" {
  let g = @types.new_game()
  assert_eq(g.plans.length(), 4)
  for s in 0..<4 {
    assert_eq(g.plans[s].crops.length(), @types.grid_rows)
  }
}

///|
test "game_scores_initialized" {
  let g = @types.new_game()
  assert_eq(g.level_scores.length(), @types.total_levels)
  for i in 0..<@types.total_levels {
    assert_true(g.level_scores[i] is None)
  }
}

///|
test "game_anim_grids_initialized" {
  let g = @types.new_game()
  assert_eq(g.harvest_flash.length(), @types.grid_rows)
  assert_eq(g.growth_anim.length(), @types.grid_rows)
}

///|
test "set_message_works" {
  let g = @types.new_game()
  @types.set_message(g, "Test", 2.0)
  assert_eq(g.message, "Test")
  assert_true(g.message_timer > 0.0)
}

///|
test "level_unlock_first_always" {
  let g = @types.new_game()
  assert_true(@game.is_level_unlocked(g, 0))
}

///|
test "level_unlock_requires_prev" {
  let g = @types.new_game()
  assert_false(@game.is_level_unlocked(g, 1))
  g.level_scores[0] = Some({
    value_earned: 50,
    target_value: 10,
    tier: Some(Bronze),
  })
  assert_true(@game.is_level_unlocked(g, 1))
}
