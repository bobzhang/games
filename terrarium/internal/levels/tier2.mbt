///|
pub fn level_08() -> @types.LevelDef {
  {
    id: 7,
    name: "Restricted Zone",
    tier: Intermediate,
    description: "Some cells are blocked. Place carefully!",
    initial_resources: @types.new_resources(40.0, 40.0, 50.0, 40.0),
    available_organisms: [Moss, Fern, Beetle],
    organism_counts: [2, 1, 1],
    par_turns: 10,
    locked_cells: [(0, 0), (0, 1), (1, 0), (5, 5), (5, 4), (4, 5)],
  }
}

///|
pub fn level_09() -> @types.LevelDef {
  {
    id: 8,
    name: "Water Crisis",
    tier: Intermediate,
    description: "Water is scarce. Use worms to help.",
    initial_resources: @types.new_resources(50.0, 50.0, 20.0, 40.0),
    available_organisms: [Moss, Worm, Snail],
    organism_counts: [2, 2, 1],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_10() -> @types.LevelDef {
  {
    id: 9,
    name: "CO2 Shortage",
    tier: Intermediate,
    description: "Plants need CO2! Add some animals.",
    initial_resources: @types.new_resources(60.0, 15.0, 50.0, 40.0),
    available_organisms: [Fern, Beetle, Snail],
    organism_counts: [2, 2, 1],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_11() -> @types.LevelDef {
  {
    id: 10,
    name: "Nutrient Starved",
    tier: Intermediate,
    description: "Soil is poor. Decomposers are essential.",
    initial_resources: @types.new_resources(50.0, 50.0, 50.0, 10.0),
    available_organisms: [Moss, Fungus, Worm],
    organism_counts: [2, 2, 2],
    par_turns: 10,
    locked_cells: [(2, 2), (3, 3)],
  }
}

///|
pub fn level_12() -> @types.LevelDef {
  {
    id: 11,
    name: "Dense Forest",
    tier: Intermediate,
    description: "Many organisms, tight quarters. Watch O2 carefully.",
    initial_resources: @types.new_resources(30.0, 50.0, 50.0, 40.0),
    available_organisms: [Moss, Fern, Beetle, Fungus],
    organism_counts: [2, 2, 1, 1],
    par_turns: 10,
    locked_cells: [(0, 5), (5, 0)],
  }
}

///|
pub fn level_13() -> @types.LevelDef {
  {
    id: 12,
    name: "The Corridor",
    tier: Intermediate,
    description: "Only a narrow strip is available. Precision matters.",
    initial_resources: @types.new_resources(40.0, 40.0, 40.0, 40.0),
    available_organisms: [Moss, Snail, Worm],
    organism_counts: [3, 1, 1],
    par_turns: 10,
    locked_cells: [
      (0, 0), (0, 1), (0, 4), (0, 5), (1, 0), (1, 5), (4, 0), (4, 5), (5, 0),
      (5, 1), (5, 4), (5, 5),
    ],
  }
}

///|
pub fn level_14() -> @types.LevelDef {
  {
    id: 13,
    name: "Full Chain",
    tier: Intermediate,
    description: "Use all organism types in a complete food web.",
    initial_resources: @types.new_resources(35.0, 35.0, 45.0, 35.0),
    available_organisms: [Moss, Fern, Beetle, Snail, Fungus, Worm],
    organism_counts: [2, 1, 1, 1, 1, 1],
    par_turns: 10,
    locked_cells: [],
  }
}
