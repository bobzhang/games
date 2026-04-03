///|
/// Create Tier 1 levels (7 levels): Simple downhill routing.
pub fn create_tier1() -> Array[@types.Level] {
  [
    level_1_1(),
    level_1_2(),
    level_1_3(),
    level_1_4(),
    level_1_5(),
    level_1_6(),
    level_1_7(),
  ]
}

///|
fn level_1_1() -> @types.Level {
  // Simple 3-tile straight line downhill
  // S . F
  // 4 3 2  (elevations, row 0 only active)
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 3, [4, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  {
    name: "First Flow",
    tier: Tier1,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 3 }],
    fountains: [{ x: 4, y: 3 }],
    reservoirs: [],
    dams: [],
    par_segments: 3,
  }
}

///|
fn level_1_2() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 2, [3, 3, 3, 2, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 3, [4, 3, 3, 2, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 4, [3, 3, 3, 2, 2, 2, 1, 1, 1, 1])
  {
    name: "Gentle Slope",
    tier: Tier1,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 3 }],
    fountains: [{ x: 8, y: 3 }],
    reservoirs: [],
    dams: [],
    par_segments: 7,
  }
}

///|
fn level_1_3() -> @types.Level {
  // L-shaped path
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 2, [4, 3, 3, 2, 1, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 3, [3, 3, 3, 2, 1, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 4, [3, 3, 3, 2, 1, 0, 0, 0, 0, 0])
  set_row(elevations, 10, 5, [3, 3, 3, 2, 1, 0, 0, 0, 0, 0])
  {
    name: "The Bend",
    tier: Tier1,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 2 }],
    fountains: [{ x: 4, y: 5 }],
    reservoirs: [],
    dams: [],
    par_segments: 5,
  }
}

///|
fn level_1_4() -> @types.Level {
  // Two fountains, one spring
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 2, [3, 3, 3, 2, 2, 1, 0, 0, 0, 0])
  set_row(elevations, 10, 3, [4, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 4, [3, 3, 3, 2, 2, 1, 0, 0, 0, 0])
  {
    name: "Twin Oasis",
    tier: Tier1,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 3 }],
    fountains: [{ x: 6, y: 2 }, { x: 6, y: 4 }],
    reservoirs: [],
    dams: [],
    par_segments: 9,
  }
}

///|
fn level_1_5() -> @types.Level {
  // Zigzag path required
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 1, [4, 4, 3, 3, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 2, [4, 4, 3, 3, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 3, [3, 3, 3, 3, 3, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 4, [2, 2, 2, 2, 3, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 5, [2, 2, 2, 2, 2, 2, 1, 0, 0, 0])
  set_row(elevations, 10, 6, [1, 1, 1, 1, 1, 1, 1, 0, 0, 0])
  {
    name: "Zigzag Falls",
    tier: Tier1,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 1 }],
    fountains: [{ x: 7, y: 6 }],
    reservoirs: [],
    dams: [],
    par_segments: 8,
  }
}

///|
fn level_1_6() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 1, [3, 3, 3, 3, 3, 2, 2, 2, 2, 2])
  set_row(elevations, 10, 2, [4, 3, 3, 3, 3, 2, 2, 2, 2, 2])
  set_row(elevations, 10, 3, [3, 3, 2, 2, 2, 2, 1, 1, 1, 0])
  set_row(elevations, 10, 4, [3, 3, 2, 2, 2, 2, 1, 1, 1, 0])
  set_row(elevations, 10, 5, [2, 2, 2, 2, 2, 2, 1, 1, 1, 1])
  {
    name: "Wide Valley",
    tier: Tier1,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 2 }],
    fountains: [{ x: 9, y: 3 }, { x: 9, y: 4 }],
    reservoirs: [],
    dams: [],
    par_segments: 10,
  }
}

///|
fn level_1_7() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 0, [4, 4, 3, 3, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 1, [4, 4, 3, 3, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 2, [3, 3, 3, 3, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 3, [3, 3, 3, 3, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 4, [2, 2, 2, 2, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 5, [2, 2, 2, 2, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 6, [1, 1, 1, 1, 1, 1, 1, 1, 0, 0])
  set_row(elevations, 10, 7, [1, 1, 1, 1, 1, 1, 0, 0, 0, 0])
  {
    name: "Cascade",
    tier: Tier1,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 0 }],
    fountains: [{ x: 9, y: 0 }, { x: 9, y: 5 }, { x: 7, y: 7 }],
    reservoirs: [],
    dams: [],
    par_segments: 14,
  }
}
