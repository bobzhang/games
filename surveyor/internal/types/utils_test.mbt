///|
test "vec2i creates correct struct" {
  let v = @types.vec2i(3, 7)
  inspect(v.x, content="3")
  inspect(v.y, content="7")
}

///|
test "make_grid creates grid with correct dimensions" {
  let tiles : Array[@types.TileKind] = [Empty, Road, Water, Empty]
  let g = @types.make_grid(2, 2, tiles)
  inspect(g.width, content="2")
  inspect(g.height, content="2")
  inspect(g.tiles.length(), content="4")
}

///|
test "grid_get returns correct tile" {
  let tiles : Array[@types.TileKind] = [Empty, Road, Water, House(0)]
  let g = @types.make_grid(2, 2, tiles)
  inspect(@types.grid_get(g, 0, 0), content="Empty")
  inspect(@types.grid_get(g, 1, 0), content="Road")
  inspect(@types.grid_get(g, 0, 1), content="Water")
  inspect(@types.grid_get(g, 1, 1), content="House(0)")
}

///|
test "grid_get out of bounds returns Water" {
  let tiles : Array[@types.TileKind] = [Empty]
  let g = @types.make_grid(1, 1, tiles)
  inspect(@types.grid_get(g, -1, 0), content="Water")
  inspect(@types.grid_get(g, 1, 0), content="Water")
  inspect(@types.grid_get(g, 0, -1), content="Water")
  inspect(@types.grid_get(g, 0, 1), content="Water")
}

///|
test "grid_set modifies tile" {
  let tiles : Array[@types.TileKind] = [Empty, Empty, Empty, Empty]
  let g = @types.make_grid(2, 2, tiles)
  @types.grid_set(g, 1, 0, Road)
  inspect(@types.grid_get(g, 1, 0), content="Road")
  // Out of bounds set should be a no-op
  @types.grid_set(g, -1, 0, Water)
  inspect(@types.grid_get(g, 0, 0), content="Empty")
}

///|
test "make_fence creates fence edge" {
  let f = @types.make_fence(2, 3, Horizontal)
  inspect(f.row, content="2")
  inspect(f.col, content="3")
  inspect(f.orient, content="Horizontal")
}

///|
test "fence_eq compares fences correctly" {
  let a = @types.make_fence(1, 2, Horizontal)
  let b = @types.make_fence(1, 2, Horizontal)
  let c = @types.make_fence(1, 2, Vertical)
  let d = @types.make_fence(1, 3, Horizontal)
  assert_true(@types.fence_eq(a, b))
  assert_false(@types.fence_eq(a, c))
  assert_false(@types.fence_eq(a, d))
}

///|
test "has_fence finds existing fence" {
  let fences : Array[@types.FenceEdge] = [
    @types.make_fence(0, 0, Horizontal),
    @types.make_fence(1, 2, Vertical),
  ]
  assert_true(@types.has_fence(fences, @types.make_fence(0, 0, Horizontal)))
  assert_true(@types.has_fence(fences, @types.make_fence(1, 2, Vertical)))
  assert_false(@types.has_fence(fences, @types.make_fence(0, 0, Vertical)))
  assert_false(@types.has_fence(fences, @types.make_fence(2, 2, Vertical)))
}

///|
test "toggle_fence adds when absent and removes when present" {
  let fences : Array[@types.FenceEdge] = []
  let f = @types.make_fence(1, 1, Horizontal)
  // Add
  @types.toggle_fence(fences, f)
  inspect(fences.length(), content="1")
  assert_true(@types.has_fence(fences, f))
  // Remove
  @types.toggle_fence(fences, f)
  inspect(fences.length(), content="0")
  assert_false(@types.has_fence(fences, f))
}

///|
test "copy_fences creates independent copy" {
  let fences : Array[@types.FenceEdge] = [
    @types.make_fence(0, 0, Horizontal),
    @types.make_fence(1, 1, Vertical),
  ]
  let copied = @types.copy_fences(fences)
  inspect(copied.length(), content="2")
  assert_true(@types.fence_eq(copied[0], fences[0]))
  // Modifying original should not affect copy
  @types.toggle_fence(fences, @types.make_fence(0, 0, Horizontal))
  inspect(fences.length(), content="1")
  inspect(copied.length(), content="2")
}

///|
test "make_house creates house with correct fields" {
  let h = @types.make_house(5, 3, 2, 4)
  inspect(h.pos.x, content="5")
  inspect(h.pos.y, content="3")
  inspect(h.color_id, content="2")
  inspect(h.required_area, content="4")
}

///|
test "make_constraint creates correct constraint" {
  let c1 = @types.make_constraint(true, false)
  assert_true(c1.must_be_rectangular)
  assert_false(c1.must_not_touch_water)
  let c2 = @types.make_constraint(false, true)
  assert_false(c2.must_be_rectangular)
  assert_true(c2.must_not_touch_water)
}

///|
test "is_region_rectangular detects rectangles" {
  // 2x2 rectangle
  let r1 : @types.Region = {
    tiles: [
      @types.vec2i(0, 0),
      @types.vec2i(1, 0),
      @types.vec2i(0, 1),
      @types.vec2i(1, 1),
    ],
    houses: [],
    has_road: false,
    area: 4,
  }
  assert_true(@types.is_region_rectangular(r1))
  // L-shape is not rectangular
  let r2 : @types.Region = {
    tiles: [@types.vec2i(0, 0), @types.vec2i(1, 0), @types.vec2i(0, 1)],
    houses: [],
    has_road: false,
    area: 3,
  }
  assert_false(@types.is_region_rectangular(r2))
  // Empty region is rectangular
  let r3 : @types.Region = { tiles: [], houses: [], has_road: false, area: 0, }
  assert_true(@types.is_region_rectangular(r3))
}

///|
test "is_region_rectangular single tile" {
  let r : @types.Region = {
    tiles: [@types.vec2i(5, 5)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_true(@types.is_region_rectangular(r))
}

///|
test "region_touches_water detects adjacent water" {
  // Grid with water at (1,0)
  let tiles : Array[@types.TileKind] = [Empty, Water, Empty, Empty]
  let g = @types.make_grid(2, 2, tiles)
  // Region at (0,0) is adjacent to water at (1,0)
  let r1 : @types.Region = {
    tiles: [@types.vec2i(0, 0)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_true(@types.region_touches_water(r1, g))
  // Region at (1,1) is adjacent to water at (1,0)
  let r2 : @types.Region = {
    tiles: [@types.vec2i(1, 1)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_true(@types.region_touches_water(r2, g))
}

///|
test "region_touches_water returns false when no adjacent water" {
  let tiles : Array[@types.TileKind] = [Empty, Empty, Empty, Empty]
  let g = @types.make_grid(2, 2, tiles)
  let r : @types.Region = {
    tiles: [@types.vec2i(0, 0)],
    houses: [],
    has_road: false,
    area: 1,
  }
  assert_false(@types.region_touches_water(r, g))
}

///|
test "tier_name returns correct names" {
  inspect(@types.tier_name(Plots), content="Plots")
  inspect(@types.tier_name(Districts), content="Districts")
  inspect(@types.tier_name(Zoning), content="Zoning")
}

///|
test "tier_start_idx returns correct offsets" {
  inspect(@types.tier_start_idx(Plots), content="0")
  inspect(@types.tier_start_idx(Districts), content="8")
  inspect(@types.tier_start_idx(Zoning), content="17")
}

///|
test "tier_level_count returns correct counts" {
  inspect(@types.tier_level_count(Plots), content="8")
  inspect(@types.tier_level_count(Districts), content="9")
  inspect(@types.tier_level_count(Zoning), content="8")
}

///|
test "new_level_score has zero values" {
  let s = @types.new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.fence_count, content="0")
}

///|
test "new_constraint_status has Unchecked values" {
  let cs = @types.new_constraint_status(3)
  inspect(cs.house_idx, content="3")
  inspect(cs.one_house, content="Unchecked")
  inspect(cs.correct_area, content="Unchecked")
  inspect(cs.road_access, content="Unchecked")
  inspect(cs.shape_ok, content="Unchecked")
}

///|
test "new_game creates game with correct defaults" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.play_state, content="Drawing")
  inspect(g.current_tier, content="Plots")
  inspect(g.level_scores.length(), content="25")
  inspect(g.fences.length(), content="0")
}

///|
test "make_level creates level definition" {
  let tiles : Array[@types.TileKind] = [Empty, Road, Empty, Empty]
  let g = @types.make_grid(2, 2, tiles)
  let houses : Array[@types.House] = [@types.make_house(0, 0, 0, 2)]
  let c = @types.make_constraint(true, false)
  let lev = @types.make_level(g, houses, c, 5, 10, Plots, "Test")
  inspect(lev.par_fences, content="5")
  inspect(lev.par_length, content="10")
  inspect(lev.name, content="Test")
  inspect(lev.tier, content="Plots")
  inspect(lev.houses.length(), content="1")
}

///|
test "absf returns absolute value" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-3.0), content="3")
  inspect(@types.absf(0.0), content="0")
}

///|
test "minf returns smaller float" {
  inspect(@types.minf(2.0, 8.0), content="2")
  inspect(@types.minf(9.0, 1.0), content="1")
}

///|
test "mini returns smaller int" {
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.mini(10, 2), content="2")
}

///|
test "maxi returns larger int" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.maxi(10, 2), content="10")
}
