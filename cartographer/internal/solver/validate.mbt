///|
pub fn check_clue(
  clue : @types.Clue,
  grid : Array[@types.FeatureKind?],
  size : Int
) -> @types.ClueStatus {
  match clue.kind {
    Distance => check_distance_clue(clue, grid, size)
    Direction => check_direction_clue(clue, grid, size)
    Adjacent => check_adjacent_clue(clue, grid, size)
    Count => check_count_clue(clue, grid, size)
    Between => check_between_clue(clue, grid, size)
    Not => check_not_clue(clue, grid, size)
  }
}

///|
fn check_distance_clue(
  clue : @types.Clue,
  grid : Array[@types.FeatureKind?],
  size : Int
) -> @types.ClueStatus {
  let pos_a = @types.find_feature_pos(grid, size, clue.feature_a)
  let pos_b = @types.find_feature_pos(grid, size, clue.feature_b)
  match (pos_a, pos_b) {
    (Some(a), Some(b)) => {
      let dist = @types.manhattan_distance(a, b)
      if dist == clue.distance {
        Satisfied
      } else {
        Violated
      }
    }
    _ => Pending
  }
}

///|
fn check_direction_clue(
  clue : @types.Clue,
  grid : Array[@types.FeatureKind?],
  size : Int
) -> @types.ClueStatus {
  let pos_a = @types.find_feature_pos(grid, size, clue.feature_a)
  let pos_b = @types.find_feature_pos(grid, size, clue.feature_b)
  match (pos_a, pos_b) {
    (Some(a), Some(b)) =>
      if @types.direction_check(b, a, clue.direction) {
        Satisfied
      } else {
        Violated
      }
    _ => Pending
  }
}

///|
fn check_adjacent_clue(
  clue : @types.Clue,
  grid : Array[@types.FeatureKind?],
  size : Int
) -> @types.ClueStatus {
  let pos_a = @types.find_feature_pos(grid, size, clue.feature_a)
  let pos_b = @types.find_feature_pos(grid, size, clue.feature_b)
  match (pos_a, pos_b) {
    (Some(a), Some(b)) =>
      if @types.is_adjacent(a, b) {
        Satisfied
      } else {
        Violated
      }
    _ => Pending
  }
}

///|
fn check_count_clue(
  clue : @types.Clue,
  grid : Array[@types.FeatureKind?],
  size : Int
) -> @types.ClueStatus {
  let mut count = 0
  for i in 0..<size {
    let idx = if clue.direction == N {
      // Row-based: row_col is the row index, iterate columns
      clue.row_col * size + i
    } else {
      // Column-based: row_col is the col index, iterate rows
      i * size + clue.row_col
    }
    match grid[idx] {
      Some(f) => if f == clue.feature_a { count += 1 }
      None => ()
    }
  }
  // If we have placed all features of this type, we can make a definitive check
  let all_positions = @types.find_all_feature_positions(grid, size, clue.feature_a)
  if all_positions.length() == 0 {
    return Pending
  }
  if count == clue.count {
    Satisfied
  } else if count > clue.count {
    Violated
  } else {
    // Haven't placed enough yet, check if it's still possible
    Pending
  }
}

///|
fn check_between_clue(
  clue : @types.Clue,
  grid : Array[@types.FeatureKind?],
  size : Int
) -> @types.ClueStatus {
  // feature_a is between feature_b and the third feature
  // We use feature_b for one endpoint and row_col encodes the third feature index
  let pos_target = @types.find_feature_pos(grid, size, clue.feature_a)
  let pos_end_a = @types.find_feature_pos(grid, size, clue.feature_b)
  // Use count field to encode the third feature kind index
  let third_kind = feature_kind_from_index(clue.count)
  let pos_end_b = @types.find_feature_pos(grid, size, third_kind)
  match (pos_target, pos_end_a, pos_end_b) {
    (Some(t), Some(a), Some(b)) =>
      if @types.is_between(t, a, b) {
        Satisfied
      } else {
        Violated
      }
    _ => Pending
  }
}

///|
fn check_not_clue(
  clue : @types.Clue,
  grid : Array[@types.FeatureKind?],
  size : Int
) -> @types.ClueStatus {
  // No feature_a in row or column specified by row_col
  // direction N = row, S = column
  for i in 0..<size {
    let idx = if clue.direction == N {
      clue.row_col * size + i
    } else {
      i * size + clue.row_col
    }
    match grid[idx] {
      Some(f) => if f == clue.feature_a { return Violated }
      None => ()
    }
  }
  Satisfied
}

///|
pub fn feature_kind_from_index(idx : Int) -> @types.FeatureKind {
  match idx {
    0 => Mountain
    1 => River
    2 => Forest
    3 => Town
    4 => Lake
    5 => Desert
    _ => Road
  }
}

///|
pub fn feature_kind_to_index(kind : @types.FeatureKind) -> Int {
  match kind {
    Mountain => 0
    River => 1
    Forest => 2
    Town => 3
    Lake => 4
    Desert => 5
    Road => 6
  }
}

///|
pub fn validate_all_clues(
  clues : Array[@types.Clue],
  grid : Array[@types.FeatureKind?],
  size : Int
) -> Unit {
  for i in 0..<clues.length() {
    clues[i].status = check_clue(clues[i], grid, size)
  }
}

///|
pub fn all_clues_satisfied(clues : Array[@types.Clue]) -> Bool {
  for i in 0..<clues.length() {
    if clues[i].status != Satisfied {
      return false
    }
  }
  true
}

///|
pub fn any_clue_violated(clues : Array[@types.Clue]) -> Bool {
  for i in 0..<clues.length() {
    if clues[i].status == Violated {
      return true
    }
  }
  false
}

///|
pub fn check_placement_consistent(
  grid : Array[@types.FeatureKind?],
  size : Int,
  clues : Array[@types.Clue],
  pos : @types.Vec2i,
  feature : @types.FeatureKind
) -> Bool {
  // Temporarily place the feature
  let idx = @types.pos_to_index(pos, size)
  let old = grid[idx]
  grid[idx] = Some(feature)
  // Check if any clue is violated
  let mut consistent = true
  for i in 0..<clues.length() {
    let status = check_clue(clues[i], grid, size)
    if status == Violated {
      consistent = false
      break
    }
  }
  // Restore
  grid[idx] = old
  consistent
}

///|
pub fn count_placed_features(
  grid : Array[@types.FeatureKind?],
  kind : @types.FeatureKind
) -> Int {
  let mut count = 0
  for i in 0..<grid.length() {
    match grid[i] {
      Some(f) => if f == kind { count += 1 }
      None => ()
    }
  }
  count
}

///|
pub fn all_features_placed(
  grid : Array[@types.FeatureKind?],
  features : Array[@types.FeatureKind]
) -> Bool {
  // Count required features
  let counts : Array[Int] = Array::make(7, 0)
  for i in 0..<features.length() {
    counts[feature_kind_to_index(features[i])] += 1
  }
  // Count placed features
  let placed : Array[Int] = Array::make(7, 0)
  for i in 0..<grid.length() {
    match grid[i] {
      Some(f) => placed[feature_kind_to_index(f)] += 1
      None => ()
    }
  }
  for i in 0..<7 {
    if placed[i] != counts[i] {
      return false
    }
  }
  true
}
