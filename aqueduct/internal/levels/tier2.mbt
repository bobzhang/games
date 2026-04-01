///|
/// Create Tier 2 levels (7 levels): Reservoirs and branching paths.
pub fn create_tier2() -> Array[@types.Level] {
  [level_2_1(), level_2_2(), level_2_3(), level_2_4(), level_2_5(), level_2_6(), level_2_7()]
}

///|
fn level_2_1() -> @types.Level {
  // Introduce reservoir: water must fill it before continuing
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 3, [4, 3, 3, 2, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 4, [3, 3, 3, 2, 2, 2, 1, 1, 1, 1])
  {
    name: "First Basin",
    tier: Tier2,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 3 }],
    fountains: [{ x: 8, y: 3 }],
    reservoirs: [{ x: 4, y: 3 }],
    dams: [],
    par_segments: 5,
  }
}

///|
fn level_2_2() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 2, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 3, [4, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 4, [3, 3, 3, 2, 2, 1, 1, 0, 0, 0])
  set_row(elevations, 10, 5, [3, 3, 3, 2, 2, 1, 1, 1, 1, 1])
  {
    name: "Split Stream",
    tier: Tier2,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 2 }],
    fountains: [{ x: 7, y: 2 }, { x: 7, y: 4 }],
    reservoirs: [{ x: 4, y: 3 }],
    dams: [],
    par_segments: 10,
  }
}

///|
fn level_2_3() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 1, [4, 4, 3, 3, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 2, [4, 3, 3, 3, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 3, [3, 3, 3, 2, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 4, [3, 3, 2, 2, 2, 2, 2, 1, 1, 1])
  set_row(elevations, 10, 5, [2, 2, 2, 2, 2, 2, 2, 1, 0, 0])
  set_row(elevations, 10, 6, [2, 2, 2, 2, 1, 1, 1, 1, 0, 0])
  {
    name: "Mountain Spring",
    tier: Tier2,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 1 }],
    fountains: [{ x: 8, y: 1 }, { x: 8, y: 6 }],
    reservoirs: [{ x: 4, y: 3 }],
    dams: [],
    par_segments: 12,
  }
}

///|
fn level_2_4() -> @types.Level {
  // Two reservoirs in sequence
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 3, [4, 4, 3, 3, 2, 2, 2, 1, 1, 0])
  set_row(elevations, 10, 4, [4, 3, 3, 3, 2, 2, 2, 1, 1, 0])
  {
    name: "Dual Basins",
    tier: Tier2,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 3 }],
    fountains: [{ x: 9, y: 3 }],
    reservoirs: [{ x: 3, y: 3 }, { x: 6, y: 3 }],
    dams: [],
    par_segments: 5,
  }
}

///|
fn level_2_5() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 0)
  set_row(elevations, 10, 1, [3, 3, 3, 2, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 2, [4, 3, 3, 2, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 3, [3, 3, 3, 3, 2, 2, 1, 1, 0, 0])
  set_row(elevations, 10, 4, [3, 3, 3, 3, 2, 2, 1, 1, 1, 1])
  set_row(elevations, 10, 5, [2, 2, 2, 2, 2, 2, 2, 1, 0, 0])
  set_row(elevations, 10, 6, [2, 2, 2, 2, 2, 2, 2, 1, 0, 0])
  {
    name: "Triple Fork",
    tier: Tier2,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 2 }],
    fountains: [{ x: 8, y: 2 }, { x: 8, y: 5 }, { x: 8, y: 6 }],
    reservoirs: [{ x: 5, y: 3 }],
    dams: [],
    par_segments: 14,
  }
}

///|
fn level_2_6() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 1)
  set_row(elevations, 10, 1, [3, 3, 3, 3, 2, 2, 2, 2, 1, 1])
  set_row(elevations, 10, 2, [4, 3, 3, 3, 2, 2, 2, 2, 1, 1])
  set_row(elevations, 10, 3, [3, 3, 3, 3, 2, 2, 2, 2, 1, 0])
  set_row(elevations, 10, 4, [3, 3, 3, 3, 2, 2, 2, 1, 1, 0])
  set_row(elevations, 10, 5, [2, 2, 2, 2, 2, 2, 2, 1, 1, 1])
  set_row(elevations, 10, 6, [2, 2, 2, 2, 2, 1, 1, 1, 0, 0])
  {
    name: "Reservoir Chain",
    tier: Tier2,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 2 }],
    fountains: [{ x: 9, y: 3 }, { x: 9, y: 4 }, { x: 8, y: 6 }],
    reservoirs: [{ x: 4, y: 2 }, { x: 7, y: 4 }],
    dams: [],
    par_segments: 14,
  }
}

///|
fn level_2_7() -> @types.Level {
  let elevations = make_flat_grid(10, 8, 0)
  for y in 0..<8 {
    for x in 0..<10 {
      let e = 4 - (x + y) / 4
      let elev = if e >= 0 { e } else { 0 }
      elevations[y * 10 + x] = elev
    }
  }
  {
    name: "Branching Delta",
    tier: Tier2,
    grid_cols: 10,
    grid_rows: 8,
    elevations,
    springs: [{ x: 0, y: 0 }],
    fountains: [{ x: 9, y: 5 }, { x: 9, y: 6 }, { x: 9, y: 7 }, { x: 7, y: 7 }],
    reservoirs: [{ x: 3, y: 3 }, { x: 6, y: 5 }],
    dams: [],
    par_segments: 16,
  }
}
