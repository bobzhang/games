///|
pub fn level_01() -> @types.LevelDef {
  {
    id: 0,
    name: "First Sprout",
    tier: Beginner,
    description: "Place moss to produce oxygen. A simple start.",
    initial_resources: @types.new_resources(40.0, 60.0, 60.0, 40.0),
    available_organisms: [Moss],
    organism_counts: [3],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_02() -> @types.LevelDef {
  {
    id: 1,
    name: "Green Carpet",
    tier: Beginner,
    description: "Moss and ferns together. Watch the water!",
    initial_resources: @types.new_resources(30.0, 60.0, 70.0, 50.0),
    available_organisms: [Moss, Fern],
    organism_counts: [2, 1],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_03() -> @types.LevelDef {
  {
    id: 2,
    name: "Beetle Garden",
    tier: Beginner,
    description: "Beetles eat plants but produce CO2. Balance the cycle.",
    initial_resources: @types.new_resources(40.0, 40.0, 60.0, 50.0),
    available_organisms: [Moss, Beetle],
    organism_counts: [3, 1],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_04() -> @types.LevelDef {
  {
    id: 3,
    name: "Slow Crawler",
    tier: Beginner,
    description: "Snails are gentle herbivores that produce nutrients.",
    initial_resources: @types.new_resources(50.0, 40.0, 60.0, 30.0),
    available_organisms: [Moss, Snail],
    organism_counts: [2, 2],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_05() -> @types.LevelDef {
  {
    id: 4,
    name: "Decomposition",
    tier: Beginner,
    description: "Fungus recycles nutrients. Feed the cycle.",
    initial_resources: @types.new_resources(50.0, 50.0, 50.0, 20.0),
    available_organisms: [Moss, Fungus],
    organism_counts: [2, 2],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_06() -> @types.LevelDef {
  {
    id: 5,
    name: "Earth Movers",
    tier: Beginner,
    description: "Worms aerate the soil and help water cycle.",
    initial_resources: @types.new_resources(50.0, 50.0, 30.0, 30.0),
    available_organisms: [Moss, Worm],
    organism_counts: [2, 2],
    par_turns: 10,
    locked_cells: [],
  }
}

///|
pub fn level_07() -> @types.LevelDef {
  {
    id: 6,
    name: "Simple Chain",
    tier: Beginner,
    description: "Build a basic food chain: plant, herbivore, decomposer.",
    initial_resources: @types.new_resources(40.0, 40.0, 50.0, 40.0),
    available_organisms: [Moss, Beetle, Fungus],
    organism_counts: [3, 1, 1],
    par_turns: 10,
    locked_cells: [],
  }
}
