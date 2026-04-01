///|
test "distance_clue_satisfied" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // Mountain at (2,2), Town at (5,2) => manhattan distance = 3
  grid[2 * 8 + 2] = Some(Mountain)
  grid[2 * 8 + 5] = Some(Town)
  let clue = @types.new_clue(
    Distance,
    Mountain,
    feature_b=Town,
    distance=3,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "distance_clue_violated" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // Mountain at (2,2), Town at (6,2) => manhattan distance = 4, not 3
  grid[2 * 8 + 2] = Some(Mountain)
  grid[2 * 8 + 6] = Some(Town)
  let clue = @types.new_clue(
    Distance,
    Mountain,
    feature_b=Town,
    distance=3,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Violated")
}

///|
test "distance_clue_pending" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  // Town not placed yet
  let clue = @types.new_clue(
    Distance,
    Mountain,
    feature_b=Town,
    distance=3,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Pending")
}

///|
test "direction_clue_north_satisfied" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // Forest at (3,1), Lake at (3,5) => forest is north of lake
  grid[1 * 8 + 3] = Some(Forest)
  grid[5 * 8 + 3] = Some(Lake)
  let clue = @types.new_clue(
    Direction,
    Forest,
    feature_b=Lake,
    direction=N,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "direction_clue_north_violated" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // Forest at (3,5), Lake at (3,1) => forest is south of lake
  grid[5 * 8 + 3] = Some(Forest)
  grid[1 * 8 + 3] = Some(Lake)
  let clue = @types.new_clue(
    Direction,
    Forest,
    feature_b=Lake,
    direction=N,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Violated")
}

///|
test "direction_clue_east" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 5] = Some(Town)
  grid[2 * 8 + 2] = Some(Mountain)
  let clue = @types.new_clue(
    Direction,
    Town,
    feature_b=Mountain,
    direction=E,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "direction_clue_west" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[3 * 8 + 1] = Some(Forest)
  grid[3 * 8 + 5] = Some(Lake)
  let clue = @types.new_clue(
    Direction,
    Forest,
    feature_b=Lake,
    direction=W,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "direction_clue_south" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[5 * 8 + 3] = Some(River)
  grid[2 * 8 + 3] = Some(Mountain)
  let clue = @types.new_clue(
    Direction,
    River,
    feature_b=Mountain,
    direction=S,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "adjacent_clue_satisfied" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[3 * 8 + 3] = Some(Mountain)
  grid[3 * 8 + 4] = Some(Town)
  let clue = @types.new_clue(Adjacent, Mountain, feature_b=Town, text="test")
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "adjacent_clue_violated" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[3 * 8 + 3] = Some(Mountain)
  grid[3 * 8 + 6] = Some(Town)
  let clue = @types.new_clue(Adjacent, Mountain, feature_b=Town, text="test")
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Violated")
}

///|
test "adjacent_clue_diagonal" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[3 * 8 + 3] = Some(Mountain)
  grid[4 * 8 + 4] = Some(River)
  let clue = @types.new_clue(Adjacent, Mountain, feature_b=River, text="test")
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "count_clue_row_satisfied" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // 2 forests in row 3 (index 2)
  grid[2 * 8 + 1] = Some(Forest)
  grid[2 * 8 + 5] = Some(Forest)
  let clue = @types.new_clue(
    Count,
    Forest,
    direction=N,
    row_col=2,
    count=2,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "count_clue_row_violated" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // 3 forests in row 3 but clue says 2
  grid[2 * 8 + 1] = Some(Forest)
  grid[2 * 8 + 3] = Some(Forest)
  grid[2 * 8 + 5] = Some(Forest)
  let clue = @types.new_clue(
    Count,
    Forest,
    direction=N,
    row_col=2,
    count=2,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Violated")
}

///|
test "count_clue_column" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // 1 town in column 3 (index 2)
  grid[1 * 8 + 2] = Some(Town)
  let clue = @types.new_clue(
    Count,
    Town,
    direction=S,
    row_col=2,
    count=1,
    text="test",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "not_clue_satisfied" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // No mountains in column 5
  grid[2 * 8 + 3] = Some(Mountain)
  let clue = @types.new_clue(Not, Mountain, direction=S, row_col=4, text="test")
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "not_clue_violated" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // Mountain in column 5 (index 4)
  grid[2 * 8 + 4] = Some(Mountain)
  let clue = @types.new_clue(Not, Mountain, direction=S, row_col=4, text="test")
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Violated")
}

///|
test "not_clue_row" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // No rivers in row 1 (index 0)
  grid[3 * 8 + 2] = Some(River)
  let clue = @types.new_clue(Not, River, direction=N, row_col=0, text="test")
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "validate_all_clues" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  grid[2 * 8 + 5] = Some(Town)
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="dist"),
    @types.new_clue(
      Direction,
      Town,
      feature_b=Mountain,
      direction=E,
      text="dir",
    ),
  ]
  @solver.validate_all_clues(clues, grid, 8)
  inspect(clues[0].status, content="Satisfied")
  inspect(clues[1].status, content="Satisfied")
}

///|
test "all_clues_satisfied" {
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="a"),
    @types.new_clue(Direction, Town, feature_b=Mountain, direction=E, text="b"),
  ]
  clues[0].status = Satisfied
  clues[1].status = Satisfied
  inspect(@solver.all_clues_satisfied(clues), content="true")
  clues[1].status = Pending
  inspect(@solver.all_clues_satisfied(clues), content="false")
}

///|
test "any_clue_violated" {
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="a"),
    @types.new_clue(Direction, Town, feature_b=Mountain, direction=E, text="b"),
  ]
  clues[0].status = Satisfied
  clues[1].status = Pending
  inspect(@solver.any_clue_violated(clues), content="false")
  clues[1].status = Violated
  inspect(@solver.any_clue_violated(clues), content="true")
}

///|
test "check_placement_consistent" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="test"),
    @types.new_clue(
      Direction,
      Town,
      feature_b=Mountain,
      direction=E,
      text="test",
    ),
  ]
  // Placing town at (5,2) should be consistent (distance 3, east)
  let ok = @solver.check_placement_consistent(
    grid,
    8,
    clues,
    @types.vec2i(5, 2),
    Town,
  )
  inspect(ok, content="true")
  // Placing town at (1,2) violates direction (west, not east)
  let bad = @solver.check_placement_consistent(
    grid,
    8,
    clues,
    @types.vec2i(1, 2),
    Town,
  )
  inspect(bad, content="false")
}

///|
test "all_features_placed" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  inspect(@solver.all_features_placed(grid, features), content="false")
  grid[0] = Some(Mountain)
  inspect(@solver.all_features_placed(grid, features), content="false")
  grid[1] = Some(Town)
  inspect(@solver.all_features_placed(grid, features), content="true")
}

///|
test "count_placed_features" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[0] = Some(Forest)
  grid[5] = Some(Forest)
  grid[10] = Some(Mountain)
  inspect(@solver.count_placed_features(grid, Forest), content="2")
  inspect(@solver.count_placed_features(grid, Mountain), content="1")
  inspect(@solver.count_placed_features(grid, Town), content="0")
}

///|
test "feature_kind_from_index roundtrip" {
  for i in 0..<7 {
    let kind = @solver.feature_kind_from_index(i)
    let back = @solver.feature_kind_to_index(kind)
    inspect(back == i, content="true")
  }
}

///|
test "full_level_validation" {
  // Level 1: Mountain at (2,2), Town at (5,2)
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  grid[2 * 8 + 5] = Some(Town)
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="dist"),
    @types.new_clue(
      Direction,
      Town,
      feature_b=Mountain,
      direction=E,
      text="dir",
    ),
    @types.new_clue(Not, Mountain, direction=N, row_col=0, text="not"),
  ]
  @solver.validate_all_clues(clues, grid, 8)
  inspect(@solver.all_clues_satisfied(clues), content="true")
  inspect(@solver.any_clue_violated(clues), content="false")
}
