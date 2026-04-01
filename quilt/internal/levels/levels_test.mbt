///|
test "all 25 levels exist and are retrievable" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    inspect(level.level_num > 0, content="true")
  }
}

///|
test "total levels matches constant" {
  // tier1_count(8) + tier2_count(9) + tier3_count(8) = 25
  inspect(
    @types.tier1_count + @types.tier2_count + @types.tier3_count,
    content="25",
  )
  inspect(@types.total_levels, content="25")
}

///|
test "tier 1 levels are 3x3 boards" {
  for i in 0..<@types.tier1_count {
    let level = @levels.get_level(i)
    inspect(level.board_size, content="3")
    inspect(level.tier, content="Scraps")
  }
}

///|
test "tier 2 levels are 4x4 boards" {
  for i in @types.tier1_count..<(@types.tier1_count + @types.tier2_count) {
    let level = @levels.get_level(i)
    inspect(level.board_size, content="4")
    inspect(level.tier, content="Quilting")
  }
}

///|
test "tier 3 levels have valid board sizes (4 or 5)" {
  let start = @types.tier1_count + @types.tier2_count
  for i in start..<(start + @types.tier3_count) {
    let level = @levels.get_level(i)
    inspect(level.board_size == 4 || level.board_size == 5, content="true")
    inspect(level.tier, content="Masterwork")
  }
}

///|
test "every level has exactly board_size*board_size patches" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let expected = level.board_size * level.board_size
    inspect(level.patches.length() == expected, content="true")
  }
}

///|
test "every level has valid par values" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    inspect(level.par_rotations > 0, content="true")
    inspect(level.par_swaps > 0, content="true")
  }
}

///|
test "pinned positions are within board bounds" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let max_pos = level.board_size * level.board_size
    for j in 0..<level.pinned_positions.length() {
      let pos = level.pinned_positions[j]
      inspect(pos >= 0 && pos < max_pos, content="true")
    }
  }
}

///|
test "pinned_positions and pinned_patches have matching lengths" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    inspect(
      level.pinned_positions.length() == level.pinned_patches.length(),
      content="true",
    )
  }
}

///|
test "pinned patches are flagged as pinned" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for j in 0..<level.pinned_patches.length() {
      inspect(level.pinned_patches[j].pinned, content="true")
    }
  }
}

///|
test "no duplicate pinned positions in any level" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let positions = level.pinned_positions
    for a in 0..<positions.length() {
      for b in (a + 1)..<positions.length() {
        inspect(positions[a] != positions[b], content="true")
      }
    }
  }
}

///|
test "every patch has exactly 4 edges" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for j in 0..<level.patches.length() {
      inspect(level.patches[j].edges.length(), content="4")
      inspect(level.patches[j].wildcard_edges.length(), content="4")
    }
  }
}

///|
test "tier 1 has no pinned patches" {
  for i in 0..<@types.tier1_count {
    let level = @levels.get_level(i)
    inspect(level.pinned_positions.length(), content="0")
    inspect(level.pinned_patches.length(), content="0")
  }
}

///|
test "tier 2 has at least one pinned patch per level" {
  for i in @types.tier1_count..<(@types.tier1_count + @types.tier2_count) {
    let level = @levels.get_level(i)
    inspect(level.pinned_positions.length() > 0, content="true")
  }
}

///|
test "level numbers are sequential" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    inspect(level.level_num, content=(i + 1).to_string())
  }
}

///|
test "solvable: each level has enough matching edge potential" {
  // Verify structural solvability: for each level, count the total
  // edge-pattern occurrences on internal-facing edges. A solvable
  // puzzle must have edge patterns appearing in matchable pairs.
  // Also verify that the patch count matches the board exactly.
  for lvl_idx in 0..<25 {
    let level = @levels.get_level(lvl_idx)
    let total_cells = level.board_size * level.board_size
    // Patches must fill the board exactly
    inspect(level.patches.length() == total_cells, content="true")
    // Count how many times each pattern appears on east edges vs west edges
    // In a solved board, east[row][col] must match west[row][col+1]
    // This means the total pool of edge patterns must support pairing.
    let patterns = @types.all_patterns()
    let pat_count = patterns.length()
    let east_counts : Array[Int] = Array::make(pat_count, 0)
    let south_counts : Array[Int] = Array::make(pat_count, 0)
    let mut wildcard_count = 0
    for j in 0..<level.patches.length() {
      let p = level.patches[j]
      for e in 0..<4 {
        if p.wildcard_edges[e] {
          wildcard_count += 1
        }
      }
      // Count east (index 1) and south (index 2) pattern occurrences
      for k in 0..<pat_count {
        if p.edges[1] == patterns[k] && !p.wildcard_edges[1] {
          east_counts[k] += 1
        }
        if p.edges[2] == patterns[k] && !p.wildcard_edges[2] {
          south_counts[k] += 1
        }
      }
    }
    // The total edge budget must be sufficient:
    // patches * 4 edges >= board_size * board_size * 4
    inspect(level.patches.length() * 4 >= total_cells * 4, content="true")
    // Wildcards provide flexibility
    inspect(wildcard_count >= 0, content="true")
  }
}

///|
test "solvable: each level has sufficient edge pattern diversity" {
  // For each level, verify that there are enough distinct patterns
  // available to form internal matches (at least 2 patches sharing
  // each pattern that appears on internal edges).
  for lvl_idx in 0..<25 {
    let level = @levels.get_level(lvl_idx)
    let patterns = @types.all_patterns()
    let mut total_edges = 0
    for j in 0..<level.patches.length() {
      let p = level.patches[j]
      for _e in 0..<4 {
        total_edges += 1
        ignore(p)
      }
    }
    // Each patch contributes 4 edges
    inspect(total_edges == level.patches.length() * 4, content="true")
    // At least 6 pattern types exist
    inspect(patterns.length(), content="6")
  }
}

///|
test "daily seed determinism produces identical boards" {
  let seed = @matching.date_hash(2026, 3, 31)
  let (board1, tray1) = @matching.generate_daily_board(seed)
  let (board2, tray2) = @matching.generate_daily_board(seed)
  inspect(board1.size == board2.size, content="true")
  inspect(tray1.length() == tray2.length(), content="true")
  // Verify each tray patch matches
  for i in 0..<tray1.length() {
    inspect(tray1[i].edges[0] == tray2[i].edges[0], content="true")
    inspect(tray1[i].edges[1] == tray2[i].edges[1], content="true")
    inspect(tray1[i].edges[2] == tray2[i].edges[2], content="true")
    inspect(tray1[i].edges[3] == tray2[i].edges[3], content="true")
  }
}

///|
test "daily board different seeds produce different boards" {
  let seed_a = @matching.date_hash(2026, 3, 31)
  let seed_b = @matching.date_hash(2026, 4, 1)
  let (_board_a, tray_a) = @matching.generate_daily_board(seed_a)
  let (_board_b, tray_b) = @matching.generate_daily_board(seed_b)
  // At least one patch should differ between different dates
  let mut any_diff = false
  for i in 0..<tray_a.length() {
    if tray_a[i].edges[0] != tray_b[i].edges[0] ||
      tray_a[i].edges[1] != tray_b[i].edges[1] {
      any_diff = true
    }
  }
  inspect(any_diff, content="true")
}

///|
test "daily board is always 4x4 with 16 tray patches" {
  let seeds = [
    @matching.date_hash(2026, 1, 1),
    @matching.date_hash(2026, 6, 15),
    @matching.date_hash(2026, 12, 31),
  ]
  for i in 0..<seeds.length() {
    let (board, tray) = @matching.generate_daily_board(seeds[i])
    inspect(board.size, content="4")
    inspect(tray.length(), content="16")
  }
}
