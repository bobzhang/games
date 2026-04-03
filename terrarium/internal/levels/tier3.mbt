///|
pub fn level_15() -> @types.LevelDef {
  {
    id: 14,
    name: "Drought Land",
    tier: Advanced,
    description: "Almost no water. Every drop counts.",
    initial_resources: @types.new_resources(50.0, 50.0, 10.0, 30.0),
    available_organisms: [Moss, Worm, Fungus, Snail],
    organism_counts: [2, 2, 1, 1],
    par_turns: 10,
    locked_cells: [(0, 0), (5, 5), (0, 5), (5, 0)],
  }
}

///|
pub fn level_16() -> @types.LevelDef {
  {
    id: 15,
    name: "Oxygen Debt",
    tier: Advanced,
    description: "O2 is dangerously low. Plants are critical.",
    initial_resources: @types.new_resources(8.0, 60.0, 50.0, 40.0),
    available_organisms: [Moss, Fern, Beetle, Worm],
    organism_counts: [3, 2, 1, 1],
    par_turns: 10,
    locked_cells: [(2, 2), (3, 3), (1, 4)],
  }
}

///|
pub fn level_17() -> @types.LevelDef {
  {
    id: 16,
    name: "Island Grid",
    tier: Advanced,
    description: "Many locked cells form islands. Connect your ecosystem.",
    initial_resources: @types.new_resources(35.0, 35.0, 35.0, 35.0),
    available_organisms: [Moss, Fern, Beetle, Snail, Fungus, Worm],
    organism_counts: [2, 1, 1, 1, 1, 1],
    par_turns: 10,
    locked_cells: [
      (0, 1),
      (0, 3),
      (0, 5),
      (1, 0),
      (1, 2),
      (1, 4),
      (2, 1),
      (2, 3),
      (2, 5),
      (3, 0),
      (3, 2),
      (3, 4),
      (4, 1),
      (4, 3),
      (4, 5),
      (5, 0),
      (5, 2),
      (5, 4),
    ],
  }
}

///|
pub fn level_18() -> @types.LevelDef {
  {
    id: 17,
    name: "Barren Start",
    tier: Advanced,
    description: "All resources start very low. Survive if you can.",
    initial_resources: @types.new_resources(15.0, 15.0, 15.0, 15.0),
    available_organisms: [Moss, Fern, Snail, Fungus, Worm],
    organism_counts: [3, 1, 1, 2, 2],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_19() -> @types.LevelDef {
  {
    id: 18,
    name: "Predator Pit",
    tier: Advanced,
    description: "Many herbivores but few plants available. Keep them fed.",
    initial_resources: @types.new_resources(40.0, 30.0, 40.0, 30.0),
    available_organisms: [Moss, Fern, Beetle, Snail, Fungus],
    organism_counts: [2, 1, 2, 2, 1],
    par_turns: 10,
    locked_cells: [(0, 0), (0, 5), (5, 0), (5, 5), (2, 2), (3, 3)],
  }
}

///|
pub fn level_20() -> @types.LevelDef {
  {
    id: 19,
    name: "Master Terrarium",
    tier: Advanced,
    description: "The ultimate challenge. Perfect balance required.",
    initial_resources: @types.new_resources(20.0, 20.0, 20.0, 20.0),
    available_organisms: [Moss, Fern, Beetle, Snail, Fungus, Worm],
    organism_counts: [2, 2, 2, 1, 1, 1],
    par_turns: 10,
    locked_cells: [
      (0, 0),
      (0, 5),
      (5, 0),
      (5, 5),
      (1, 1),
      (1, 4),
      (4, 1),
      (4, 4),
    ],
  }
}
