///|
/// Get level definition by index (0-19)
pub fn get_level(id : Int) -> @types.LevelDef {
  match id {
    0 => level_01()
    1 => level_02()
    2 => level_03()
    3 => level_04()
    4 => level_05()
    5 => level_06()
    6 => level_07()
    7 => level_08()
    8 => level_09()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    _ => level_01()
  }
}

///|
/// Get tier name for a level
pub fn get_tier_name(id : Int) -> String {
  if id < @types.tier1_count {
    "Foundations"
  } else if id < @types.tier1_count + @types.tier2_count {
    "Generators"
  } else {
    "Power Grid"
  }
}

///|
/// Get tier for a level
pub fn get_tier(id : Int) -> @types.Tier {
  if id < @types.tier1_count {
    Foundations
  } else if id < @types.tier1_count + @types.tier2_count {
    Generators
  } else {
    PowerGrid
  }
}

///|
/// Load a level into playable state
pub fn load_level(id : Int) -> @types.LevelState {
  let def = get_level(id)
  let state = @types.new_level_state(def.magnet_budget, def.coil_budget, def.par_magnets)
  // Place fixed components
  for i in 0..<def.fixed_cells.length() {
    let p = def.fixed_cells[i]
    let cell = state.cells[p.row][p.col]
    cell.component = p.component
    cell.fixed = true
    for j in 0..<p.connections.length() {
      if j < 4 {
        cell.connections[j] = p.connections[j]
      }
    }
  }
  // Auto-connect fixed cells
  for i in 0..<def.fixed_cells.length() {
    let p = def.fixed_cells[i]
    let dirs = @types.all_directions()
    for d in 0..<dirs.length() {
      let di = @types.direction_index(dirs[d])
      if p.connections[di] {
        let (dc, dr) = @types.direction_delta(dirs[d])
        let nc = p.col + dc
        let nr = p.row + dr
        if @types.in_bounds(nc, nr) {
          let neighbor = state.cells[nr][nc]
          let opp = @types.opposite_direction(dirs[d])
          let oi = @types.direction_index(opp)
          if @types.is_connectable(neighbor.component) {
            neighbor.connections[oi] = true
          }
        }
      }
    }
  }
  // Count devices
  let mut dev_count = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      match state.cells[r][c].component {
        Device(_) => dev_count += 1
        _ => ()
      }
    }
  }
  state.devices_total = dev_count
  state
}

// ============================================================
// TIER 1: FOUNDATIONS (Levels 1-7) - Basic magnet-coil interaction
// ============================================================

///|
fn level_01() -> @types.LevelDef {
  {
    id: 0,
    name: "First Spark",
    tier: Foundations,
    description: "Place a magnet next to the coil to power the lamp.",
    magnet_budget: 1,
    coil_budget: 0,
    par_magnets: 1,
    fixed_cells: [
      { col: 4, row: 2, component: Coil, connections: [false, false, false, true] },
      {
        col: 5,
        row: 2,
        component: Wire,
        connections: [false, false, true, true],
      },
      {
        col: 6,
        row: 2,
        component: Device(1.5),
        connections: [false, false, true, false],
      },
    ],
  }
}

///|
fn level_02() -> @types.LevelDef {
  {
    id: 1,
    name: "Double Flux",
    tier: Foundations,
    description: "Two magnets flanking a coil generate more power.",
    magnet_budget: 2,
    coil_budget: 0,
    par_magnets: 2,
    fixed_cells: [
      { col: 3, row: 2, component: Coil, connections: [false, false, false, true] },
      {
        col: 4,
        row: 2,
        component: Wire,
        connections: [false, false, true, true],
      },
      {
        col: 5,
        row: 2,
        component: Device(3.0),
        connections: [false, false, true, false],
      },
    ],
  }
}

///|
fn level_03() -> @types.LevelDef {
  {
    id: 2,
    name: "Long Reach",
    tier: Foundations,
    description: "Field lines travel far. Wire the coil to the lamp.",
    magnet_budget: 1,
    coil_budget: 1,
    par_magnets: 1,
    fixed_cells: [
      {
        col: 0,
        row: 3,
        component: Magnet(North),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 3,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_04() -> @types.LevelDef {
  {
    id: 3,
    name: "Pole Position",
    tier: Foundations,
    description: "North and South poles both emit field lines.",
    magnet_budget: 2,
    coil_budget: 1,
    par_magnets: 2,
    fixed_cells: [
      {
        col: 6,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_05() -> @types.LevelDef {
  {
    id: 4,
    name: "Corner Coil",
    tier: Foundations,
    description: "Route field lines around the corner.",
    magnet_budget: 2,
    coil_budget: 1,
    par_magnets: 2,
    fixed_cells: [
      {
        col: 0,
        row: 0,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_06() -> @types.LevelDef {
  {
    id: 5,
    name: "Power Boost",
    tier: Foundations,
    description: "Stack field lines on one coil for 4.5W.",
    magnet_budget: 3,
    coil_budget: 1,
    par_magnets: 3,
    fixed_cells: [
      {
        col: 7,
        row: 3,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_07() -> @types.LevelDef {
  {
    id: 6,
    name: "Full Charge",
    tier: Foundations,
    description: "Four magnets feed one coil for 6W.",
    magnet_budget: 4,
    coil_budget: 1,
    par_magnets: 4,
    fixed_cells: [
      {
        col: 7,
        row: 2,
        component: Device(6.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

// ============================================================
// TIER 2: GENERATORS (Levels 8-14) - Multiple coils and devices
// ============================================================

///|
fn level_08() -> @types.LevelDef {
  {
    id: 7,
    name: "Twin Turbines",
    tier: Generators,
    description: "Two coils, two lamps. Split your magnets.",
    magnet_budget: 2,
    coil_budget: 2,
    par_magnets: 2,
    fixed_cells: [
      {
        col: 7,
        row: 1,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 4,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_09() -> @types.LevelDef {
  {
    id: 8,
    name: "Power Split",
    tier: Generators,
    description: "Different devices need different wattage.",
    magnet_budget: 3,
    coil_budget: 2,
    par_magnets: 3,
    fixed_cells: [
      {
        col: 7,
        row: 1,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 4,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_10() -> @types.LevelDef {
  {
    id: 9,
    name: "Triple Output",
    tier: Generators,
    description: "Three lamps, all need 1.5W each.",
    magnet_budget: 3,
    coil_budget: 3,
    par_magnets: 3,
    fixed_cells: [
      {
        col: 7,
        row: 0,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 4,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_11() -> @types.LevelDef {
  {
    id: 10,
    name: "Wattage Ladder",
    tier: Generators,
    description: "Devices need 1.5W, 3W, and 4.5W.",
    magnet_budget: 5,
    coil_budget: 3,
    par_magnets: 4,
    fixed_cells: [
      {
        col: 7,
        row: 0,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 4,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_12() -> @types.LevelDef {
  {
    id: 11,
    name: "Field Maze",
    tier: Generators,
    description: "Navigate magnets through obstacles.",
    magnet_budget: 4,
    coil_budget: 2,
    par_magnets: 3,
    fixed_cells: [
      {
        col: 0,
        row: 0,
        component: Magnet(North),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 1,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 4,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_13() -> @types.LevelDef {
  {
    id: 12,
    name: "Generator Grid",
    tier: Generators,
    description: "Four devices in a grid need power.",
    magnet_budget: 5,
    coil_budget: 4,
    par_magnets: 4,
    fixed_cells: [
      {
        col: 5,
        row: 0,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 0,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 5,
        row: 5,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 5,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_14() -> @types.LevelDef {
  {
    id: 13,
    name: "Shared Fields",
    tier: Generators,
    description: "One magnet can feed multiple coils.",
    magnet_budget: 3,
    coil_budget: 3,
    par_magnets: 2,
    fixed_cells: [
      {
        col: 6,
        row: 0,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 2,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 5,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

// ============================================================
// TIER 3: POWER GRID (Levels 15-20) - Complex multi-network puzzles
// ============================================================

///|
fn level_15() -> @types.LevelDef {
  {
    id: 14,
    name: "Dual Networks",
    tier: PowerGrid,
    description: "Two separate power networks needed.",
    magnet_budget: 4,
    coil_budget: 2,
    par_magnets: 4,
    fixed_cells: [
      {
        col: 3,
        row: 0,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 3,
        row: 5,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_16() -> @types.LevelDef {
  {
    id: 15,
    name: "Power Plant",
    tier: PowerGrid,
    description: "Five devices across two networks.",
    magnet_budget: 6,
    coil_budget: 4,
    par_magnets: 5,
    fixed_cells: [
      {
        col: 5,
        row: 0,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 1,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 5,
        row: 2,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 3,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 5,
        row: 4,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_17() -> @types.LevelDef {
  {
    id: 16,
    name: "Mega Generator",
    tier: PowerGrid,
    description: "High-wattage devices need many field lines.",
    magnet_budget: 7,
    coil_budget: 3,
    par_magnets: 6,
    fixed_cells: [
      {
        col: 7,
        row: 0,
        component: Device(6.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 5,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_18() -> @types.LevelDef {
  {
    id: 17,
    name: "Grid Overload",
    tier: PowerGrid,
    description: "Six devices on a tight budget.",
    magnet_budget: 6,
    coil_budget: 4,
    par_magnets: 5,
    fixed_cells: [
      {
        col: 6,
        row: 0,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 0,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 2,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 4,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 4,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_19() -> @types.LevelDef {
  {
    id: 18,
    name: "Dynamo Core",
    tier: PowerGrid,
    description: "High power: 9W device demands four field lines.",
    magnet_budget: 8,
    coil_budget: 3,
    par_magnets: 6,
    fixed_cells: [
      {
        col: 6,
        row: 0,
        component: Device(6.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 4,
        component: Device(9.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_20() -> @types.LevelDef {
  {
    id: 19,
    name: "Master Dynamo",
    tier: PowerGrid,
    description: "The ultimate electromagnetic challenge.",
    magnet_budget: 10,
    coil_budget: 5,
    par_magnets: 8,
    fixed_cells: [
      {
        col: 5,
        row: 0,
        component: Device(6.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 0,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
      {
        col: 5,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 3,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 5,
        row: 4,
        component: Device(9.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 5,
        component: Device(7.5),
        connections: [false, false, false, false],
      },
    ],
  }
}
