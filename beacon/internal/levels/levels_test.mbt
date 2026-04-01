///|
test "all 25 levels load without panic" {
  for i in 0..<25 {
    let data = get_level(i)
    assert_true!(data.id >= 1 && data.id <= 25)
    assert_true!(data.budget > 0)
    assert_true!(data.par_towers > 0)
    assert_true!(data.par_chain > 0)
    assert_eq!(data.grid.length(), @types.grid_rows)
    assert_eq!(data.elevations.length(), @types.grid_rows)
    for r in 0..<@types.grid_rows {
      assert_eq!(data.grid[r].length(), @types.grid_cols)
      assert_eq!(data.elevations[r].length(), @types.grid_cols)
    }
  }
}

///|
test "each level has at least one transmitter and receiver" {
  for i in 0..<25 {
    let data = get_level(i)
    let mut has_tx = false
    let mut has_rx = false
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        if data.grid[r][c] == Transmitter {
          has_tx = true
        }
        if data.grid[r][c] == Receiver {
          has_rx = true
        }
      }
    }
    assert_true!(has_tx)
    assert_true!(has_rx)
  }
}

///|
test "tier assignments are correct" {
  for i in 0..<8 {
    assert_eq!(get_level(i).tier, 1)
  }
  for i in 8..<17 {
    assert_eq!(get_level(i).tier, 2)
  }
  for i in 17..<25 {
    assert_eq!(get_level(i).tier, 3)
  }
}

///|
test "tier_start_index correct" {
  assert_eq!(tier_start_index(1), 0)
  assert_eq!(tier_start_index(2), 8)
  assert_eq!(tier_start_index(3), 17)
}

///|
test "tier_level_count correct" {
  assert_eq!(tier_level_count(1), 8)
  assert_eq!(tier_level_count(2), 9)
  assert_eq!(tier_level_count(3), 8)
}

///|
test "elevations within valid range" {
  for i in 0..<25 {
    let data = get_level(i)
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        assert_true!(data.elevations[r][c] >= 0)
        assert_true!(data.elevations[r][c] <= @types.max_elevation)
      }
    }
  }
}
