///|
pub fn get_levels() -> Array[@types.Level] {
  [
    // Level 1: Stacking Basics
    {
      name: "Stacking Basics",
      description: "Build a simple tower. No hazards.",
      target_height: 200.0,
      budget: 8,
      test_kinds: [],
      available_pieces: [
        (Block, Wood, 4),
        (Beam, Wood, 4),
      ],
    },
    // Level 2: Gentle Breeze
    {
      name: "Gentle Breeze",
      description: "Your tower must survive a light wind.",
      target_height: 250.0,
      budget: 10,
      test_kinds: [Wind],
      available_pieces: [
        (Block, Wood, 5),
        (Beam, Wood, 5),
      ],
    },
    // Level 3: Stone Foundation
    {
      name: "Stone Foundation",
      description: "Use stone blocks for a sturdy base.",
      target_height: 300.0,
      budget: 12,
      test_kinds: [Wind],
      available_pieces: [
        (Block, Stone, 4),
        (Block, Wood, 4),
        (Beam, Wood, 4),
      ],
    },
    // Level 4: Tremors
    {
      name: "Tremors",
      description: "An earthquake will shake your foundation!",
      target_height: 250.0,
      budget: 12,
      test_kinds: [Earthquake],
      available_pieces: [
        (Block, Stone, 4),
        (Block, Wood, 4),
        (Beam, Wood, 4),
      ],
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
    },
    // Level 8: Arch Rivals
    {
      name: "Arch Rivals",
      description: "Use arches for maximum height under all hazards.",
      target_height: 450.0,
      budget: 20,
      test_kinds: [Wind, Earthquake, Impact],
      available_pieces: [
        (Arch, Stone, 5),
        (Beam, Steel, 4),
        (Block, Stone, 3),
        (Triangle, Wood, 4),
        (Cable, Steel, 4),
      ],
    },
    // Level 9: Cable Challenge
    {
      name: "Cable Challenge",
      description: "Cables and beams only. Reach for the sky!",
      target_height: 500.0,
      budget: 22,
      test_kinds: [Wind, Earthquake, Impact],
      available_pieces: [
        (Beam, Steel, 8),
        (Cable, Steel, 8),
        (Block, Stone, 6),
      ],
    },
    // Level 10: Sky Fortress
    {
      name: "Sky Fortress",
      description: "Build the ultimate tower. Survive everything.",
      target_height: 600.0,
      budget: 30,
      test_kinds: [Wind, Earthquake, Impact],
      available_pieces: [
        (Block, Stone, 6),
        (Block, Wood, 4),
        (Beam, Steel, 6),
        (Beam, Wood, 4),
        (Triangle, Wood, 4),
        (Arch, Stone, 3),
        (Cable, Steel, 3),
      ],
    },
  ]
}

///|
pub fn get_sandbox_inventory() -> Array[(@types.PieceKind, @types.Material, Int)] {
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
