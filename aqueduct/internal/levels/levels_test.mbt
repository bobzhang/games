///|
test "create_all_levels returns 20 levels" {
  let levels = create_all_levels()
  inspect(levels.length(), content="20")
}

///|
test "tier1 has 7 levels" {
  let t1 = create_tier1()
  inspect(t1.length(), content="7")
  for lv in t1 {
    inspect(lv.tier, content="Tier1")
    inspect(
      lv.elevations.length() == lv.grid_cols * lv.grid_rows,
      content="true",
    )
  }
}

///|
test "tier2 has 7 levels" {
  let t2 = create_tier2()
  inspect(t2.length(), content="7")
  for lv in t2 {
    inspect(lv.tier, content="Tier2")
  }
}

///|
test "tier3 has 6 levels" {
  let t3 = create_tier3()
  inspect(t3.length(), content="6")
  for lv in t3 {
    inspect(lv.tier, content="Tier3")
  }
}

///|
test "all levels have valid elevations" {
  let levels = create_all_levels()
  for lv in levels {
    for e in lv.elevations {
      assert_true(e >= 0 && e <= 4)
    }
  }
}

///|
test "all levels have springs and fountains" {
  let levels = create_all_levels()
  for lv in levels {
    assert_true(lv.springs.length() > 0)
    assert_true(lv.fountains.length() > 0)
  }
}

///|
test "make_flat_grid creates correct size" {
  let grid = make_flat_grid(5, 3, 2)
  inspect(grid.length(), content="15")
  for v in grid {
    inspect(v, content="2")
  }
}

///|
test "set_row modifies correct row" {
  let grid = make_flat_grid(4, 3, 0)
  set_row(grid, 4, 1, [1, 2, 3, 4])
  inspect(grid[4], content="1")
  inspect(grid[5], content="2")
  inspect(grid[6], content="3")
  inspect(grid[7], content="4")
  // Other rows unchanged
  inspect(grid[0], content="0")
  inspect(grid[8], content="0")
}
