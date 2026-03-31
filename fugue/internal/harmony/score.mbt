///|
pub fn compute_column_harmony(grid : @types.Grid, col : Int) -> Int {
  let notes = @types.column_notes(grid, col)
  let mut score = 0
  for i in 0..<notes.length() {
    for j = i + 1; j < notes.length(); j = j + 1 {
      score += @types.harmony_between(notes[i], notes[j])
    }
  }
  score
}

///|
pub fn compute_total_harmony(grid : @types.Grid) -> Int {
  let mut score = 0
  for c in 0..<grid.cols {
    score += compute_column_harmony(grid, c)
  }
  score
}

///|
pub fn check_all_targets(
  grid : @types.Grid,
  targets : Array[@types.TargetPos]
) -> Bool {
  @types.all_targets_matched(grid, targets)
}

///|
pub fn count_matched(
  grid : @types.Grid,
  targets : Array[@types.TargetPos]
) -> Int {
  @types.count_targets_matched(grid, targets)
}

///|
pub fn compute_stars(
  grid : @types.Grid,
  level : @types.Level
) -> Int {
  let targets_ok = check_all_targets(grid, level.targets)
  if !targets_ok {
    return 0
  }
  let harmony = compute_total_harmony(grid)
  if harmony >= level.harmony_threshold_3star && level.harmony_threshold_3star > 0 {
    return 3
  }
  if harmony >= level.harmony_threshold_2star && level.harmony_threshold_2star > 0 {
    return 2
  }
  // For Melody tier (thresholds are 0), just matching targets gets 3 stars
  if level.tier == Melody {
    return 3
  }
  1
}

///|
pub fn column_interval_pairs(
  grid : @types.Grid,
  col : Int
) -> Array[(Int, Int, Int)] {
  let notes = @types.column_notes(grid, col)
  let pairs : Array[(Int, Int, Int)] = []
  for i in 0..<notes.length() {
    for j = i + 1; j < notes.length(); j = j + 1 {
      let sc = @types.harmony_between(notes[i], notes[j])
      pairs.push((notes[i], notes[j], sc))
    }
  }
  pairs
}

///|
pub fn evaluate_placement(
  grid : @types.Grid,
  col : Int,
  row : Int
) -> Int {
  // Compute harmony change if a note were added at (col, row)
  let notes = @types.column_notes(grid, col)
  let mut delta = 0
  for i in 0..<notes.length() {
    if notes[i] != row {
      delta += @types.harmony_between(notes[i], row)
    }
  }
  delta
}
