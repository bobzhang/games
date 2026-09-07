///|
test "hint_narrow_most_constrained" {
  // Mountain at (2,2), clues force Town to small area
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let clues = [
    @types.new_clue(
      Distance,
      Mountain,
      feature_b=Town,
      distance=3,
      text="dist 3",
    ),
    @types.new_clue(
      Direction,
      Town,
      feature_b=Mountain,
      direction=E,
      text="town east",
    ),
    @types.new_clue(Not, Town, direction=N, row_col=0, text="no town row 1"),
    @types.new_clue(Not, Town, direction=N, row_col=1, text="no town row 2"),
  ]
  let (cells, feat) = @solver.compute_narrow_hint(grid, 8, features, clues)
  // Should narrow Town to a few cells
  assert_true(cells.length() > 0)
  assert_true(cells.length() < 64)
  debug_inspect(feat, content="Some(Town)")
}

///|
test "hint_narrow_empty_grid" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="test"),
  ]
  let (cells, feat) = @solver.compute_narrow_hint(grid, 8, features, clues)
  // Both features need placement; should return cells for one of them
  assert_true(cells.length() > 0)
  assert_true(feat is Some(_))
}

///|
test "hint_reveal_forced_cell" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="dist"),
    @types.new_clue(
      Direction,
      Town,
      feature_b=Mountain,
      direction=E,
      text="east",
    ),
    @types.new_clue(Not, Town, direction=N, row_col=0, text="no row 1"),
    @types.new_clue(Not, Town, direction=N, row_col=1, text="no row 2"),
    @types.new_clue(Not, Town, direction=N, row_col=3, text="no row 4"),
    @types.new_clue(Not, Town, direction=N, row_col=4, text="no row 5"),
    @types.new_clue(Not, Town, direction=N, row_col=5, text="no row 6"),
    @types.new_clue(Not, Town, direction=N, row_col=6, text="no row 7"),
    @types.new_clue(Not, Town, direction=N, row_col=7, text="no row 8"),
  ]
  let (cell, feat) = @solver.compute_reveal_hint(grid, 8, features, clues)
  debug_inspect(
    cell,
    content=(
      #|Some({ x: 5, y: 2 })
    ),
  )
  debug_inspect(feat, content="Some(Town)")
}

///|
test "hint_reveal_no_features_needed" {
  // All features already placed
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[0] = Some(Mountain)
  grid[1] = Some(Town)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let clues = [
    @types.new_clue(
      Distance,
      Mountain,
      feature_b=Town,
      distance=1,
      text="dist 1",
    ),
  ]
  let (cell, feat) = @solver.compute_reveal_hint(grid, 8, features, clues)
  debug_inspect(cell, content="None")
  debug_inspect(feat, content="None")
}

///|
test "hint_all_features_placed_empty_hints" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[0] = Some(Mountain)
  grid[1] = Some(Town)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=1, text="test"),
  ]
  let hints = @solver.compute_hints(grid, 8, features, clues)
  inspect(hints.length(), content="0")
}

///|
test "needed_features_all_placed" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[0] = Some(Mountain)
  grid[1] = Some(Town)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let needed = @solver.get_needed_features_pub(grid, features)
  inspect(needed.length(), content="0")
}

///|
test "needed_features_partial" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[0] = Some(Mountain)
  let features : Array[@types.FeatureKind] = [Mountain, Town, Forest]
  let needed = @solver.get_needed_features_pub(grid, features)
  inspect(needed.length(), content="2")
}

///|
test "valid_positions_empty_grid" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  let clues : Array[@types.Clue] = [
    @types.new_clue(Not, Mountain, direction=N, row_col=0, text="no row 1"),
  ]
  let valid = @solver.find_valid_positions_pub(grid, 8, clues, Mountain)
  // Should have 56 valid positions (64 - 8 in row 0)
  inspect(valid.length(), content="56")
}

///|
test "valid_positions_highly_constrained" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  let clues = [
    @types.new_clue(
      Distance,
      Mountain,
      feature_b=Town,
      distance=1,
      text="dist 1",
    ),
    @types.new_clue(
      Direction,
      Town,
      feature_b=Mountain,
      direction=E,
      text="east",
    ),
  ]
  let valid = @solver.find_valid_positions_pub(grid, 8, clues, Town)
  // Town must be 1 tile from mountain and east of mountain => (3,2)
  inspect(valid.length(), content="1")
  inspect(valid[0].x, content="3")
  inspect(valid[0].y, content="2")
}

///|
test "between_clue_integration" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  // Mountain at (1,3), Forest at (5,3), Town at (3,3) => town between mountain and forest
  grid[3 * 8 + 1] = Some(Mountain)
  grid[3 * 8 + 5] = Some(Forest)
  grid[3 * 8 + 3] = Some(Town)
  let clue = @types.new_clue(
    Between,
    Town,
    feature_b=Mountain,
    count=2,
    text="Town is between Mountain and Forest",
  )
  let status = @solver.check_clue(clue, grid, 8)
  inspect(status, content="Satisfied")
}

///|
test "count_solutions_simple_level" {
  // A very constrained mini-puzzle should have exactly 1 solution
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let clues = [
    @types.new_clue(
      Distance,
      Mountain,
      feature_b=Town,
      distance=1,
      text="dist 1",
    ),
    @types.new_clue(
      Direction,
      Town,
      feature_b=Mountain,
      direction=E,
      text="east",
    ),
    @types.new_clue(Not, Mountain, direction=N, row_col=0, text="no row 1"),
    @types.new_clue(Not, Mountain, direction=N, row_col=1, text="no row 2"),
    @types.new_clue(Not, Mountain, direction=N, row_col=2, text="no row 3"),
    @types.new_clue(Not, Mountain, direction=N, row_col=4, text="no row 5"),
    @types.new_clue(Not, Mountain, direction=N, row_col=5, text="no row 6"),
    @types.new_clue(Not, Mountain, direction=N, row_col=6, text="no row 7"),
    @types.new_clue(Not, Mountain, direction=N, row_col=7, text="no row 8"),
    @types.new_clue(Not, Mountain, direction=S, row_col=0, text="no col 1"),
    @types.new_clue(Not, Mountain, direction=S, row_col=1, text="no col 2"),
    @types.new_clue(Not, Mountain, direction=S, row_col=3, text="no col 4"),
    @types.new_clue(Not, Mountain, direction=S, row_col=4, text="no col 5"),
    @types.new_clue(Not, Mountain, direction=S, row_col=5, text="no col 6"),
    @types.new_clue(Not, Mountain, direction=S, row_col=6, text="no col 7"),
    @types.new_clue(Not, Mountain, direction=S, row_col=7, text="no col 8"),
  ]
  // Mountain forced to (2,3), Town must be at (3,3)
  let count = @solver.count_solutions(8, features, clues, max_solutions=3)
  inspect(count, content="1")
}
