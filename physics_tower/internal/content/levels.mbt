///|
/// Returns all world info for the 3 campaign worlds.
pub fn get_worlds() -> Array[@types.WorldInfo] {
  [
    // World 1: Stone Fortress (levels 0-6)
    {
      theme: StoneFortress,
      name: "Stone Fortress",
      description: "Ancient stronghold - master the basics of tower building",
      level_start: 0,
      level_end: 6,
      stars_required: 0,
      bg_r: 18,
      bg_g: 22,
      bg_b: 32,
      accent_r: 100,
      accent_g: 140,
      accent_b: 200,
      gravity_mult: 1.0,
      wind_mult: 1.0,
      friction_mult: 1.0,
    },
    // World 2: Desert Ruins (levels 7-13)
    {
      theme: DesertRuins,
      name: "Desert Ruins",
      description: "Sandstorms rage - wind shifts direction mid-test!",
      level_start: 7,
      level_end: 13,
      stars_required: 8,
      bg_r: 40,
      bg_g: 30,
      bg_b: 18,
      accent_r: 220,
      accent_g: 170,
      accent_b: 60,
      gravity_mult: 1.0,
      wind_mult: 1.5,
      friction_mult: 0.9,
    },
    // World 3: Arctic Peaks (levels 14-19)
    {
      theme: ArcticPeaks,
      name: "Arctic Peaks",
      description: "Ice and snow - slippery surfaces, heavy snowfall!",
      level_start: 14,
      level_end: 19,
      stars_required: 18,
      bg_r: 20,
      bg_g: 28,
      bg_b: 42,
      accent_r: 140,
      accent_g: 200,
      accent_b: 240,
      gravity_mult: 1.3,
      wind_mult: 1.2,
      friction_mult: 0.5,
    },
  ]
}

///|
/// Returns the world index for a given level index.
pub fn world_for_level(level_idx : Int) -> Int {
  let worlds = get_worlds()
  for i, w in worlds {
    if level_idx >= w.level_start && level_idx <= w.level_end {
      return i
    }
  }
  0
}

///|
/// Checks if a world is unlocked given the total stars earned.
pub fn is_world_unlocked(world_idx : Int, total_stars : Int) -> Bool {
  let worlds = get_worlds()
  if world_idx < 0 || world_idx >= worlds.length() {
    return false
  }
  total_stars >= worlds[world_idx].stars_required
}

///|
/// Returns the theme colors for a world.
pub fn world_bg_color(world_idx : Int) -> (Int, Int, Int) {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    let w = worlds[world_idx]
    (w.bg_r, w.bg_g, w.bg_b)
  } else {
    (18, 22, 32)
  }
}

///|
/// Returns the accent color for a world.
pub fn world_accent_color(world_idx : Int) -> (Int, Int, Int) {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    let w = worlds[world_idx]
    (w.accent_r, w.accent_g, w.accent_b)
  } else {
    (100, 140, 200)
  }
}

///|
pub fn get_levels() -> Array[@types.Level] {
  [
    // ============================================
    // WORLD 1: STONE FORTRESS (levels 0-6)
    // Basic building, gentle tests
    // ============================================
    // Level 1: Stacking Basics
    {
      name: "Stacking Basics",
      description: "Build a simple tower. No hazards.",
      target_height: 200.0,
      budget: 8,
      test_kinds: [],
      available_pieces: [(Block, Wood, 4), (Beam, Wood, 4)],
      world_index: 0,
    },
    // Level 2: Gentle Breeze
    {
      name: "Gentle Breeze",
      description: "Your tower must survive a light wind.",
      target_height: 250.0,
      budget: 10,
      test_kinds: [Wind],
      available_pieces: [(Block, Wood, 5), (Beam, Wood, 5)],
      world_index: 0,
    },
    // Level 3: Stone Foundation
    {
      name: "Stone Foundation",
      description: "Use stone blocks for a sturdy base.",
      target_height: 300.0,
      budget: 12,
      test_kinds: [Wind],
      available_pieces: [(Block, Stone, 4), (Block, Wood, 4), (Beam, Wood, 4)],
      world_index: 0,
    },
    // Level 4: Tremors
    {
      name: "Tremors",
      description: "An earthquake will shake your foundation!",
      target_height: 250.0,
      budget: 12,
      test_kinds: [Earthquake],
      available_pieces: [(Block, Stone, 4), (Block, Wood, 4), (Beam, Wood, 4)],
      world_index: 0,
    },
    // Level 5: Triangle Power
    {
      name: "Triangle Power",
      description: "Triangles add stability. Survive wind and quake.",
      target_height: 350.0,
      budget: 15,
      test_kinds: [Wind, Earthquake],
      available_pieces: [
        (Block, Wood, 4),
        (Beam, Wood, 4),
        (Triangle, Wood, 4),
        (Block, Stone, 3),
      ],
      world_index: 0,
    },
    // Level 6: Steel Nerves
    {
      name: "Steel Nerves",
      description: "Steel beams for a tall tower under bombardment.",
      target_height: 400.0,
      budget: 14,
      test_kinds: [Impact],
      available_pieces: [
        (Beam, Steel, 4),
        (Block, Stone, 4),
        (Block, Wood, 3),
        (Triangle, Wood, 3),
      ],
      world_index: 0,
    },
    // Level 7: Full Assault
    {
      name: "Full Assault",
      description: "Wind, earthquake, then projectile. Good luck!",
      target_height: 350.0,
      budget: 18,
      test_kinds: [Wind, Earthquake, Impact],
      available_pieces: [
        (Block, Stone, 4),
        (Block, Wood, 4),
        (Beam, Steel, 4),
        (Triangle, Wood, 3),
        (Arch, Stone, 3),
      ],
      world_index: 0,
    },
    // ============================================
    // WORLD 2: DESERT RUINS (levels 7-13)
    // Stronger wind, sandstorm (wind shifts), harsher terrain
    // ============================================
    // Level 8: Desert Foundations
    {
      name: "Desert Foundations",
      description: "Build on shifting sands. Wind is stronger here.",
      target_height: 280.0,
      budget: 12,
      test_kinds: [Wind],
      available_pieces: [(Block, Stone, 5), (Beam, Wood, 4), (Block, Wood, 3)],
      world_index: 1,
    },
    // Level 9: Sandstorm Surge
    {
      name: "Sandstorm Surge",
      description: "Sandstorm! Wind changes direction mid-test.",
      target_height: 320.0,
      budget: 14,
      test_kinds: [Wind, Wind],
      available_pieces: [
        (Block, Stone, 4),
        (Beam, Steel, 4),
        (Triangle, Wood, 3),
        (Block, Wood, 3),
      ],
      world_index: 1,
    },
    // Level 10: Oasis Tower
    {
      name: "Oasis Tower",
      description: "Build tall with limited steel. Desert quakes lurk.",
      target_height: 380.0,
      budget: 16,
      test_kinds: [Earthquake, Wind],
      available_pieces: [
        (Block, Stone, 5),
        (Beam, Steel, 3),
        (Block, Wood, 4),
        (Triangle, Wood, 4),
      ],
      world_index: 1,
    },
    // Level 11: Pyramid Scheme
    {
      name: "Pyramid Scheme",
      description: "Use triangles and arches to resist the desert wind.",
      target_height: 400.0,
      budget: 18,
      test_kinds: [Wind, Wind, Earthquake],
      available_pieces: [
        (Triangle, Wood, 6),
        (Arch, Stone, 4),
        (Block, Stone, 4),
        (Beam, Steel, 4),
      ],
      world_index: 1,
    },
    // Level 12: Scorching Impact
    {
      name: "Scorching Impact",
      description: "Sandstorm then projectile. Stone is your friend.",
      target_height: 420.0,
      budget: 18,
      test_kinds: [Wind, Impact],
      available_pieces: [
        (Block, Stone, 6),
        (Beam, Steel, 4),
        (Triangle, Wood, 4),
        (Arch, Stone, 3),
        (Cable, Steel, 3),
      ],
      world_index: 1,
    },
    // Level 13: Desert Gauntlet
    {
      name: "Desert Gauntlet",
      description: "All hazards at 1.5x wind. Brace yourself!",
      target_height: 450.0,
      budget: 22,
      test_kinds: [Wind, Earthquake, Impact, Wind],
      available_pieces: [
        (Block, Stone, 5),
        (Block, Wood, 4),
        (Beam, Steel, 5),
        (Triangle, Wood, 4),
        (Arch, Stone, 3),
        (Cable, Steel, 3),
      ],
      world_index: 1,
    },
    // Level 14: Ruins Restored
    {
      name: "Ruins Restored",
      description: "Rebuild the ancient ruin. Use every piece wisely.",
      target_height: 500.0,
      budget: 26,
      test_kinds: [Wind, Earthquake, Impact],
      available_pieces: [
        (Block, Stone, 6),
        (Block, Wood, 4),
        (Beam, Steel, 5),
        (Beam, Wood, 4),
        (Triangle, Wood, 4),
        (Arch, Stone, 4),
        (Cable, Steel, 3),
      ],
      world_index: 1,
    },
    // ============================================
    // WORLD 3: ARCTIC PEAKS (levels 14-19)
    // Ice friction (bodies slide more), heavy snow (gravity*1.3)
    // ============================================
    // Level 15: Frozen Ground
    {
      name: "Frozen Ground",
      description: "Ice makes everything slippery. Build carefully!",
      target_height: 250.0,
      budget: 12,
      test_kinds: [Wind],
      available_pieces: [(Block, Stone, 5), (Block, Wood, 4), (Beam, Steel, 3)],
      world_index: 2,
    },
    // Level 16: Snow Load
    {
      name: "Snow Load",
      description: "Heavy snow presses down. Gravity is 1.3x stronger.",
      target_height: 300.0,
      budget: 14,
      test_kinds: [Earthquake],
      available_pieces: [
        (Block, Stone, 5),
        (Beam, Steel, 4),
        (Triangle, Wood, 3),
        (Block, Wood, 3),
      ],
      world_index: 2,
    },
    // Level 17: Blizzard Bastion
    {
      name: "Blizzard Bastion",
      description: "Blizzard winds plus heavy gravity. Steel is key.",
      target_height: 350.0,
      budget: 16,
      test_kinds: [Wind, Wind, Earthquake],
      available_pieces: [
        (Beam, Steel, 6),
        (Block, Stone, 4),
        (Triangle, Wood, 4),
        (Cable, Steel, 3),
      ],
      world_index: 2,
    },
    // Level 18: Avalanche Alley
    {
      name: "Avalanche Alley",
      description: "Impact from above simulates an avalanche!",
      target_height: 380.0,
      budget: 18,
      test_kinds: [Impact, Wind, Earthquake],
      available_pieces: [
        (Block, Stone, 5),
        (Beam, Steel, 5),
        (Triangle, Wood, 4),
        (Arch, Stone, 3),
        (Cable, Steel, 3),
      ],
      world_index: 2,
    },
    // Level 19: Glacier Spire
    {
      name: "Glacier Spire",
      description: "Build a spire on ice. Wind, quake, and impact.",
      target_height: 450.0,
      budget: 22,
      test_kinds: [Wind, Earthquake, Impact, Wind],
      available_pieces: [
        (Block, Stone, 5),
        (Block, Wood, 4),
        (Beam, Steel, 6),
        (Triangle, Wood, 4),
        (Arch, Stone, 3),
        (Cable, Steel, 4),
      ],
      world_index: 2,
    },
    // Level 20: Summit of the World
    {
      name: "Summit of the World",
      description: "The ultimate challenge. Build the tallest tower on ice!",
      target_height: 600.0,
      budget: 30,
      test_kinds: [Wind, Earthquake, Impact, Wind, Earthquake],
      available_pieces: [
        (Block, Stone, 6),
        (Block, Wood, 4),
        (Beam, Steel, 6),
        (Beam, Wood, 4),
        (Triangle, Wood, 5),
        (Arch, Stone, 4),
        (Cable, Steel, 4),
      ],
      world_index: 2,
    },
  ]
}

///|
pub fn get_sandbox_inventory() -> Array[
  (@types.PieceKind, @types.Material, Int),
] {
  [
    (Block, Wood, 99),
    (Block, Stone, 99),
    (Block, Steel, 99),
    (Beam, Wood, 99),
    (Beam, Stone, 99),
    (Beam, Steel, 99),
    (Triangle, Wood, 99),
    (Triangle, Stone, 99),
    (Arch, Stone, 99),
    (Arch, Steel, 99),
    (Cable, Steel, 99),
  ]
}

///|
/// Returns the number of levels in a given world.
pub fn world_level_count(world_idx : Int) -> Int {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    let w = worlds[world_idx]
    w.level_end - w.level_start + 1
  } else {
    0
  }
}

///|
/// Returns the world name for display.
pub fn world_name(world_idx : Int) -> String {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    worlds[world_idx].name
  } else {
    "Unknown"
  }
}

///|
/// Returns the world theme for a given world index.
pub fn world_theme(world_idx : Int) -> @types.WorldTheme {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    worlds[world_idx].theme
  } else {
    StoneFortress
  }
}

///|
/// Returns physics modifiers for a world.
pub fn world_gravity_mult(world_idx : Int) -> Float {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    worlds[world_idx].gravity_mult
  } else {
    1.0
  }
}

///|
/// Returns the wind multiplier for a world.
pub fn world_wind_mult(world_idx : Int) -> Float {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    worlds[world_idx].wind_mult
  } else {
    1.0
  }
}

///|
/// Returns the friction multiplier for a world.
pub fn world_friction_mult(world_idx : Int) -> Float {
  let worlds = get_worlds()
  if world_idx >= 0 && world_idx < worlds.length() {
    worlds[world_idx].friction_mult
  } else {
    1.0
  }
}
