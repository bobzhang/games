///|
test "make_ocean_grid_dimensions" {
  let grid = @levels.make_ocean_grid()
  inspect(grid.length(), content="10")
  inspect(grid[0].length(), content="12")
}

///|
test "make_ocean_grid_all_ocean" {
  let grid = @levels.make_ocean_grid()
  let mut all_ocean = true
  for row in grid {
    for tile in row {
      if !(tile is Ocean) {
        all_ocean = false
      }
    }
  }
  inspect(all_ocean, content="true")
}

///|
test "set_tile" {
  let grid = @levels.make_ocean_grid()
  @levels.set_tile(grid, 3, 5, Land)
  inspect(grid[5][3], content="Land")
  inspect(grid[0][0], content="Ocean")
}

///|
test "set_land_rect" {
  let grid = @levels.make_ocean_grid()
  @levels.set_land_rect(grid, 2, 3, 3, 2)
  inspect(grid[3][2], content="Land")
  inspect(grid[3][3], content="Land")
  inspect(grid[3][4], content="Land")
  inspect(grid[4][2], content="Land")
  inspect(grid[4][4], content="Land")
  inspect(grid[3][1], content="Ocean")
  inspect(grid[3][5], content="Ocean")
}

///|
test "count_landmarks" {
  let grid = @levels.make_ocean_grid()
  @levels.set_tile(grid, 1, 1, Landmark)
  @levels.set_tile(grid, 5, 5, Landmark)
  @levels.set_tile(grid, 3, 3, Land)
  inspect(@levels.count_landmarks(grid), content="2")
}

///|
test "get_level_1" {
  let lvl = @levels.get_level(0)
  inspect(lvl.tier, content="1")
  debug_inspect(
    lvl.start,
    content=(
      #|{ x: 1, y: 1 }
    ),
  )
  debug_inspect(
    lvl.lighthouse,
    content=(
      #|{ x: 10, y: 8 }
    ),
  )
  assert_true(lvl.landmark_count > 0)
  assert_true(lvl.par_steps > 0)
}

///|
test "get_level_tier_2" {
  let lvl = @levels.get_level(7)
  inspect(lvl.tier, content="2")
}

///|
test "get_level_tier_3" {
  let lvl = @levels.get_level(14)
  inspect(lvl.tier, content="3")
}

///|
test "get_level_out_of_range" {
  let lvl = @levels.get_level(99)
  inspect(lvl.tier, content="1")
}

///|
test "init_level_reveals_start" {
  let state = @levels.init_level(0)
  // Start is 1,1 so 3x3 around it should be revealed
  inspect(state.revealed[0][0], content="true")
  inspect(state.revealed[1][1], content="true")
  inspect(state.revealed[2][2], content="true")
  // Far corner should not be revealed
  inspect(state.revealed[9][11], content="false")
}

///|
test "init_level_ship_at_start" {
  let state = @levels.init_level(0)
  let lvl = @levels.get_level(0)
  inspect(state.ship.pos == lvl.start, content="true")
  inspect(state.ship.hp, content="3")
  inspect(state.ship.steps, content="0")
}

///|
test "reveal_area" {
  let revealed : Array[Array[Bool]] = []
  for _y in 0..<@types.grid_rows {
    revealed.push(Array::make(@types.grid_cols, false))
  }
  @levels.reveal_area(revealed, 5, 5)
  inspect(revealed[4][4], content="true")
  inspect(revealed[5][5], content="true")
  inspect(revealed[6][6], content="true")
  inspect(revealed[3][5], content="false")
}

///|
test "reveal_area_edge" {
  let revealed : Array[Array[Bool]] = []
  for _y in 0..<@types.grid_rows {
    revealed.push(Array::make(@types.grid_cols, false))
  }
  @levels.reveal_area(revealed, 0, 0)
  inspect(revealed[0][0], content="true")
  inspect(revealed[0][1], content="true")
  inspect(revealed[1][0], content="true")
  inspect(revealed[1][1], content="true")
}

///|
test "tier_name" {
  inspect(@levels.tier_name(1), content="Calm Seas")
  inspect(@levels.tier_name(2), content="Rough Waters")
  inspect(@levels.tier_name(3), content="Treacherous Depths")
  inspect(@levels.tier_name(4), content="Unknown")
}

///|
test "all_20_levels_valid" {
  for i in 0..<20 {
    let lvl = @levels.get_level(i)
    // Grid dimensions
    assert_true(lvl.grid.length() == @types.grid_rows)
    assert_true(lvl.grid[0].length() == @types.grid_cols)
    // Start is in bounds
    assert_true(@types.in_bounds(lvl.start.x, lvl.start.y))
    // Lighthouse is in bounds
    assert_true(@types.in_bounds(lvl.lighthouse.x, lvl.lighthouse.y))
    // Start tile is ocean (not blocked)
    assert_true(lvl.grid[lvl.start.y][lvl.start.x] is Ocean)
    // Lighthouse tile is lighthouse
    assert_true(lvl.grid[lvl.lighthouse.y][lvl.lighthouse.x] is Lighthouse)
    // Par steps > 0
    assert_true(lvl.par_steps > 0)
    // Tier valid
    assert_true(lvl.tier >= 1 && lvl.tier <= 3)
  }
}

///|
test "tier_distribution" {
  let mut t1 = 0
  let mut t2 = 0
  let mut t3 = 0
  for i in 0..<20 {
    let lvl = @levels.get_level(i)
    match lvl.tier {
      1 => t1 += 1
      2 => t2 += 1
      3 => t3 += 1
      _ => ()
    }
  }
  inspect(t1, content="7")
  inspect(t2, content="7")
  inspect(t3, content="6")
}
