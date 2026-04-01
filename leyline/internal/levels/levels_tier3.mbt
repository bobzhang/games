///|
pub fn level_14() -> @types.LevelDef {
  // "The Gauntlet" - long maze with amplifiers
  {
    id: 14,
    name: "The Gauntlet",
    tier: 3,
    waystone_budget: 10,
    par_waystones: 7,
    gold_threshold: 80.0,
    silver_threshold: 55.0,
    grid: [
      [e(), s(), e(), v(), e(), e(), a(), e(), e(), e()],
      [e(), e(), e(), v(), e(), v(), e(), v(), e(), e()],
      [e(), e(), e(), e(), e(), v(), e(), v(), e(), e()],
      [e(), v(), v(), v(), e(), v(), e(), v(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), v(), e(), e()],
      [e(), v(), v(), v(), v(), v(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), v(), t(50.0), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_15() -> @types.LevelDef {
  // "Four Corners" - temples in each corner
  {
    id: 15,
    name: "Four Corners",
    tier: 3,
    waystone_budget: 12,
    par_waystones: 9,
    gold_threshold: 80.0,
    silver_threshold: 55.0,
    grid: [
      [t(15.0), e(), e(), e(), e(), e(), e(), e(), e(), t(15.0)],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), s(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), a(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [t(15.0), e(), e(), e(), e(), e(), e(), e(), e(), t(15.0)],
    ],
  }
}

///|
pub fn level_16() -> @types.LevelDef {
  // "Serpentine" - winding path through voids
  {
    id: 16,
    name: "Serpentine",
    tier: 3,
    waystone_budget: 10,
    par_waystones: 8,
    gold_threshold: 60.0,
    silver_threshold: 40.0,
    grid: [
      [s(), e(), v(), v(), v(), v(), v(), v(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), v()],
      [v(), v(), v(), v(), v(), v(), v(), e(), e(), v()],
      [e(), e(), e(), e(), e(), e(), e(), e(), v(), v()],
      [e(), v(), v(), v(), v(), v(), v(), v(), v(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [v(), v(), v(), v(), v(), v(), v(), v(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), a(), e(), t(35.0)],
    ],
  }
}

///|
pub fn level_17() -> @types.LevelDef {
  // "Power Grid" - two sources, many temples
  {
    id: 17,
    name: "Power Grid",
    tier: 3,
    waystone_budget: 10,
    par_waystones: 8,
    gold_threshold: 160.0,
    silver_threshold: 120.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), t(20.0), e(), t(20.0), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), v(), v(), v(), e(), e(), e(), e()],
      [e(), e(), e(), v(), v(), v(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), t(20.0), e(), t(20.0), e(), s(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_18() -> @types.LevelDef {
  // "Diamond Vault" - diamond-shaped void, temples inside
  {
    id: 18,
    name: "Diamond Vault",
    tier: 3,
    waystone_budget: 10,
    par_waystones: 7,
    gold_threshold: 100.0,
    silver_threshold: 70.0,
    grid: [
      [e(), e(), e(), e(), v(), e(), e(), e(), e(), e()],
      [e(), e(), e(), v(), e(), v(), e(), e(), e(), e()],
      [e(), e(), v(), e(), t(30.0), e(), v(), e(), e(), e()],
      [e(), v(), e(), e(), e(), e(), e(), v(), e(), e()],
      [s(), e(), e(), e(), a(), e(), e(), e(), t(40.0), e()],
      [e(), v(), e(), e(), e(), e(), e(), v(), e(), e()],
      [e(), e(), v(), e(), t(30.0), e(), v(), e(), e(), e()],
      [e(), e(), e(), v(), e(), v(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_19() -> @types.LevelDef {
  // "Grand Nexus" - ultimate challenge
  {
    id: 19,
    name: "Grand Nexus",
    tier: 3,
    waystone_budget: 14,
    par_waystones: 10,
    gold_threshold: 200.0,
    silver_threshold: 140.0,
    grid: [
      [t(20.0), e(), e(), v(), e(), e(), v(), e(), e(), t(20.0)],
      [e(), e(), e(), v(), e(), e(), v(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), a(), a(), e(), e(), e(), e()],
      [e(), s(), e(), e(), e(), e(), e(), e(), s(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), v(), e(), e(), v(), e(), e(), e()],
      [t(20.0), e(), e(), v(), e(), e(), v(), e(), e(), t(20.0)],
    ],
  }
}
