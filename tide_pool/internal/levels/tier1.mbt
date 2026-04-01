///|
pub fn get_level_1() -> @types.LevelDef {
  {
    id: 0,
    name: "First Steps",
    tier: Shallow,
    description: "Place barnacles where the tide reaches them.",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [Barnacle],
    organism_counts: [3],
    target_species: [Barnacle],
    rock_cells: [],
  }
}

///|
pub fn get_level_2() -> @types.LevelDef {
  {
    id: 1,
    name: "Deep Dweller",
    tier: Shallow,
    description: "Anemones need constant water. Place them deep.",
    depth_profile: [0, 1, 1, 2, 2, 3, 3, 4],
    available_organisms: [Anemone],
    organism_counts: [2],
    target_species: [Anemone],
    rock_cells: [],
  }
}

///|
pub fn get_level_3() -> @types.LevelDef {
  {
    id: 2,
    name: "Green Carpet",
    tier: Shallow,
    description: "Algae needs light and some water. Find the right zone.",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [Algae],
    organism_counts: [3],
    target_species: [Algae],
    rock_cells: [],
  }
}

///|
pub fn get_level_4() -> @types.LevelDef {
  {
    id: 3,
    name: "Crab Walk",
    tier: Shallow,
    description: "Crabs eat algae. Place both to keep balance.",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [Algae, Crab],
    organism_counts: [3, 1],
    target_species: [Algae, Crab],
    rock_cells: [],
  }
}

///|
pub fn get_level_5() -> @types.LevelDef {
  {
    id: 4,
    name: "Rocky Shore",
    tier: Shallow,
    description: "Navigate around rocks to place organisms.",
    depth_profile: [0, 1, 1, 2, 2, 3, 3, 4],
    available_organisms: [Barnacle, Anemone],
    organism_counts: [2, 2],
    target_species: [Barnacle, Anemone],
    rock_cells: [(1, 2), (2, 5), (3, 1)],
  }
}

///|
pub fn get_level_6() -> @types.LevelDef {
  {
    id: 5,
    name: "Tidal Garden",
    tier: Shallow,
    description: "Create a diverse pool with three species.",
    depth_profile: [0, 0, 1, 2, 2, 3, 3, 4],
    available_organisms: [Barnacle, Algae, Crab],
    organism_counts: [2, 2, 1],
    target_species: [Barnacle, Algae],
    rock_cells: [],
  }
}

///|
pub fn get_level_7() -> @types.LevelDef {
  {
    id: 6,
    name: "Urchin Patrol",
    tier: Shallow,
    description: "Urchins control algae blooms. Balance the grazing.",
    depth_profile: [0, 0, 1, 1, 2, 3, 3, 4],
    available_organisms: [Algae, Urchin],
    organism_counts: [4, 2],
    target_species: [Algae, Urchin],
    rock_cells: [],
  }
}
