///|
test "load_all_levels" {
  for i in 0..<20 {
    let level = load_level(i)
    assert_true(level.target_value > 0)
    assert_true(level.bronze_threshold > 0)
    assert_true(level.silver_threshold >= level.bronze_threshold)
    assert_true(level.gold_threshold >= level.silver_threshold)
  }
}

///|
test "level_soil_dimensions" {
  for i in 0..<20 {
    let level = load_level(i)
    assert_eq(level.initial_soil.length(), @types.grid_rows)
    for r in 0..<@types.grid_rows {
      assert_eq(level.initial_soil[r].length(), @types.grid_cols)
    }
  }
}

///|
test "level_names" {
  assert_eq(level_name(0), "First Furrow")
  assert_eq(level_name(19), "Grand Harvest")
}

///|
test "level_tiers" {
  assert_eq(level_tier(0), "Beginner")
  assert_eq(level_tier(6), "Beginner")
  assert_eq(level_tier(7), "Intermediate")
  assert_eq(level_tier(13), "Intermediate")
  assert_eq(level_tier(14), "Expert")
  assert_eq(level_tier(19), "Expert")
}

///|
test "level_difficulty_progression" {
  let l1 = load_level(0)
  let l10 = load_level(9)
  let l20 = load_level(19)
  assert_true(l1.target_value <= l10.target_value)
  assert_true(l10.target_value <= l20.target_value)
}

///|
test "locked_plots_valid" {
  for i in 0..<20 {
    let level = load_level(i)
    for j in 0..<level.locked_plots.length() {
      let (c, r) = level.locked_plots[j]
      assert_true(@types.in_bounds(c, r))
    }
  }
}

///|
test "soil_nutrients_in_range" {
  for i in 0..<20 {
    let level = load_level(i)
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        let (n, p, k) = level.initial_soil[r][c]
        assert_true(n >= 0 && n <= 100)
        assert_true(p >= 0 && p <= 100)
        assert_true(k >= 0 && k <= 100)
      }
    }
  }
}

///|
test "beginner_levels_no_locked" {
  for i in 0..<7 {
    let level = load_level(i)
    assert_eq(level.locked_plots.length(), 0)
  }
}

///|
test "hints_non_empty" {
  for i in 0..<20 {
    let level = load_level(i)
    assert_true(level.hint.length() > 0)
  }
}

///|
test "uniform_soil_consistency" {
  let level = load_level(0)
  let (n0, p0, k0) = level.initial_soil[0][0]
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let (n, p, k) = level.initial_soil[r][c]
      assert_eq(n, n0)
      assert_eq(p, p0)
      assert_eq(k, k0)
    }
  }
}
