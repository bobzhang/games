///|
test "ink mixing C+M=Blue" {
  let c = @types.ink_cyan()
  let m = @types.ink_magenta()
  let result = @types.ink_mix(c, m)
  assert_true(result.c)
  assert_true(result.m)
  assert_false(result.y)
  assert_eq(@types.ink_display_name(result), "Blue")
}

///|
test "ink mixing C+Y=Green" {
  let c = @types.ink_cyan()
  let y = @types.ink_yellow()
  let result = @types.ink_mix(c, y)
  assert_true(result.c)
  assert_false(result.m)
  assert_true(result.y)
  assert_eq(@types.ink_display_name(result), "Green")
}

///|
test "ink mixing M+Y=Red" {
  let m = @types.ink_magenta()
  let y = @types.ink_yellow()
  let result = @types.ink_mix(m, y)
  assert_false(result.c)
  assert_true(result.m)
  assert_true(result.y)
  assert_eq(@types.ink_display_name(result), "Red")
}

///|
test "ink mixing C+M+Y=Black" {
  let c = @types.ink_cyan()
  let m = @types.ink_magenta()
  let cm = @types.ink_mix(c, m)
  let y = @types.ink_yellow()
  let result = @types.ink_mix(cm, y)
  assert_true(result.c)
  assert_true(result.m)
  assert_true(result.y)
  assert_eq(@types.ink_display_name(result), "Black")
}

///|
test "spread to adjacent tiles" {
  let g = @types.make_grid(3, 3)
  // Place cyan ink at center
  let center = @types.grid_get(g, 1, 1)
  center.ink = @types.ink_cyan()
  let g2 = spread_once(g)
  // Check 4 neighbors have cyan
  let up = @types.grid_get(g2, 1, 0)
  assert_true(up.ink.c)
  let down = @types.grid_get(g2, 1, 2)
  assert_true(down.ink.c)
  let left = @types.grid_get(g2, 0, 1)
  assert_true(left.ink.c)
  let right = @types.grid_get(g2, 2, 1)
  assert_true(right.ink.c)
  // Corners should still be empty
  let corner = @types.grid_get(g2, 0, 0)
  assert_true(@types.ink_is_empty(corner.ink))
}

///|
test "barrier blocks spread" {
  let g = @types.make_grid(3, 1)
  // Place cyan at left
  let left = @types.grid_get(g, 0, 0)
  left.ink = @types.ink_cyan()
  // Barrier in middle
  @types.grid_set(g, 1, 0, @types.make_tile(Barrier))
  let g2 = spread_once(g)
  // Right tile should NOT have ink (barrier blocks)
  let right = @types.grid_get(g2, 2, 0)
  assert_true(@types.ink_is_empty(right.ink))
}

///|
test "target satisfaction check" {
  let g = @types.make_grid(2, 1)
  @types.grid_set(g, 0, 0, @types.make_target_tile(@types.ink_cyan()))
  @types.grid_set(g, 1, 0, @types.make_target_tile(@types.ink_magenta()))
  // No ink yet
  assert_false(all_targets_satisfied(g))
  // Add correct ink to first target
  let t0 = @types.grid_get(g, 0, 0)
  t0.ink = @types.ink_cyan()
  assert_false(all_targets_satisfied(g))
  // Add correct ink to second target
  let t1 = @types.grid_get(g, 1, 0)
  t1.ink = @types.ink_magenta()
  assert_true(all_targets_satisfied(g))
}

///|
test "waste counting" {
  let g = @types.make_grid(3, 1)
  @types.grid_set(g, 1, 0, @types.make_target_tile(@types.ink_cyan()))
  // Paper tile at 0 has ink -> waste
  let t0 = @types.grid_get(g, 0, 0)
  t0.ink = @types.ink_cyan()
  // Target tile at 1 has ink -> NOT waste
  let t1 = @types.grid_get(g, 1, 0)
  t1.ink = @types.ink_cyan()
  // Paper tile at 2 no ink -> NOT waste
  assert_eq(count_waste(g), 1)
}

///|
test "multi-turn spread distance" {
  let g = @types.make_grid(5, 1)
  let left = @types.grid_get(g, 0, 0)
  left.ink = @types.ink_magenta()
  // After 1 turn, should reach tile 1
  let g1 = spread_once(g)
  assert_true(!@types.ink_is_empty(@types.grid_get(g1, 1, 0).ink))
  assert_true(@types.ink_is_empty(@types.grid_get(g1, 2, 0).ink))
  // After 2 turns, should reach tile 2
  let g2 = spread_once(g1)
  assert_true(!@types.ink_is_empty(@types.grid_get(g2, 2, 0).ink))
  assert_true(@types.ink_is_empty(@types.grid_get(g2, 3, 0).ink))
  // After 4 turns, should reach tile 4
  let g4 = spread_n_turns(g, 4)
  assert_true(!@types.ink_is_empty(@types.grid_get(g4, 4, 0).ink))
}
