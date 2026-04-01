///|
test "ink_empty has no channels" {
  let ink = ink_empty()
  assert_false(ink.c)
  assert_false(ink.m)
  assert_false(ink.y)
  assert_true(ink_is_empty(ink))
}

///|
test "ink_cyan has only cyan channel" {
  let ink = ink_cyan()
  assert_true(ink.c)
  assert_false(ink.m)
  assert_false(ink.y)
}

///|
test "ink_magenta has only magenta channel" {
  let ink = ink_magenta()
  assert_false(ink.c)
  assert_true(ink.m)
  assert_false(ink.y)
}

///|
test "ink_yellow has only yellow channel" {
  let ink = ink_yellow()
  assert_false(ink.c)
  assert_false(ink.m)
  assert_true(ink.y)
}

///|
test "ink_blue is cyan plus magenta" {
  let ink = ink_blue()
  assert_true(ink.c)
  assert_true(ink.m)
  assert_false(ink.y)
}

///|
test "ink_green is cyan plus yellow" {
  let ink = ink_green()
  assert_true(ink.c)
  assert_false(ink.m)
  assert_true(ink.y)
}

///|
test "ink_red is magenta plus yellow" {
  let ink = ink_red()
  assert_false(ink.c)
  assert_true(ink.m)
  assert_true(ink.y)
}

///|
test "ink_black has all channels" {
  let ink = ink_black()
  assert_true(ink.c)
  assert_true(ink.m)
  assert_true(ink.y)
  assert_false(ink_is_empty(ink))
}

///|
test "ink_from_channel creates correct colors" {
  assert_true(ink_equals(ink_from_channel(Cyan), ink_cyan()))
  assert_true(ink_equals(ink_from_channel(Magenta), ink_magenta()))
  assert_true(ink_equals(ink_from_channel(Yellow), ink_yellow()))
}

///|
test "ink_mix combines channels with OR" {
  // cyan + magenta = blue
  let blue = ink_mix(ink_cyan(), ink_magenta())
  assert_true(ink_equals(blue, ink_blue()))
  // cyan + yellow = green
  let green = ink_mix(ink_cyan(), ink_yellow())
  assert_true(ink_equals(green, ink_green()))
  // magenta + yellow = red
  let red = ink_mix(ink_magenta(), ink_yellow())
  assert_true(ink_equals(red, ink_red()))
  // cyan + red (m+y) = black
  let black = ink_mix(ink_cyan(), ink_red())
  assert_true(ink_equals(black, ink_black()))
  // empty + empty = empty
  let empty = ink_mix(ink_empty(), ink_empty())
  assert_true(ink_is_empty(empty))
}

///|
test "ink_add_channel adds single channel" {
  let ink = ink_empty()
  let with_c = ink_add_channel(ink, Cyan)
  assert_true(ink_equals(with_c, ink_cyan()))
  let with_cm = ink_add_channel(with_c, Magenta)
  assert_true(ink_equals(with_cm, ink_blue()))
  let with_cmy = ink_add_channel(with_cm, Yellow)
  assert_true(ink_equals(with_cmy, ink_black()))
}

///|
test "ink_add_channel is idempotent" {
  let ink = ink_cyan()
  let result = ink_add_channel(ink, Cyan)
  assert_true(ink_equals(result, ink_cyan()))
}

///|
test "ink_equals checks all channels" {
  assert_true(ink_equals(ink_empty(), ink_empty()))
  assert_true(ink_equals(ink_black(), ink_black()))
  assert_false(ink_equals(ink_cyan(), ink_magenta()))
  assert_false(ink_equals(ink_empty(), ink_cyan()))
}

///|
test "ink_display_name returns correct names" {
  inspect(ink_display_name(ink_empty()), content="Empty")
  inspect(ink_display_name(ink_cyan()), content="Cyan")
  inspect(ink_display_name(ink_magenta()), content="Magenta")
  inspect(ink_display_name(ink_yellow()), content="Yellow")
  inspect(ink_display_name(ink_blue()), content="Blue")
  inspect(ink_display_name(ink_green()), content="Green")
  inspect(ink_display_name(ink_red()), content="Red")
  inspect(ink_display_name(ink_black()), content="Black")
}

///|
test "channel_name returns correct names" {
  inspect(channel_name(Cyan), content="Cyan")
  inspect(channel_name(Magenta), content="Magenta")
  inspect(channel_name(Yellow), content="Yellow")
}

///|
test "make_tile creates paper tile with empty ink" {
  let t = make_tile(Paper)
  inspect(t.kind, content="Paper")
  assert_true(ink_is_empty(t.ink))
  assert_true(ink_is_empty(t.target_color))
}

///|
test "make_target_tile creates target with specified color" {
  let t = make_target_tile(ink_blue())
  inspect(t.kind, content="Target")
  assert_true(ink_is_empty(t.ink))
  assert_true(ink_equals(t.target_color, ink_blue()))
}

///|
test "make_grid creates grid with correct dimensions" {
  let g = make_grid(4, 3)
  inspect(g.width, content="4")
  inspect(g.height, content="3")
  inspect(g.tiles.length(), content="12")
  // All tiles should be paper with empty ink
  inspect(g.tiles[0].kind, content="Paper")
  assert_true(ink_is_empty(g.tiles[0].ink))
}

///|
test "grid_index computes row-major index" {
  let g = make_grid(5, 3)
  inspect(grid_index(g, 0, 0), content="0")
  inspect(grid_index(g, 4, 0), content="4")
  inspect(grid_index(g, 0, 1), content="5")
  inspect(grid_index(g, 2, 2), content="12")
}

///|
test "grid_get and grid_set round-trip" {
  let g = make_grid(3, 3)
  let t = make_target_tile(ink_cyan())
  grid_set(g, 1, 2, t)
  let result = grid_get(g, 1, 2)
  inspect(result.kind, content="Target")
  assert_true(ink_equals(result.target_color, ink_cyan()))
}

///|
test "grid_in_bounds checks boundaries" {
  let g = make_grid(4, 3)
  assert_true(grid_in_bounds(g, 0, 0))
  assert_true(grid_in_bounds(g, 3, 2))
  assert_false(grid_in_bounds(g, -1, 0))
  assert_false(grid_in_bounds(g, 4, 0))
  assert_false(grid_in_bounds(g, 0, -1))
  assert_false(grid_in_bounds(g, 0, 3))
}

///|
test "clone_tile creates independent copy" {
  let t = make_tile(Paper)
  t.ink = ink_cyan()
  let c = clone_tile(t)
  assert_true(ink_equals(c.ink, ink_cyan()))
  // Modifying original should not affect clone
  t.ink = ink_magenta()
  assert_true(ink_equals(c.ink, ink_cyan()))
}

///|
test "clone_tiles creates independent array" {
  let tiles : Array[Tile] = [make_tile(Paper), make_tile(Barrier)]
  tiles[0].ink = ink_yellow()
  let cloned = clone_tiles(tiles)
  inspect(cloned.length(), content="2")
  assert_true(ink_equals(cloned[0].ink, ink_yellow()))
  inspect(cloned[1].kind, content="Barrier")
  // Modify original
  tiles[0].ink = ink_black()
  assert_true(ink_equals(cloned[0].ink, ink_yellow()))
}

///|
test "budget_get retrieves correct channel count" {
  let b : InkBudget = { cyan: 3, magenta: 5, yellow: 2 }
  inspect(budget_get(b, Cyan), content="3")
  inspect(budget_get(b, Magenta), content="5")
  inspect(budget_get(b, Yellow), content="2")
}

///|
test "budget_use decrements correct channel" {
  let b : InkBudget = { cyan: 3, magenta: 5, yellow: 2 }
  budget_use(b, Cyan)
  inspect(b.cyan, content="2")
  budget_use(b, Magenta)
  inspect(b.magenta, content="4")
  budget_use(b, Yellow)
  inspect(b.yellow, content="1")
}

///|
test "clone_budget creates independent copy" {
  let b : InkBudget = { cyan: 3, magenta: 5, yellow: 2 }
  let c = clone_budget(b)
  inspect(c.cyan, content="3")
  inspect(c.magenta, content="5")
  // Modify original
  b.cyan = 0
  inspect(c.cyan, content="3")
}

///|
test "tier_for_level returns correct tier" {
  inspect(tier_for_level(0), content="Watercolor")
  inspect(tier_for_level(7), content="Watercolor")
  inspect(tier_for_level(8), content="Pigment")
  inspect(tier_for_level(16), content="Pigment")
  inspect(tier_for_level(17), content="Palette")
  inspect(tier_for_level(24), content="Palette")
}

///|
test "tier_name returns correct names" {
  inspect(tier_name(Watercolor), content="Watercolor")
  inspect(tier_name(Pigment), content="Pigment")
  inspect(tier_name(Palette), content="Palette")
}

///|
test "tier_start_index returns correct offsets" {
  inspect(tier_start_index(Watercolor), content="0")
  inspect(tier_start_index(Pigment), content="8")
  inspect(tier_start_index(Palette), content="17")
}

///|
test "tier_level_count returns correct counts" {
  inspect(tier_level_count(Watercolor), content="8")
  inspect(tier_level_count(Pigment), content="9")
  inspect(tier_level_count(Palette), content="8")
}

///|
test "star_count converts rating to int" {
  inspect(star_count(Zero), content="0")
  inspect(star_count(One), content="1")
  inspect(star_count(Two), content="2")
  inspect(star_count(Three), content="3")
}

///|
test "new_level_score has zero values" {
  let s = new_level_score()
  assert_false(s.completed)
  inspect(s.stars, content="Zero")
  inspect(s.drops_used, content="0")
}

///|
test "new_game creates game with correct defaults" {
  let g = new_game()
  inspect(g.screen, content="Title")
  inspect(g.selected_tier, content="Watercolor")
  inspect(g.play_state, content="Placing")
  inspect(g.scores.length(), content="25")
  inspect(g.drops_used, content="0")
}
