///|
test "vec2i creates correct struct" {
  let v = vec2i(3, 7)
  inspect(v.x, content="3")
  inspect(v.y, content="7")
}

///|
test "make_grid creates grid with correct dimensions" {
  let tiles : Array[TileKind] = [Empty, Road, Water, Empty]
  let g = make_grid(2, 2, tiles)
  inspect(g.width, content="2")
  inspect(g.height, content="2")
  inspect(g.tiles.length(), content="4")
}

///|
test "grid_get returns correct tile" {
  let tiles : Array[TileKind] = [Empty, Road, Water, House(0)]
  let g = make_grid(2, 2, tiles)
  inspect(grid_get(g, 0, 0), content="Empty")
  inspect(grid_get(g, 1, 0), content="Road")
  inspect(grid_get(g, 0, 1), content="Water")
  inspect(grid_get(g, 1, 1), content="House(0)")
}

///|
test "grid_get out of bounds returns Water" {
  let tiles : Array[TileKind] = [Empty]
  let g = make_grid(1, 1, tiles)
  inspect(grid_get(g, -1, 0), content="Water")
  inspect(grid_get(g, 1, 0), content="Water")
  inspect(grid_get(g, 0, -1), content="Water")
  inspect(grid_get(g, 0, 1), content="Water")
}

///|
test "grid_set modifies tile" {
  let tiles : Array[TileKind] = [Empty, Empty, Empty, Empty]
  let g = make_grid(2, 2, tiles)
  grid_set(g, 1, 0, Road)
  inspect(grid_get(g, 1, 0), content="Road")
  // Out of bounds set should be a no-op
  grid_set(g, -1, 0, Water)
  inspect(grid_get(g, 0, 0), content="Empty")
}

///|
test "make_fence creates fence edge" {
  let f = make_fence(2, 3, Horizontal)
  inspect(f.row, content="2")
  inspect(f.col, content="3")
  inspect(f.orient, content="Horizontal")
}

///|
test "fence_eq compares fences correctly" {
  let a = make_fence(1, 2, Horizontal)
  let b = make_fence(1, 2, Horizontal)
  let c = make_fence(1, 2, Vertical)
  let d = make_fence(1, 3, Horizontal)
  assert_true(fence_eq(a, b))
  assert_false(fence_eq(a, c))
  assert_false(fence_eq(a, d))
}

///|
test "has_fence finds existing fence" {
  let fences : Array[FenceEdge] = [
    make_fence(0, 0, Horizontal),
    make_fence(1, 2, Vertical),
  ]
  assert_true(has_fence(fences, make_fence(0, 0, Horizontal)))
  assert_true(has_fence(fences, make_fence(1, 2, Vertical)))
  assert_false(has_fence(fences, make_fence(0, 0, Vertical)))
  assert_false(has_fence(fences, make_fence(2, 2, Vertical)))
}

///|
test "toggle_fence adds when absent and removes when present" {
  let fences : Array[FenceEdge] = []
  let f = make_fence(1, 1, Horizontal)
  // Add
  toggle_fence(fences, f)
  inspect(fences.length(), content="1")
  assert_true(has_fence(fences, f))
  // Remove
  toggle_fence(fences, f)
  inspect(fences.length(), content="0")
  assert_false(has_fence(fences, f))
}

///|
test "copy_fences creates independent copy" {
  let fences : Array[FenceEdge] = [
    make_fence(0, 0, Horizontal),
    make_fence(1, 1, Vertical),
  ]
  let copied = copy_fences(fences)
  inspect(copied.length(), content="2")
  assert_true(fence_eq(copied[0], fences[0]))
  // Modifying original should not affect copy
  toggle_fence(fences, make_fence(0, 0, Horizontal))
  inspect(fences.length(), content="1")
  inspect(copied.length(), content="2")
}

///|
test "make_house creates house with correct fields" {
  let h = make_house(5, 3, 2, 4)
  inspect(h.pos.x, content="5")
  inspect(h.pos.y, content="3")
  inspect(h.color_id, content="2")
  inspect(h.required_area, content="4")
}

///|
test "make_constraint creates correct constraint" {
  let c1 = make_constraint(true, false)
  assert_true(c1.must_be_rectangular)
  assert_false(c1.must_not_touch_water)
  let c2 = make_constraint(false, true)
  assert_false(c2.must_be_rectangular)
  assert_true(c2.must_not_touch_water)
}

///|
test "is_region_rectangular detects rectangles" {
  // 2x2 rectangle
  let r1 : Region = {
    tiles: [vec2i(0, 0), vec2i(1, 0), vec2i(0, 1), vec2i(1, 1)],
    houses: [],
    has_road: false,
    area: 4,
  }
  assert_true(is_region_rectangular(r1))
  // L-shape is not rectangular
  let r2 : Region = {
    tiles: [vec2i(0, 0), vec2i(1, 0), vec2i(0, 1)],
    houses: [],
    has_road: false,
    area: 3,
  }
  assert_false(is_region_rectangular(r2))
  // Empty region is rectangular
  let r3 : Region = { tiles: [], houses: [], has_road: false, area: 0, }
  assert_true(is_region_rectangular(r3))
}

///|
test "is_region_rectangular single tile" {
  let r : Region = {
    tiles: [vec2i(5, 5)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_true(is_region_rectangular(r))
}

///|
test "region_touches_water detects adjacent water" {
  // Grid with water at (1,0)
  let tiles : Array[TileKind] = [Empty, Water, Empty, Empty]
  let g = make_grid(2, 2, tiles)
  // Region at (0,0) is adjacent to water at (1,0)
  let r1 : Region = {
    tiles: [vec2i(0, 0)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_true(region_touches_water(r1, g))
  // Region at (1,1) is adjacent to water at (1,0)
  let r2 : Region = {
    tiles: [vec2i(1, 1)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_true(region_touches_water(r2, g))
}

///|
test "region_touches_water returns false when no adjacent water" {
  let tiles : Array[TileKind] = [Empty, Empty, Empty, Empty]
  let g = make_grid(2, 2, tiles)
  let r : Region = {
    tiles: [vec2i(0, 0)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_false(region_touches_water(r, g))
}

///|
test "tier_name returns correct names" {
  inspect(tier_name(Plots), content="Plots")
  inspect(tier_name(Districts), content="Districts")
  inspect(tier_name(Zoning), content="Zoning")
}

///|
test "tier_start_idx returns correct offsets" {
  inspect(tier_start_idx(Plots), content="0")
  inspect(tier_start_idx(Districts), content="8")
  inspect(tier_start_idx(Zoning), content="17")
}

///|
test "tier_level_count returns correct counts" {
  inspect(tier_level_count(Plots), content="8")
  inspect(tier_level_count(Districts), content="9")
  inspect(tier_level_count(Zoning), content="8")
}

///|
test "new_level_score has zero values" {
  let s = new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.fence_count, content="0")
}

///|
test "new_constraint_status has Unchecked values" {
  let cs = new_constraint_status(3)
  inspect(cs.house_idx, content="3")
  inspect(cs.one_house, content="Unchecked")
  inspect(cs.correct_area, content="Unchecked")
  inspect(cs.road_access, content="Unchecked")
  inspect(cs.shape_ok, content="Unchecked")
}

///|
test "new_game creates game with correct defaults" {
  let g = new_game()
  inspect(g.screen, content="Title")
  inspect(g.play_state, content="Drawing")
  inspect(g.current_tier, content="Plots")
  inspect(g.level_scores.length(), content="25")
  inspect(g.fences.length(), content="0")
}

///|
test "make_level creates level definition" {
  let tiles : Array[TileKind] = [Empty, Road, Empty, Empty]
  let g = make_grid(2, 2, tiles)
  let houses : Array[House] = [make_house(0, 0, 0, 2)]
  let c = make_constraint(true, false)
  let lev = make_level(g, houses, c, 5, 10, Plots, "Test")
  inspect(lev.par_fences, content="5")
  inspect(lev.par_length, content="10")
  inspect(lev.name, content="Test")
  inspect(lev.tier, content="Plots")
  inspect(lev.houses.length(), content="1")
}

///|
test "absf returns absolute value" {
  inspect(absf(5.0), content="5")
  inspect(absf(-3.0), content="3")
  inspect(absf(0.0), content="0")
}

///|
test "minf returns smaller float" {
  inspect(minf(2.0, 8.0), content="2")
  inspect(minf(9.0, 1.0), content="1")
}

///|
test "mini returns smaller int" {
  inspect(mini(3, 7), content="3")
  inspect(mini(10, 2), content="2")
}

///|
test "maxi returns larger int" {
  inspect(maxi(3, 7), content="7")
  inspect(maxi(10, 2), content="10")
}
