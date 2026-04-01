///|
/// Get all 30 levels
pub fn get_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // Tier 1: Propagation (10 levels)
  levels.push(tier1_level1())
  levels.push(tier1_level2())
  levels.push(tier1_level3())
  levels.push(tier1_level4())
  levels.push(tier1_level5())
  levels.push(tier1_level6())
  levels.push(tier1_level7())
  levels.push(tier1_level8())
  levels.push(tier1_level9())
  levels.push(tier1_level10())
  // Tier 2: Reflection (10 levels)
  levels.push(tier2_level1())
  levels.push(tier2_level2())
  levels.push(tier2_level3())
  levels.push(tier2_level4())
  levels.push(tier2_level5())
  levels.push(tier2_level6())
  levels.push(tier2_level7())
  levels.push(tier2_level8())
  levels.push(tier2_level9())
  levels.push(tier2_level10())
  // Tier 3: Phase (10 levels)
  levels.push(tier3_level1())
  levels.push(tier3_level2())
  levels.push(tier3_level3())
  levels.push(tier3_level4())
  levels.push(tier3_level5())
  levels.push(tier3_level6())
  levels.push(tier3_level7())
  levels.push(tier3_level8())
  levels.push(tier3_level9())
  levels.push(tier3_level10())
  levels
}

///|
pub fn get_level(index : Int) -> @types.Level {
  let levels = get_all_levels()
  levels[index]
}

///|
pub fn tier_name(tier : Int) -> String {
  match tier {
    0 => "Propagation"
    1 => "Reflection"
    2 => "Phase"
    _ => "Unknown"
  }
}

// ============ TIER 1: PROPAGATION ============

///|
fn tier1_level1() -> @types.Level {
  // Simple: one emitter, one nearby target
  {
    tier: 0,
    index: 0,
    name: "First Wave",
    grid_template: [],
    targets: [{ x: 5, y: 4, min_amp: 0.3, max_amp: 1.0, phase: -1 }],
    pre_placed: [],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 3,
  }
}

///|
fn tier1_level2() -> @types.Level {
  // Two targets in a line
  {
    tier: 0,
    index: 1,
    name: "Reach Out",
    grid_template: [],
    targets: [
      { x: 8, y: 4, min_amp: 0.2, max_amp: 1.0, phase: -1 },
      { x: 3, y: 4, min_amp: 0.2, max_amp: 1.0, phase: -1 },
    ],
    pre_placed: [],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 5,
  }
}

///|
fn tier1_level3() -> @types.Level {
  // Wall blocks direct path
  {
    tier: 0,
    index: 2,
    name: "Around the Wall",
    grid_template: [],
    targets: [{ x: 8, y: 4, min_amp: 0.1, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 5, y: 3, kind: Wall },
      { x: 5, y: 4, kind: Wall },
      { x: 5, y: 5, kind: Wall },
    ],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 6,
  }
}

///|
fn tier1_level4() -> @types.Level {
  // Two targets, need two emitters
  {
    tier: 0,
    index: 3,
    name: "Dual Signal",
    grid_template: [],
    targets: [
      { x: 1, y: 1, min_amp: 0.5, max_amp: 1.0, phase: -1 },
      { x: 10, y: 8, min_amp: 0.5, max_amp: 1.0, phase: -1 },
    ],
    pre_placed: [],
    budget: [{ kind: PlaceEmitter, total: 2, used: 0 }],
    par_objects: 2,
    par_ticks: 4,
  }
}

///|
fn tier1_level5() -> @types.Level {
  // Target needs high amplitude - must be adjacent to emitter
  {
    tier: 0,
    index: 4,
    name: "Strong Signal",
    grid_template: [],
    targets: [{ x: 6, y: 5, min_amp: 0.8, max_amp: 1.0, phase: -1 }],
    pre_placed: [{ x: 6, y: 3, kind: Wall }, { x: 6, y: 7, kind: Wall }],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 2,
  }
}

///|
fn tier1_level6() -> @types.Level {
  // Corridor of walls, target at end
  {
    tier: 0,
    index: 5,
    name: "Corridor",
    grid_template: [],
    targets: [{ x: 10, y: 4, min_amp: 0.1, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 2, y: 3, kind: Wall },
      { x: 3, y: 3, kind: Wall },
      { x: 4, y: 3, kind: Wall },
      { x: 5, y: 3, kind: Wall },
      { x: 6, y: 3, kind: Wall },
      { x: 7, y: 3, kind: Wall },
      { x: 8, y: 3, kind: Wall },
      { x: 9, y: 3, kind: Wall },
      { x: 2, y: 5, kind: Wall },
      { x: 3, y: 5, kind: Wall },
      { x: 4, y: 5, kind: Wall },
      { x: 5, y: 5, kind: Wall },
      { x: 6, y: 5, kind: Wall },
      { x: 7, y: 5, kind: Wall },
      { x: 8, y: 5, kind: Wall },
      { x: 9, y: 5, kind: Wall },
    ],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 8,
  }
}

///|
fn tier1_level7() -> @types.Level {
  // Multiple targets around a central emitter
  {
    tier: 0,
    index: 6,
    name: "Broadcast",
    grid_template: [],
    targets: [
      { x: 6, y: 2, min_amp: 0.3, max_amp: 1.0, phase: -1 },
      { x: 6, y: 7, min_amp: 0.3, max_amp: 1.0, phase: -1 },
      { x: 3, y: 5, min_amp: 0.3, max_amp: 1.0, phase: -1 },
      { x: 9, y: 5, min_amp: 0.3, max_amp: 1.0, phase: -1 },
    ],
    pre_placed: [],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 5,
  }
}

///|
fn tier1_level8() -> @types.Level {
  // Wall maze with target
  {
    tier: 0,
    index: 7,
    name: "Maze Runner",
    grid_template: [],
    targets: [{ x: 10, y: 8, min_amp: 0.05, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 3, y: 0, kind: Wall },
      { x: 3, y: 1, kind: Wall },
      { x: 3, y: 2, kind: Wall },
      { x: 3, y: 3, kind: Wall },
      { x: 3, y: 4, kind: Wall },
      { x: 3, y: 5, kind: Wall },
      { x: 3, y: 6, kind: Wall },
      { x: 7, y: 3, kind: Wall },
      { x: 7, y: 4, kind: Wall },
      { x: 7, y: 5, kind: Wall },
      { x: 7, y: 6, kind: Wall },
      { x: 7, y: 7, kind: Wall },
      { x: 7, y: 8, kind: Wall },
      { x: 7, y: 9, kind: Wall },
    ],
    budget: [{ kind: PlaceEmitter, total: 2, used: 0 }],
    par_objects: 2,
    par_ticks: 8,
  }
}

///|
fn tier1_level9() -> @types.Level {
  // Low amplitude target - needs distance
  {
    tier: 0,
    index: 8,
    name: "Whisper",
    grid_template: [],
    targets: [{ x: 6, y: 5, min_amp: 0.1, max_amp: 0.4, phase: -1 }],
    pre_placed: [],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 6,
  }
}

///|
fn tier1_level10() -> @types.Level {
  // Complex wall layout, three targets
  {
    tier: 0,
    index: 9,
    name: "Signal Tower",
    grid_template: [],
    targets: [
      { x: 1, y: 1, min_amp: 0.2, max_amp: 1.0, phase: -1 },
      { x: 10, y: 1, min_amp: 0.2, max_amp: 1.0, phase: -1 },
      { x: 6, y: 8, min_amp: 0.2, max_amp: 1.0, phase: -1 },
    ],
    pre_placed: [
      { x: 4, y: 4, kind: Wall },
      { x: 5, y: 4, kind: Wall },
      { x: 6, y: 4, kind: Wall },
      { x: 7, y: 4, kind: Wall },
      { x: 8, y: 4, kind: Wall },
    ],
    budget: [{ kind: PlaceEmitter, total: 3, used: 0 }],
    par_objects: 3,
    par_ticks: 6,
  }
}

// ============ TIER 2: REFLECTION ============

///|
fn tier2_level1() -> @types.Level {
  // Intro to reflectors
  {
    tier: 1,
    index: 0,
    name: "Bounce",
    grid_template: [],
    targets: [{ x: 2, y: 2, min_amp: 0.2, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 8, y: 5, kind: Emitter(0) },
      { x: 5, y: 0, kind: Wall },
      { x: 5, y: 1, kind: Wall },
      { x: 5, y: 2, kind: Wall },
      { x: 5, y: 3, kind: Wall },
      { x: 5, y: 4, kind: Wall },
      { x: 5, y: 5, kind: Wall },
      { x: 5, y: 6, kind: Wall },
    ],
    budget: [{ kind: PlaceReflector, total: 2, used: 0 }],
    par_objects: 2,
    par_ticks: 8,
  }
}

///|
fn tier2_level2() -> @types.Level {
  // Redirect wave around corner
  {
    tier: 1,
    index: 1,
    name: "Corner Shot",
    grid_template: [],
    targets: [{ x: 10, y: 2, min_amp: 0.1, max_amp: 1.0, phase: -1 }],
    pre_placed: [{ x: 2, y: 7, kind: Emitter(0) }],
    budget: [{ kind: PlaceReflector, total: 3, used: 0 }],
    par_objects: 2,
    par_ticks: 10,
  }
}

///|
fn tier2_level3() -> @types.Level {
  // Intro to absorbers
  {
    tier: 1,
    index: 2,
    name: "Silence Zone",
    grid_template: [],
    targets: [
      { x: 8, y: 5, min_amp: 0.3, max_amp: 1.0, phase: -1 },
      { x: 2, y: 5, min_amp: 0.0, max_amp: 0.05, phase: -1 },
    ],
    pre_placed: [{ x: 5, y: 5, kind: Emitter(0) }],
    budget: [{ kind: PlaceAbsorber, total: 2, used: 0 }],
    par_objects: 1,
    par_ticks: 5,
  }
}

///|
fn tier2_level4() -> @types.Level {
  // Reflect and absorb
  {
    tier: 1,
    index: 3,
    name: "Guided Path",
    grid_template: [],
    targets: [{ x: 10, y: 8, min_amp: 0.1, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 1, y: 1, kind: Emitter(0) },
      { x: 6, y: 0, kind: Wall },
      { x: 6, y: 1, kind: Wall },
      { x: 6, y: 2, kind: Wall },
      { x: 6, y: 3, kind: Wall },
      { x: 6, y: 4, kind: Wall },
      { x: 6, y: 5, kind: Wall },
      { x: 6, y: 6, kind: Wall },
      { x: 6, y: 7, kind: Wall },
    ],
    budget: [
      { kind: PlaceReflector, total: 2, used: 0 },
      { kind: PlaceAbsorber, total: 1, used: 0 },
    ],
    par_objects: 2,
    par_ticks: 12,
  }
}

///|
fn tier2_level5() -> @types.Level {
  // Multiple reflectors chain
  {
    tier: 1,
    index: 4,
    name: "Relay Chain",
    grid_template: [],
    targets: [{ x: 10, y: 1, min_amp: 0.05, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 1, y: 8, kind: Emitter(0) },
      { x: 0, y: 4, kind: Wall },
      { x: 1, y: 4, kind: Wall },
      { x: 2, y: 4, kind: Wall },
      { x: 3, y: 4, kind: Wall },
      { x: 8, y: 4, kind: Wall },
      { x: 9, y: 4, kind: Wall },
      { x: 10, y: 4, kind: Wall },
      { x: 11, y: 4, kind: Wall },
    ],
    budget: [{ kind: PlaceReflector, total: 4, used: 0 }],
    par_objects: 3,
    par_ticks: 12,
  }
}

///|
fn tier2_level6() -> @types.Level {
  // Absorb unwanted waves
  {
    tier: 1,
    index: 5,
    name: "Selective",
    grid_template: [],
    targets: [
      { x: 10, y: 5, min_amp: 0.3, max_amp: 1.0, phase: -1 },
      { x: 1, y: 5, min_amp: 0.0, max_amp: 0.1, phase: -1 },
      { x: 5, y: 1, min_amp: 0.0, max_amp: 0.1, phase: -1 },
    ],
    pre_placed: [{ x: 5, y: 5, kind: Emitter(0) }],
    budget: [{ kind: PlaceAbsorber, total: 3, used: 0 }],
    par_objects: 2,
    par_ticks: 6,
  }
}

///|
fn tier2_level7() -> @types.Level {
  // Reflect into a box
  {
    tier: 1,
    index: 6,
    name: "Focus",
    grid_template: [],
    targets: [{ x: 6, y: 5, min_amp: 0.5, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 1, y: 5, kind: Emitter(0) },
      { x: 10, y: 5, kind: Emitter(0) },
    ],
    budget: [
      { kind: PlaceReflector, total: 2, used: 0 },
      { kind: PlaceAbsorber, total: 2, used: 0 },
    ],
    par_objects: 2,
    par_ticks: 6,
  }
}

///|
fn tier2_level8() -> @types.Level {
  // Complex reflection maze
  {
    tier: 1,
    index: 7,
    name: "Mirror Maze",
    grid_template: [],
    targets: [{ x: 1, y: 8, min_amp: 0.05, max_amp: 1.0, phase: -1 }],
    pre_placed: [
      { x: 10, y: 1, kind: Emitter(0) },
      { x: 5, y: 0, kind: Wall },
      { x: 5, y: 1, kind: Wall },
      { x: 5, y: 2, kind: Wall },
      { x: 5, y: 3, kind: Wall },
      { x: 5, y: 6, kind: Wall },
      { x: 5, y: 7, kind: Wall },
      { x: 5, y: 8, kind: Wall },
      { x: 5, y: 9, kind: Wall },
    ],
    budget: [{ kind: PlaceReflector, total: 4, used: 0 }],
    par_objects: 3,
    par_ticks: 14,
  }
}

///|
fn tier2_level9() -> @types.Level {
  // Two emitters, selective targets
  {
    tier: 1,
    index: 8,
    name: "Crossfire",
    grid_template: [],
    targets: [
      { x: 6, y: 2, min_amp: 0.4, max_amp: 1.0, phase: -1 },
      { x: 6, y: 7, min_amp: 0.0, max_amp: 0.1, phase: -1 },
    ],
    pre_placed: [
      { x: 1, y: 5, kind: Emitter(0) },
      { x: 11, y: 5, kind: Emitter(0) },
    ],
    budget: [
      { kind: PlaceReflector, total: 3, used: 0 },
      { kind: PlaceAbsorber, total: 2, used: 0 },
    ],
    par_objects: 3,
    par_ticks: 8,
  }
}

///|
fn tier2_level10() -> @types.Level {
  // Complex: absorb, reflect, multiple targets
  {
    tier: 1,
    index: 9,
    name: "Conductor",
    grid_template: [],
    targets: [
      { x: 2, y: 1, min_amp: 0.2, max_amp: 1.0, phase: -1 },
      { x: 9, y: 1, min_amp: 0.2, max_amp: 1.0, phase: -1 },
      { x: 5, y: 8, min_amp: 0.0, max_amp: 0.1, phase: -1 },
    ],
    pre_placed: [
      { x: 5, y: 5, kind: Emitter(0) },
      { x: 5, y: 3, kind: Wall },
      { x: 5, y: 4, kind: Wall },
    ],
    budget: [
      { kind: PlaceReflector, total: 3, used: 0 },
      { kind: PlaceAbsorber, total: 2, used: 0 },
    ],
    par_objects: 3,
    par_ticks: 8,
  }
}

// ============ TIER 3: PHASE ============

///|
fn tier3_level1() -> @types.Level {
  // Intro: target requires specific phase
  {
    tier: 2,
    index: 0,
    name: "Phase Match",
    grid_template: [],
    targets: [{ x: 8, y: 5, min_amp: 0.3, max_amp: 1.0, phase: 0 }],
    pre_placed: [],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 4,
  }
}

///|
fn tier3_level2() -> @types.Level {
  // Phase shifter intro
  {
    tier: 2,
    index: 1,
    name: "Shift It",
    grid_template: [],
    targets: [{ x: 9, y: 5, min_amp: 0.2, max_amp: 1.0, phase: 1 }],
    pre_placed: [{ x: 2, y: 5, kind: Emitter(0) }],
    budget: [{ kind: PlacePhaseShifter, total: 2, used: 0 }],
    par_objects: 1,
    par_ticks: 8,
  }
}

///|
fn tier3_level3() -> @types.Level {
  // Two targets different phases
  {
    tier: 2,
    index: 2,
    name: "Dual Phase",
    grid_template: [],
    targets: [
      { x: 3, y: 3, min_amp: 0.3, max_amp: 1.0, phase: 0 },
      { x: 9, y: 3, min_amp: 0.3, max_amp: 1.0, phase: 2 },
    ],
    pre_placed: [],
    budget: [
      { kind: PlaceEmitter, total: 2, used: 0 },
      { kind: PlacePhaseShifter, total: 2, used: 0 },
    ],
    par_objects: 3,
    par_ticks: 6,
  }
}

///|
fn tier3_level4() -> @types.Level {
  // Constructive interference required
  {
    tier: 2,
    index: 3,
    name: "Resonance",
    grid_template: [],
    targets: [{ x: 6, y: 5, min_amp: 0.8, max_amp: 1.0, phase: -1 }],
    pre_placed: [],
    budget: [{ kind: PlaceEmitter, total: 2, used: 0 }],
    par_objects: 2,
    par_ticks: 5,
  }
}

///|
fn tier3_level5() -> @types.Level {
  // Destructive interference - cancel waves at target
  {
    tier: 2,
    index: 4,
    name: "Cancellation",
    grid_template: [],
    targets: [
      { x: 6, y: 5, min_amp: 0.0, max_amp: 0.1, phase: -1 },
      { x: 2, y: 5, min_amp: 0.3, max_amp: 1.0, phase: -1 },
    ],
    pre_placed: [{ x: 10, y: 5, kind: Emitter(0) }],
    budget: [{ kind: PlaceEmitter, total: 1, used: 0 }],
    par_objects: 1,
    par_ticks: 6,
  }
}

///|
fn tier3_level6() -> @types.Level {
  // Phase shift chain
  {
    tier: 2,
    index: 5,
    name: "Triple Shift",
    grid_template: [],
    targets: [{ x: 10, y: 5, min_amp: 0.1, max_amp: 1.0, phase: 3 }],
    pre_placed: [{ x: 1, y: 5, kind: Emitter(0) }],
    budget: [{ kind: PlacePhaseShifter, total: 4, used: 0 }],
    par_objects: 3,
    par_ticks: 10,
  }
}

///|
fn tier3_level7() -> @types.Level {
  // Reflect + phase shift
  {
    tier: 2,
    index: 6,
    name: "Phase Bounce",
    grid_template: [],
    targets: [{ x: 2, y: 2, min_amp: 0.1, max_amp: 1.0, phase: 1 }],
    pre_placed: [
      { x: 2, y: 8, kind: Emitter(0) },
      { x: 5, y: 0, kind: Wall },
      { x: 5, y: 1, kind: Wall },
      { x: 5, y: 2, kind: Wall },
      { x: 5, y: 3, kind: Wall },
      { x: 5, y: 4, kind: Wall },
      { x: 5, y: 5, kind: Wall },
      { x: 5, y: 6, kind: Wall },
      { x: 5, y: 7, kind: Wall },
      { x: 5, y: 8, kind: Wall },
    ],
    budget: [
      { kind: PlaceReflector, total: 3, used: 0 },
      { kind: PlacePhaseShifter, total: 2, used: 0 },
    ],
    par_objects: 3,
    par_ticks: 12,
  }
}

///|
fn tier3_level8() -> @types.Level {
  // Multi-emitter phase alignment
  {
    tier: 2,
    index: 7,
    name: "Alignment",
    grid_template: [],
    targets: [
      { x: 6, y: 2, min_amp: 0.5, max_amp: 1.0, phase: 0 },
      { x: 6, y: 8, min_amp: 0.5, max_amp: 1.0, phase: 2 },
    ],
    pre_placed: [],
    budget: [
      { kind: PlaceEmitter, total: 3, used: 0 },
      { kind: PlacePhaseShifter, total: 2, used: 0 },
    ],
    par_objects: 4,
    par_ticks: 6,
  }
}

///|
fn tier3_level9() -> @types.Level {
  // All tools puzzle
  {
    tier: 2,
    index: 8,
    name: "Full Spectrum",
    grid_template: [],
    targets: [
      { x: 1, y: 1, min_amp: 0.2, max_amp: 1.0, phase: 0 },
      { x: 10, y: 1, min_amp: 0.2, max_amp: 1.0, phase: 1 },
      { x: 10, y: 8, min_amp: 0.2, max_amp: 1.0, phase: 2 },
      { x: 1, y: 8, min_amp: 0.0, max_amp: 0.1, phase: -1 },
    ],
    pre_placed: [{ x: 5, y: 5, kind: Wall }, { x: 6, y: 5, kind: Wall }],
    budget: [
      { kind: PlaceEmitter, total: 3, used: 0 },
      { kind: PlaceReflector, total: 2, used: 0 },
      { kind: PlacePhaseShifter, total: 3, used: 0 },
      { kind: PlaceAbsorber, total: 2, used: 0 },
    ],
    par_objects: 6,
    par_ticks: 10,
  }
}

///|
fn tier3_level10() -> @types.Level {
  // Final challenge
  {
    tier: 2,
    index: 9,
    name: "Tidal Master",
    grid_template: [],
    targets: [
      { x: 3, y: 2, min_amp: 0.3, max_amp: 1.0, phase: 0 },
      { x: 9, y: 2, min_amp: 0.3, max_amp: 1.0, phase: 1 },
      { x: 9, y: 7, min_amp: 0.3, max_amp: 1.0, phase: 2 },
      { x: 3, y: 7, min_amp: 0.3, max_amp: 1.0, phase: 3 },
      { x: 6, y: 5, min_amp: 0.0, max_amp: 0.15, phase: -1 },
    ],
    pre_placed: [
      { x: 5, y: 4, kind: Wall },
      { x: 6, y: 4, kind: Wall },
      { x: 7, y: 4, kind: Wall },
      { x: 5, y: 6, kind: Wall },
      { x: 6, y: 6, kind: Wall },
      { x: 7, y: 6, kind: Wall },
    ],
    budget: [
      { kind: PlaceEmitter, total: 4, used: 0 },
      { kind: PlaceReflector, total: 3, used: 0 },
      { kind: PlacePhaseShifter, total: 4, used: 0 },
      { kind: PlaceAbsorber, total: 2, used: 0 },
    ],
    par_objects: 8,
    par_ticks: 10,
  }
}
