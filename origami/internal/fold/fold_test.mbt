///|
test "center fold left doubles layers" {
  let paper = @types.full_paper(8, 8)
  let result = execute_fold(paper, Left, 4)
  // Right half folded onto left half
  // Cells 0-3 should have paper with 2 layers
  let cell = @types.get_cell(result, 2, 3)
  assert_true(cell.has_paper)
  assert_eq(cell.layers, 2)
  // Cells 4-7 should be empty
  let cell2 = @types.get_cell(result, 5, 3)
  assert_true(!cell2.has_paper)
}

///|
test "center fold up doubles layers" {
  let paper = @types.full_paper(8, 8)
  let result = execute_fold(paper, Up, 4)
  // Bottom half folded onto top half
  let cell = @types.get_cell(result, 3, 2)
  assert_true(cell.has_paper)
  assert_eq(cell.layers, 2)
  // Bottom should be empty
  let cell2 = @types.get_cell(result, 3, 6)
  assert_true(!cell2.has_paper)
}

///|
test "off-center fold creates partial overlap" {
  let paper = @types.full_paper(8, 8)
  // Fold left at col 6: cols 6,7 fold to cols 4,5
  let result = execute_fold(paper, Left, 6)
  // Cols 0-3: still 1 layer
  let c0 = @types.get_cell(result, 1, 0)
  assert_eq(c0.layers, 1)
  // Cols 4-5: 2 layers (original + folded)
  let c4 = @types.get_cell(result, 4, 0)
  assert_eq(c4.layers, 2)
  let c5 = @types.get_cell(result, 5, 0)
  assert_eq(c5.layers, 2)
  // Cols 6-7: empty
  let c6 = @types.get_cell(result, 6, 0)
  assert_true(!c6.has_paper)
}

///|
test "silhouette matching" {
  let p1 = @types.make_rect_paper(8, 8, 0, 0, 4, 8)
  let p2 = @types.make_rect_paper(8, 8, 0, 0, 4, 8)
  assert_true(@types.paper_matches_silhouette(p1, p2))
  let p3 = @types.make_rect_paper(8, 8, 0, 0, 3, 8)
  assert_true(!@types.paper_matches_silhouette(p1, p3))
}

///|
test "layer check satisfaction" {
  let paper = @types.full_paper(4, 4)
  // Fold left at 2 -> cols 0-1 have 2 layers
  let folded = execute_fold(paper, Left, 2)
  let check : @types.LayerCheck = {
    pos: { x: 0, y: 0 },
    required_layers: 2,
  }
  assert_true(@types.single_layer_check_ok(folded, check))
  let check2 : @types.LayerCheck = {
    pos: { x: 0, y: 0 },
    required_layers: 3,
  }
  assert_true(!@types.single_layer_check_ok(folded, check2))
}

///|
test "fold and undo restores original" {
  let paper = @types.full_paper(8, 8)
  let saved = @types.clone_paper(paper)
  let folded = execute_fold(paper, Left, 4)
  // Folded should differ
  let c = @types.get_cell(folded, 0, 0)
  assert_eq(c.layers, 2)
  // Original saved should still be 1
  let sc = @types.get_cell(saved, 0, 0)
  assert_eq(sc.layers, 1)
  assert_eq(sc.has_paper, true)
  // "Undo" by using saved copy
  assert_true(@types.paper_matches_silhouette(saved, @types.full_paper(8, 8)))
}

///|
test "multi-fold sequence" {
  let paper = @types.full_paper(8, 8)
  // Fold left at 4, fold up at 4 -> 4x4 with 4 layers
  let step1 = execute_fold(paper, Left, 4)
  let step2 = execute_fold(step1, Up, 4)
  let c = @types.get_cell(step2, 2, 2)
  assert_true(c.has_paper)
  assert_eq(c.layers, 4)
  // Cells outside should be empty
  let c2 = @types.get_cell(step2, 6, 6)
  assert_true(!c2.has_paper)
}

///|
test "fold right" {
  let paper = @types.full_paper(8, 8)
  let result = execute_fold(paper, Right, 4)
  // Left half folds to right half
  let c = @types.get_cell(result, 5, 3)
  assert_true(c.has_paper)
  assert_eq(c.layers, 2)
  let c2 = @types.get_cell(result, 2, 3)
  assert_true(!c2.has_paper)
}

///|
test "fold down" {
  let paper = @types.full_paper(8, 8)
  let result = execute_fold(paper, Down, 4)
  // Top half folds to bottom
  let c = @types.get_cell(result, 3, 5)
  assert_true(c.has_paper)
  assert_eq(c.layers, 2)
  let c2 = @types.get_cell(result, 3, 1)
  assert_true(!c2.has_paper)
}

///|
test "is_valid_fold returns false for empty side" {
  let paper = @types.make_rect_paper(8, 8, 0, 0, 4, 8)
  // No paper on right side, fold left should be invalid
  assert_true(!is_valid_fold(paper, Left, 4))
  // But fold right at 4 should be valid (paper on left side)
  assert_true(is_valid_fold(paper, Right, 4))
}
