///|
test "clue_references_feature_positive" {
  let clue = @types.new_clue(
    Distance,
    Mountain,
    feature_b=Town,
    distance=3,
    text="test",
  )
  inspect(@types.clue_references_feature(clue, Mountain), content="true")
  inspect(@types.clue_references_feature(clue, Town), content="true")
  inspect(@types.clue_references_feature(clue, Forest), content="false")
}

///|
test "clues_referencing_feature" {
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="c1"),
    @types.new_clue(Direction, Forest, feature_b=Lake, direction=N, text="c2"),
    @types.new_clue(Adjacent, Mountain, feature_b=River, text="c3"),
  ]
  let refs = @types.clues_referencing_feature(clues, Mountain)
  inspect(refs.length(), content="2")
  inspect(refs[0], content="0")
  inspect(refs[1], content="2")
}

///|
test "clues_referencing_feature_none_found" {
  let clues = [
    @types.new_clue(Distance, Mountain, feature_b=Town, distance=3, text="c1"),
  ]
  let refs = @types.clues_referencing_feature(clues, Desert)
  inspect(refs.length(), content="0")
}

///|
test "cells_referenced_by_clue_distance" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 3] = Some(Mountain)
  grid[4 * 8 + 5] = Some(Town)
  let clue = @types.new_clue(
    Distance,
    Mountain,
    feature_b=Town,
    distance=4,
    text="test",
  )
  let cells = @types.cells_referenced_by_clue(clue, grid, 8)
  // Should contain positions for Mountain and Town
  inspect(cells.length(), content="2")
  debug_inspect(
    cells[0],
    content=(
      #|{ x: 3, y: 2 }
    ),
  )
  debug_inspect(
    cells[1],
    content=(
      #|{ x: 5, y: 4 }
    ),
  )
}

///|
test "cells_referenced_by_clue_count_row" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[2 * 8 + 3] = Some(Forest)
  let clue = @types.new_clue(
    Count,
    Forest,
    direction=N,
    row_col=2,
    count=1,
    text="test",
  )
  let cells = @types.cells_referenced_by_clue(clue, grid, 8)
  // Should have Forest position + 8 row cells
  // Forest at (3,2) + row 2 cells (0,2) through (7,2)
  inspect(cells.length(), content="9")
}

///|
test "cells_referenced_by_clue_not_column" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  let clue = @types.new_clue(
    Not,
    Mountain,
    direction=S,
    row_col=3,
    text="no mountain col 4",
  )
  let cells = @types.cells_referenced_by_clue(clue, grid, 8)
  // No Mountain placed, but column 3 should have 8 cells
  inspect(cells.length(), content="8")
  // First cell should be (3,0)
  debug_inspect(
    cells[0],
    content=(
      #|{ x: 3, y: 0 }
    ),
  )
}

///|
test "cells_referenced_by_clue_partial_placement" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[3 * 8 + 2] = Some(Mountain)
  // Town not yet placed
  let clue = @types.new_clue(
    Distance,
    Mountain,
    feature_b=Town,
    distance=3,
    text="test",
  )
  let cells = @types.cells_referenced_by_clue(clue, grid, 8)
  // Only Mountain position should be returned (Town not placed)
  inspect(cells.length(), content="1")
  debug_inspect(
    cells[0],
    content=(
      #|{ x: 2, y: 3 }
    ),
  )
}
