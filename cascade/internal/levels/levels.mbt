///|
fn mk(
  x : Int,
  y : Int,
  kind : @types.DominoKind,
  o : @types.Orientation,
  target : Bool,
) -> @types.Domino {
  @types.new_domino(@types.vec2i(x, y), kind, o, target, false)
}

///|
fn mk_starter(x : Int, y : Int, o : @types.Orientation) -> @types.Domino {
  @types.new_domino(@types.vec2i(x, y), Normal, o, false, true)
}

// ── Tier 1: Chains (levels 0-7) ──

///|
fn level_0() -> @types.Level {
  // "First Step" - simple 3-domino straight line
  let dominoes = [mk_starter(2, 6, E), mk(4, 6, Normal, E, true)]
  {
    id: 0,
    tier: Chains,
    name: "First Step",
    dominoes,
    starter_pos: @types.vec2i(2, 6),
    budget: @types.new_budget(1, 0, 0, 0),
    par_count: 1,
    par_ticks: 3,
  }
}

///|
fn level_1() -> @types.Level {
  // "Straight Line" - 5 sockets in a row, place middle ones
  let dominoes = [mk_starter(2, 6, E), mk(6, 6, Normal, E, true)]
  {
    id: 1,
    tier: Chains,
    name: "Straight Line",
    dominoes,
    starter_pos: @types.vec2i(2, 6),
    budget: @types.new_budget(3, 0, 0, 0),
    par_count: 2,
    par_ticks: 5,
  }
}

///|
fn level_2() -> @types.Level {
  // "Corner Turn" - chain must turn a corner
  let dominoes = [
    mk_starter(2, 3, E),
    mk(4, 3, Normal, S, false),
    mk(7, 6, Normal, E, true),
  ]
  {
    id: 2,
    tier: Chains,
    name: "Corner Turn",
    dominoes,
    starter_pos: @types.vec2i(2, 3),
    budget: @types.new_budget(3, 0, 0, 0),
    par_count: 2,
    par_ticks: 6,
  }
}

///|
fn level_3() -> @types.Level {
  // "Zigzag" - S/E/S/E pattern
  let dominoes = [
    mk_starter(3, 2, S),
    mk(3, 4, Normal, E, false),
    mk(5, 4, Normal, S, false),
    mk(5, 8, Normal, S, true),
  ]
  {
    id: 3,
    tier: Chains,
    name: "Zigzag",
    dominoes,
    starter_pos: @types.vec2i(3, 2),
    budget: @types.new_budget(3, 0, 0, 0),
    par_count: 2,
    par_ticks: 7,
  }
}

///|
fn level_4() -> @types.Level {
  // "Two Targets" - hit two targets in a line
  let dominoes = [
    mk_starter(1, 6, E),
    mk(5, 6, Normal, E, true),
    mk(9, 6, Normal, E, true),
  ]
  {
    id: 4,
    tier: Chains,
    name: "Two Targets",
    dominoes,
    starter_pos: @types.vec2i(1, 6),
    budget: @types.new_budget(4, 0, 0, 0),
    par_count: 3,
    par_ticks: 8,
  }
}

///|
fn level_5() -> @types.Level {
  // "L-Shape" - go east then south
  let dominoes = [
    mk_starter(2, 2, E),
    mk(6, 2, Normal, S, false),
    mk(6, 8, Normal, S, true),
  ]
  {
    id: 5,
    tier: Chains,
    name: "L-Shape",
    dominoes,
    starter_pos: @types.vec2i(2, 2),
    budget: @types.new_budget(4, 0, 0, 0),
    par_count: 3,
    par_ticks: 9,
  }
}

///|
fn level_6() -> @types.Level {
  // "U-Turn" - east, south, west
  let dominoes = [
    mk_starter(3, 2, E),
    mk(8, 2, Normal, S, false),
    mk(8, 6, Normal, W, false),
    mk(3, 6, Normal, W, true),
  ]
  {
    id: 6,
    tier: Chains,
    name: "U-Turn",
    dominoes,
    starter_pos: @types.vec2i(3, 2),
    budget: @types.new_budget(4, 0, 0, 0),
    par_count: 3,
    par_ticks: 10,
  }
}

///|
fn level_7() -> @types.Level {
  // "Spiral" - goes around in a rectangle hitting 3 targets
  let dominoes = [
    mk_starter(2, 2, E),
    mk(8, 2, Normal, E, true),
    mk(10, 2, Normal, S, false),
    mk(10, 8, Normal, S, true),
    mk(10, 10, Normal, W, false),
    mk(4, 10, Normal, W, true),
  ]
  {
    id: 7,
    tier: Chains,
    name: "Spiral",
    dominoes,
    starter_pos: @types.vec2i(2, 2),
    budget: @types.new_budget(5, 0, 0, 0),
    par_count: 4,
    par_ticks: 14,
  }
}

// ── Tier 2: Splits (levels 8-15) ──

///|
fn level_8() -> @types.Level {
  // "First Split" - splitter sends chain two ways
  let dominoes = [
    mk_starter(2, 5, E),
    mk(5, 5, Splitter, E, false),
    mk(5, 3, Normal, E, true),
    mk(5, 7, Normal, E, true),
  ]
  {
    id: 8,
    tier: Splits,
    name: "First Split",
    dominoes,
    starter_pos: @types.vec2i(2, 5),
    budget: @types.new_budget(2, 0, 0, 0),
    par_count: 1,
    par_ticks: 5,
  }
}

///|
fn level_9() -> @types.Level {
  // "Heavy Reach" - heavy domino reaches across a gap
  let dominoes = [mk_starter(2, 6, E), mk(6, 6, Normal, E, true)]
  {
    id: 9,
    tier: Splits,
    name: "Heavy Reach",
    dominoes,
    starter_pos: @types.vec2i(2, 6),
    budget: @types.new_budget(1, 1, 0, 0),
    par_count: 2,
    par_ticks: 4,
  }
}

///|
fn level_10() -> @types.Level {
  // "Double Split" - two splitters create 4 paths
  let dominoes = [
    mk_starter(1, 5, E),
    mk(4, 5, Splitter, E, false),
    mk(4, 3, Normal, E, false),
    mk(4, 7, Normal, E, false),
    mk(7, 3, Normal, E, true),
    mk(7, 7, Normal, E, true),
  ]
  {
    id: 10,
    tier: Splits,
    name: "Double Split",
    dominoes,
    starter_pos: @types.vec2i(1, 5),
    budget: @types.new_budget(2, 0, 0, 0),
    par_count: 2,
    par_ticks: 6,
  }
}

///|
fn level_11() -> @types.Level {
  // "Bridge Gap" - use heavy to bridge a 2-socket gap
  let dominoes = [
    mk_starter(2, 6, E),
    mk(5, 6, Normal, E, false),
    mk(9, 6, Normal, E, true),
  ]
  {
    id: 11,
    tier: Splits,
    name: "Bridge Gap",
    dominoes,
    starter_pos: @types.vec2i(2, 6),
    budget: @types.new_budget(1, 1, 0, 0),
    par_count: 2,
    par_ticks: 6,
  }
}

///|
fn level_12() -> @types.Level {
  // "Split and Reach" - splitter + heavy combo
  let dominoes = [
    mk_starter(2, 5, E),
    mk(5, 5, Splitter, E, false),
    mk(5, 2, Normal, E, true),
    mk(5, 8, Normal, E, true),
    mk(9, 5, Normal, E, true),
  ]
  {
    id: 12,
    tier: Splits,
    name: "Split and Reach",
    dominoes,
    starter_pos: @types.vec2i(2, 5),
    budget: @types.new_budget(2, 1, 0, 0),
    par_count: 2,
    par_ticks: 7,
  }
}

///|
fn level_13() -> @types.Level {
  // "Parallel Lines" - two parallel chains from one splitter
  let dominoes = [
    mk_starter(1, 5, E),
    mk(3, 5, Splitter, E, false),
    mk(3, 3, Normal, E, false),
    mk(3, 7, Normal, E, false),
    mk(6, 3, Normal, E, false),
    mk(6, 7, Normal, E, false),
    mk(9, 3, Normal, E, true),
    mk(9, 7, Normal, E, true),
  ]
  {
    id: 13,
    tier: Splits,
    name: "Parallel Lines",
    dominoes,
    starter_pos: @types.vec2i(1, 5),
    budget: @types.new_budget(2, 0, 0, 0),
    par_count: 2,
    par_ticks: 7,
  }
}

///|
fn level_14() -> @types.Level {
  // "Heavy Chain" - chain of heavy dominoes
  let dominoes = [
    mk_starter(1, 6, E),
    mk(5, 6, Normal, E, false),
    mk(9, 6, Normal, E, false),
    mk(13, 6, Normal, E, true),
  ]
  {
    id: 14,
    tier: Splits,
    name: "Heavy Chain",
    dominoes,
    starter_pos: @types.vec2i(1, 6),
    budget: @types.new_budget(0, 3, 0, 0),
    par_count: 3,
    par_ticks: 7,
  }
}

///|
fn level_15() -> @types.Level {
  // "Split Maze" - multiple splitters create a maze-like path
  let dominoes = [
    mk_starter(1, 5, E),
    mk(3, 5, Splitter, E, false),
    mk(3, 3, Normal, E, false),
    mk(3, 7, Normal, E, false),
    mk(6, 3, Splitter, E, false),
    mk(6, 7, Splitter, E, false),
    mk(6, 1, Normal, E, true),
    mk(6, 5, Normal, E, true),
    mk(6, 9, Normal, E, true),
  ]
  {
    id: 15,
    tier: Splits,
    name: "Split Maze",
    dominoes,
    starter_pos: @types.vec2i(1, 5),
    budget: @types.new_budget(3, 0, 1, 0),
    par_count: 3,
    par_ticks: 8,
  }
}

// ── Tier 3: Timing (levels 16-23) ──

///|
fn level_16() -> @types.Level {
  // "First Delay" - delay domino introduction
  let dominoes = [
    mk_starter(2, 6, E),
    mk(4, 6, Delay, E, false),
    mk(6, 6, Normal, E, true),
  ]
  {
    id: 16,
    tier: Timing,
    name: "First Delay",
    dominoes,
    starter_pos: @types.vec2i(2, 6),
    budget: @types.new_budget(1, 0, 0, 0),
    par_count: 1,
    par_ticks: 6,
  }
}

///|
fn level_17() -> @types.Level {
  // "Sync Paths" - two paths must arrive at same time
  let dominoes = [
    mk_starter(2, 5, E),
    mk(4, 5, Splitter, E, false),
    mk(4, 3, Normal, E, false),
    mk(4, 7, Delay, E, false),
    mk(8, 3, Normal, S, false),
    mk(8, 7, Normal, N, false),
    mk(8, 5, Normal, E, true),
  ]
  {
    id: 17,
    tier: Timing,
    name: "Sync Paths",
    dominoes,
    starter_pos: @types.vec2i(2, 5),
    budget: @types.new_budget(2, 0, 0, 1),
    par_count: 2,
    par_ticks: 8,
  }
}

///|
fn level_18() -> @types.Level {
  // "Delayed Split" - delay then split
  let dominoes = [
    mk_starter(1, 5, E),
    mk(3, 5, Delay, E, false),
    mk(5, 5, Splitter, E, false),
    mk(5, 3, Normal, E, true),
    mk(5, 7, Normal, E, true),
  ]
  {
    id: 18,
    tier: Timing,
    name: "Delayed Split",
    dominoes,
    starter_pos: @types.vec2i(1, 5),
    budget: @types.new_budget(2, 0, 0, 0),
    par_count: 1,
    par_ticks: 8,
  }
}

///|
fn level_19() -> @types.Level {
  // "Cascade Timing" - staggered delays for sequential hits
  let dominoes = [
    mk_starter(1, 3, E),
    mk(3, 3, Normal, S, false),
    mk(3, 6, Delay, E, false),
    mk(3, 9, Normal, E, false),
    mk(7, 6, Normal, E, true),
    mk(7, 9, Normal, E, true),
  ]
  {
    id: 19,
    tier: Timing,
    name: "Cascade Timing",
    dominoes,
    starter_pos: @types.vec2i(1, 3),
    budget: @types.new_budget(3, 0, 0, 1),
    par_count: 2,
    par_ticks: 10,
  }
}

///|
fn level_20() -> @types.Level {
  // "Heavy Delay" - heavy + delay combo
  let dominoes = [
    mk_starter(1, 5, E),
    mk(3, 5, Delay, E, false),
    mk(7, 5, Normal, E, true),
    mk(11, 5, Normal, E, true),
  ]
  {
    id: 20,
    tier: Timing,
    name: "Heavy Delay",
    dominoes,
    starter_pos: @types.vec2i(1, 5),
    budget: @types.new_budget(1, 2, 0, 0),
    par_count: 2,
    par_ticks: 8,
  }
}

///|
fn level_21() -> @types.Level {
  // "Triple Threat" - all types combined
  let dominoes = [
    mk_starter(1, 5, E),
    mk(3, 5, Normal, E, false),
    mk(5, 5, Splitter, E, false),
    mk(5, 3, Delay, E, false),
    mk(5, 7, Normal, E, false),
    mk(9, 3, Normal, S, true),
    mk(9, 7, Normal, N, true),
    mk(9, 5, Normal, E, true),
  ]
  {
    id: 21,
    tier: Timing,
    name: "Triple Threat",
    dominoes,
    starter_pos: @types.vec2i(1, 5),
    budget: @types.new_budget(2, 1, 0, 0),
    par_count: 2,
    par_ticks: 10,
  }
}

///|
fn level_22() -> @types.Level {
  // "Clock" - circular chain with precise timing
  let dominoes = [
    mk_starter(5, 2, E),
    mk(8, 2, Normal, S, false),
    mk(8, 5, Normal, S, false),
    mk(8, 8, Normal, W, false),
    mk(5, 8, Normal, W, false),
    mk(2, 8, Normal, N, false),
    mk(2, 5, Normal, N, false),
    mk(2, 2, Normal, E, true),
    mk(5, 5, Normal, E, true),
  ]
  {
    id: 22,
    tier: Timing,
    name: "Clock",
    dominoes,
    starter_pos: @types.vec2i(5, 2),
    budget: @types.new_budget(3, 0, 1, 1),
    par_count: 3,
    par_ticks: 14,
  }
}

///|
fn level_23() -> @types.Level {
  // "Grand Finale" - uses all types, multiple paths, timing critical
  let dominoes = [
    mk_starter(1, 5, E),
    mk(3, 5, Splitter, E, false),
    mk(3, 2, Normal, E, false),
    mk(3, 8, Delay, E, false),
    mk(6, 2, Normal, S, false),
    mk(6, 5, Normal, E, false),
    mk(6, 8, Normal, E, false),
    mk(10, 2, Normal, S, true),
    mk(10, 5, Normal, E, true),
    mk(10, 8, Normal, N, true),
    mk(10, 10, Normal, W, true),
  ]
  {
    id: 23,
    tier: Timing,
    name: "Grand Finale",
    dominoes,
    starter_pos: @types.vec2i(1, 5),
    budget: @types.new_budget(3, 2, 1, 1),
    par_count: 4,
    par_ticks: 14,
  }
}

///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_0()
    1 => level_1()
    2 => level_2()
    3 => level_3()
    4 => level_4()
    5 => level_5()
    6 => level_6()
    7 => level_7()
    8 => level_8()
    9 => level_9()
    10 => level_10()
    11 => level_11()
    12 => level_12()
    13 => level_13()
    14 => level_14()
    15 => level_15()
    16 => level_16()
    17 => level_17()
    18 => level_18()
    19 => level_19()
    20 => level_20()
    21 => level_21()
    22 => level_22()
    23 => level_23()
    _ => level_0()
  }
}

///|
pub fn level_name(index : Int) -> String {
  get_level(index).name
}

///|
pub fn tier_unlocked(
  scores : Array[@types.LevelScore],
  tier : @types.Tier,
) -> Bool {
  match tier {
    Chains => true
    Splits => {
      // Need at least 4 levels completed in Chains
      let mut count = 0
      for i in 0..<@types.levels_per_tier {
        if scores[i].completed {
          count += 1
        }
      }
      count >= 4
    }
    Timing => {
      // Need at least 4 levels completed in Splits
      let base = @types.levels_per_tier
      let mut count = 0
      for i in base..<(base + @types.levels_per_tier) {
        if scores[i].completed {
          count += 1
        }
      }
      count >= 4
    }
  }
}
