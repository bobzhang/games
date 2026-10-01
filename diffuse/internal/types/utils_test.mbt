///|
test "ink_empty has no channels" {
  let ink = @types.ink_empty()
  assert_false(ink.c)
  assert_false(ink.m)
  assert_false(ink.y)
  assert_true(@types.ink_is_empty(ink))
}

///|
test "ink_cyan has only cyan channel" {
  let ink = @types.ink_cyan()
  assert_true(ink.c)
  assert_false(ink.m)
  assert_false(ink.y)
}

///|
test "ink_magenta has only magenta channel" {
  let ink = @types.ink_magenta()
  assert_false(ink.c)
  assert_true(ink.m)
  assert_false(ink.y)
}

///|
test "ink_yellow has only yellow channel" {
  let ink = @types.ink_yellow()
  assert_false(ink.c)
  assert_false(ink.m)
  assert_true(ink.y)
}

///|
test "ink_blue is cyan plus magenta" {
  let ink = @types.ink_blue()
  assert_true(ink.c)
  assert_true(ink.m)
  assert_false(ink.y)
}

///|
test "ink_green is cyan plus yellow" {
  let ink = @types.ink_green()
  assert_true(ink.c)
  assert_false(ink.m)
  assert_true(ink.y)
}

///|
test "ink_red is magenta plus yellow" {
  let ink = @types.ink_red()
  assert_false(ink.c)
  assert_true(ink.m)
  assert_true(ink.y)
}

///|
test "ink_black has all channels" {
  let ink = @types.ink_black()
  assert_true(ink.c)
  assert_true(ink.m)
  assert_true(ink.y)
  assert_false(@types.ink_is_empty(ink))
}

///|
test "ink_from_channel creates correct colors" {
  assert_true(
    @types.ink_equals(@types.ink_from_channel(Cyan), @types.ink_cyan()),
  )
  assert_true(
    @types.ink_equals(@types.ink_from_channel(Magenta), @types.ink_magenta()),
  )
  assert_true(
    @types.ink_equals(@types.ink_from_channel(Yellow), @types.ink_yellow()),
  )
}

///|
test "ink_mix combines channels with OR" {
  // cyan + magenta = blue
  let blue = @types.ink_mix(@types.ink_cyan(), @types.ink_magenta())
  assert_true(@types.ink_equals(blue, @types.ink_blue()))
  // cyan + yellow = green
  let green = @types.ink_mix(@types.ink_cyan(), @types.ink_yellow())
  assert_true(@types.ink_equals(green, @types.ink_green()))
  // magenta + yellow = red
  let red = @types.ink_mix(@types.ink_magenta(), @types.ink_yellow())
  assert_true(@types.ink_equals(red, @types.ink_red()))
  // cyan + red (m+y) = black
  let black = @types.ink_mix(@types.ink_cyan(), @types.ink_red())
  assert_true(@types.ink_equals(black, @types.ink_black()))
  // empty + empty = empty
  let empty = @types.ink_mix(@types.ink_empty(), @types.ink_empty())
  assert_true(@types.ink_is_empty(empty))
}

///|
test "ink_add_channel adds single channel" {
  let ink = @types.ink_empty()
  let with_c = @types.ink_add_channel(ink, Cyan)
  assert_true(@types.ink_equals(with_c, @types.ink_cyan()))
  let with_cm = @types.ink_add_channel(with_c, Magenta)
  assert_true(@types.ink_equals(with_cm, @types.ink_blue()))
  let with_cmy = @types.ink_add_channel(with_cm, Yellow)
  assert_true(@types.ink_equals(with_cmy, @types.ink_black()))
}

///|
test "ink_add_channel is idempotent" {
  let ink = @types.ink_cyan()
  let result = @types.ink_add_channel(ink, Cyan)
  assert_true(@types.ink_equals(result, @types.ink_cyan()))
}

///|
test "ink_equals checks all channels" {
  assert_true(@types.ink_equals(@types.ink_empty(), @types.ink_empty()))
  assert_true(@types.ink_equals(@types.ink_black(), @types.ink_black()))
  assert_false(@types.ink_equals(@types.ink_cyan(), @types.ink_magenta()))
  assert_false(@types.ink_equals(@types.ink_empty(), @types.ink_cyan()))
}

///|
test "ink_display_name returns correct names" {
  inspect(@types.ink_display_name(@types.ink_empty()), content="Empty")
  inspect(@types.ink_display_name(@types.ink_cyan()), content="Cyan")
  inspect(@types.ink_display_name(@types.ink_magenta()), content="Magenta")
  inspect(@types.ink_display_name(@types.ink_yellow()), content="Yellow")
  inspect(@types.ink_display_name(@types.ink_blue()), content="Blue")
  inspect(@types.ink_display_name(@types.ink_green()), content="Green")
  inspect(@types.ink_display_name(@types.ink_red()), content="Red")
  inspect(@types.ink_display_name(@types.ink_black()), content="Black")
}

///|
test "channel_name returns correct names" {
  inspect(@types.channel_name(Cyan), content="Cyan")
  inspect(@types.channel_name(Magenta), content="Magenta")
  inspect(@types.channel_name(Yellow), content="Yellow")
}

///|
test "make_tile creates paper tile with empty ink" {
  let t = @types.make_tile(Paper)
  inspect(t.kind, content="Paper")
  assert_true(@types.ink_is_empty(t.ink))
  assert_true(@types.ink_is_empty(t.target_color))
}

///|
test "make_target_tile creates target with specified color" {
  let t = @types.make_target_tile(@types.ink_blue())
  inspect(t.kind, content="Target")
  assert_true(@types.ink_is_empty(t.ink))
  assert_true(@types.ink_equals(t.target_color, @types.ink_blue()))
}

///|
test "make_grid creates grid with correct dimensions" {
  let g = @types.make_grid(4, 3)
  inspect(g.width, content="4")
  inspect(g.height, content="3")
  inspect(g.tiles.length(), content="12")
  // All tiles should be paper with empty ink
  inspect(g.tiles[0].kind, content="Paper")
  assert_true(@types.ink_is_empty(g.tiles[0].ink))
}

///|
test "grid_index computes row-major index" {
  let g = @types.make_grid(5, 3)
  inspect(@types.grid_index(g, 0, 0), content="0")
  inspect(@types.grid_index(g, 4, 0), content="4")
  inspect(@types.grid_index(g, 0, 1), content="5")
  inspect(@types.grid_index(g, 2, 2), content="12")
}

///|
test "grid_get and grid_set round-trip" {
  let g = @types.make_grid(3, 3)
  let t = @types.make_target_tile(@types.ink_cyan())
  @types.grid_set(g, 1, 2, t)
  let result = @types.grid_get(g, 1, 2)
  inspect(result.kind, content="Target")
  assert_true(@types.ink_equals(result.target_color, @types.ink_cyan()))
}

///|
test "grid_in_bounds checks boundaries" {
  let g = @types.make_grid(4, 3)
  assert_true(@types.grid_in_bounds(g, 0, 0))
  assert_true(@types.grid_in_bounds(g, 3, 2))
  assert_false(@types.grid_in_bounds(g, -1, 0))
  assert_false(@types.grid_in_bounds(g, 4, 0))
  assert_false(@types.grid_in_bounds(g, 0, -1))
  assert_false(@types.grid_in_bounds(g, 0, 3))
}

///|
test "clone_tile creates independent copy" {
  let t = @types.make_tile(Paper)
  t.ink = @types.ink_cyan()
  let c = @types.clone_tile(t)
  assert_true(@types.ink_equals(c.ink, @types.ink_cyan()))
  // Modifying original should not affect clone
  t.ink = @types.ink_magenta()
  assert_true(@types.ink_equals(c.ink, @types.ink_cyan()))
}

///|
test "clone_tiles creates independent array" {
  let tiles : Array[@types.Tile] = [
    @types.make_tile(Paper),
    @types.make_tile(Barrier),
  ]
  tiles[0].ink = @types.ink_yellow()
  let cloned = @types.clone_tiles(tiles)
  inspect(cloned.length(), content="2")
  assert_true(@types.ink_equals(cloned[0].ink, @types.ink_yellow()))
  inspect(cloned[1].kind, content="Barrier")
  // Modify original
  tiles[0].ink = @types.ink_black()
  assert_true(@types.ink_equals(cloned[0].ink, @types.ink_yellow()))
}

///|
test "budget_get retrieves correct channel count" {
  let b : @types.InkBudget = { cyan: 3, magenta: 5, yellow: 2, }
  inspect(@types.budget_get(b, Cyan), content="3")
  inspect(@types.budget_get(b, Magenta), content="5")
  inspect(@types.budget_get(b, Yellow), content="2")
}

///|
test "budget_use decrements correct channel" {
  let b : @types.InkBudget = { cyan: 3, magenta: 5, yellow: 2, }
  @types.budget_use(b, Cyan)
  inspect(b.cyan, content="2")
  @types.budget_use(b, Magenta)
  inspect(b.magenta, content="4")
  @types.budget_use(b, Yellow)
  inspect(b.yellow, content="1")
}

///|
test "clone_budget creates independent copy" {
  let b : @types.InkBudget = { cyan: 3, magenta: 5, yellow: 2, }
  let c = @types.clone_budget(b)
  inspect(c.cyan, content="3")
  inspect(c.magenta, content="5")
  // Modify original
  b.cyan = 0
  inspect(c.cyan, content="3")
}

///|
test "tier_for_level returns correct tier" {
  inspect(@types.tier_for_level(0), content="Watercolor")
  inspect(@types.tier_for_level(7), content="Watercolor")
  inspect(@types.tier_for_level(8), content="Pigment")
  inspect(@types.tier_for_level(16), content="Pigment")
  inspect(@types.tier_for_level(17), content="Palette")
  inspect(@types.tier_for_level(24), content="Palette")
}

///|
test "tier_name returns correct names" {
  inspect(@types.tier_name(Watercolor), content="Watercolor")
  inspect(@types.tier_name(Pigment), content="Pigment")
  inspect(@types.tier_name(Palette), content="Palette")
}

///|
test "tier_start_index returns correct offsets" {
  inspect(@types.tier_start_index(Watercolor), content="0")
  inspect(@types.tier_start_index(Pigment), content="8")
  inspect(@types.tier_start_index(Palette), content="17")
}

///|
test "tier_level_count returns correct counts" {
  inspect(@types.tier_level_count(Watercolor), content="8")
  inspect(@types.tier_level_count(Pigment), content="9")
  inspect(@types.tier_level_count(Palette), content="8")
}

///|
test "star_count converts rating to int" {
  inspect(@types.star_count(Zero), content="0")
  inspect(@types.star_count(One), content="1")
  inspect(@types.star_count(Two), content="2")
  inspect(@types.star_count(Three), content="3")
}

///|
test "new_level_score has zero values" {
  let s = @types.new_level_score()
  assert_false(s.completed)
  inspect(s.stars, content="Zero")
  inspect(s.drops_used, content="0")
}

///|
test "new_game creates game with correct defaults" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.selected_tier, content="Watercolor")
  inspect(g.play_state, content="Placing")
  inspect(g.scores.length(), content="25")
  inspect(g.drops_used, content="0")
}
