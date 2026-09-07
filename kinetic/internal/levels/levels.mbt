///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_1_1()
    1 => level_1_2()
    2 => level_1_3()
    3 => level_1_4()
    4 => level_1_5()
    5 => level_1_6()
    6 => level_1_7()
    7 => level_1_8()
    8 => level_2_1()
    9 => level_2_2()
    10 => level_2_3()
    11 => level_2_4()
    12 => level_2_5()
    13 => level_2_6()
    14 => level_2_7()
    15 => level_2_8()
    16 => level_2_9()
    17 => level_3_1()
    18 => level_3_2()
    19 => level_3_3()
    20 => level_3_4()
    21 => level_3_5()
    22 => level_3_6()
    23 => level_3_7()
    24 => level_3_8()
    _ => level_1_1()
  }
}

// ============================================================
// Tier 1: "Gears" (8 levels) - 2 gear sizes, 1 output
// ============================================================

///|
fn level_1_1() -> @types.Level {
  // Simple direct mesh: Small drives Medium
  {
    name: "First Mesh",
    tier: Gears,
    input: { pos: { x: 3, y: 4, }, rpm: 60.0, dir: CW, radius: 1, },
    outputs: [@types.new_output({ x: 5, y: 4, }, 30.0, CCW)],
    available_gears: [Small, Medium],
    gear_budget: 3,
    par_gears: 1,
    hint: "Place a Medium gear next to the input",
  }
}

///|
fn level_1_2() -> @types.Level {
  // Medium drives Small = speed up
  {
    name: "Speed Up",
    tier: Gears,
    input: { pos: { x: 2, y: 4, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [@types.new_output({ x: 5, y: 4, }, 120.0, CCW)],
    available_gears: [Small, Medium],
    gear_budget: 3,
    par_gears: 1,
    hint: "A Small gear driven by a Medium spins faster",
  }
}

///|
fn level_1_3() -> @types.Level {
  // Two meshes: direction flips twice = same as input
  {
    name: "Double Flip",
    tier: Gears,
    input: { pos: { x: 2, y: 4, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [@types.new_output({ x: 6, y: 4, }, 60.0, CW)],
    available_gears: [Small, Medium],
    gear_budget: 4,
    par_gears: 2,
    hint: "Two meshes flip direction twice",
  }
}

///|
fn level_1_4() -> @types.Level {
  // Speed down chain
  {
    name: "Slow Down",
    tier: Gears,
    input: { pos: { x: 3, y: 3, }, rpm: 120.0, dir: CW, radius: 1, },
    outputs: [@types.new_output({ x: 5, y: 3, }, 60.0, CCW)],
    available_gears: [Small, Medium],
    gear_budget: 3,
    par_gears: 1,
    hint: "Small driving Medium halves the speed",
  }
}

///|
fn level_1_5() -> @types.Level {
  // Chain of 3: get CCW at output
  {
    name: "The Chain",
    tier: Gears,
    input: { pos: { x: 1, y: 4, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [@types.new_output({ x: 7, y: 4, }, 60.0, CCW)],
    available_gears: [Small, Medium],
    gear_budget: 5,
    par_gears: 3,
    hint: "Build a chain of gears to reach the output",
  }
}

///|
fn level_1_6() -> @types.Level {
  // Vertical meshing
  {
    name: "Vertical",
    tier: Gears,
    input: { pos: { x: 4, y: 1, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [@types.new_output({ x: 4, y: 5, }, 60.0, CW)],
    available_gears: [Small, Medium],
    gear_budget: 4,
    par_gears: 2,
    hint: "Gears mesh vertically too",
  }
}

///|
fn level_1_7() -> @types.Level {
  // Ratio: speed multiply then direction
  {
    name: "Ratio Master",
    tier: Gears,
    input: { pos: { x: 2, y: 3, }, rpm: 30.0, dir: CW, radius: 2, },
    outputs: [@types.new_output({ x: 5, y: 3, }, 60.0, CW)],
    available_gears: [Small, Medium],
    gear_budget: 5,
    par_gears: 3,
    hint: "Combine ratios to double speed and keep CW",
  }
}

///|
fn level_1_8() -> @types.Level {
  // Final tier 1 challenge
  {
    name: "Graduation",
    tier: Gears,
    input: { pos: { x: 1, y: 2, }, rpm: 120.0, dir: CW, radius: 1, },
    outputs: [@types.new_output({ x: 7, y: 6, }, 30.0, CW)],
    available_gears: [Small, Medium],
    gear_budget: 6,
    par_gears: 4,
    hint: "Navigate diagonally across the grid",
  }
}

// ============================================================
// Tier 2: "Trains" (9 levels) - 3 sizes + belts, 2 outputs
// ============================================================

///|
fn level_2_1() -> @types.Level {
  // Introduce Large gear
  {
    name: "Big Wheel",
    tier: Trains,
    input: { pos: { x: 2, y: 4, }, rpm: 60.0, dir: CW, radius: 1, },
    outputs: [@types.new_output({ x: 6, y: 4, }, 15.0, CCW)],
    available_gears: [Small, Medium, Large],
    gear_budget: 4,
    par_gears: 2,
    hint: "Large gears spin slower but with more torque",
  }
}

///|
fn level_2_2() -> @types.Level {
  // Two outputs same direction
  {
    name: "Split Path",
    tier: Trains,
    input: { pos: { x: 4, y: 2, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 2, y: 4, }, 30.0, CCW),
      @types.new_output({ x: 6, y: 4, }, 30.0, CCW),
    ],
    available_gears: [Small, Medium, Large],
    gear_budget: 5,
    par_gears: 3,
    hint: "One input can drive multiple outputs",
  }
}

///|
fn level_2_3() -> @types.Level {
  // Speed up and speed down simultaneously
  {
    name: "Divergence",
    tier: Trains,
    input: { pos: { x: 4, y: 3, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 7, y: 3, }, 120.0, CCW),
      @types.new_output({ x: 1, y: 3, }, 30.0, CCW),
    ],
    available_gears: [Small, Medium, Large],
    gear_budget: 5,
    par_gears: 3,
    hint: "Use different gear sizes for different speeds",
  }
}

///|
fn level_2_4() -> @types.Level {
  // Introduce belts
  {
    name: "Belt Drive",
    tier: Trains,
    input: { pos: { x: 2, y: 2, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [@types.new_output({ x: 7, y: 5, }, 60.0, CW)],
    available_gears: [Small, Medium, Large, Belt],
    gear_budget: 4,
    par_gears: 2,
    hint: "Belts connect distant gears and preserve direction",
  }
}

///|
fn level_2_5() -> @types.Level {
  // Belt + mesh combo
  {
    name: "Hybrid Drive",
    tier: Trains,
    input: { pos: { x: 1, y: 2, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 8, y: 2, }, 60.0, CW),
      @types.new_output({ x: 8, y: 5, }, 30.0, CCW),
    ],
    available_gears: [Small, Medium, Large, Belt],
    gear_budget: 6,
    par_gears: 4,
    hint: "Combine belts and gears for complex routing",
  }
}

///|
fn level_2_6() -> @types.Level {
  // Opposite directions at two outputs
  {
    name: "Counter Spin",
    tier: Trains,
    input: { pos: { x: 4, y: 1, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 2, y: 5, }, 60.0, CW),
      @types.new_output({ x: 6, y: 5, }, 60.0, CCW),
    ],
    available_gears: [Small, Medium, Large, Belt],
    gear_budget: 6,
    par_gears: 4,
    hint: "Use different chain lengths for different directions",
  }
}

///|
fn level_2_7() -> @types.Level {
  // Large reduction ratio
  {
    name: "Gear Down",
    tier: Trains,
    input: { pos: { x: 2, y: 3, }, rpm: 180.0, dir: CW, radius: 1, },
    outputs: [
      @types.new_output({ x: 6, y: 3, }, 20.0, CCW),
      @types.new_output({ x: 6, y: 6, }, 60.0, CW),
    ],
    available_gears: [Small, Medium, Large, Belt],
    gear_budget: 7,
    par_gears: 5,
    hint: "Chain reductions to achieve very low RPM",
  }
}

///|
fn level_2_8() -> @types.Level {
  // Complex routing
  {
    name: "The Factory",
    tier: Trains,
    input: { pos: { x: 1, y: 1, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 8, y: 1, }, 120.0, CW),
      @types.new_output({ x: 8, y: 6, }, 30.0, CW),
    ],
    available_gears: [Small, Medium, Large, Belt],
    gear_budget: 8,
    par_gears: 6,
    hint: "Plan your gear train carefully",
  }
}

///|
fn level_2_9() -> @types.Level {
  // Tier 2 finale
  {
    name: "Clockwork",
    tier: Trains,
    input: { pos: { x: 4, y: 0, }, rpm: 120.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 1, y: 6, }, 60.0, CW),
      @types.new_output({ x: 7, y: 6, }, 240.0, CCW),
    ],
    available_gears: [Small, Medium, Large, Belt],
    gear_budget: 8,
    par_gears: 6,
    hint: "A true clockmaker designs efficient trains",
  }
}

// ============================================================
// Tier 3: "Workshop" (8 levels) - All parts + ratchets, 2-3 outputs
// ============================================================

///|
fn level_3_1() -> @types.Level {
  // Introduce ratchets
  {
    name: "One Way",
    tier: Workshop,
    input: { pos: { x: 2, y: 3, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 5, y: 3, }, 30.0, CCW),
      @types.new_output({ x: 8, y: 3, }, 60.0, CW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 6,
    par_gears: 4,
    hint: "Ratchets only transmit in one direction",
  }
}

///|
fn level_3_2() -> @types.Level {
  // 3 outputs
  {
    name: "Triple Output",
    tier: Workshop,
    input: { pos: { x: 4, y: 1, }, rpm: 120.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 1, y: 4, }, 60.0, CCW),
      @types.new_output({ x: 4, y: 6, }, 120.0, CW),
      @types.new_output({ x: 7, y: 4, }, 60.0, CCW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 8,
    par_gears: 6,
    hint: "Distribute power to three outputs",
  }
}

///|
fn level_3_3() -> @types.Level {
  // Mixed ratios
  {
    name: "Gear Ratio Lab",
    tier: Workshop,
    input: { pos: { x: 1, y: 2, }, rpm: 90.0, dir: CW, radius: 1, },
    outputs: [
      @types.new_output({ x: 5, y: 2, }, 45.0, CW),
      @types.new_output({ x: 8, y: 5, }, 180.0, CCW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 7,
    par_gears: 5,
    hint: "Mix gear sizes to achieve precise ratios",
  }
}

///|
fn level_3_4() -> @types.Level {
  // Ratchet gates
  {
    name: "Gate Keeper",
    tier: Workshop,
    input: { pos: { x: 3, y: 1, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 1, y: 5, }, 30.0, CCW),
      @types.new_output({ x: 5, y: 5, }, 60.0, CW),
      @types.new_output({ x: 8, y: 5, }, 120.0, CCW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 9,
    par_gears: 7,
    hint: "Use ratchets to control power flow",
  }
}

///|
fn level_3_5() -> @types.Level {
  // Extreme ratio
  {
    name: "Precision",
    tier: Workshop,
    input: { pos: { x: 1, y: 3, }, rpm: 180.0, dir: CW, radius: 1, },
    outputs: [
      @types.new_output({ x: 8, y: 1, }, 10.0, CCW),
      @types.new_output({ x: 8, y: 6, }, 360.0, CW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 10,
    par_gears: 7,
    hint: "Extreme ratios need long gear trains",
  }
}

///|
fn level_3_6() -> @types.Level {
  // All directions
  {
    name: "Choreography",
    tier: Workshop,
    input: { pos: { x: 4, y: 3, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 1, y: 1, }, 60.0, CCW),
      @types.new_output({ x: 7, y: 1, }, 60.0, CW),
      @types.new_output({ x: 4, y: 7, }, 30.0, CW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 10,
    par_gears: 7,
    hint: "Coordinate all three outputs in harmony",
  }
}

///|
fn level_3_7() -> @types.Level {
  // Dense packing challenge
  {
    name: "Tight Fit",
    tier: Workshop,
    input: { pos: { x: 2, y: 2, }, rpm: 120.0, dir: CW, radius: 1, },
    outputs: [
      @types.new_output({ x: 7, y: 2, }, 40.0, CCW),
      @types.new_output({ x: 7, y: 5, }, 120.0, CW),
      @types.new_output({ x: 2, y: 5, }, 60.0, CCW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 10,
    par_gears: 8,
    hint: "Every peg counts in this tight layout",
  }
}

///|
fn level_3_8() -> @types.Level {
  // Final challenge - master workshop
  {
    name: "Master Work",
    tier: Workshop,
    input: { pos: { x: 0, y: 0, }, rpm: 60.0, dir: CW, radius: 2, },
    outputs: [
      @types.new_output({ x: 9, y: 0, }, 120.0, CW),
      @types.new_output({ x: 9, y: 7, }, 30.0, CCW),
      @types.new_output({ x: 0, y: 7, }, 60.0, CW),
    ],
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: 12,
    par_gears: 9,
    hint: "The ultimate mechanical choreography",
  }
}
