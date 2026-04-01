// Helper to make a 3x3 level

///|
fn mk3(
  name : String,
  top : Array[Int],
  front : Array[Int],
  side : Array[Int],
  budget : Int,
  connected : Bool,
  par_moves : Int,
  par_voxels : Int,
  tier : @types.Tier,
) -> @types.Level {
  let t = @types.silhouette_from_bits(3, 3, top)
  let f = @types.silhouette_from_bits(3, 3, front)
  let s = @types.silhouette_from_bits(3, 3, side)
  {
    size: 3,
    targets: @types.new_target_set(t, f, s),
    voxel_budget: budget,
    requires_connected: connected,
    par_moves,
    par_voxels,
    tier,
    name,
  }
}

// Helper to make a 4x4 level

///|
fn mk4(
  name : String,
  top : Array[Int],
  front : Array[Int],
  side : Array[Int],
  budget : Int,
  connected : Bool,
  par_moves : Int,
  par_voxels : Int,
  tier : @types.Tier,
) -> @types.Level {
  let t = @types.silhouette_from_bits(4, 4, top)
  let f = @types.silhouette_from_bits(4, 4, front)
  let s = @types.silhouette_from_bits(4, 4, side)
  {
    size: 4,
    targets: @types.new_target_set(t, f, s),
    voxel_budget: budget,
    requires_connected: connected,
    par_moves,
    par_voxels,
    tier,
    name,
  }
}

// Helper to make a 5x5 level

///|
fn mk5(
  name : String,
  top : Array[Int],
  front : Array[Int],
  side : Array[Int],
  budget : Int,
  connected : Bool,
  par_moves : Int,
  par_voxels : Int,
  tier : @types.Tier,
) -> @types.Level {
  let t = @types.silhouette_from_bits(5, 5, top)
  let f = @types.silhouette_from_bits(5, 5, front)
  let s = @types.silhouette_from_bits(5, 5, side)
  {
    size: 5,
    targets: @types.new_target_set(t, f, s),
    voxel_budget: budget,
    requires_connected: connected,
    par_moves,
    par_voxels,
    tier,
    name,
  }
}

///|
pub fn get_all_levels() -> Array[@types.Level] {
  [
    // ============ TIER 1: SHAPES (3x3x3) ============
    // Level 1: "Dot" - single column
    // Top: center dot, Front: center column, Side: center column
    mk3(
      "Dot",
      [0b010, 0b000, 0b000],
      [0b010, 0b010, 0b010],
      [0b000, 0b000, 0b100],
      -1,
      false,
      3,
      3,
      Shapes,
    ),
    // Level 2: "Plus" - cross shape from top
    mk3(
      "Plus",
      [0b010, 0b111, 0b010],
      [0b010, 0b111, 0b010],
      [0b010, 0b111, 0b010],
      -1,
      false,
      9,
      9,
      Shapes,
    ),
    // Level 3: "Corner"
    mk3(
      "Corner",
      [0b110, 0b100, 0b000],
      [0b110, 0b110, 0b000],
      [0b000, 0b011, 0b011],
      -1,
      false,
      5,
      4,
      Shapes,
    ),
    // Level 4: "L Shape"
    mk3(
      "L Shape",
      [0b100, 0b100, 0b110],
      [0b100, 0b100, 0b110],
      [0b001, 0b001, 0b011],
      -1,
      false,
      6,
      5,
      Shapes,
    ),
    // Level 5: "T Block"
    mk3(
      "T Block",
      [0b111, 0b010, 0b000],
      [0b111, 0b010, 0b000],
      [0b010, 0b010, 0b000],
      -1,
      false,
      5,
      4,
      Shapes,
    ),
    // Level 6: "Diagonal"
    mk3(
      "Diagonal",
      [0b100, 0b010, 0b001],
      [0b100, 0b010, 0b001],
      [0b100, 0b010, 0b001],
      -1,
      false,
      3,
      3,
      Shapes,
    ),
    // Level 7: "Frame"
    mk3(
      "Frame",
      [0b111, 0b101, 0b111],
      [0b111, 0b101, 0b111],
      [0b111, 0b101, 0b111],
      -1,
      false,
      20,
      20,
      Shapes,
    ),
    // Level 8: "Steps"
    mk3(
      "Steps",
      [0b100, 0b110, 0b111],
      [0b001, 0b011, 0b111],
      [0b100, 0b110, 0b111],
      -1,
      false,
      6,
      6,
      Shapes,
    ),
    // Level 9: "Pillar"
    mk3(
      "Pillar",
      [0b010, 0b010, 0b010],
      [0b111, 0b111, 0b111],
      [0b010, 0b010, 0b010],
      -1,
      false,
      9,
      9,
      Shapes,
    ),
    // Level 10: "Cross"
    mk3(
      "Cross",
      [0b010, 0b111, 0b010],
      [0b010, 0b010, 0b010],
      [0b010, 0b010, 0b010],
      -1,
      false,
      5,
      5,
      Shapes,
    ),
    // ============ TIER 2: STRUCTURES (4x4x4) ============
    // Level 11: "Tower"
    mk4(
      "Tower",
      [0b0110, 0b0110, 0b0000, 0b0000],
      [0b0110, 0b0110, 0b0110, 0b0110],
      [0b0110, 0b0110, 0b0110, 0b0110],
      20,
      false,
      16,
      16,
      Structures,
    ),
    // Level 12: "Bridge"
    mk4(
      "Bridge",
      [0b1111, 0b0000, 0b0000, 0b1111],
      [0b1001, 0b1001, 0b1001, 0b1111],
      [0b0000, 0b0000, 0b0000, 0b1111],
      20,
      false,
      12,
      12,
      Structures,
    ),
    // Level 13: "Arch"
    mk4(
      "Arch",
      [0b0110, 0b0110, 0b0110, 0b0110],
      [0b0110, 0b1111, 0b1001, 0b1001],
      [0b0110, 0b1111, 0b1001, 0b1001],
      18,
      false,
      14,
      14,
      Structures,
    ),
    // Level 14: "Pyramid"
    mk4(
      "Pyramid",
      [0b0000, 0b0110, 0b0110, 0b0000],
      [0b0000, 0b0110, 0b1111, 0b1111],
      [0b0000, 0b0110, 0b1111, 0b1111],
      16,
      false,
      12,
      10,
      Structures,
    ),
    // Level 15: "Window"
    mk4(
      "Window",
      [0b1111, 0b1001, 0b1001, 0b1111],
      [0b1111, 0b1001, 0b1001, 0b1111],
      [0b1111, 0b1111, 0b1111, 0b1111],
      24,
      false,
      16,
      16,
      Structures,
    ),
    // Level 16: "Zigzag"
    mk4(
      "Zigzag",
      [0b1100, 0b0110, 0b0011, 0b0000],
      [0b1100, 0b0110, 0b0011, 0b0000],
      [0b1000, 0b1100, 0b0110, 0b0000],
      10,
      false,
      8,
      6,
      Structures,
    ),
    // Level 17: "Fortress"
    mk4(
      "Fortress",
      [0b1111, 0b1001, 0b1001, 0b1111],
      [0b1001, 0b0000, 0b0000, 0b1111],
      [0b1001, 0b0000, 0b0000, 0b1111],
      20,
      false,
      14,
      12,
      Structures,
    ),
    // Level 18: "Staircase"
    mk4(
      "Staircase",
      [0b1000, 0b1100, 0b1110, 0b1111],
      [0b0001, 0b0011, 0b0111, 0b1111],
      [0b1000, 0b1100, 0b1110, 0b1111],
      12,
      false,
      10,
      10,
      Structures,
    ),
    // Level 19: "Tunnel"
    mk4(
      "Tunnel",
      [0b1111, 0b0000, 0b0000, 0b1111],
      [0b1111, 0b1001, 0b1001, 0b1111],
      [0b1001, 0b1001, 0b1001, 0b1001],
      18,
      false,
      16,
      16,
      Structures,
    ),
    // Level 20: "Diamond"
    mk4(
      "Diamond",
      [0b0110, 0b1111, 0b1111, 0b0110],
      [0b0110, 0b1111, 0b1111, 0b0110],
      [0b0110, 0b1111, 0b1111, 0b0110],
      20,
      false,
      16,
      16,
      Structures,
    ),
    // ============ TIER 3: SCULPTURES (4x4x4 and 5x5x5) ============
    // Level 21: "Helix" (4x4x4)
    mk4(
      "Helix",
      [0b1100, 0b0110, 0b0011, 0b1001],
      [0b1001, 0b0110, 0b0110, 0b1001],
      [0b1001, 0b0110, 0b0110, 0b1001],
      14,
      true,
      12,
      8,
      Sculptures,
    ),
    // Level 22: "Knot" (4x4x4)
    mk4(
      "Knot",
      [0b0110, 0b1111, 0b1111, 0b0110],
      [0b0110, 0b1001, 0b1001, 0b0110],
      [0b0110, 0b1001, 0b1001, 0b0110],
      16,
      true,
      14,
      12,
      Sculptures,
    ),
    // Level 23: "Spiral" (5x5x5)
    mk5(
      "Spiral",
      [0b11111, 0b10001, 0b10101, 0b10001, 0b11111],
      [0b11111, 0b10001, 0b10101, 0b10001, 0b11111],
      [0b11111, 0b10001, 0b10101, 0b10001, 0b11111],
      40,
      true,
      30,
      25,
      Sculptures,
    ),
    // Level 24: "Star" (5x5x5)
    mk5(
      "Star",
      [0b00100, 0b01110, 0b11111, 0b01110, 0b00100],
      [0b00100, 0b01110, 0b11111, 0b01110, 0b00100],
      [0b00100, 0b01110, 0b11111, 0b01110, 0b00100],
      30,
      true,
      20,
      13,
      Sculptures,
    ),
    // Level 25: "Castle" (5x5x5)
    mk5(
      "Castle",
      [0b11111, 0b10001, 0b10001, 0b10001, 0b11111],
      [0b10101, 0b10101, 0b11111, 0b10001, 0b11111],
      [0b10101, 0b10101, 0b11111, 0b10001, 0b11111],
      40,
      true,
      30,
      25,
      Sculptures,
    ),
    // Level 26: "Hollow" (5x5x5)
    mk5(
      "Hollow",
      [0b11111, 0b11111, 0b11011, 0b11111, 0b11111],
      [0b11111, 0b11111, 0b11011, 0b11111, 0b11111],
      [0b11111, 0b11111, 0b11011, 0b11111, 0b11111],
      50,
      true,
      35,
      30,
      Sculptures,
    ),
    // Level 27: "Temple" (5x5x5)
    mk5(
      "Temple",
      [0b01110, 0b01110, 0b11111, 0b01110, 0b01110],
      [0b00100, 0b01110, 0b11111, 0b11111, 0b11111],
      [0b00100, 0b01110, 0b11111, 0b11111, 0b11111],
      35,
      true,
      25,
      20,
      Sculptures,
    ),
    // Level 28: "Claw" (5x5x5)
    mk5(
      "Claw",
      [0b10101, 0b10101, 0b01110, 0b00100, 0b00100],
      [0b10101, 0b10101, 0b01110, 0b00100, 0b00100],
      [0b10101, 0b10101, 0b01110, 0b00100, 0b00100],
      20,
      true,
      18,
      13,
      Sculptures,
    ),
    // Level 29: "Rings" (5x5x5)
    mk5(
      "Rings",
      [0b01110, 0b10001, 0b10001, 0b10001, 0b01110],
      [0b01110, 0b10001, 0b10001, 0b10001, 0b01110],
      [0b01110, 0b11111, 0b11111, 0b11111, 0b01110],
      35,
      true,
      28,
      22,
      Sculptures,
    ),
    // Level 30: "Masterwork" (5x5x5)
    mk5(
      "Masterwork",
      [0b11111, 0b10101, 0b11111, 0b10101, 0b11111],
      [0b11111, 0b10101, 0b11111, 0b10101, 0b11111],
      [0b11111, 0b10101, 0b11111, 0b10101, 0b11111],
      50,
      true,
      40,
      35,
      Sculptures,
    ),
  ]
}

///|
pub fn get_level(index : Int) -> @types.Level {
  let levels = get_all_levels()
  levels[index]
}
