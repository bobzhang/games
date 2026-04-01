///|
/// Get level definition by index (0-24)
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
    20 => level_21()
    21 => level_22()
    22 => level_23()
    23 => level_24()
    24 => level_25()
    _ => level_01()
  }
}

///|
/// Get tier name for a level
pub fn get_tier_name(id : Int) -> String {
  if id < @types.tier1_count {
    "Basics"
  } else if id < @types.tier1_count + @types.tier2_count {
    "Parallel"
  } else {
    "Networks"
  }
}

///|
/// Get tier for a level
pub fn get_tier(id : Int) -> @types.Tier {
  if id < @types.tier1_count {
    Basics
  } else if id < @types.tier1_count + @types.tier2_count {
    Parallel
  } else {
    Networks
  }
}

///|
/// Load a level into playable state
pub fn load_level(id : Int) -> @types.LevelState {
  let def = get_level(id)
  let state = @types.new_level_state(
    def.battery_budget,
    def.par_batteries,
    def.fuse_budget,
    def.switch_budget,
  )
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
// TIER 1: BASICS (Levels 1-8) - Series circuits, single devices
// ============================================================

///|
fn level_01() -> @types.LevelDef {
  {
    id: 0,
    name: "First Light",
    tier: Basics,
    description: "Connect one battery to power the bulb.",
    battery_budget: 1,
    par_batteries: 1,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 5,
        row: 2,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_02() -> @types.LevelDef {
  {
    id: 1,
    name: "Double Up",
    tier: Basics,
    description: "Use 2 batteries in series for 3V.",
    battery_budget: 2,
    par_batteries: 2,
    fuse_budget: 0,
    switch_budget: 0,
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
fn level_03() -> @types.LevelDef {
  {
    id: 2,
    name: "Long Wire",
    tier: Basics,
    description: "Bridge the gap with wires.",
    battery_budget: 1,
    par_batteries: 1,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 0,
        row: 3,
        component: Battery,
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
    name: "Triple Threat",
    tier: Basics,
    description: "Three batteries in series for 4.5V.",
    battery_budget: 3,
    par_batteries: 3,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 6,
        row: 3,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_05() -> @types.LevelDef {
  {
    id: 4,
    name: "Corner Route",
    tier: Basics,
    description: "Route power around the corner.",
    battery_budget: 2,
    par_batteries: 2,
    fuse_budget: 0,
    switch_budget: 0,
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
    name: "Six Pack",
    tier: Basics,
    description: "Chain 4 batteries for 6V.",
    battery_budget: 4,
    par_batteries: 4,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 7,
        row: 5,
        component: Device(6.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_07() -> @types.LevelDef {
  {
    id: 6,
    name: "Maze Runner",
    tier: Basics,
    description: "Navigate batteries through the maze.",
    battery_budget: 3,
    par_batteries: 2,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 0,
        row: 0,
        component: Battery,
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 5,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_08() -> @types.LevelDef {
  {
    id: 7,
    name: "Full Power",
    tier: Basics,
    description: "Maximum series: 6 batteries for 9V.",
    battery_budget: 6,
    par_batteries: 6,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 7,
        row: 2,
        component: Device(9.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

// ============================================================
// TIER 2: PARALLEL (Levels 9-17) - Parallel circuits, multi-device
// ============================================================

///|
fn level_09() -> @types.LevelDef {
  {
    id: 8,
    name: "Split Path",
    tier: Parallel,
    description: "Power two 1.5V devices from one battery.",
    battery_budget: 2,
    par_batteries: 1,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 6,
        row: 1,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 4,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_10() -> @types.LevelDef {
  {
    id: 9,
    name: "Dual Power",
    tier: Parallel,
    description: "Two devices need 3V each.",
    battery_budget: 4,
    par_batteries: 4,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
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
fn level_11() -> @types.LevelDef {
  {
    id: 10,
    name: "Mixed Needs",
    tier: Parallel,
    description: "Devices need different voltages.",
    battery_budget: 4,
    par_batteries: 3,
    fuse_budget: 0,
    switch_budget: 0,
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
fn level_12() -> @types.LevelDef {
  {
    id: 11,
    name: "Triple Feed",
    tier: Parallel,
    description: "Three devices, all need 1.5V.",
    battery_budget: 3,
    par_batteries: 1,
    fuse_budget: 0,
    switch_budget: 0,
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
fn level_13() -> @types.LevelDef {
  {
    id: 12,
    name: "Voltage Ladder",
    tier: Parallel,
    description: "Devices need 1.5V, 3V, and 4.5V.",
    battery_budget: 5,
    par_batteries: 4,
    fuse_budget: 0,
    switch_budget: 0,
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
fn level_14() -> @types.LevelDef {
  {
    id: 13,
    name: "Power Grid",
    tier: Parallel,
    description: "Four devices in a grid layout.",
    battery_budget: 5,
    par_batteries: 4,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 3,
        row: 0,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 0,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 3,
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
fn level_15() -> @types.LevelDef {
  {
    id: 14,
    name: "Branching Out",
    tier: Parallel,
    description: "One source, multiple branches.",
    battery_budget: 4,
    par_batteries: 3,
    fuse_budget: 0,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 0,
        row: 2,
        component: Battery,
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 0,
        component: Device(3.0),
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
fn level_16() -> @types.LevelDef {
  {
    id: 15,
    name: "Dense Network",
    tier: Parallel,
    description: "Five devices need power.",
    battery_budget: 6,
    par_batteries: 5,
    fuse_budget: 0,
    switch_budget: 0,
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
    name: "Parallel Master",
    tier: Parallel,
    description: "Six devices, optimize battery usage.",
    battery_budget: 8,
    par_batteries: 6,
    fuse_budget: 0,
    switch_budget: 0,
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
        component: Device(4.5),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 4,
        component: Device(3.0),
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

// ============================================================
// TIER 3: NETWORKS (Levels 18-25) - Mixed with fuses and switches
// ============================================================

///|
fn level_18() -> @types.LevelDef {
  {
    id: 17,
    name: "Fuse Box",
    tier: Networks,
    description: "Don't blow the fuse! Route carefully.",
    battery_budget: 3,
    par_batteries: 2,
    fuse_budget: 1,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 3,
        row: 2,
        component: Fuse(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_19() -> @types.LevelDef {
  {
    id: 18,
    name: "Switch It Up",
    tier: Networks,
    description: "Use a switch to control power flow.",
    battery_budget: 2,
    par_batteries: 2,
    fuse_budget: 0,
    switch_budget: 1,
    fixed_cells: [
      {
        col: 0,
        row: 2,
        component: Battery,
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_20() -> @types.LevelDef {
  {
    id: 19,
    name: "Protected Path",
    tier: Networks,
    description: "Fuse-protected circuit with 2 devices.",
    battery_budget: 4,
    par_batteries: 3,
    fuse_budget: 2,
    switch_budget: 0,
    fixed_cells: [
      {
        col: 6,
        row: 1,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 4,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_21() -> @types.LevelDef {
  {
    id: 20,
    name: "Toggle Routes",
    tier: Networks,
    description: "Switches select which device to power.",
    battery_budget: 3,
    par_batteries: 2,
    fuse_budget: 0,
    switch_budget: 2,
    fixed_cells: [
      {
        col: 7,
        row: 0,
        component: Device(3.0),
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
fn level_22() -> @types.LevelDef {
  {
    id: 21,
    name: "Safety First",
    tier: Networks,
    description: "Fuses protect against overload.",
    battery_budget: 5,
    par_batteries: 4,
    fuse_budget: 2,
    switch_budget: 1,
    fixed_cells: [
      {
        col: 6,
        row: 0,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 3,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 5,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_23() -> @types.LevelDef {
  {
    id: 22,
    name: "Complex Grid",
    tier: Networks,
    description: "Multiple paths, fuses, and switches.",
    battery_budget: 6,
    par_batteries: 5,
    fuse_budget: 2,
    switch_budget: 2,
    fixed_cells: [
      {
        col: 5,
        row: 0,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 5,
        row: 4,
        component: Device(6.0),
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
fn level_24() -> @types.LevelDef {
  {
    id: 23,
    name: "Power Station",
    tier: Networks,
    description: "Large network with protection.",
    battery_budget: 8,
    par_batteries: 6,
    fuse_budget: 3,
    switch_budget: 2,
    fixed_cells: [
      {
        col: 6,
        row: 0,
        component: Device(6.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 1,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 2,
        component: Device(4.5),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 3,
        component: Device(1.5),
        connections: [false, false, false, false],
      },
      {
        col: 6,
        row: 5,
        component: Device(9.0),
        connections: [false, false, false, false],
      },
    ],
  }
}

///|
fn level_25() -> @types.LevelDef {
  {
    id: 24,
    name: "Master Electrician",
    tier: Networks,
    description: "The ultimate circuit challenge.",
    battery_budget: 10,
    par_batteries: 8,
    fuse_budget: 3,
    switch_budget: 3,
    fixed_cells: [
      {
        col: 5,
        row: 0,
        component: Device(9.0),
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
        component: Device(6.0),
        connections: [false, false, false, false],
      },
      {
        col: 7,
        row: 2,
        component: Device(3.0),
        connections: [false, false, false, false],
      },
      {
        col: 5,
        row: 4,
        component: Device(1.5),
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
