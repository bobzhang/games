///|
pub fn note_index(note : Note) -> Int {
  match note {
    C => 0
    D => 1
    E => 2
    F => 3
    G => 4
    A => 5
    B => 6
  }
}

///|
pub fn note_from_row(row : Int) -> Note {
  match row {
    0 => B
    1 => A
    2 => G
    3 => F
    4 => E
    5 => D
    _ => C
  }
}

///|
pub fn note_name(note : Note) -> String {
  match note {
    C => "C"
    D => "D"
    E => "E"
    F => "F"
    G => "G"
    A => "A"
    B => "B"
  }
}

///|
pub fn row_from_note(note : Note) -> Int {
  match note {
    B => 0
    A => 1
    G => 2
    F => 3
    E => 4
    D => 5
    C => 6
  }
}

///|
pub fn note_color(note : Note) -> @raylib.Color {
  match note {
    C => color_note_c
    D => color_note_d
    E => color_note_e
    F => color_note_f
    G => color_note_g
    A => color_note_a
    B => color_note_b
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Melody => "Melody"
    Harmony => "Harmony"
    Counterpoint => "Counterpoint"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Melody => color_melody_tier
    Harmony => color_harmony_tier
    Counterpoint => color_counterpoint_tier
  }
}

///|
pub fn tier_level_range(tier : Tier) -> (Int, Int) {
  match tier {
    Melody => (0, 6)
    Harmony => (7, 13)
    Counterpoint => (14, 19)
  }
}

///|
pub fn interval_between(row_a : Int, row_b : Int) -> Int {
  let diff = if row_a > row_b { row_a - row_b } else { row_b - row_a }
  diff % 7
}

///|
pub fn interval_quality(steps : Int) -> IntervalQuality {
  match steps {
    0 => Unison
    1 => Second
    2 => Third
    3 => Tritone
    4 => Fifth
    5 => Sixth
    6 => Seventh
    _ => Unison
  }
}

///|
pub fn interval_score(quality : IntervalQuality) -> Int {
  match quality {
    Unison => score_unison
    Second => score_second
    Third => score_third
    Tritone => score_tritone
    Fifth => score_fifth
    Sixth => score_sixth
    Seventh => score_seventh
  }
}

///|
pub fn harmony_between(row_a : Int, row_b : Int) -> Int {
  let steps = interval_between(row_a, row_b)
  let quality = interval_quality(steps)
  interval_score(quality)
}

///|
pub fn new_note_cell() -> NoteCell {
  { has_note: false, is_target: false, is_locked: false, }
}

///|
pub fn new_grid(cols : Int, rows : Int) -> Grid {
  let cells : Array[Array[NoteCell]] = []
  for _c in 0..<cols {
    let col : Array[NoteCell] = []
    for _r in 0..<rows {
      col.push(new_note_cell())
    }
    cells.push(col)
  }
  { cols, rows, cells, }
}

///|
pub fn new_level_score() -> LevelScore {
  {
    stars: 0,
    harmony_score: 0,
    targets_matched: 0,
    total_targets: 0,
    completed: false,
  }
}

///|
pub fn new_game() -> Game {
  let level_scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    level_scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Melody,
    selected_level: 0,
    grid: new_grid(grid_cols, grid_rows),
    current_level: placeholder_level(),
    playback_col: 0,
    play_state: Idle,
    play_timer: 0.0,
    harmony_score: 0,
    notes_placed: 0,
    targets_matched: 0,
    stars: 0,
    level_scores,
    undo_stack: [],
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
  }
}

///|
pub fn placeholder_level() -> Level {
  {
    id: 0,
    name: "Placeholder",
    tier: Melody,
    grid_cols,
    grid_rows,
    targets: [],
    note_budget: 8,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
}

///|
pub fn count_notes_in_grid(grid : Grid) -> Int {
  let mut count = 0
  for c in 0..<grid.cols {
    for r in 0..<grid.rows {
      if grid.cells[c][r].has_note && !grid.cells[c][r].is_locked {
        count += 1
      }
    }
  }
  count
}

///|
pub fn count_targets_matched(grid : Grid, targets : Array[TargetPos]) -> Int {
  let mut count = 0
  for i in 0..<targets.length() {
    let t = targets[i]
    if t.col < grid.cols && t.row < grid.rows {
      if grid.cells[t.col][t.row].has_note {
        count += 1
      }
    }
  }
  count
}

///|
pub fn all_targets_matched(grid : Grid, targets : Array[TargetPos]) -> Bool {
  count_targets_matched(grid, targets) == targets.length()
}

///|
pub fn column_notes(grid : Grid, col : Int) -> Array[Int] {
  let notes : Array[Int] = []
  for r in 0..<grid.rows {
    if grid.cells[col][r].has_note {
      notes.push(r)
    }
  }
  notes
}

///|
pub fn column_harmony_score(grid : Grid, col : Int) -> Int {
  let notes = column_notes(grid, col)
  let mut score = 0
  for i in 0..<notes.length() {
    for j = i + 1; j < notes.length(); j = j + 1 {
      score += harmony_between(notes[i], notes[j])
    }
  }
  score
}

///|
pub fn total_harmony_score(grid : Grid) -> Int {
  let mut score = 0
  for c in 0..<grid.cols {
    score += column_harmony_score(grid, c)
  }
  score
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}
