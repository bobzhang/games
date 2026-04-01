///|
/// Get a level by global index (0-24)
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => pine_1()
    1 => pine_2()
    2 => pine_3()
    3 => pine_4()
    4 => pine_5()
    5 => pine_6()
    6 => pine_7()
    7 => pine_8()
    8 => maple_1()
    9 => maple_2()
    10 => maple_3()
    11 => maple_4()
    12 => maple_5()
    13 => maple_6()
    14 => maple_7()
    15 => maple_8()
    16 => maple_9()
    17 => cherry_1()
    18 => cherry_2()
    19 => cherry_3()
    20 => cherry_4()
    21 => cherry_5()
    22 => cherry_6()
    23 => cherry_7()
    _ => cherry_8()
  }
}

// ============================================================
// TIER 1: PINE (8 levels) - Simple upward growth, wide spacing
// ============================================================

///|
/// Pine 1: "First Growth" - Simple: grow up, fill required zone
fn pine_1() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [{ x: 5, y: 10 }, { x: 5, y: 11 }, { x: 5, y: 12 }],
        kind: Required,
      },
    ],
    max_turns: 8,
    prune_budget_per_turn: 1,
    par_prunes: 0,
    tier: Tier1,
    level_index: 0,
  }
}

///|
/// Pine 2: "Reaching Up" - Grow taller, avoid forbidden zone on left
fn pine_2() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 5, y: 6 }, { x: 5, y: 7 }], kind: Required },
      { positions: [{ x: 3, y: 6 }, { x: 3, y: 7 }], kind: Forbidden },
    ],
    max_turns: 10,
    prune_budget_per_turn: 2,
    par_prunes: 1,
    tier: Tier1,
    level_index: 1,
  }
}

///|
/// Pine 3: "Fork Path" - First fork, guide one branch to target
fn pine_3() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 7, y: 8 }], kind: TipTarget },
      {
        positions: [{ x: 3, y: 8 }, { x: 2, y: 8 }, { x: 2, y: 7 }],
        kind: Forbidden,
      },
    ],
    max_turns: 10,
    prune_budget_per_turn: 2,
    par_prunes: 1,
    tier: Tier1,
    level_index: 2,
  }
}

///|
/// Pine 4: "Twin Peaks" - Two tips must reach two targets
fn pine_4() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 3, y: 5 }], kind: TipTarget },
      { positions: [{ x: 7, y: 5 }], kind: TipTarget },
    ],
    max_turns: 12,
    prune_budget_per_turn: 2,
    par_prunes: 2,
    tier: Tier1,
    level_index: 3,
  }
}

///|
/// Pine 5: "Narrow Pass" - Grow through a corridor (forbidden zones on sides)
fn pine_5() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 5, y: 4 }, { x: 5, y: 5 }], kind: Required },
      {
        positions: [
          { x: 3, y: 8 },
          { x: 3, y: 9 },
          { x: 3, y: 10 },
          { x: 7, y: 8 },
          { x: 7, y: 9 },
          { x: 7, y: 10 },
        ],
        kind: Forbidden,
      },
    ],
    max_turns: 12,
    prune_budget_per_turn: 3,
    par_prunes: 2,
    tier: Tier1,
    level_index: 4,
  }
}

///|
/// Pine 6: "Windswept" - Start with UpRight direction, prune to fill left zone
fn pine_6() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 3, y: 15, dir: Up }, { x: 3, y: 14, dir: UpRight }],
    zones: [
      { positions: [{ x: 6, y: 8 }, { x: 7, y: 7 }], kind: Required },
      { positions: [{ x: 1, y: 8 }, { x: 0, y: 7 }], kind: Forbidden },
    ],
    max_turns: 10,
    prune_budget_per_turn: 2,
    par_prunes: 1,
    tier: Tier1,
    level_index: 5,
  }
}

///|
/// Pine 7: "Three Tiers" - Fill three required zones at different heights
fn pine_7() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 5, y: 12 }], kind: Required },
      { positions: [{ x: 4, y: 8 }, { x: 6, y: 8 }], kind: Required },
      { positions: [{ x: 3, y: 4 }, { x: 7, y: 4 }], kind: Required },
    ],
    max_turns: 14,
    prune_budget_per_turn: 2,
    par_prunes: 3,
    tier: Tier1,
    level_index: 6,
  }
}

///|
/// Pine 8: "Bonsai Master" - Complex pine: fill zones, avoid forbidden, hit tips
fn pine_8() -> @types.Level {
  {
    species: Pine,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [{ x: 4, y: 7 }, { x: 5, y: 7 }, { x: 6, y: 7 }],
        kind: Required,
      },
      { positions: [{ x: 3, y: 3 }], kind: TipTarget },
      { positions: [{ x: 7, y: 3 }], kind: TipTarget },
      { positions: [{ x: 5, y: 2 }, { x: 5, y: 1 }], kind: Forbidden },
    ],
    max_turns: 14,
    prune_budget_per_turn: 3,
    par_prunes: 4,
    tier: Tier1,
    level_index: 7,
  }
}

// ============================================================
// TIER 2: MAPLE (9 levels) - Fork-heavy, more spreading
// ============================================================

///|
/// Maple 1: "Spread Out" - Intro to maple's faster forking
fn maple_1() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [{ positions: [{ x: 3, y: 9 }, { x: 7, y: 9 }], kind: Required }],
    max_turns: 8,
    prune_budget_per_turn: 2,
    par_prunes: 0,
    tier: Tier2,
    level_index: 8,
  }
}

///|
/// Maple 2: "Canopy" - Fill a wide zone at the top
fn maple_2() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [
          { x: 3, y: 5 },
          { x: 4, y: 5 },
          { x: 5, y: 5 },
          { x: 6, y: 5 },
          { x: 7, y: 5 },
        ],
        kind: Required,
      },
    ],
    max_turns: 10,
    prune_budget_per_turn: 2,
    par_prunes: 1,
    tier: Tier2,
    level_index: 9,
  }
}

///|
/// Maple 3: "Contained" - Grow within boundaries
fn maple_3() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 5, y: 6 }], kind: Required },
      {
        positions: [
          { x: 1, y: 6 },
          { x: 1, y: 7 },
          { x: 1, y: 8 },
          { x: 9, y: 6 },
          { x: 9, y: 7 },
          { x: 9, y: 8 },
        ],
        kind: Forbidden,
      },
    ],
    max_turns: 10,
    prune_budget_per_turn: 3,
    par_prunes: 2,
    tier: Tier2,
    level_index: 10,
  }
}

///|
/// Maple 4: "Left Lean" - Direct growth leftward
fn maple_4() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 8, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 3, y: 7 }, { x: 2, y: 6 }], kind: Required },
      { positions: [{ x: 10, y: 7 }, { x: 11, y: 7 }], kind: Forbidden },
    ],
    max_turns: 10,
    prune_budget_per_turn: 3,
    par_prunes: 3,
    tier: Tier2,
    level_index: 11,
  }
}

///|
/// Maple 5: "Diamond" - Fill a diamond-shaped required zone
fn maple_5() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [
          { x: 5, y: 6 },
          { x: 4, y: 7 },
          { x: 6, y: 7 },
          { x: 5, y: 8 },
        ],
        kind: Required,
      },
    ],
    max_turns: 10,
    prune_budget_per_turn: 2,
    par_prunes: 1,
    tier: Tier2,
    level_index: 12,
  }
}

///|
/// Maple 6: "Four Corners" - Tips must reach four spots
fn maple_6() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 2, y: 4 }], kind: TipTarget },
      { positions: [{ x: 8, y: 4 }], kind: TipTarget },
      { positions: [{ x: 2, y: 9 }], kind: TipTarget },
      { positions: [{ x: 8, y: 9 }], kind: TipTarget },
    ],
    max_turns: 12,
    prune_budget_per_turn: 3,
    par_prunes: 4,
    tier: Tier2,
    level_index: 13,
  }
}

///|
/// Maple 7: "Pruner's Test" - Heavy pruning needed, limited budget
fn maple_7() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 5, y: 3 }], kind: TipTarget },
      {
        positions: [
          { x: 3, y: 3 },
          { x: 4, y: 3 },
          { x: 6, y: 3 },
          { x: 7, y: 3 },
          { x: 3, y: 4 },
          { x: 7, y: 4 },
        ],
        kind: Forbidden,
      },
    ],
    max_turns: 10,
    prune_budget_per_turn: 2,
    par_prunes: 3,
    tier: Tier2,
    level_index: 14,
  }
}

///|
/// Maple 8: "The Arch" - Grow around a forbidden center zone
fn maple_8() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 3, y: 5 }, { x: 7, y: 5 }], kind: Required },
      {
        positions: [
          { x: 4, y: 5 },
          { x: 5, y: 5 },
          { x: 6, y: 5 },
          { x: 5, y: 6 },
          { x: 5, y: 4 },
        ],
        kind: Forbidden,
      },
    ],
    max_turns: 12,
    prune_budget_per_turn: 3,
    par_prunes: 4,
    tier: Tier2,
    level_index: 15,
  }
}

///|
/// Maple 9: "Grand Maple" - Full challenge, all zone types
fn maple_9() -> @types.Level {
  {
    species: Maple,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [
          { x: 3, y: 6 },
          { x: 4, y: 6 },
          { x: 6, y: 6 },
          { x: 7, y: 6 },
        ],
        kind: Required,
      },
      { positions: [{ x: 2, y: 3 }], kind: TipTarget },
      { positions: [{ x: 8, y: 3 }], kind: TipTarget },
      { positions: [{ x: 5, y: 3 }, { x: 5, y: 2 }], kind: Forbidden },
    ],
    max_turns: 14,
    prune_budget_per_turn: 3,
    par_prunes: 5,
    tier: Tier2,
    level_index: 16,
  }
}

// ============================================================
// TIER 3: CHERRY (8 levels) - Curved growth, aesthetic targets
// ============================================================

///|
/// Cherry 1: "First Bloom" - Intro to cherry's curved growth
fn cherry_1() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [{ x: 4, y: 9 }, { x: 5, y: 9 }, { x: 6, y: 9 }],
        kind: Required,
      },
    ],
    max_turns: 8,
    prune_budget_per_turn: 2,
    par_prunes: 0,
    tier: Tier3,
    level_index: 17,
  }
}

///|
/// Cherry 2: "Weeping" - Guide branches to droop to sides
fn cherry_2() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 2, y: 8 }], kind: TipTarget },
      { positions: [{ x: 8, y: 8 }], kind: TipTarget },
    ],
    max_turns: 10,
    prune_budget_per_turn: 2,
    par_prunes: 2,
    tier: Tier3,
    level_index: 18,
  }
}

///|
/// Cherry 3: "Blossom Ring" - Fill a ring-shaped required zone
fn cherry_3() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [
          { x: 4, y: 6 },
          { x: 6, y: 6 },
          { x: 3, y: 7 },
          { x: 7, y: 7 },
          { x: 4, y: 8 },
          { x: 6, y: 8 },
        ],
        kind: Required,
      },
      { positions: [{ x: 5, y: 7 }], kind: Forbidden },
    ],
    max_turns: 12,
    prune_budget_per_turn: 3,
    par_prunes: 3,
    tier: Tier3,
    level_index: 19,
  }
}

///|
/// Cherry 4: "Cascade" - Staircase pattern from top-left to bottom-right
fn cherry_4() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 3, y: 4 }], kind: TipTarget },
      { positions: [{ x: 5, y: 6 }], kind: Required },
      { positions: [{ x: 7, y: 8 }], kind: TipTarget },
    ],
    max_turns: 12,
    prune_budget_per_turn: 3,
    par_prunes: 3,
    tier: Tier3,
    level_index: 20,
  }
}

///|
/// Cherry 5: "Forbidden Garden" - Many forbidden zones, narrow valid path
fn cherry_5() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 5, y: 4 }], kind: Required },
      {
        positions: [
          { x: 3, y: 5 },
          { x: 3, y: 6 },
          { x: 3, y: 7 },
          { x: 7, y: 5 },
          { x: 7, y: 6 },
          { x: 7, y: 7 },
          { x: 4, y: 3 },
          { x: 6, y: 3 },
        ],
        kind: Forbidden,
      },
    ],
    max_turns: 12,
    prune_budget_per_turn: 3,
    par_prunes: 4,
    tier: Tier3,
    level_index: 21,
  }
}

///|
/// Cherry 6: "Symmetry" - Must be symmetric, tips at mirror positions
fn cherry_6() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      { positions: [{ x: 2, y: 5 }], kind: TipTarget },
      { positions: [{ x: 8, y: 5 }], kind: TipTarget },
      { positions: [{ x: 2, y: 9 }], kind: TipTarget },
      { positions: [{ x: 8, y: 9 }], kind: TipTarget },
      { positions: [{ x: 5, y: 4 }, { x: 5, y: 3 }], kind: Forbidden },
    ],
    max_turns: 14,
    prune_budget_per_turn: 3,
    par_prunes: 5,
    tier: Tier3,
    level_index: 22,
  }
}

///|
/// Cherry 7: "Crown" - Complex crown shape
fn cherry_7() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [
          { x: 2, y: 4 },
          { x: 4, y: 3 },
          { x: 6, y: 3 },
          { x: 8, y: 4 },
        ],
        kind: Required,
      },
      { positions: [{ x: 3, y: 2 }], kind: TipTarget },
      { positions: [{ x: 7, y: 2 }], kind: TipTarget },
      { positions: [{ x: 5, y: 2 }, { x: 5, y: 1 }], kind: Forbidden },
    ],
    max_turns: 14,
    prune_budget_per_turn: 3,
    par_prunes: 5,
    tier: Tier3,
    level_index: 23,
  }
}

///|
/// Cherry 8: "Masterpiece" - Ultimate challenge, all mechanics
fn cherry_8() -> @types.Level {
  {
    species: Cherry,
    initial_branches: [{ x: 5, y: 15, dir: Up }],
    zones: [
      {
        positions: [
          { x: 3, y: 5 },
          { x: 4, y: 5 },
          { x: 6, y: 5 },
          { x: 7, y: 5 },
          { x: 3, y: 8 },
          { x: 7, y: 8 },
        ],
        kind: Required,
      },
      { positions: [{ x: 1, y: 3 }], kind: TipTarget },
      { positions: [{ x: 9, y: 3 }], kind: TipTarget },
      { positions: [{ x: 5, y: 2 }], kind: TipTarget },
      {
        positions: [
          { x: 0, y: 5 },
          { x: 0, y: 6 },
          { x: 11, y: 5 },
          { x: 11, y: 6 },
        ],
        kind: Forbidden,
      },
    ],
    max_turns: 16,
    prune_budget_per_turn: 4,
    par_prunes: 6,
    tier: Tier3,
    level_index: 24,
  }
}
