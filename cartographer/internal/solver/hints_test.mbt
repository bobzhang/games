///|
test "hint_computation_forced_cell" {
  // If mountain at (2,2) and clue says town is distance 3 east of mountain,
  // and only one position east at distance 3, the hint should find it
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
      text="dir east",
    ),
    @types.new_clue(Not, Town, direction=N, row_col=0, text="not row 1"),
    @types.new_clue(Not, Town, direction=N, row_col=1, text="not row 2"),
    @types.new_clue(Not, Town, direction=N, row_col=3, text="not row 4"),
    @types.new_clue(Not, Town, direction=N, row_col=4, text="not row 5"),
    @types.new_clue(Not, Town, direction=N, row_col=5, text="not row 6"),
    @types.new_clue(Not, Town, direction=N, row_col=6, text="not row 7"),
    @types.new_clue(Not, Town, direction=N, row_col=7, text="not row 8"),
  ]
  let hints = @solver.compute_hints(grid, 8, features, clues)
  // Town must be at (5,2) - only valid position
  inspect(hints.length(), content="1")
  inspect(hints[0].x, content="5")
  inspect(hints[0].y, content="2")
}

///|
test "hint_no_forced_cells" {
  // Multiple valid positions => no hints
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 2] = Some(Mountain)
  let features : Array[@types.FeatureKind] = [Mountain, Town]
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="dist"),
  ]
  let hints = @solver.compute_hints(grid, 8, features, clues)
  // Multiple positions at distance 3, no forced cell
  inspect(hints.length(), content="0")
}

///|
test "get_feature_placement_count" {
  let features : Array[@types.FeatureKind] = [Mountain, Town, Forest, Town]
  inspect(@solver.get_feature_placement_count(features, Town), content="2")
  inspect(@solver.get_feature_placement_count(features, Mountain), content="1")
  inspect(@solver.get_feature_placement_count(features, Lake), content="0")
}
