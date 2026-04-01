///|
test "get all 20 levels" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.level_num > 0)
    assert_true(level.target.rows == @types.grid_rows)
    assert_true(level.target.cols == @types.grid_cols)
    assert_true(level.par_changes > 0)
  }
}

///|
test "tier1 levels are plain weave" {
  for i in 0..<@types.tier1_count {
    let level = get_level(i)
    assert_eq(level.weave_type, Plain)
    assert_eq(level.tier, Apprentice)
  }
}

///|
test "tier2 levels are twill or satin" {
  for i in 0..<@types.tier2_count {
    let level = get_level(@types.tier1_count + i)
    assert_eq(level.tier, Journeyman)
    let is_valid = level.weave_type == Twill || level.weave_type == Satin
    assert_true(is_valid)
  }
}

///|
test "tier3 levels are complex" {
  for i in 0..<@types.tier3_count {
    let level = get_level(@types.tier1_count + @types.tier2_count + i)
    assert_eq(level.tier, Master)
    let is_valid = level.weave_type == Herringbone || level.weave_type == Diamond
    assert_true(is_valid)
  }
}

///|
test "star computation" {
  let level = get_level(0)
  // 1 star: just matching
  let s1 = compute_stars(level, level.par_changes + 5, false)
  assert_eq(s1, 1)
  // 2 stars: at or under par changes
  let s2 = compute_stars(level, level.par_changes, false)
  assert_eq(s2, 2)
  // 3 stars: under par + correct type
  let s3 = compute_stars(level, level.par_changes - 1, true)
  assert_eq(s3, 3)
}

///|
test "level warp_colors length matches grid_cols" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_eq(level.warp_colors.length(), @types.grid_cols)
  }
}

///|
test "level weft_colors length matches grid_rows" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_eq(level.weft_colors.length(), @types.grid_rows)
  }
}
