///|
test "weather_name returns correct strings" {
  inspect(weather_name(Clear), content="Clear")
  inspect(weather_name(Sunny), content="Sunny")
  inspect(weather_name(Rainy), content="Rainy")
  inspect(weather_name(Cloudy), content="Cloudy")
  inspect(weather_name(Windy), content="Windy")
  inspect(weather_name(Stormy), content="Stormy")
}

///|
test "source_name returns correct strings" {
  inspect(source_name(Sun), content="Sun")
  inspect(source_name(Rain), content="Rain")
  inspect(source_name(Wind), content="Wind")
}

///|
test "tier_name returns correct strings" {
  inspect(tier_name(Spring), content="Spring")
  inspect(tier_name(Summer), content="Summer")
  inspect(tier_name(Monsoon), content="Monsoon")
}

///|
test "tier_level_count returns expected counts" {
  inspect(tier_level_count(Spring), content="8")
  inspect(tier_level_count(Summer), content="9")
  inspect(tier_level_count(Monsoon), content="8")
}

///|
test "tier_level_offset returns expected offsets" {
  inspect(tier_level_offset(Spring), content="0")
  inspect(tier_level_offset(Summer), content="8")
  inspect(tier_level_offset(Monsoon), content="17")
}

///|
test "grid_index computes row-major index" {
  inspect(grid_index(0, 0, 10), content="0")
  inspect(grid_index(5, 0, 10), content="5")
  inspect(grid_index(0, 1, 10), content="10")
  inspect(grid_index(3, 2, 10), content="23")
}

///|
test "in_bounds checks boundary conditions" {
  assert_true(in_bounds(0, 0, 10, 8))
  assert_true(in_bounds(9, 7, 10, 8))
  assert_false(in_bounds(-1, 0, 10, 8))
  assert_false(in_bounds(10, 0, 10, 8))
  assert_false(in_bounds(0, -1, 10, 8))
  assert_false(in_bounds(0, 8, 10, 8))
}

///|
test "wind_dir_dx returns correct delta" {
  inspect(wind_dir_dx(East), content="1")
  inspect(wind_dir_dx(West), content="-1")
  inspect(wind_dir_dx(North), content="0")
  inspect(wind_dir_dx(South), content="0")
}

///|
test "wind_dir_dy returns correct delta" {
  inspect(wind_dir_dy(South), content="1")
  inspect(wind_dir_dy(North), content="-1")
  inspect(wind_dir_dy(East), content="0")
  inspect(wind_dir_dy(West), content="0")
}

///|
test "make_grid creates grid with correct dimensions" {
  let g = make_grid(3, 2, [1, 0, 2, 0, 1, 0], [])
  inspect(g.width, content="3")
  inspect(g.height, content="2")
  inspect(g.tiles.length(), content="6")
  inspect(g.tiles[0].height, content="1")
  inspect(g.tiles[2].height, content="2")
}

///|
test "make_grid marks targets correctly" {
  let g = make_grid(3, 2, [0, 0, 0, 0, 0, 0], [(1, 0, Sunny), (2, 1, Rainy)])
  // Tile at col=1, row=0 should be target with Sunny
  let t1 = grid_get(g, 1, 0)
  assert_true(t1.is_target)
  assert_eq(t1.target_weather, Sunny)
  // Tile at col=2, row=1 should be target with Rainy
  let t2 = grid_get(g, 2, 1)
  assert_true(t2.is_target)
  assert_eq(t2.target_weather, Rainy)
  // Tile at col=0, row=0 should not be target
  let t0 = grid_get(g, 0, 0)
  assert_false(t0.is_target)
}

///|
test "grid_get returns correct tile" {
  let g = make_grid(3, 2, [10, 20, 30, 40, 50, 60], [])
  inspect(grid_get(g, 0, 0).height, content="10")
  inspect(grid_get(g, 2, 0).height, content="30")
  inspect(grid_get(g, 1, 1).height, content="50")
}

///|
test "clone_weather and restore_weather round-trip" {
  let g = make_grid(2, 2, [0, 0, 0, 0], [])
  g.tiles[0].weather = Sunny
  g.tiles[1].weather = Rainy
  g.tiles[2].weather = Windy
  g.tiles[3].weather = Stormy
  let saved = clone_weather(g)
  inspect(saved.length(), content="4")
  inspect(saved[0], content="Sunny")
  // Clear and verify
  clear_weather(g)
  inspect(g.tiles[0].weather, content="Clear")
  inspect(g.tiles[3].weather, content="Clear")
  // Restore and verify
  restore_weather(g, saved)
  inspect(g.tiles[0].weather, content="Sunny")
  inspect(g.tiles[1].weather, content="Rainy")
  inspect(g.tiles[2].weather, content="Windy")
  inspect(g.tiles[3].weather, content="Stormy")
}

///|
test "clear_weather resets all tiles" {
  let g = make_grid(2, 1, [0, 0], [])
  g.tiles[0].weather = Stormy
  g.tiles[1].weather = Cloudy
  clear_weather(g)
  inspect(g.tiles[0].weather, content="Clear")
  inspect(g.tiles[1].weather, content="Clear")
}

///|
test "new_level_score has zero values" {
  let s = new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.sources_used, content="0")
  inspect(s.turns_taken, content="0")
}

///|
test "new_game creates game with correct defaults" {
  let g = new_game()
  inspect(g.screen, content="Title")
  inspect(g.play_state, content="Placing")
  inspect(g.current_tier, content="Spring")
  inspect(g.current_level, content="0")
  inspect(g.level_scores.length(), content="25")
  inspect(g.wind_dir, content="East")
}

///|
test "set_message stores message and timer" {
  let g = new_game()
  set_message(g, "hello", 2.5)
  inspect(g.message, content="hello")
  inspect(g.message_timer, content="2.5")
}

///|
test "minf returns smaller float" {
  inspect(minf(3.0, 5.0), content="3")
  inspect(minf(7.0, 2.0), content="2")
  inspect(minf(4.0, 4.0), content="4")
}

///|
test "maxf returns larger float" {
  inspect(maxf(3.0, 5.0), content="5")
  inspect(maxf(7.0, 2.0), content="7")
}

///|
test "mini returns smaller int" {
  inspect(mini(3, 5), content="3")
  inspect(mini(7, 2), content="2")
}

///|
test "maxi returns larger int" {
  inspect(maxi(3, 5), content="5")
  inspect(maxi(7, 2), content="7")
}
