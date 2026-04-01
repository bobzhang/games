///|
/// E=Empty, S=Source, T=Temple, W=Waystone(pre-placed), A=Amplifier, V=Void
/// Temple(N) means needs N energy.
/// Tier 1: Introductory puzzles (levels 0-6)
fn e() -> @types.CellKind {
  Empty
}

///|
fn s() -> @types.CellKind {
  Source
}

///|
fn t(required : Float) -> @types.CellKind {
  Temple(required)
}

///|
fn w() -> @types.CellKind {
  Waystone
}

///|
fn a() -> @types.CellKind {
  Amplifier
}

///|
fn v() -> @types.CellKind {
  Void
}

///|
pub fn level_0() -> @types.LevelDef {
  // "First Light" - simplest: source, short path, one temple
  {
    id: 0,
    name: "First Light",
    tier: 1,
    waystone_budget: 2,
    par_waystones: 1,
    gold_threshold: 80.0,
    silver_threshold: 70.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), e(), t(70.0), e(), e(), e(), e(), e()],
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
pub fn level_1() -> @types.LevelDef {
  // "Stone Bridge" - two hops
  {
    id: 1,
    name: "Stone Bridge",
    tier: 1,
    waystone_budget: 3,
    par_waystones: 2,
    gold_threshold: 65.0,
    silver_threshold: 55.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), e(), e(), t(60.0), e(), e(), e(), e()],
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
pub fn level_2() -> @types.LevelDef {
  // "Fork in the Road" - split to two temples
  {
    id: 2,
    name: "Fork in the Road",
    tier: 1,
    waystone_budget: 4,
    par_waystones: 3,
    gold_threshold: 70.0,
    silver_threshold: 55.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), t(30.0), e(), e(), e(), e(), e()],
      [e(), s(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), t(30.0), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_3() -> @types.LevelDef {
  // "Void Passage" - navigate around void
  {
    id: 3,
    name: "Void Passage",
    tier: 1,
    waystone_budget: 5,
    par_waystones: 3,
    gold_threshold: 60.0,
    silver_threshold: 50.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), v(), v(), e(), t(50.0), e(), e(), e()],
      [e(), e(), e(), v(), v(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_4() -> @types.LevelDef {
  // "Amplified" - use amplifier to boost
  {
    id: 4,
    name: "Amplified",
    tier: 1,
    waystone_budget: 3,
    par_waystones: 2,
    gold_threshold: 100.0,
    silver_threshold: 80.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), a(), e(), t(90.0), e(), e(), e(), e()],
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
pub fn level_5() -> @types.LevelDef {
  // "Twin Temples" - two temples need balanced supply
  {
    id: 5,
    name: "Twin Temples",
    tier: 1,
    waystone_budget: 5,
    par_waystones: 4,
    gold_threshold: 80.0,
    silver_threshold: 60.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), t(35.0), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), s(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), t(35.0), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}

///|
pub fn level_6() -> @types.LevelDef {
  // "The Long Road" - long chain tests decay
  {
    id: 6,
    name: "The Long Road",
    tier: 1,
    waystone_budget: 8,
    par_waystones: 7,
    gold_threshold: 45.0,
    silver_threshold: 35.0,
    grid: [
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [s(), e(), e(), e(), e(), e(), e(), e(), t(40.0), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
      [e(), e(), e(), e(), e(), e(), e(), e(), e(), e()],
    ],
  }
}
