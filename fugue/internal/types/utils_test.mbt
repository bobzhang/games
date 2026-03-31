///|
test "interval_between same note" {
  let result = interval_between(3, 3)
  assert_eq(result, 0)
}

///|
test "interval_between second" {
  let result = interval_between(0, 1)
  assert_eq(result, 1)
}

///|
test "interval_between third" {
  // C(row6) and E(row4) => 2 steps
  let result = interval_between(6, 4)
  assert_eq(result, 2)
}

///|
test "interval_between fifth" {
  // C(row6) and G(row2) => 4 steps
  let result = interval_between(6, 2)
  assert_eq(result, 4)
}

///|
test "interval_between tritone" {
  // C(row6) and F(row3) => 3 steps
  let result = interval_between(6, 3)
  assert_eq(result, 3)
}

///|
test "interval_between symmetric" {
  let a = interval_between(2, 5)
  let b = interval_between(5, 2)
  assert_eq(a, b)
}

///|
test "interval_quality unison" {
  let q = interval_quality(0)
  assert_eq(q, Unison)
}

///|
test "interval_quality third" {
  let q = interval_quality(2)
  assert_eq(q, Third)
}

///|
test "interval_quality fifth" {
  let q = interval_quality(4)
  assert_eq(q, Fifth)
}

///|
test "interval_quality tritone" {
  let q = interval_quality(3)
  assert_eq(q, Tritone)
}

///|
test "interval_score values" {
  assert_eq(interval_score(Unison), 0)
  assert_eq(interval_score(Second), -1)
  assert_eq(interval_score(Third), 2)
  assert_eq(interval_score(Tritone), -2)
  assert_eq(interval_score(Fifth), 3)
  assert_eq(interval_score(Sixth), 2)
  assert_eq(interval_score(Seventh), -1)
}

///|
test "harmony_between third gives +2" {
  let score = harmony_between(6, 4)
  assert_eq(score, 2)
}

///|
test "harmony_between fifth gives +3" {
  let score = harmony_between(6, 2)
  assert_eq(score, 3)
}

///|
test "harmony_between second gives -1" {
  let score = harmony_between(6, 5)
  assert_eq(score, -1)
}

///|
test "harmony_between tritone gives -2" {
  let score = harmony_between(6, 3)
  assert_eq(score, -2)
}

///|
test "column_harmony_score empty column" {
  let grid = new_grid(8, 7)
  let score = column_harmony_score(grid, 0)
  assert_eq(score, 0)
}

///|
test "column_harmony_score single note" {
  let grid = new_grid(8, 7)
  grid.cells[0][6].has_note = true
  let score = column_harmony_score(grid, 0)
  assert_eq(score, 0)
}

///|
test "column_harmony_score third pair" {
  let grid = new_grid(8, 7)
  grid.cells[0][6].has_note = true // C
  grid.cells[0][4].has_note = true // E (2 steps = third)
  let score = column_harmony_score(grid, 0)
  assert_eq(score, 2)
}

///|
test "column_harmony_score fifth pair" {
  let grid = new_grid(8, 7)
  grid.cells[0][6].has_note = true // C
  grid.cells[0][2].has_note = true // G (4 steps = fifth)
  let score = column_harmony_score(grid, 0)
  assert_eq(score, 3)
}

///|
test "column_harmony_score triad" {
  let grid = new_grid(8, 7)
  grid.cells[0][6].has_note = true // C (row 6)
  grid.cells[0][4].has_note = true // E (row 4) - third from C
  grid.cells[0][2].has_note = true // G (row 2) - fifth from C, third from E
  // C-E: third (+2), C-G: fifth (+3), E-G: third (+2) = total +7
  let score = column_harmony_score(grid, 0)
  assert_eq(score, 7)
}

///|
test "total_harmony_score across columns" {
  let grid = new_grid(8, 7)
  // Column 0: C + E = +2
  grid.cells[0][6].has_note = true
  grid.cells[0][4].has_note = true
  // Column 1: C + G = +3
  grid.cells[1][6].has_note = true
  grid.cells[1][2].has_note = true
  let score = total_harmony_score(grid)
  assert_eq(score, 5)
}

///|
test "count_targets_matched" {
  let grid = new_grid(8, 7)
  let targets : Array[TargetPos] = [{ col: 0, row: 6 }, { col: 2, row: 4 }]
  // No notes placed yet
  assert_eq(count_targets_matched(grid, targets), 0)
  // Place one target
  grid.cells[0][6].has_note = true
  assert_eq(count_targets_matched(grid, targets), 1)
  // Place both
  grid.cells[2][4].has_note = true
  assert_eq(count_targets_matched(grid, targets), 2)
}

///|
test "all_targets_matched" {
  let grid = new_grid(8, 7)
  let targets : Array[TargetPos] = [{ col: 0, row: 6 }, { col: 2, row: 4 }]
  assert_eq(all_targets_matched(grid, targets), false)
  grid.cells[0][6].has_note = true
  grid.cells[2][4].has_note = true
  assert_eq(all_targets_matched(grid, targets), true)
}

///|
test "count_notes_in_grid excludes locked" {
  let grid = new_grid(8, 7)
  grid.cells[0][6].has_note = true
  grid.cells[0][6].is_locked = true
  grid.cells[1][4].has_note = true
  // Only the unlocked note counts
  assert_eq(count_notes_in_grid(grid), 1)
}

///|
test "note_from_row mapping" {
  assert_eq(note_from_row(0), B)
  assert_eq(note_from_row(1), A)
  assert_eq(note_from_row(2), G)
  assert_eq(note_from_row(3), F)
  assert_eq(note_from_row(4), E)
  assert_eq(note_from_row(5), D)
  assert_eq(note_from_row(6), C)
}

///|
test "row_from_note roundtrip" {
  let notes : Array[Note] = [C, D, E, F, G, A, B]
  for i in 0..<notes.length() {
    let note = notes[i]
    let row = row_from_note(note)
    let back = note_from_row(row)
    assert_eq(back, note)
  }
}
