///|
test "get_all_levels returns 20 levels" {
  let levels = @levels.get_all_levels()
  assert_eq(levels.length(), 20)
}

///|
test "tier_level_range covers all 20" {
  let (s1, e1) = @levels.tier_level_range(Fundamentals)
  let (s2, e2) = @levels.tier_level_range(Chromatics)
  let (s3, e3) = @levels.tier_level_range(Mastery)
  assert_eq(s1, 0)
  assert_eq(e1, s2)
  assert_eq(e2, s3)
  assert_eq(e3, 20)
}

///|
test "all levels have valid grid coordinates" {
  let levels = @levels.get_all_levels()
  let grid = @types.new_hex_grid()
  for i in 0..<levels.length() {
    let level = levels[i]
    for j in 0..<level.grid_template.length() {
      let (q, r, _, _, _, _, _) = level.grid_template[j]
      assert_true(@types.grid_in_bounds(grid, q, r))
    }
  }
}

///|
test "load_level places components correctly" {
  let game = @types.new_game()
  @levels.load_level(game, 0)
  // Level 0: First Light has source at (-3,0) and target at (3,0)
  match @types.grid_get(game.grid, -3, 0) {
    Some(cell) => {
      assert_eq(cell.component, Some(Source))
      assert_eq(cell.locked, true)
    }
    None => fail("source cell missing")
  }
  match @types.grid_get(game.grid, 3, 0) {
    Some(cell) => {
      assert_eq(cell.component, Some(Target))
      assert_eq(cell.locked, true)
    }
    None => fail("target cell missing")
  }
}

///|
test "tier_level_count matches ranges" {
  let tiers : Array[@types.Tier] = [Fundamentals, Chromatics, Mastery]
  for i in 0..<tiers.length() {
    let t = tiers[i]
    let (start, end_) = @levels.tier_level_range(t)
    assert_eq(@levels.tier_level_count(t), end_ - start)
  }
}

///|
test "level 1 is solvable with no components" {
  let game = @types.new_game()
  @levels.load_level(game, 0)
  // Level 1: First Light - source at (-3,0) E, target at (3,0) W expecting white
  // Should be already solvable by just simulating
  game.beams = @optics.trace_all_beams(game.grid)
  assert_true(@optics.check_all_targets(game.grid))
}

///|
test "each tier has correct name" {
  assert_eq(@types.tier_name(Fundamentals), "Fundamentals")
  assert_eq(@types.tier_name(Chromatics), "Chromatics")
  assert_eq(@types.tier_name(Mastery), "Mastery")
}
