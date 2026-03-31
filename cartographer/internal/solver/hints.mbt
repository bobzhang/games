///|
pub fn compute_hints(
  grid : Array[@types.FeatureKind?],
  size : Int,
  features_to_place : Array[@types.FeatureKind],
  clues : Array[@types.Clue]
) -> Array[@types.Vec2i] {
  let hints : Array[@types.Vec2i] = []
  // Find features that still need to be placed
  let needed = get_needed_features(grid, features_to_place)
  // For each needed feature, check if there's only one valid position
  for i in 0..<needed.length() {
    let feature = needed[i]
    let valid_positions = find_valid_positions(grid, size, clues, feature)
    if valid_positions.length() == 1 {
      let pos = valid_positions[0]
      // Check that this hint isn't already in our list
      let mut already = false
      for j in 0..<hints.length() {
        if hints[j].x == pos.x && hints[j].y == pos.y {
          already = true
          break
        }
      }
      if !already {
        hints.push(pos)
      }
    }
  }
  hints
}

///|
fn get_needed_features(
  grid : Array[@types.FeatureKind?],
  features_to_place : Array[@types.FeatureKind]
) -> Array[@types.FeatureKind] {
  let needed : Array[@types.FeatureKind] = []
  // Count how many of each feature type we need
  let required : Array[Int] = Array::make(7, 0)
  for i in 0..<features_to_place.length() {
    required[feature_kind_to_index(features_to_place[i])] += 1
  }
  // Count how many are placed
  let placed : Array[Int] = Array::make(7, 0)
  for i in 0..<grid.length() {
    match grid[i] {
      Some(f) => placed[feature_kind_to_index(f)] += 1
      None => ()
    }
  }
  // Add needed ones
  for i in 0..<7 {
    let diff = required[i] - placed[i]
    for _j in 0..<diff {
      needed.push(feature_kind_from_index(i))
    }
  }
  needed
}

///|
fn find_valid_positions(
  grid : Array[@types.FeatureKind?],
  size : Int,
  clues : Array[@types.Clue],
  feature : @types.FeatureKind
) -> Array[@types.Vec2i] {
  let valid : Array[@types.Vec2i] = []
  for row in 0..<size {
    for col in 0..<size {
      let idx = row * size + col
      // Only consider empty cells
      match grid[idx] {
        Some(_) => ()
        None => {
          let pos = @types.vec2i(col, row)
          if check_placement_consistent(grid, size, clues, pos, feature) {
            valid.push(pos)
          }
        }
      }
    }
  }
  valid
}

///|
pub fn get_feature_placement_count(
  features_to_place : Array[@types.FeatureKind],
  kind : @types.FeatureKind
) -> Int {
  let mut count = 0
  for i in 0..<features_to_place.length() {
    if features_to_place[i] == kind {
      count += 1
    }
  }
  count
}
