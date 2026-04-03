///|
/// Get all 20 levels.
pub fn get_all_levels() -> Array[@types.Level] {
  [
    level_1(),
    level_2(),
    level_3(),
    level_4(),
    level_5(),
    level_6(),
    level_7(),
    level_8(),
    level_9(),
    level_10(),
    level_11(),
    level_12(),
    level_13(),
    level_14(),
    level_15(),
    level_16(),
    level_17(),
    level_18(),
    level_19(),
    level_20(),
  ]
}

///|
/// Get a specific level by index (0-19).
pub fn get_level(index : Int) -> @types.Level {
  let levels = get_all_levels()
  levels[index]
}

// ============================================================
// TIER 1: BEGINNER (Levels 1-7) - Learn basics
// ============================================================

///|
/// Level 1: "First Glaze" - Single red, learn placement
fn level_1() -> @types.Level {
  let target = build_target([
    e, e, e, e, e, e, e, e, r, r, e, e, e, e, r, r, e, e, e, e, r, r, e, e, e, e,
    e, e, e, e, e, e, e, e, e, e,
  ])
  {
    tier: Beginner,
    name: "First Glaze",
    target,
    allowed_glazes: [Red],
    max_moves: 10,
    par_moves: 6,
  }
}

///|
/// Level 2: "Blue Stripe" - Learn blue placement
fn level_2() -> @types.Level {
  let target = build_target([
    e, e, e, e, e, e, b, b, b, b, b, b, e, e, e, e, e, e, e, e, e, e, e, e, b, b,
    b, b, b, b, e, e, e, e, e, e,
  ])
  {
    tier: Beginner,
    name: "Blue Stripe",
    target,
    allowed_glazes: [Blue],
    max_moves: 16,
    par_moves: 12,
  }
}

///|
/// Level 3: "Green Cross" - Learn shape making
fn level_3() -> @types.Level {
  let target = build_target([
    e, e, g, g, e, e, e, e, g, g, e, e, g, g, g, g, g, g, g, g, g, g, g, g, e, e,
    g, g, e, e, e, e, g, g, e, e,
  ])
  {
    tier: Beginner,
    name: "Green Cross",
    target,
    allowed_glazes: [Green],
    max_moves: 24,
    par_moves: 20,
  }
}

///|
/// Level 4: "Gold Frame" - Border pattern
fn level_4() -> @types.Level {
  let target = build_target([
    o, o, o, o, o, o, o, e, e, e, e, o, o, e, e, e, e, o, o, e, e, e, e, o, o, e,
    e, e, e, o, o, o, o, o, o, o,
  ])
  {
    tier: Beginner,
    name: "Gold Frame",
    target,
    allowed_glazes: [Gold],
    max_moves: 24,
    par_moves: 20,
  }
}

///|
/// Level 5: "Two Tone" - Learn two colors
fn level_5() -> @types.Level {
  let target = build_target([
    r, r, r, b, b, b, r, r, r, b, b, b, r, r, r, b, b, b, r, r, r, b, b, b, r, r,
    r, b, b, b, r, r, r, b, b, b,
  ])
  {
    tier: Beginner,
    name: "Two Tone",
    target,
    allowed_glazes: [Red, Blue],
    max_moves: 40,
    par_moves: 36,
  }
}

///|
/// Level 6: "Purple Mix" - Learn Red+Blue blending
fn level_6() -> @types.Level {
  let target = build_target([
    e, e, e, e, e, e, e, r, b, r, b, e, e, b, r, b, r, e, e, r, b, r, b, e, e, b,
    r, b, r, e, e, e, e, e, e, e,
  ])
  {
    tier: Beginner,
    name: "Purple Mix",
    target,
    allowed_glazes: [Red, Blue],
    max_moves: 20,
    par_moves: 16,
  }
}

///|
/// Level 7: "Checkerboard" - Alternating pattern
fn level_7() -> @types.Level {
  let target = build_target([
    w, k, w, k, w, k, k, w, k, w, k, w, w, k, w, k, w, k, k, w, k, w, k, w, w, k,
    w, k, w, k, k, w, k, w, k, w,
  ])
  {
    tier: Beginner,
    name: "Checkerboard",
    target,
    allowed_glazes: [White, Black],
    max_moves: 40,
    par_moves: 36,
  }
}

// ============================================================
// TIER 2: INTERMEDIATE (Levels 8-14) - Multi-color, interactions
// ============================================================

///|
/// Level 8: "Sunset" - Red and Gold bands
fn level_8() -> @types.Level {
  let target = build_target([
    r, r, r, r, r, r, r, r, r, r, r, r, o, o, o, o, o, o, o, o, o, o, o, o, e, e,
    e, e, e, e, e, e, e, e, e, e,
  ])
  {
    tier: Intermediate,
    name: "Sunset",
    target,
    allowed_glazes: [Red, Gold],
    max_moves: 28,
    par_moves: 24,
  }
}

///|
/// Level 9: "Ocean" - Blue and White waves
fn level_9() -> @types.Level {
  let target = build_target([
    b, b, w, w, b, b, w, b, b, b, b, w, b, w, w, w, w, b, w, b, b, b, b, w, b, b,
    w, w, b, b, w, w, b, b, w, w,
  ])
  {
    tier: Intermediate,
    name: "Ocean",
    target,
    allowed_glazes: [Blue, White],
    max_moves: 40,
    par_moves: 36,
  }
}

///|
/// Level 10: "Forest Floor" - Green and Gold
fn level_10() -> @types.Level {
  let target = build_target([
    g, g, e, e, g, g, g, o, o, o, o, g, e, o, g, g, o, e, e, o, g, g, o, e, g, o,
    o, o, o, g, g, g, e, e, g, g,
  ])
  {
    tier: Intermediate,
    name: "Forest Floor",
    target,
    allowed_glazes: [Green, Gold],
    max_moves: 30,
    par_moves: 24,
  }
}

///|
/// Level 11: "Amethyst" - Purple center with Red/Blue edges
fn level_11() -> @types.Level {
  let target = build_target([
    r, r, r, b, b, b, r, r, b, r, b, b, r, b, r, b, r, b, b, r, b, r, b, r, b, b,
    r, b, r, r, b, b, b, r, r, r,
  ])
  {
    tier: Intermediate,
    name: "Amethyst",
    target,
    allowed_glazes: [Red, Blue],
    max_moves: 40,
    par_moves: 36,
  }
}

///|
/// Level 12: "Night Sky" - White dots on Black
fn level_12() -> @types.Level {
  let target = build_target([
    k, k, w, k, k, k, k, k, k, k, w, k, w, k, k, k, k, k, k, k, k, w, k, k, k, w,
    k, k, k, w, k, k, k, k, k, k,
  ])
  {
    tier: Intermediate,
    name: "Night Sky",
    target,
    allowed_glazes: [White, Black],
    max_moves: 38,
    par_moves: 31,
  }
}

///|
/// Level 13: "Stained Glass" - Three-color pattern
fn level_13() -> @types.Level {
  let target = build_target([
    r, r, b, b, o, o, r, r, b, b, o, o, b, b, o, o, r, r, b, b, o, o, r, r, o, o,
    r, r, b, b, o, o, r, r, b, b,
  ])
  {
    tier: Intermediate,
    name: "Stained Glass",
    target,
    allowed_glazes: [Red, Blue, Gold],
    max_moves: 40,
    par_moves: 36,
  }
}

///|
/// Level 14: "Royal Crest" - Complex multi-color
fn level_14() -> @types.Level {
  let target = build_target([
    o, o, b, b, o, o, o, b, b, b, b, o, b, b, r, r, b, b, b, b, r, r, b, b, o, b,
    b, b, b, o, o, o, b, b, o, o,
  ])
  {
    tier: Intermediate,
    name: "Royal Crest",
    target,
    allowed_glazes: [Red, Blue, Gold],
    max_moves: 38,
    par_moves: 32,
  }
}

// ============================================================
// TIER 3: ADVANCED (Levels 15-20) - Full palette, tight budgets
// ============================================================

///|
/// Level 15: "Dragon Scale" - Complex interlocking
fn level_15() -> @types.Level {
  let target = build_target([
    r, o, r, o, r, o, o, g, o, g, o, g, r, o, r, o, r, o, o, g, o, g, o, g, r, o,
    r, o, r, o, o, g, o, g, o, g,
  ])
  {
    tier: Advanced,
    name: "Dragon Scale",
    target,
    allowed_glazes: [Red, Green, Gold],
    max_moves: 40,
    par_moves: 36,
  }
}

///|
/// Level 16: "Porcelain Dream" - White, Blue, Gold
fn level_16() -> @types.Level {
  let target = build_target([
    w, w, b, b, w, w, w, b, o, o, b, w, b, o, w, w, o, b, b, o, w, w, o, b, w, b,
    o, o, b, w, w, w, b, b, w, w,
  ])
  {
    tier: Advanced,
    name: "Porcelain Dream",
    target,
    allowed_glazes: [White, Blue, Gold],
    max_moves: 40,
    par_moves: 36,
  }
}

///|
/// Level 17: "Obsidian Flame" - Black, Red, Gold
fn level_17() -> @types.Level {
  let target = build_target([
    k, k, k, k, k, k, k, r, r, r, r, k, k, r, o, o, r, k, k, r, o, o, r, k, k, r,
    r, r, r, k, k, k, k, k, k, k,
  ])
  {
    tier: Advanced,
    name: "Obsidian Flame",
    target,
    allowed_glazes: [Black, Red, Gold],
    max_moves: 38,
    par_moves: 32,
  }
}

///|
/// Level 18: "Persian Tile" - 4-color symmetry
fn level_18() -> @types.Level {
  let target = build_target([
    b, b, w, w, g, g, b, o, w, g, o, g, w, w, o, o, g, g, g, g, o, o, w, w, g, o,
    g, w, o, b, g, g, w, w, b, b,
  ])
  {
    tier: Advanced,
    name: "Persian Tile",
    target,
    allowed_glazes: [Blue, White, Green, Gold],
    max_moves: 40,
    par_moves: 36,
  }
}

///|
/// Level 19: "Phoenix Mosaic" - 5 colors
fn level_19() -> @types.Level {
  let target = build_target([
    r, r, o, o, r, r, r, b, o, o, b, r, o, o, w, w, o, o, o, o, w, w, o, o, r, b,
    o, o, b, r, r, r, o, o, r, r,
  ])
  {
    tier: Advanced,
    name: "Phoenix Mosaic",
    target,
    allowed_glazes: [Red, Blue, Gold, White],
    max_moves: 38,
    par_moves: 32,
  }
}

///|
/// Level 20: "Magnum Opus" - Full palette masterwork
fn level_20() -> @types.Level {
  let target = build_target([
    o, k, b, b, k, o, k, w, r, r, w, k, b, r, g, g, r, b, b, r, g, g, r, b, k, w,
    r, r, w, k, o, k, b, b, k, o,
  ])
  {
    tier: Advanced,
    name: "Magnum Opus",
    target,
    allowed_glazes: [Red, Blue, Green, Gold, White, Black],
    max_moves: 40,
    par_moves: 36,
  }
}
