///|
fn c(kind : @types.ClueKind, a : Int, b : Int, text : String) -> @types.Clue {
  @types.new_clue(kind, a, b, text)
}

// Rock indices for reference:
// 0=Sandstone, 1=Limestone, 2=Shale, 3=Granite, 4=Basalt, 5=Coal, 6=Chalk, 7=Slate

///|
pub fn get_level(idx : Int) -> @types.Level {
  match idx {
    // ===== TIER 1: Surface (levels 0-7, 4-5 layers, 3-4 clues) =====
    0 =>
      @types.new_level(
        Surface,
        "First Dig",
        [Sandstone, Limestone, Shale, Chalk],
        [
          c(Dating, 0, 0, "Sandstone is the bottom layer"),
          c(Superposition, 1, 0, "Limestone sits directly above sandstone"),
          c(Dating, 6, 3, "Chalk is the top layer"),
        ],
        4,
      )
    1 =>
      @types.new_level(
        Surface,
        "Layer Cake",
        [Limestone, Shale, Coal, Sandstone],
        [
          c(Dating, 2, 0, "Shale is the bottom layer"),
          c(Superposition, 5, 2, "Coal sits directly above shale"),
          c(Superposition, 0, 5, "Sandstone sits directly above coal"),
          c(Dating, 1, 3, "Limestone is the top layer"),
        ],
        4,
      )
    2 =>
      @types.new_level(
        Surface,
        "Fossil Record",
        [Chalk, Limestone, Sandstone, Shale, Coal],
        [
          c(Dating, 2, 0, "Shale is the bottom layer"),
          c(Superposition, 0, 2, "Sandstone sits directly above shale"),
          c(Dating, 5, 2, "Coal is the 3rd layer"),
          c(Superposition, 6, 5, "Chalk sits directly above coal"),
        ],
        5,
      )
    3 =>
      @types.new_level(
        Surface,
        "Ancient Seabed",
        [Limestone, Chalk, Sandstone, Shale],
        [
          c(Dating, 1, 0, "Limestone is the bottom layer"),
          c(Dating, 6, 1, "Chalk is the 2nd layer"),
          c(Superposition, 0, 6, "Sandstone sits directly above chalk"),
        ],
        4,
      )
    4 =>
      @types.new_level(
        Surface,
        "Eroded Cliff",
        [Sandstone, Granite, Shale, Limestone, Coal],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 2, 3, "Shale sits directly above granite"),
          c(Dating, 0, 2, "Sandstone is the 3rd layer"),
          c(Superposition, 1, 0, "Limestone sits directly above sandstone"),
        ],
        5,
      )
    5 =>
      @types.new_level(
        Surface,
        "Desert Outcrop",
        [Sandstone, Chalk, Limestone, Shale, Coal],
        [
          c(Dating, 5, 0, "Coal is the bottom layer"),
          c(Superposition, 2, 5, "Shale sits directly above coal"),
          c(Superposition, 0, 2, "Sandstone sits directly above shale"),
          c(Dating, 6, 4, "Chalk is the top layer"),
        ],
        5,
      )
    6 =>
      @types.new_level(
        Surface,
        "River Cut",
        [Shale, Limestone, Granite, Sandstone],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Dating, 2, 3, "Shale is the top layer"),
          c(Superposition, 1, 3, "Limestone sits directly above granite"),
        ],
        4,
      )
    7 =>
      @types.new_level(
        Surface,
        "Quarry Face",
        [Coal, Sandstone, Limestone, Chalk, Shale],
        [
          c(Dating, 0, 0, "Sandstone is the bottom layer"),
          c(Superposition, 1, 0, "Limestone sits directly above sandstone"),
          c(Superposition, 5, 1, "Coal sits directly above limestone"),
          c(Dating, 6, 4, "Chalk is the top layer"),
        ],
        5,
      )
    // ===== TIER 2: Bedrock (levels 8-16, 6-7 layers, 5-7 clues) =====
    8 =>
      @types.new_level(
        Bedrock,
        "Deep Valley",
        [Sandstone, Limestone, Shale, Granite, Coal, Chalk],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Superposition, 0, 2, "Sandstone sits directly above shale"),
          c(Dating, 5, 3, "Coal is the 4th layer"),
          c(FossilAge, 1, 6, "Limestone is older than chalk"),
        ],
        6,
      )
    9 =>
      @types.new_level(
        Bedrock,
        "Cave System",
        [Limestone, Shale, Granite, Sandstone, Coal, Slate],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 7, 3, "Slate sits directly above granite"),
          c(FossilAge, 2, 1, "Shale is older than limestone"),
          c(Dating, 5, 5, "Coal is the top layer"),
          c(Unconformity, 0, 5, "Gap between sandstone and coal"),
        ],
        7,
      )
    10 =>
      @types.new_level(
        Bedrock,
        "Mountain Pass",
        [Chalk, Limestone, Shale, Granite, Sandstone, Slate, Coal],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 2, 3, "Shale sits directly above granite"),
          c(FossilAge, 7, 0, "Slate is older than sandstone"),
          c(FossilAge, 0, 1, "Sandstone is older than limestone"),
          c(Dating, 6, 6, "Chalk is the top layer"),
          c(Superposition, 1, 0, "Limestone sits directly above sandstone"),
        ],
        7,
      )
    11 =>
      @types.new_level(
        Bedrock,
        "Coastal Bluff",
        [Sandstone, Limestone, Coal, Chalk, Shale, Slate],
        [
          c(Dating, 7, 0, "Slate is the bottom layer"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Superposition, 2, 7, "Shale sits directly above slate"),
          c(Dating, 5, 2, "Coal is the 3rd layer"),
          c(FossilAge, 0, 6, "Sandstone is older than chalk"),
          c(Superposition, 6, 1, "Chalk sits directly above limestone"),
        ],
        6,
      )
    12 =>
      @types.new_level(
        Bedrock,
        "Fault Line",
        [Granite, Limestone, Shale, Sandstone, Coal, Chalk, Slate],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 7, 3, "Slate sits directly above granite"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Dating, 5, 4, "Coal is the 5th layer"),
          c(FossilAge, 0, 1, "Sandstone is older than limestone"),
          c(Unconformity, 1, 6, "Gap between limestone and chalk"),
        ],
        8,
      )
    13 =>
      @types.new_level(
        Bedrock,
        "Glacial Moraine",
        [Sandstone, Shale, Granite, Limestone, Coal, Chalk],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(FossilAge, 0, 1, "Sandstone is older than limestone"),
          c(Superposition, 5, 1, "Coal sits directly above limestone"),
          c(Dating, 6, 5, "Chalk is the top layer"),
        ],
        6,
      )
    14 =>
      @types.new_level(
        Bedrock,
        "Volcanic Rim",
        [Basalt, Sandstone, Limestone, Shale, Chalk, Granite, Coal],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Superposition, 2, 3, "Shale sits directly above granite"),
          c(FossilAge, 0, 1, "Sandstone is older than limestone"),
          c(Dating, 4, 4, "Basalt is the 5th layer"),
          c(Unconformity, 4, 6, "Gap between basalt and chalk"),
          c(Dating, 6, 6, "Chalk is the top layer"),
        ],
        7,
      )
    15 =>
      @types.new_level(
        Bedrock,
        "Subduction Zone",
        [Slate, Shale, Granite, Limestone, Coal, Sandstone],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 7, 3, "Slate sits directly above granite"),
          c(FossilAge, 7, 2, "Slate is older than shale"),
          c(Dating, 5, 5, "Coal is the top layer"),
          c(FossilAge, 0, 5, "Sandstone is older than coal"),
          c(Superposition, 1, 0, "Limestone sits directly above sandstone"),
        ],
        6,
      )
    16 =>
      @types.new_level(
        Bedrock,
        "Mineral Vein",
        [Granite, Shale, Sandstone, Coal, Limestone, Chalk, Slate],
        [
          c(Dating, 7, 0, "Slate is the bottom layer"),
          c(Superposition, 3, 7, "Granite sits directly above slate"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Superposition, 2, 3, "Shale sits directly above granite"),
          c(Dating, 5, 4, "Coal is the 5th layer"),
          c(FossilAge, 1, 6, "Limestone is older than chalk"),
          c(Dating, 6, 6, "Chalk is the top layer"),
        ],
        7,
      )
    // ===== TIER 3: Deep Core (levels 17-24, 7-8 layers, 7-10 clues) =====
    17 =>
      @types.new_level(
        DeepCore,
        "Magma Chamber",
        [Granite, Basalt, Sandstone, Limestone, Shale, Coal, Chalk],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 2, 3, "Shale sits directly above granite"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Intrusion, 4, 0, "Basalt intrudes into sandstone"),
          c(FossilAge, 0, 1, "Sandstone is older than limestone"),
          c(Dating, 5, 4, "Coal is the 5th layer"),
          c(Unconformity, 4, 6, "Gap between basalt and chalk"),
        ],
        8,
      )
    18 =>
      @types.new_level(
        DeepCore,
        "Tectonic Rift",
        [Granite, Basalt, Sandstone, Limestone, Shale, Coal, Slate, Chalk],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 7, 3, "Slate sits directly above granite"),
          c(FossilAge, 7, 2, "Slate is older than shale"),
          c(Superposition, 0, 2, "Sandstone sits directly above shale"),
          c(Intrusion, 4, 7, "Basalt intrudes into slate"),
          c(Dating, 5, 5, "Coal is the 6th layer"),
          c(Unconformity, 5, 6, "Gap between coal and chalk"),
          c(Dating, 6, 7, "Chalk is the top layer"),
        ],
        8,
      )
    19 =>
      @types.new_level(
        DeepCore,
        "Fossil Canyon",
        [Sandstone, Limestone, Shale, Granite, Basalt, Coal, Chalk, Slate],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 7, 3, "Slate sits directly above granite"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Dating, 0, 3, "Sandstone is the 4th layer"),
          c(Intrusion, 4, 2, "Basalt intrudes into shale"),
          c(FossilAge, 1, 6, "Limestone is older than chalk"),
          c(Superposition, 6, 1, "Chalk sits directly above limestone"),
          c(Unconformity, 4, 5, "Gap between basalt and coal"),
        ],
        9,
      )
    20 =>
      @types.new_level(
        DeepCore,
        "Mantle Plume",
        [Granite, Basalt, Sandstone, Limestone, Shale, Coal, Chalk],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Superposition, 2, 3, "Shale sits directly above granite"),
          c(Intrusion, 4, 2, "Basalt intrudes into shale"),
          c(Superposition, 0, 4, "Sandstone sits directly above basalt"),
          c(FossilAge, 1, 5, "Limestone is older than coal"),
          c(Dating, 6, 6, "Chalk is the top layer"),
        ],
        7,
      )
    21 =>
      @types.new_level(
        DeepCore,
        "Crystal Cavern",
        [Granite, Basalt, Sandstone, Limestone, Shale, Coal, Slate, Chalk],
        [
          c(Dating, 7, 0, "Slate is the bottom layer"),
          c(Superposition, 3, 7, "Granite sits directly above slate"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Dating, 2, 2, "Shale is the 3rd layer"),
          c(Intrusion, 4, 3, "Basalt intrudes into granite"),
          c(Superposition, 0, 4, "Sandstone sits directly above basalt"),
          c(FossilAge, 1, 6, "Limestone is older than chalk"),
          c(Unconformity, 5, 6, "Gap between coal and chalk"),
          c(Dating, 6, 7, "Chalk is the top layer"),
        ],
        9,
      )
    22 =>
      @types.new_level(
        DeepCore,
        "Obsidian Depths",
        [Granite, Basalt, Sandstone, Limestone, Shale, Coal, Chalk, Slate],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 2, 3, "Shale sits directly above granite"),
          c(FossilAge, 2, 7, "Shale is older than slate"),
          c(Intrusion, 4, 2, "Basalt intrudes into shale"),
          c(Superposition, 7, 4, "Slate sits directly above basalt"),
          c(Dating, 0, 4, "Sandstone is the 5th layer"),
          c(FossilAge, 1, 6, "Limestone is older than chalk"),
          c(Unconformity, 0, 6, "Gap between sandstone and chalk"),
          c(Dating, 6, 7, "Chalk is the top layer"),
          c(Superposition, 1, 0, "Limestone sits directly above sandstone"),
        ],
        8,
      )
    23 =>
      @types.new_level(
        DeepCore,
        "Core Sample",
        [Granite, Basalt, Sandstone, Limestone, Coal, Chalk, Slate],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 7, 3, "Slate sits directly above granite"),
          c(Intrusion, 4, 7, "Basalt intrudes into slate"),
          c(FossilAge, 0, 1, "Sandstone is older than limestone"),
          c(Superposition, 0, 4, "Sandstone sits directly above basalt"),
          c(Dating, 5, 5, "Coal is the 6th layer"),
          c(Unconformity, 4, 5, "Gap between basalt and coal"),
          c(Dating, 6, 6, "Chalk is the top layer"),
        ],
        8,
      )
    _ =>
      // Level 24: Final level
      @types.new_level(
        DeepCore,
        "Earth's Heart",
        [Granite, Basalt, Sandstone, Limestone, Shale, Coal, Chalk, Slate],
        [
          c(Dating, 3, 0, "Granite is the bottom layer"),
          c(Superposition, 7, 3, "Slate sits directly above granite"),
          c(FossilAge, 7, 2, "Slate is older than shale"),
          c(Intrusion, 4, 7, "Basalt intrudes into slate"),
          c(FossilAge, 2, 0, "Shale is older than sandstone"),
          c(Superposition, 0, 2, "Sandstone sits directly above shale"),
          c(Dating, 1, 5, "Limestone is the 6th layer"),
          c(Unconformity, 4, 6, "Gap between basalt and chalk"),
          c(Superposition, 6, 5, "Chalk sits directly above coal"),
          c(Dating, 6, 7, "Chalk is the top layer"),
        ],
        9,
      )
  }
}

///|
pub fn level_count() -> Int {
  @types.total_levels
}
