///|
test "compute_column_harmony empty" {
  let grid = @types.new_grid(8, 7)
  let score = compute_column_harmony(grid, 0)
  assert_eq(score, 0)
}

///|
test "compute_column_harmony with third" {
  let grid = @types.new_grid(8, 7)
  grid.cells[0][6].has_note = true
  grid.cells[0][4].has_note = true
  let score = compute_column_harmony(grid, 0)
  assert_eq(score, 2)
}

///|
test "compute_total_harmony multi-column" {
  let grid = @types.new_grid(8, 7)
  // Col 0: C+E = third = +2
  grid.cells[0][6].has_note = true
  grid.cells[0][4].has_note = true
  // Col 3: C+G = fifth = +3
  grid.cells[3][6].has_note = true
  grid.cells[3][2].has_note = true
  let total = compute_total_harmony(grid)
  assert_eq(total, 5)
}

///|
test "check_all_targets true" {
  let grid = @types.new_grid(8, 7)
  let targets : Array[@types.TargetPos] = [
    { col: 1, row: 6, },
    { col: 3, row: 4, },
  ]
  grid.cells[1][6].has_note = true
  grid.cells[3][4].has_note = true
  assert_eq(check_all_targets(grid, targets), true)
}

///|
test "check_all_targets false" {
  let grid = @types.new_grid(8, 7)
  let targets : Array[@types.TargetPos] = [
    { col: 1, row: 6, },
    { col: 3, row: 4, },
  ]
  grid.cells[1][6].has_note = true
  // Missing second target
  assert_eq(check_all_targets(grid, targets), false)
}

///|
test "compute_stars melody tier all matched" {
  let grid = @types.new_grid(8, 7)
  let level : @types.Level = {
    id: 0,
    name: "Test",
    tier: Melody,
    grid_cols: 8,
    grid_rows: 7,
    targets: [{ col: 0, row: 6, }],
    note_budget: 3,
    harmony_threshold_2star: 0,
    harmony_threshold_3star: 0,
  }
  grid.cells[0][6].has_note = true
  let stars = compute_stars(grid, level)
  assert_eq(stars, 3)
}

///|
test "compute_stars no targets matched" {
  let grid = @types.new_grid(8, 7)
  let level : @types.Level = {
    id: 0,
    name: "Test",
    tier: Harmony,
    grid_cols: 8,
    grid_rows: 7,
    targets: [{ col: 0, row: 6, }],
    note_budget: 3,
    harmony_threshold_2star: 4,
    harmony_threshold_3star: 8,
  }
  let stars = compute_stars(grid, level)
  assert_eq(stars, 0)
}

///|
test "compute_stars harmony tier 2 star" {
  let grid = @types.new_grid(8, 7)
  let level : @types.Level = {
    id: 7,
    name: "Test",
    tier: Harmony,
    grid_cols: 8,
    grid_rows: 7,
    targets: [{ col: 0, row: 6, }],
    note_budget: 5,
    harmony_threshold_2star: 2,
    harmony_threshold_3star: 6,
  }
  grid.cells[0][6].has_note = true // target matched
  grid.cells[0][4].has_note = true // E - third from C = +2
  let stars = compute_stars(grid, level)
  assert_eq(stars, 2)
}

///|
test "compute_stars harmony tier 3 star" {
  let grid = @types.new_grid(8, 7)
  let level : @types.Level = {
    id: 7,
    name: "Test",
    tier: Harmony,
    grid_cols: 8,
    grid_rows: 7,
    targets: [{ col: 0, row: 6, }],
    note_budget: 5,
    harmony_threshold_2star: 2,
    harmony_threshold_3star: 5,
  }
  grid.cells[0][6].has_note = true // C (target)
  grid.cells[0][4].has_note = true // E - third = +2
  grid.cells[0][2].has_note = true // G - fifth from C(+3), third from E(+2) = total +7
  let stars = compute_stars(grid, level)
  assert_eq(stars, 3)
}

///|
test "column_interval_pairs" {
  let grid = @types.new_grid(8, 7)
  grid.cells[0][6].has_note = true // C
  grid.cells[0][4].has_note = true // E
  grid.cells[0][2].has_note = true // G
  let pairs = column_interval_pairs(grid, 0)
  assert_eq(pairs.length(), 3)
}

///|
test "evaluate_placement" {
  let grid = @types.new_grid(8, 7)
  grid.cells[0][6].has_note = true // C
  // Evaluate placing E (row 4) - should give +2 (third)
  let delta = evaluate_placement(grid, 0, 4)
  assert_eq(delta, 2)
}

///|
test "evaluate_placement dissonant" {
  let grid = @types.new_grid(8, 7)
  grid.cells[0][6].has_note = true // C
  // Evaluate placing D (row 5) - should give -1 (second)
  let delta = evaluate_placement(grid, 0, 5)
  assert_eq(delta, -1)
}
