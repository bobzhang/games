///|
pub fn get_level_15() -> @types.LevelDef {
  {
    id: 14,
    name: "Deep Trench",
    tier: Deep,
    description: "Extreme depths. Only specialized organisms survive.",
    depth_profile: [2, 2, 3, 3, 4, 4, 4, 4],
    available_organisms: [Anemone, Starfish, Urchin, Barnacle],
    organism_counts: [3, 2, 2, 3],
    target_species: [Anemone, Starfish, Urchin],
    rock_cells: [(0, 0), (1, 1)],
  }
}

///|
pub fn get_level_16() -> @types.LevelDef {
  {
    id: 15,
    name: "Bloom Control",
    tier: Deep,
    description: "Algae threatens to overwhelm. Deploy all grazers.",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [Algae, Urchin, Crab, Barnacle],
    organism_counts: [6, 2, 2, 2],
    target_species: [Algae, Urchin, Crab],
    rock_cells: [],
  }
}

///|
pub fn get_level_17() -> @types.LevelDef {
  {
    id: 16,
    name: "Fortress Reef",
    tier: Deep,
    description: "Heavy rock formations limit placement severely.",
    depth_profile: [1, 1, 2, 3, 3, 4, 4, 4],
    available_organisms: [Barnacle, Anemone, Algae, Crab, Starfish],
    organism_counts: [2, 2, 2, 1, 1],
    target_species: [Barnacle, Anemone, Algae, Crab],
    rock_cells: [
      (0, 1), (0, 3), (1, 0), (1, 4), (2, 2), (2, 6), (3, 1), (3, 5),
      (4, 3), (4, 7),
    ],
  }
}

///|
pub fn get_level_18() -> @types.LevelDef {
  {
    id: 17,
    name: "Full Ecosystem",
    tier: Deep,
    description: "All six species must thrive together.",
    depth_profile: [0, 1, 1, 2, 3, 3, 4, 4],
    available_organisms: [Barnacle, Anemone, Crab, Starfish, Algae, Urchin],
    organism_counts: [2, 2, 1, 1, 3, 1],
    target_species: [Barnacle, Anemone, Crab, Starfish, Algae, Urchin],
    rock_cells: [],
  }
}

///|
pub fn get_level_19() -> @types.LevelDef {
  {
    id: 18,
    name: "Shallow Nightmare",
    tier: Deep,
    description: "Very shallow pool. Everything dries out at low tide.",
    depth_profile: [0, 0, 0, 0, 1, 1, 1, 2],
    available_organisms: [Barnacle, Anemone, Algae, Urchin, Crab],
    organism_counts: [3, 2, 4, 2, 2],
    target_species: [Anemone, Algae, Urchin],
    rock_cells: [(0, 0), (5, 7)],
  }
}

///|
pub fn get_level_20() -> @types.LevelDef {
  {
    id: 19,
    name: "Tidal Master",
    tier: Deep,
    description: "The ultimate challenge. All species, many rocks, extreme tides.",
    depth_profile: [1, 2, 2, 3, 3, 4, 4, 4],
    available_organisms: [Barnacle, Anemone, Crab, Starfish, Algae, Urchin],
    organism_counts: [3, 2, 2, 1, 4, 2],
    target_species: [Barnacle, Anemone, Crab, Starfish, Algae, Urchin],
    rock_cells: [
      (0, 0), (0, 4), (1, 2), (1, 6), (2, 1), (3, 5), (4, 3), (4, 7),
    ],
  }
}
