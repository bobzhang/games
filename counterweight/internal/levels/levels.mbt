///|
fn make_rope(
  from_n : Int,
  to_n : Int,
  from_s : @types.RopeSide,
  to_s : @types.RopeSide
) -> @types.Rope {
  {
    active: true,
    from_node: from_n,
    to_node: to_n,
    from_side: from_s,
    to_side: to_s,
    max_load: 999.0,
    broken: false,
    breakable: false,
  }
}

///|
fn make_breakable_rope(
  from_n : Int,
  to_n : Int,
  from_s : @types.RopeSide,
  to_s : @types.RopeSide,
  max_load : Float
) -> @types.Rope {
  {
    active: true,
    from_node: from_n,
    to_node: to_n,
    from_side: from_s,
    to_side: to_s,
    max_load,
    broken: false,
    breakable: true,
  }
}

///|
pub fn get_level(index : Int) -> @types.LevelDef {
  match index {
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
    _ => level_25()
  }
}

///|
pub fn get_level_name(index : Int) -> String {
  match index {
    0 => "First Balance"
    1 => "Heavy Lift"
    2 => "Double Hook"
    3 => "Three Way"
    4 => "Weight Swap"
    5 => "Platform Rise"
    6 => "Anchor Point"
    7 => "Graduated"
    8 => "Chain Link"
    9 => "Double Pulley"
    10 => "Ratchet Start"
    11 => "Cascade"
    12 => "Lock and Load"
    13 => "Three Tier"
    14 => "Zigzag Chain"
    15 => "Ratchet Pair"
    16 => "Complex Chain"
    17 => "Break Point"
    18 => "Snap Decision"
    19 => "Water Bucket"
    20 => "Flood Gate"
    21 => "Chain Break"
    22 => "Full Workshop"
    23 => "Master Chain"
    _ => "Clocktower"
  }
}

// ============================================================
// TIER 1: BASICS (Levels 1-8)
// ============================================================

///|
fn level_01() -> @types.LevelDef {
  // Simple: one pulley, one weight, one crate. Connect weight to lift crate.
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 3, WeightHook),
    @types.new_node(2, 7, 3, CrateHook),
  ]
  let weights = [@types.new_weight(1, 3.0)]
  let crates = [@types.new_crate(2, 2.0, -0.5)]
  {
    tier: Basics,
    index: 0,
    name: "First Balance",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -0.5, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_02() -> @types.LevelDef {
  // Heavier weight needed to lift crate higher
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 3, WeightHook),
    @types.new_node(2, 7, 3, CrateHook),
    @types.new_node(3, 2, 5, WeightHook),
  ]
  let weights = [
    @types.new_weight(1, 2.0),
    @types.new_weight(3, 3.0),
  ]
  let crates = [@types.new_crate(2, 1.0, -1.0)]
  {
    tier: Basics,
    index: 1,
    name: "Heavy Lift",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -1.0, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_03() -> @types.LevelDef {
  // Two pulleys, two crates
  let nodes = [
    @types.new_node(0, 3, 1, Pulley),
    @types.new_node(1, 7, 1, Pulley),
    @types.new_node(2, 2, 3, WeightHook),
    @types.new_node(3, 4, 3, CrateHook),
    @types.new_node(4, 6, 3, WeightHook),
    @types.new_node(5, 8, 3, CrateHook),
  ]
  let weights = [
    @types.new_weight(2, 3.0),
    @types.new_weight(4, 2.0),
  ]
  let crates = [
    @types.new_crate(3, 2.0, -0.5),
    @types.new_crate(5, 1.0, -0.5),
  ]
  {
    tier: Basics,
    index: 2,
    name: "Double Hook",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -0.5, tolerance: 0.3 },
      { crate_index: 1, target_height: -0.5, tolerance: 0.3 },
    ],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_04() -> @types.LevelDef {
  // Three hooks on one pulley - choose the right weight
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 3, WeightHook),
    @types.new_node(2, 7, 3, CrateHook),
    @types.new_node(3, 1, 5, WeightHook),
    @types.new_node(4, 5, 5, WeightHook),
  ]
  let weights = [
    @types.new_weight(1, 1.0),
    @types.new_weight(3, 4.0),
    @types.new_weight(4, 2.0),
  ]
  let crates = [@types.new_crate(2, 3.0, -0.5)]
  {
    tier: Basics,
    index: 3,
    name: "Three Way",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -0.5, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_05() -> @types.LevelDef {
  // Need to swap weight positions
  let nodes = [
    @types.new_node(0, 3, 1, Pulley),
    @types.new_node(1, 7, 1, Pulley),
    @types.new_node(2, 2, 4, WeightHook),
    @types.new_node(3, 4, 4, CrateHook),
    @types.new_node(4, 6, 4, CrateHook),
    @types.new_node(5, 8, 4, WeightHook),
  ]
  let weights = [
    @types.new_weight(2, 4.0),
    @types.new_weight(5, 2.0),
  ]
  let crates = [
    @types.new_crate(3, 3.0, -0.5),
    @types.new_crate(4, 1.0, -0.5),
  ]
  {
    tier: Basics,
    index: 4,
    name: "Weight Swap",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -0.5, tolerance: 0.3 },
      { crate_index: 1, target_height: -0.5, tolerance: 0.3 },
    ],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_06() -> @types.LevelDef {
  // Platform that rises with pulley
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 3, WeightHook),
    @types.new_node(2, 7, 3, CrateHook),
    @types.new_node(3, 7, 5, Anchor),
  ]
  let weights = [@types.new_weight(1, 4.0)]
  let crates = [@types.new_crate(2, 2.0, -1.0)]
  let platforms = [@types.new_platform(3, 80.0)]
  {
    tier: Basics,
    index: 5,
    name: "Platform Rise",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms,
    buckets: [],
    targets: [{ crate_index: 0, target_height: -1.0, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_07() -> @types.LevelDef {
  // Use anchor to fix one side
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 1, Anchor),
    @types.new_node(2, 7, 4, CrateHook),
    @types.new_node(3, 3, 4, WeightHook),
  ]
  let weights = [@types.new_weight(3, 3.0)]
  let crates = [@types.new_crate(2, 1.0, -1.0)]
  {
    tier: Basics,
    index: 6,
    name: "Anchor Point",
    nodes,
    ropes: [make_rope(0, 1, LeftSide, LeftSide)],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -1.0, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_08() -> @types.LevelDef {
  // Precise weight matching for specific height
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 3, WeightHook),
    @types.new_node(2, 7, 3, CrateHook),
    @types.new_node(3, 1, 3, WeightHook),
    @types.new_node(4, 9, 3, WeightHook),
  ]
  let weights = [
    @types.new_weight(1, 1.0),
    @types.new_weight(3, 2.0),
    @types.new_weight(4, 5.0),
  ]
  let crates = [@types.new_crate(2, 3.0, -1.5)]
  {
    tier: Basics,
    index: 7,
    name: "Graduated",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -1.5, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

// ============================================================
// TIER 2: CHAINS (Levels 9-17)
// ============================================================

///|
fn level_09() -> @types.LevelDef {
  // First chained pulleys
  let nodes = [
    @types.new_node(0, 3, 1, Pulley),
    @types.new_node(1, 7, 1, Pulley),
    @types.new_node(2, 2, 4, WeightHook),
    @types.new_node(3, 8, 4, CrateHook),
  ]
  let weights = [@types.new_weight(2, 4.0)]
  let crates = [@types.new_crate(3, 2.0, -0.5)]
  {
    tier: Chains,
    index: 0,
    name: "Chain Link",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -0.5, tolerance: 0.3 }],
    par_connections: 3,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_10() -> @types.LevelDef {
  // Two pulleys connected
  let nodes = [
    @types.new_node(0, 3, 1, Pulley),
    @types.new_node(1, 7, 1, Pulley),
    @types.new_node(2, 2, 4, WeightHook),
    @types.new_node(3, 4, 4, CrateHook),
    @types.new_node(4, 6, 4, WeightHook),
    @types.new_node(5, 8, 4, CrateHook),
  ]
  let weights = [
    @types.new_weight(2, 3.0),
    @types.new_weight(4, 3.0),
  ]
  let crates = [
    @types.new_crate(3, 2.0, -0.5),
    @types.new_crate(5, 2.0, -0.5),
  ]
  {
    tier: Chains,
    index: 1,
    name: "Double Pulley",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -0.5, tolerance: 0.3 },
      { crate_index: 1, target_height: -0.5, tolerance: 0.3 },
    ],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_11() -> @types.LevelDef {
  // First ratchet level
  let nodes = [
    @types.new_node(0, 5, 1, Ratchet),
    @types.new_node(1, 3, 4, WeightHook),
    @types.new_node(2, 7, 4, CrateHook),
  ]
  let weights = [@types.new_weight(1, 4.0)]
  let crates = [@types.new_crate(2, 2.0, -1.0)]
  {
    tier: Chains,
    index: 2,
    name: "Ratchet Start",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -1.0, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_12() -> @types.LevelDef {
  // Cascade - A lifts B which lifts C
  let nodes = [
    @types.new_node(0, 2, 1, Pulley),
    @types.new_node(1, 5, 1, Pulley),
    @types.new_node(2, 8, 1, Pulley),
    @types.new_node(3, 1, 4, WeightHook),
    @types.new_node(4, 9, 4, CrateHook),
  ]
  let weights = [@types.new_weight(3, 5.0)]
  let crates = [@types.new_crate(4, 1.0, -0.5)]
  {
    tier: Chains,
    index: 3,
    name: "Cascade",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -0.5, tolerance: 0.3 }],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_13() -> @types.LevelDef {
  // Ratchet locks position, then use second pulley
  let nodes = [
    @types.new_node(0, 3, 1, Ratchet),
    @types.new_node(1, 7, 1, Pulley),
    @types.new_node(2, 2, 4, WeightHook),
    @types.new_node(3, 4, 4, CrateHook),
    @types.new_node(4, 6, 4, WeightHook),
    @types.new_node(5, 8, 4, CrateHook),
  ]
  let weights = [
    @types.new_weight(2, 3.0),
    @types.new_weight(4, 4.0),
  ]
  let crates = [
    @types.new_crate(3, 2.0, -0.5),
    @types.new_crate(5, 2.0, -1.0),
  ]
  {
    tier: Chains,
    index: 4,
    name: "Lock and Load",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -0.5, tolerance: 0.3 },
      { crate_index: 1, target_height: -1.0, tolerance: 0.3 },
    ],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_14() -> @types.LevelDef {
  // Three tier chain
  let nodes = [
    @types.new_node(0, 2, 0, Pulley),
    @types.new_node(1, 5, 0, Pulley),
    @types.new_node(2, 8, 0, Pulley),
    @types.new_node(3, 1, 3, WeightHook),
    @types.new_node(4, 3, 3, CrateHook),
    @types.new_node(5, 6, 3, CrateHook),
    @types.new_node(6, 9, 3, CrateHook),
  ]
  let weights = [@types.new_weight(3, 5.0)]
  let crates = [
    @types.new_crate(4, 1.0, -0.5),
    @types.new_crate(5, 1.0, -0.5),
    @types.new_crate(6, 1.0, -0.5),
  ]
  {
    tier: Chains,
    index: 5,
    name: "Three Tier",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -0.5, tolerance: 0.3 },
      { crate_index: 1, target_height: -0.5, tolerance: 0.3 },
      { crate_index: 2, target_height: -0.5, tolerance: 0.3 },
    ],
    par_connections: 5,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_15() -> @types.LevelDef {
  // Zigzag chain path
  let nodes = [
    @types.new_node(0, 2, 1, Pulley),
    @types.new_node(1, 5, 3, Pulley),
    @types.new_node(2, 8, 1, Pulley),
    @types.new_node(3, 1, 4, WeightHook),
    @types.new_node(4, 9, 4, CrateHook),
  ]
  let weights = [@types.new_weight(3, 4.0)]
  let crates = [@types.new_crate(4, 2.0, -0.5)]
  {
    tier: Chains,
    index: 6,
    name: "Zigzag Chain",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -0.5, tolerance: 0.3 }],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_16() -> @types.LevelDef {
  // Two ratchets
  let nodes = [
    @types.new_node(0, 3, 1, Ratchet),
    @types.new_node(1, 7, 1, Ratchet),
    @types.new_node(2, 2, 4, WeightHook),
    @types.new_node(3, 4, 4, CrateHook),
    @types.new_node(4, 6, 4, WeightHook),
    @types.new_node(5, 8, 4, CrateHook),
  ]
  let weights = [
    @types.new_weight(2, 4.0),
    @types.new_weight(4, 3.0),
  ]
  let crates = [
    @types.new_crate(3, 2.0, -1.0),
    @types.new_crate(5, 2.0, -0.5),
  ]
  {
    tier: Chains,
    index: 7,
    name: "Ratchet Pair",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -1.0, tolerance: 0.3 },
      { crate_index: 1, target_height: -0.5, tolerance: 0.3 },
    ],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_17() -> @types.LevelDef {
  // Complex chain with multiple weights
  let nodes = [
    @types.new_node(0, 2, 0, Pulley),
    @types.new_node(1, 5, 0, Pulley),
    @types.new_node(2, 8, 0, Ratchet),
    @types.new_node(3, 1, 3, WeightHook),
    @types.new_node(4, 3, 3, WeightHook),
    @types.new_node(5, 6, 3, CrateHook),
    @types.new_node(6, 9, 3, CrateHook),
    @types.new_node(7, 4, 5, WeightHook),
  ]
  let weights = [
    @types.new_weight(3, 3.0),
    @types.new_weight(4, 2.0),
    @types.new_weight(7, 5.0),
  ]
  let crates = [
    @types.new_crate(5, 2.0, -0.5),
    @types.new_crate(6, 1.0, -1.0),
  ]
  {
    tier: Chains,
    index: 8,
    name: "Complex Chain",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -0.5, tolerance: 0.3 },
      { crate_index: 1, target_height: -1.0, tolerance: 0.3 },
    ],
    par_connections: 5,
    par_rehooks: 1,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

// ============================================================
// TIER 3: WORKSHOP (Levels 18-25)
// ============================================================

///|
fn level_18() -> @types.LevelDef {
  // First breakable rope
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 3, WeightHook),
    @types.new_node(2, 7, 3, CrateHook),
    @types.new_node(3, 5, 5, WeightHook),
  ]
  let weights = [
    @types.new_weight(1, 2.0),
    @types.new_weight(3, 5.0),
  ]
  let crates = [@types.new_crate(2, 1.0, 0.5)]
  {
    tier: Workshop,
    index: 0,
    name: "Break Point",
    nodes,
    ropes: [make_breakable_rope(0, 1, LeftSide, LeftSide, 3.0)],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: 0.5, tolerance: 0.3 }],
    par_connections: 3,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_19() -> @types.LevelDef {
  // Strategic rope breaking
  let nodes = [
    @types.new_node(0, 3, 1, Pulley),
    @types.new_node(1, 7, 1, Pulley),
    @types.new_node(2, 2, 4, WeightHook),
    @types.new_node(3, 4, 4, CrateHook),
    @types.new_node(4, 6, 4, WeightHook),
    @types.new_node(5, 8, 4, CrateHook),
  ]
  let weights = [
    @types.new_weight(2, 5.0),
    @types.new_weight(4, 4.0),
  ]
  let crates = [
    @types.new_crate(3, 1.0, -1.0),
    @types.new_crate(5, 2.0, 0.5),
  ]
  {
    tier: Workshop,
    index: 1,
    name: "Snap Decision",
    nodes,
    ropes: [
      make_breakable_rope(0, 2, LeftSide, LeftSide, 4.0),
    ],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -1.0, tolerance: 0.3 },
      { crate_index: 1, target_height: 0.5, tolerance: 0.3 },
    ],
    par_connections: 4,
    par_rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_20() -> @types.LevelDef {
  // First bucket level
  let nodes = [
    @types.new_node(0, 5, 1, Pulley),
    @types.new_node(1, 3, 3, WeightHook),
    @types.new_node(2, 7, 3, CrateHook),
  ]
  let buckets = [@types.new_bucket(1, 1.0, 5.0, 0.3)]
  let crates = [@types.new_crate(2, 3.0, -0.5)]
  {
    tier: Workshop,
    index: 2,
    name: "Water Bucket",
    nodes,
    ropes: [],
    weights: [],
    crates,
    platforms: [],
    buckets,
    targets: [{ crate_index: 0, target_height: -0.5, tolerance: 0.3 }],
    par_connections: 2,
    par_rehooks: 0,
    has_waterfall: true,
    waterfall_x: 3,
  }
}

///|
fn level_21() -> @types.LevelDef {
  // Bucket + waterfall + pulley chain
  let nodes = [
    @types.new_node(0, 3, 1, Pulley),
    @types.new_node(1, 7, 1, Pulley),
    @types.new_node(2, 2, 4, WeightHook),
    @types.new_node(3, 8, 4, CrateHook),
  ]
  let buckets = [@types.new_bucket(2, 0.5, 6.0, 0.4)]
  let crates = [@types.new_crate(3, 2.0, -1.0)]
  {
    tier: Workshop,
    index: 3,
    name: "Flood Gate",
    nodes,
    ropes: [],
    weights: [],
    crates,
    platforms: [],
    buckets,
    targets: [{ crate_index: 0, target_height: -1.0, tolerance: 0.3 }],
    par_connections: 3,
    par_rehooks: 0,
    has_waterfall: true,
    waterfall_x: 2,
  }
}

///|
fn level_22() -> @types.LevelDef {
  // Breakable rope + chain
  let nodes = [
    @types.new_node(0, 2, 1, Pulley),
    @types.new_node(1, 5, 1, Pulley),
    @types.new_node(2, 8, 1, Pulley),
    @types.new_node(3, 1, 4, WeightHook),
    @types.new_node(4, 6, 4, CrateHook),
    @types.new_node(5, 9, 4, WeightHook),
  ]
  let weights = [
    @types.new_weight(3, 4.0),
    @types.new_weight(5, 3.0),
  ]
  let crates = [@types.new_crate(4, 2.0, -0.5)]
  {
    tier: Workshop,
    index: 4,
    name: "Chain Break",
    nodes,
    ropes: [
      make_breakable_rope(1, 2, RightSide, LeftSide, 5.0),
    ],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [{ crate_index: 0, target_height: -0.5, tolerance: 0.3 }],
    par_connections: 4,
    par_rehooks: 1,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_23() -> @types.LevelDef {
  // Full workshop - all mechanics
  let nodes = [
    @types.new_node(0, 2, 0, Pulley),
    @types.new_node(1, 5, 0, Ratchet),
    @types.new_node(2, 8, 0, Pulley),
    @types.new_node(3, 1, 3, WeightHook),
    @types.new_node(4, 3, 3, CrateHook),
    @types.new_node(5, 6, 3, WeightHook),
    @types.new_node(6, 9, 3, CrateHook),
    @types.new_node(7, 5, 5, WeightHook),
  ]
  let weights = [
    @types.new_weight(3, 4.0),
    @types.new_weight(5, 2.0),
    @types.new_weight(7, 3.0),
  ]
  let crates = [
    @types.new_crate(4, 2.0, -1.0),
    @types.new_crate(6, 1.0, -0.5),
  ]
  {
    tier: Workshop,
    index: 5,
    name: "Full Workshop",
    nodes,
    ropes: [],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -1.0, tolerance: 0.3 },
      { crate_index: 1, target_height: -0.5, tolerance: 0.3 },
    ],
    par_connections: 5,
    par_rehooks: 1,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_24() -> @types.LevelDef {
  // Master chain with everything
  let nodes = [
    @types.new_node(0, 1, 0, Pulley),
    @types.new_node(1, 4, 0, Ratchet),
    @types.new_node(2, 7, 0, Pulley),
    @types.new_node(3, 0, 3, WeightHook),
    @types.new_node(4, 2, 3, CrateHook),
    @types.new_node(5, 5, 3, WeightHook),
    @types.new_node(6, 8, 3, CrateHook),
    @types.new_node(7, 9, 3, WeightHook),
    @types.new_node(8, 3, 5, WeightHook),
  ]
  let weights = [
    @types.new_weight(3, 5.0),
    @types.new_weight(5, 2.0),
    @types.new_weight(7, 3.0),
    @types.new_weight(8, 4.0),
  ]
  let crates = [
    @types.new_crate(4, 2.0, -1.0),
    @types.new_crate(6, 3.0, -0.5),
  ]
  {
    tier: Workshop,
    index: 6,
    name: "Master Chain",
    nodes,
    ropes: [
      make_breakable_rope(1, 5, RightSide, LeftSide, 4.0),
    ],
    weights,
    crates,
    platforms: [],
    buckets: [],
    targets: [
      { crate_index: 0, target_height: -1.0, tolerance: 0.3 },
      { crate_index: 1, target_height: -0.5, tolerance: 0.3 },
    ],
    par_connections: 5,
    par_rehooks: 1,
    has_waterfall: false,
    waterfall_x: 0,
  }
}

///|
fn level_25() -> @types.LevelDef {
  // Grand finale - clocktower puzzle
  let nodes = [
    @types.new_node(0, 1, 0, Pulley),
    @types.new_node(1, 4, 0, Pulley),
    @types.new_node(2, 7, 0, Ratchet),
    @types.new_node(3, 0, 3, WeightHook),
    @types.new_node(4, 2, 3, CrateHook),
    @types.new_node(5, 5, 3, WeightHook),
    @types.new_node(6, 8, 3, CrateHook),
    @types.new_node(7, 9, 3, WeightHook),
    @types.new_node(8, 3, 5, WeightHook),
    @types.new_node(9, 6, 5, Anchor),
  ]
  let weights = [
    @types.new_weight(3, 4.0),
    @types.new_weight(5, 3.0),
    @types.new_weight(7, 5.0),
    @types.new_weight(8, 2.0),
  ]
  let crates = [
    @types.new_crate(4, 2.0, -1.0),
    @types.new_crate(6, 2.0, -1.5),
  ]
  let buckets = [@types.new_bucket(5, 1.0, 6.0, 0.2)]
  {
    tier: Workshop,
    index: 7,
    name: "Clocktower",
    nodes,
    ropes: [
      make_breakable_rope(0, 3, LeftSide, LeftSide, 5.0),
    ],
    weights,
    crates,
    platforms: [],
    buckets,
    targets: [
      { crate_index: 0, target_height: -1.0, tolerance: 0.3 },
      { crate_index: 1, target_height: -1.5, tolerance: 0.3 },
    ],
    par_connections: 6,
    par_rehooks: 1,
    has_waterfall: true,
    waterfall_x: 5,
  }
}
