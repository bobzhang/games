///|
pub fn level_7() -> @types.LevelDef {
  // "Maze Runner" - voids create a maze
  {
    id: 7,
    name: "Maze Runner",
    tier: 2,
    waystone_budget: 7,
    par_waystones: 5,
    gold_threshold: 55.0,
    silver_threshold: 40.0,
    grid: [
      [e(), e(), e(), v(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), v(), e(), e(), e(), t(40.0), e(), e()],
      [e(), e(), e(), v(), e(), v(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), v(), e(), e(), e(), e()],
      [e(), e(), e(), v(), e(), v(), e(), e(), e(), e()],
      [e(), e(), e(), v(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_8() -> @types.LevelDef {
  // "Triple Threat" - three temples
  {
    id: 8,
    name: "Triple Threat",
    tier: 2,
    waystone_budget: 8,
    par_waystones: 6,
    gold_threshold: 80.0,
    silver_threshold: 60.0,
    grid: [
      [e(), e(), e(), e(), t(25.0), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), t(25.0), e(), e(), t(25.0), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_9() -> @types.LevelDef {
  // "Amplifier Chain" - chain amplifiers for max boost
  {
    id: 9,
    name: "Amplifier Chain",
    tier: 2,
    waystone_budget: 4,
    par_waystones: 3,
    gold_threshold: 150.0,
    silver_threshold: 120.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), a(), e(), a(), e(), t(130.0), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_10() -> @types.LevelDef {
  // "Divided" - two sources, two temple groups
  {
    id: 10,
    name: "Divided",
    tier: 2,
    waystone_budget: 6,
    par_waystones: 4,
    gold_threshold: 130.0,
    silver_threshold: 100.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), t(60.0), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), v(), v(), e(), e(), e(), e()],
      [e(), e(), e(), e(), v(), v(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), t(60.0), e(), s(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_11() -> @types.LevelDef {
  // "Bottleneck" - narrow passage forces efficiency
  {
    id: 11,
    name: "Bottleneck",
    tier: 2,
    waystone_budget: 6,
    par_waystones: 5,
    gold_threshold: 70.0,
    silver_threshold: 50.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), v(), v(), v(), v(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), v(), v(), v(), v(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), t(45.0), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_12() -> @types.LevelDef {
  // "Relay Network" - pre-placed waystones to extend
  {
    id: 12,
    name: "Relay Network",
    tier: 2,
    waystone_budget: 5,
    par_waystones: 3,
    gold_threshold: 90.0,
    silver_threshold: 70.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), w(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), w(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), t(50.0), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_13() -> @types.LevelDef {
  // "Crossroads" - dense grid needing careful pathing
  {
    id: 13,
    name: "Crossroads",
    tier: 2,
    waystone_budget: 7,
    par_waystones: 5,
    gold_threshold: 100.0,
    silver_threshold: 75.0,
    grid: [
      [e(), e(), e(), e(), t(30.0), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), s(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [t(30.0), e(), e(), e(), e(), e(), e(), e(), t(30.0), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}
