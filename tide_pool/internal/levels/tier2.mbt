///|
pub fn get_level_8() -> @types.LevelDef {
  {
    id: 7,
    name: "Predator Prey",
    tier: Middle,
    description: "Starfish hunt barnacles. Keep both alive.",
    depth_profile: [0, 1, 1, 2, 2, 3, 3, 4],
    available_organisms: [Barnacle, Starfish],
    organism_counts: [4, 1],
    target_species: [Barnacle, Starfish],
    rock_cells: [],
  }
}

///|
pub fn get_level_9() -> @types.LevelDef {
  {
    id: 8,
    name: "Zonation",
    tier: Middle,
    description: "Each species has its preferred zone. Place wisely.",
    depth_profile: [0, 0, 1, 2, 2, 3, 4, 4],
    available_organisms: [Barnacle, Anemone, Algae],
    organism_counts: [2, 2, 2],
    target_species: [Barnacle, Anemone, Algae],
    rock_cells: [(2, 3), (4, 6)],
  }
}

///|
pub fn get_level_10() -> @types.LevelDef {
  {
    id: 9,
    name: "Food Web",
    tier: Middle,
    description: "Build a food chain: algae, crab, and starfish.",
    depth_profile: [0, 1, 1, 2, 3, 3, 4, 4],
    available_organisms: [Algae, Crab, Barnacle, Starfish],
    organism_counts: [3, 2, 3, 1],
    target_species: [Algae, Crab, Starfish],
    rock_cells: [],
  }
}

///|
pub fn get_level_11() -> @types.LevelDef {
  {
    id: 10,
    name: "Tidal Surge",
    tier: Middle,
    description: "High tides flood everything. Protect surface dwellers.",
    depth_profile: [1, 1, 2, 2, 3, 3, 4, 4],
    available_organisms: [Algae, Barnacle, Anemone],
    organism_counts: [3, 2, 2],
    target_species: [Algae, Barnacle],
    rock_cells: [(0, 0), (0, 1)],
  }
}

///|
pub fn get_level_12() -> @types.LevelDef {
  {
    id: 11,
    name: "Grazer Wars",
    tier: Middle,
    description: "Urchins and crabs both eat algae. Enough for all?",
    depth_profile: [0, 0, 1, 2, 2, 3, 3, 4],
    available_organisms: [Algae, Urchin, Crab],
    organism_counts: [5, 2, 2],
    target_species: [Algae, Urchin, Crab],
    rock_cells: [],
  }
}

///|
pub fn get_level_13() -> @types.LevelDef {
  {
    id: 12,
    name: "Narrow Pool",
    tier: Middle,
    description: "Rocks block many cells. Fit your ecosystem in tight spaces.",
    depth_profile: [0, 1, 2, 2, 3, 3, 4, 4],
    available_organisms: [Barnacle, Anemone, Algae, Crab],
    organism_counts: [2, 1, 2, 1],
    target_species: [Barnacle, Anemone],
    rock_cells: [(0, 2), (1, 3), (2, 4), (3, 5), (4, 6)],
  }
}

///|
pub fn get_level_14() -> @types.LevelDef {
  {
    id: 13,
    name: "Balanced Reef",
    tier: Middle,
    description: "Four species must coexist. Balance predation and grazing.",
    depth_profile: [0, 1, 1, 2, 3, 3, 4, 4],
    available_organisms: [Barnacle, Algae, Starfish, Urchin],
    organism_counts: [3, 3, 1, 2],
    target_species: [Barnacle, Algae, Starfish, Urchin],
    rock_cells: [],
  }
}
