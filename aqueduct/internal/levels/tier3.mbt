///|
/// Create Tier 3 levels (6 levels): Dams, complex elevation, multiple springs.
pub fn create_tier3() -> Array[@types.Level] {
  [level_3_1(), level_3_2(), level_3_3(), level_3_4(), level_3_5(), level_3_6()]
}

///|
fn level_3_1() -> @types.Level {
  // Introduce dams: must route around blocked directions
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 2, [4, 3, 3, 2, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 3, [4, 3, 3, 2, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 4, [3, 3, 3, 2, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 5, [3, 3, 3, 2, 2, 1, 1, 1, 0, 0])
  {
    name: "Dam It",
    tier: Tier3,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 2, }],
    fountains: [{ x: 8, y: 5, }],
    reservoirs: [],
    dams: [({ x: 4, y: 2, }, East)],
    par_segments: 8,
  }
}

///|
fn level_3_2() -> @types.Level {
  // Two springs converge
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 1, [4, 3, 3, 2, 2, 1, 1, 1, 0, 0])
  set_row(elevations, 10, 2, [3, 3, 3, 2, 2, 1, 1, 1, 0, 0])
  set_row(elevations, 10, 3, [2, 2, 2, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 4, [2, 2, 2, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 5, [3, 3, 3, 2, 2, 1, 1, 1, 0, 0])
  set_row(elevations, 10, 6, [4, 3, 3, 2, 2, 1, 1, 1, 0, 0])
  {
    name: "Convergence",
    tier: Tier3,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 1, }, { x: 0, y: 6, }],
    fountains: [{ x: 8, y: 1, }, { x: 8, y: 6, }],
    reservoirs: [],
    dams: [],
    par_segments: 12,
  }
}

///|
fn level_3_3() -> @types.Level {
  // Dam + reservoir combo
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 1, [4, 4, 3, 3, 2, 2, 2, 1, 1, 1])
  set_row(elevations, 10, 2, [4, 3, 3, 3, 2, 2, 2, 1, 1, 0])
  set_row(elevations, 10, 3, [3, 3, 3, 3, 2, 2, 2, 1, 1, 0])
  set_row(elevations, 10, 4, [3, 3, 2, 2, 2, 2, 2, 1, 1, 0])
  set_row(elevations, 10, 5, [2, 2, 2, 2, 2, 2, 2, 1, 1, 1])
  set_row(elevations, 10, 6, [2, 2, 2, 2, 1, 1, 1, 1, 0, 0])
  {
    name: "Blocked Basin",
    tier: Tier3,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 1, }],
    fountains: [{ x: 9, y: 2, }, { x: 9, y: 4, }, { x: 8, y: 6, }],
    reservoirs: [{ x: 5, y: 3, }],
    dams: [({ x: 3, y: 2, }, South), ({ x: 7, y: 5, }, East)],
    par_segments: 14,
  }
}

///|
fn level_3_4() -> @types.Level {
  // Multiple springs, multiple dams
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 0, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 1, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 2, [3, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 3, [3, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 4, [3, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 5, [3, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 6, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 7, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  {
    name: "Dual Source Maze",
    tier: Tier3,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 0, }, { x: 0, y: 7, }],
    fountains: [
      { x: 7, y: 0, },
      { x: 7, y: 7, },
      { x: 9, y: 3, },
      { x: 9, y: 4, },
    ],
    reservoirs: [{ x: 4, y: 3, }],
    dams: [({ x: 3, y: 1, }, South), ({ x: 3, y: 6, }, North)],
    par_segments: 18,
  }
}

///|
fn level_3_5() -> @types.Level {
  // Complex terrain with ridges
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 0, [4, 4, 3, 2, 4, 3, 2, 1, 0, 0])
  set_row(elevations, 10, 1, [4, 3, 3, 2, 3, 3, 2, 1, 0, 0])
  set_row(elevations, 10, 2, [3, 3, 2, 2, 2, 2, 2, 1, 1, 1])
  set_row(elevations, 10, 3, [3, 3, 2, 1, 1, 1, 2, 1, 1, 1])
  set_row(elevations, 10, 4, [3, 3, 2, 1, 1, 1, 2, 1, 1, 1])
  set_row(elevations, 10, 5, [3, 3, 2, 2, 2, 2, 2, 1, 1, 1])
  set_row(elevations, 10, 6, [4, 3, 3, 2, 3, 3, 2, 1, 0, 0])
  set_row(elevations, 10, 7, [4, 4, 3, 2, 4, 3, 2, 1, 0, 0])
  {
    name: "Ridge Runner",
    tier: Tier3,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 0, }, { x: 0, y: 7, }],
    fountains: [
      { x: 8, y: 0, },
      { x: 8, y: 7, },
      { x: 4, y: 3, },
      { x: 4, y: 4, },
    ],
    reservoirs: [{ x: 2, y: 3, }, { x: 6, y: 3, }],
    dams: [({ x: 3, y: 0, }, South), ({ x: 3, y: 7, }, North)],
    par_segments: 18,
  }
}

///|
fn level_3_6() -> @types.Level {
  // Grand finale: three springs, complex routing
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 0, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 1, [3, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 2, [3, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 3, [4, 3, 3, 2, 2, 1, 1, 1, 0, 0])
  set_row(elevations, 10, 4, [4, 3, 3, 2, 2, 1, 1, 1, 0, 0])
  set_row(elevations, 10, 5, [3, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  set_row(elevations, 10, 6, [3, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 7, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  {
    name: "Grand Aqueduct",
    tier: Tier3,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 0, }, { x: 0, y: 3, }, { x: 0, y: 7, }],
    fountains: [
      { x: 8, y: 0, },
      { x: 8, y: 3, },
      { x: 8, y: 4, },
      { x: 8, y: 7, },
      { x: 7, y: 1, },
    ],
    reservoirs: [{ x: 4, y: 2, }, { x: 4, y: 5, }],
    dams: [
      ({ x: 2, y: 1, }, South),
      ({ x: 2, y: 6, }, North),
      ({ x: 6, y: 3, }, South),
    ],
    par_segments: 22,
  }
}
