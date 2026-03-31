///|
test "all 30 levels exist" {
  let levels = @levels.get_all_levels()
  inspect(levels.length(), content="30")
}

///|
test "tier 1 levels are 3x3x3" {
  let levels = @levels.get_all_levels()
  for i in 0..<10 {
    inspect(levels[i].size, content="3")
    inspect(levels[i].tier, content="Shapes")
  }
}

///|
test "tier 2 levels are 4x4x4" {
  let levels = @levels.get_all_levels()
  for i in 10..<20 {
    inspect(levels[i].size, content="4")
    inspect(levels[i].tier, content="Structures")
  }
}

///|
test "tier 3 levels have correct tier" {
  let levels = @levels.get_all_levels()
  for i in 20..<30 {
    inspect(levels[i].tier, content="Sculptures")
  }
}

///|
test "tier 2 levels have voxel budget" {
  let levels = @levels.get_all_levels()
  for i in 10..<20 {
    inspect(levels[i].voxel_budget > 0, content="true")
  }
}

///|
test "tier 3 levels require connectivity" {
  let levels = @levels.get_all_levels()
  for i in 20..<30 {
    inspect(levels[i].requires_connected, content="true")
  }
}

///|
test "all levels have valid target dimensions" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let lev = levels[i]
    let valid = @levels.validate_level_targets(lev)
    inspect(valid, content="true")
  }
}

///|
test "get_level returns correct level" {
  let lev = @levels.get_level(0)
  inspect(lev.name, content="Dot")
  inspect(lev.size, content="3")
  let lev2 = @levels.get_level(29)
  inspect(lev2.name, content="Masterwork")
}

///|
test "level descriptions exist for all levels" {
  for i in 0..<30 {
    let desc = @levels.get_level_description(i)
    inspect(desc.length() > 0, content="true")
  }
}

///|
test "difficulty ratings are in range" {
  for i in 0..<30 {
    let diff = @levels.get_difficulty(i)
    inspect(diff >= 1 && diff <= 5, content="true")
  }
}

///|
test "tier 1 difficulty is lower than tier 3" {
  let d1 = @levels.get_difficulty(0)
  let d3 = @levels.get_difficulty(29)
  inspect(d1 <= d3, content="true")
}

///|
test "target_cell_count is positive for all levels" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let count = @levels.target_cell_count(levels[i])
    inspect(count > 0, content="true")
  }
}

///|
test "tier descriptions exist" {
  for t in 0..<3 {
    let desc = @levels.get_tier_description(t)
    inspect(desc.length() > 0, content="true")
  }
}

///|
test "level names are unique" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    for j = i + 1; j < levels.length(); j = j + 1 {
      let same = levels[i].name == levels[j].name
      inspect(same, content="false")
    }
  }
}

///|
test "par_moves and par_voxels are positive" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].par_moves > 0, content="true")
    inspect(levels[i].par_voxels > 0, content="true")
  }
}

///|
test "silhouette_from_bits creates correct 4x4 pattern" {
  let s = @types.silhouette_from_bits(
    4,
    4,
    [0b1111, 0b1001, 0b1001, 0b1111],
  )
  // Top row: all filled
  inspect(s.cells[0], content="true")
  inspect(s.cells[1], content="true")
  inspect(s.cells[2], content="true")
  inspect(s.cells[3], content="true")
  // Row 1: ends filled, middle empty
  inspect(s.cells[4], content="true")
  inspect(s.cells[5], content="false")
  inspect(s.cells[6], content="false")
  inspect(s.cells[7], content="true")
  // Bottom row: all filled
  inspect(s.cells[12], content="true")
  inspect(s.cells[13], content="true")
  inspect(s.cells[14], content="true")
  inspect(s.cells[15], content="true")
}

///|
test "silhouette_from_bits 5x5" {
  let s = @types.silhouette_from_bits(
    5,
    5,
    [0b11111, 0b10001, 0b10101, 0b10001, 0b11111],
  )
  inspect(s.width, content="5")
  inspect(s.height, content="5")
  // Center cell
  inspect(s.cells[12], content="true") // (2, 2) = idx 12
  // Corner cells
  inspect(s.cells[0], content="true") // (0, 0)
  inspect(s.cells[4], content="true") // (4, 0)
  inspect(s.cells[20], content="true") // (0, 4)
  inspect(s.cells[24], content="true") // (4, 4)
}
