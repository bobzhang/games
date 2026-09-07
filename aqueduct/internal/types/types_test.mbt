///|
test "pos_to_index and index_to_pos round trip" {
  let pos : @types.Pos = { x: 3, y: 5, }
  let idx = @types.pos_to_index(pos, 10)
  inspect(idx, content="53")
  let back = @types.index_to_pos(idx, 10)
  inspect(back.x, content="3")
  inspect(back.y, content="5")
}

///|
test "in_bounds checks correctly" {
  inspect(@types.in_bounds({ x: 0, y: 0, }, 10, 8), content="true")
  inspect(@types.in_bounds({ x: 9, y: 7, }, 10, 8), content="true")
  inspect(@types.in_bounds({ x: 10, y: 0, }, 10, 8), content="false")
  inspect(@types.in_bounds({ x: 0, y: 8, }, 10, 8), content="false")
  inspect(@types.in_bounds({ x: -1, y: 0, }, 10, 8), content="false")
}

///|
test "neighbor computes correctly" {
  let p : @types.Pos = { x: 5, y: 3, }
  let n = @types.neighbor(p, North)
  inspect(n.x, content="5")
  inspect(n.y, content="2")
  let s = @types.neighbor(p, South)
  inspect(s.y, content="4")
  let e = @types.neighbor(p, East)
  inspect(e.x, content="6")
  let w = @types.neighbor(p, West)
  inspect(w.x, content="4")
}

///|
test "Direction::opposite" {
  inspect(@types.Direction::North.opposite(), content="South")
  inspect(@types.Direction::South.opposite(), content="North")
  inspect(@types.Direction::East.opposite(), content="West")
  inspect(@types.Direction::West.opposite(), content="East")
}

///|
test "Direction::dx and dy" {
  inspect(@types.Direction::East.dx(), content="1")
  inspect(@types.Direction::West.dx(), content="-1")
  inspect(@types.Direction::North.dx(), content="0")
  inspect(@types.Direction::North.dy(), content="-1")
  inspect(@types.Direction::South.dy(), content="1")
}

///|
test "new_tile creates empty tile" {
  let t = @types.new_tile(3)
  inspect(t.kind, content="Empty")
  inspect(t.elevation, content="3")
  inspect(t.has_water, content="false")
  inspect(t.connections.length(), content="0")
}

///|
test "init_grid sets up springs and fountains" {
  let level : @types.Level = {
    name: "test",
    tier: Tier1,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [3, 2, 1],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  @types.init_grid(game)
  inspect(game.grid[0].kind, content="Spring")
  inspect(game.grid[0].has_water, content="true")
  inspect(game.grid[2].kind, content="Fountain")
  inspect(game.grid[1].kind, content="Empty")
}

///|
test "can_place_at returns true for empty tiles only" {
  let level : @types.Level = {
    name: "test",
    tier: Tier1,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [3, 2, 1],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  @types.init_grid(game)
  inspect(@types.can_place_at(game, { x: 1, y: 0, }), content="true")
  inspect(@types.can_place_at(game, { x: 0, y: 0, }), content="false")
  inspect(@types.can_place_at(game, { x: 2, y: 0, }), content="false")
}

///|
test "tier_levels filters correctly" {
  let levels : Array[@types.Level] = [
    {
      name: "a",
      tier: Tier1,
      grid_cols: 1,
      grid_rows: 1,
      elevations: [0],
      springs: [{ x: 0, y: 0, }],
      fountains: [{ x: 0, y: 0, }],
      reservoirs: [],
      dams: [],
      par_segments: 0,
    },
    {
      name: "b",
      tier: Tier2,
      grid_cols: 1,
      grid_rows: 1,
      elevations: [0],
      springs: [{ x: 0, y: 0, }],
      fountains: [{ x: 0, y: 0, }],
      reservoirs: [],
      dams: [],
      par_segments: 0,
    },
    {
      name: "c",
      tier: Tier1,
      grid_cols: 1,
      grid_rows: 1,
      elevations: [0],
      springs: [{ x: 0, y: 0, }],
      fountains: [{ x: 0, y: 0, }],
      reservoirs: [],
      dams: [],
      par_segments: 0,
    },
  ]
  let t1 = @types.tier_levels(levels, Tier1)
  inspect(t1.length(), content="2")
  inspect(t1[0], content="0")
  inspect(t1[1], content="2")
  let t2 = @types.tier_levels(levels, Tier2)
  inspect(t2.length(), content="1")
  inspect(t2[0], content="1")
}

///|
test "screen_to_grid maps correctly" {
  // grid_offset_x=40, grid_offset_y=80, cell_size=64
  let result = @types.screen_to_grid(40, 80)
  debug_inspect(
    result,
    content=(
      #|Some({ x: 0, y: 0 })
    ),
  )
  let result2 = @types.screen_to_grid(40 + 64, 80 + 64)
  debug_inspect(
    result2,
    content=(
      #|Some({ x: 1, y: 1 })
    ),
  )
  // Outside grid
  let result3 = @types.screen_to_grid(0, 0)
  debug_inspect(result3, content="None")
}

///|
test "grid_to_screen maps correctly" {
  let (sx, sy) = @types.grid_to_screen({ x: 0, y: 0, })
  inspect(sx, content="40")
  inspect(sy, content="80")
  let (sx2, sy2) = @types.grid_to_screen({ x: 1, y: 1, })
  inspect(sx2, content="104")
  inspect(sy2, content="144")
}

///|
test "count_segments counts aqueducts" {
  let level : @types.Level = {
    name: "test",
    tier: Tier1,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [3, 2, 1],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  @types.init_grid(game)
  inspect(@types.count_segments(game), content="0")
  game.grid[1].kind = Aqueduct
  inspect(@types.count_segments(game), content="1")
}
