///|
test "all 30 levels load without error" {
  for i in 0..<30 {
    let level = get_level(i)
    // Region should have valid dimensions
    assert_true(level.region.width > 0)
    assert_true(level.region.height > 0)
    // Should have at least one piece
    assert_true(level.pieces.length() > 0)
  }
}

///|
test "all regions have active cells" {
  for i in 0..<30 {
    let level = get_level(i)
    let count = @types.count_active_cells(level.region)
    assert_true(count > 0)
  }
}

///|
test "total piece cells equal region active cells" {
  // For a valid tessellation puzzle, total piece area must equal region area
  for i in 0..<30 {
    let level = get_level(i)
    let region_cells = @types.count_active_cells(level.region)
    let mut piece_cells = 0
    for j in 0..<level.pieces.length() {
      piece_cells += level.pieces[j].cells.length()
    }
    inspect(piece_cells == region_cells, content="true")
  }
}

///|
test "all pieces have at least one cell" {
  for i in 0..<30 {
    let level = get_level(i)
    for j in 0..<level.pieces.length() {
      assert_true(level.pieces[j].cells.length() > 0)
    }
  }
}

///|
test "par time is positive for all levels" {
  for i in 0..<30 {
    let level = get_level(i)
    assert_true(level.par_time > 0)
  }
}

///|
test "par rotations is positive for all levels" {
  for i in 0..<30 {
    let level = get_level(i)
    assert_true(level.par_rotations > 0)
  }
}

///|
test "region dimensions match grid constants" {
  for i in 0..<30 {
    let level = get_level(i)
    inspect(level.region.width, content="10")
    inspect(level.region.height, content="10")
  }
}

///|
test "region active array dimensions match declared size" {
  for i in 0..<30 {
    let level = get_level(i)
    inspect(level.region.active.length() == level.region.height, content="true")
    for r in 0..<level.region.active.length() {
      inspect(
        level.region.active[r].length() == level.region.width,
        content="true",
      )
    }
  }
}

///|
test "tier 1 levels are indices 0-9" {
  for i in 0..<10 {
    let level = get_level(i)
    // Tier 1 levels should be simpler (rectangular regions mostly)
    let count = @types.count_active_cells(level.region)
    assert_true(count > 0)
    assert_true(count <= 100)
  }
}

///|
test "tier 2 levels are indices 10-19" {
  for i in 10..<20 {
    let level = get_level(i)
    let count = @types.count_active_cells(level.region)
    assert_true(count > 0)
    assert_true(count <= 100)
  }
}

///|
test "tier 3 levels are indices 20-29" {
  for i in 20..<30 {
    let level = get_level(i)
    let count = @types.count_active_cells(level.region)
    assert_true(count > 0)
    assert_true(count <= 100)
  }
}

///|
test "later tiers have higher par times on average" {
  let mut tier1_total = 0
  let mut tier3_total = 0
  for i in 0..<10 {
    tier1_total += get_level(i).par_time
  }
  for i in 20..<30 {
    tier3_total += get_level(i).par_time
  }
  // Tier 3 (Art) should have higher par times than Tier 1 (Squares)
  assert_true(tier3_total > tier1_total)
}

///|
test "no piece has more than 5 cells" {
  // Pieces should be at most pentominoes (5 cells)
  for i in 0..<30 {
    let level = get_level(i)
    for j in 0..<level.pieces.length() {
      assert_true(level.pieces[j].cells.length() <= 5)
    }
  }
}

///|
test "total levels constant is 30" {
  inspect(@types.total_levels, content="30")
}

///|
test "piece cells are contiguous" {
  // Each piece should have contiguous cells (every cell adjacent to at least one other)
  for i in 0..<30 {
    let level = get_level(i)
    for j in 0..<level.pieces.length() {
      let cells = level.pieces[j].cells
      if cells.length() > 1 {
        // Check that every cell is adjacent to at least one other cell in the piece
        for k in 0..<cells.length() {
          let c = cells[k]
          let mut has_neighbor = false
          for m in 0..<cells.length() {
            if m != k {
              let n = cells[m]
              let dx = if c.x > n.x { c.x - n.x } else { n.x - c.x }
              let dy = if c.y > n.y { c.y - n.y } else { n.y - c.y }
              if (dx == 1 && dy == 0) || (dx == 0 && dy == 1) {
                has_neighbor = true
              }
            }
          }
          inspect(has_neighbor, content="true")
        }
      }
    }
  }
}
