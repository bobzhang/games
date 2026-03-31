///|
fn tp(col : Int, row : Int) -> @types.TargetPos {
  { col, row }
}

// ========================================
// Tier 1: Melody (7 levels) - match targets only
// ========================================

///|
fn level_0() -> @types.Level {
  // "First Steps" - place 3 notes in a simple ascending pattern
  {
    id: 0,
    name: "First Steps",
    tier: Melody,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(1, 6), tp(3, 5), tp(5, 4)],
    note_budget: 3,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

///|
fn level_1() -> @types.Level {
  // "Scale Up" - ascending C-D-E-F
  {
    id: 1,
    name: "Scale Up",
    tier: Melody,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(2, 5), tp(4, 4), tp(6, 3)],
    note_budget: 4,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

///|
fn level_2() -> @types.Level {
  // "Peak" - up then down
  {
    id: 2,
    name: "Peak",
    tier: Melody,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(2, 4), tp(4, 2), tp(6, 4)],
    note_budget: 4,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

///|
fn level_3() -> @types.Level {
  // "Stepwise" - all adjacent steps
  {
    id: 3,
    name: "Stepwise",
    tier: Melody,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(1, 5), tp(2, 4), tp(3, 3), tp(4, 4)],
    note_budget: 5,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

///|
fn level_4() -> @types.Level {
  // "Leap" - wider intervals
  {
    id: 4,
    name: "Leap",
    tier: Melody,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(2, 2), tp(4, 6), tp(6, 0)],
    note_budget: 4,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

///|
fn level_5() -> @types.Level {
  // "Zigzag" - alternating high/low
  {
    id: 5,
    name: "Zigzag",
    tier: Melody,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 5), tp(1, 2), tp(2, 5), tp(3, 2), tp(4, 5), tp(5, 2)],
    note_budget: 6,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

///|
fn level_6() -> @types.Level {
  // "Full Scale" - complete C to B
  {
    id: 6,
    name: "Full Scale",
    tier: Melody,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(1, 5), tp(2, 4), tp(3, 3), tp(4, 2), tp(5, 1), tp(6, 0)],
    note_budget: 7,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

// ========================================
// Tier 2: Harmony (7 levels) - targets + harmony scoring
// ========================================

///|
fn level_7() -> @types.Level {
  // "First Chord" - place a third on top of target
  {
    id: 7,
    name: "First Chord",
    tier: Harmony,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(2, 6), tp(4, 6), tp(6, 6)],
    note_budget: 8,
    harmony_threshold_2star: 4,
    harmony_threshold_3star: 8,
  }
}

///|
fn level_8() -> @types.Level {
  // "Power Fifths" - build fifths
  {
    id: 8,
    name: "Power Fifths",
    tier: Harmony,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(2, 5), tp(4, 4), tp(6, 3)],
    note_budget: 8,
    harmony_threshold_2star: 6,
    harmony_threshold_3star: 10,
  }
}

///|
fn level_9() -> @types.Level {
  // "Triad" - build triads (root + third + fifth)
  {
    id: 9,
    name: "Triad Builder",
    tier: Harmony,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(0, 4), tp(4, 6), tp(4, 4)],
    note_budget: 8,
    harmony_threshold_2star: 8,
    harmony_threshold_3star: 14,
  }
}

///|
fn level_10() -> @types.Level {
  // "Avoid Dissonance" - tight budget, must avoid bad intervals
  {
    id: 10,
    name: "Careful Steps",
    tier: Harmony,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(1, 6), tp(3, 4), tp(5, 2), tp(7, 0)],
    note_budget: 6,
    harmony_threshold_2star: 4,
    harmony_threshold_3star: 8,
  }
}

///|
fn level_11() -> @types.Level {
  // "Dense Harmony" - multiple notes per column
  {
    id: 11,
    name: "Dense Harmony",
    tier: Harmony,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(0, 2), tp(4, 6), tp(4, 2)],
    note_budget: 8,
    harmony_threshold_2star: 10,
    harmony_threshold_3star: 16,
  }
}

///|
fn level_12() -> @types.Level {
  // "Consonance Chain" - consecutive consonant chords
  {
    id: 12,
    name: "Consonance Chain",
    tier: Harmony,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(2, 4), tp(4, 2), tp(6, 0)],
    note_budget: 10,
    harmony_threshold_2star: 12,
    harmony_threshold_3star: 18,
  }
}

///|
fn level_13() -> @types.Level {
  // "Full Harmony" - fill all columns with harmony
  {
    id: 13,
    name: "Full Harmony",
    tier: Harmony,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [
      tp(0, 6), tp(1, 5), tp(2, 4), tp(3, 3), tp(4, 4), tp(5, 5), tp(6, 6),
      tp(7, 5),
    ],
    note_budget: 10,
    harmony_threshold_2star: 10,
    harmony_threshold_3star: 18,
  }
}

// ========================================
// Tier 3: Counterpoint (6 levels) - two melodies, tight budgets
// ========================================

///|
fn level_14() -> @types.Level {
  // "Parallel Motion" - two lines moving in same direction
  {
    id: 14,
    name: "Parallel Motion",
    tier: Counterpoint,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(2, 5), tp(4, 4), tp(6, 3)],
    note_budget: 8,
    harmony_threshold_2star: 8,
    harmony_threshold_3star: 14,
  }
}

///|
fn level_15() -> @types.Level {
  // "Contrary Motion" - lines move in opposite directions
  {
    id: 15,
    name: "Contrary Motion",
    tier: Counterpoint,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(0, 0), tp(4, 3), tp(4, 3)],
    note_budget: 8,
    harmony_threshold_2star: 8,
    harmony_threshold_3star: 14,
  }
}

///|
fn level_16() -> @types.Level {
  // "Call and Response" - alternating melody lines
  {
    id: 16,
    name: "Call and Response",
    tier: Counterpoint,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [tp(0, 6), tp(1, 0), tp(2, 5), tp(3, 1), tp(4, 4), tp(5, 2)],
    note_budget: 8,
    harmony_threshold_2star: 6,
    harmony_threshold_3star: 12,
  }
}

///|
fn level_17() -> @types.Level {
  // "Tight Weave" - two lines that interlock
  {
    id: 17,
    name: "Tight Weave",
    tier: Counterpoint,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [
      tp(0, 6), tp(0, 2), tp(2, 5), tp(2, 1), tp(4, 4), tp(4, 0), tp(6, 3),
      tp(6, 1),
    ],
    note_budget: 6,
    harmony_threshold_2star: 10,
    harmony_threshold_3star: 18,
  }
}

///|
fn level_18() -> @types.Level {
  // "Grand Fugue" - complex two-voice pattern
  {
    id: 18,
    name: "Grand Fugue",
    tier: Counterpoint,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [
      tp(0, 6), tp(1, 4), tp(2, 2), tp(3, 0), tp(4, 2), tp(5, 4), tp(6, 6),
    ],
    note_budget: 9,
    harmony_threshold_2star: 12,
    harmony_threshold_3star: 20,
  }
}

///|
fn level_19() -> @types.Level {
  // "Masterwork" - the ultimate challenge
  {
    id: 19,
    name: "Masterwork",
    tier: Counterpoint,
    grid_cols: @types.grid_cols,
    grid_rows: @types.grid_rows,
    targets: [
      tp(0, 6), tp(0, 0), tp(2, 4), tp(2, 2), tp(4, 2), tp(4, 4), tp(6, 0),
      tp(6, 6), tp(7, 3),
    ],
    note_budget: 7,
    harmony_threshold_2star: 14,
    harmony_threshold_3star: 22,
  }
}

///|
pub fn get_level(id : Int) -> @types.Level {
  match id {
    0 => level_0()
    1 => level_1()
    2 => level_2()
    3 => level_3()
    4 => level_4()
    5 => level_5()
    6 => level_6()
    7 => level_7()
    8 => level_8()
    9 => level_9()
    10 => level_10()
    11 => level_11()
    12 => level_12()
    13 => level_13()
    14 => level_14()
    15 => level_15()
    16 => level_16()
    17 => level_17()
    18 => level_18()
    19 => level_19()
    _ => level_0()
  }
}

///|
pub fn get_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  for i in 0..<@types.total_levels {
    levels.push(get_level(i))
  }
  levels
}
