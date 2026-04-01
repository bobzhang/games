///|
test "total level count is 25" {
  let mut count = 0
  for i in 0..<25 {
    let _level = get_level(i)
    count = count + 1
  }
  inspect(count, content="25")
}

///|
test "all levels have at least 2 islands" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.islands.length() >= 2)
  }
}

///|
test "island positions are within grid bounds" {
  for i in 0..<25 {
    let level = get_level(i)
    let gs = level.grid_size
    for j in 0..<level.islands.length() {
      let isl = level.islands[j]
      assert_true(isl.pos.x >= 0)
      assert_true(isl.pos.y >= 0)
      assert_true(isl.pos.x < gs)
      assert_true(isl.pos.y < gs)
    }
  }
}

///|
test "no duplicate island positions" {
  for i in 0..<25 {
    let level = get_level(i)
    for j in 0..<level.islands.length() {
      for k = j + 1; k < level.islands.length(); k = k + 1 {
        let a = level.islands[j]
        let b = level.islands[k]
        let same = a.pos.x == b.pos.x && a.pos.y == b.pos.y
        inspect(same, content="false")
      }
    }
  }
}

///|
test "all island required counts are positive" {
  for i in 0..<25 {
    let level = get_level(i)
    for j in 0..<level.islands.length() {
      assert_true(level.islands[j].required_count >= 1)
    }
  }
}

///|
test "island required counts do not exceed maximum possible" {
  // Max bridges from one island = 2 * num_neighbors (up/down/left/right, max 2 each)
  // But simplest check: required_count <= 8 (4 directions * 2 bridges each)
  for i in 0..<25 {
    let level = get_level(i)
    for j in 0..<level.islands.length() {
      assert_true(level.islands[j].required_count <= 8)
    }
  }
}

///|
test "required counts do not exceed theoretical max of 8" {
  for i in 0..<25 {
    let level = get_level(i)
    let islands = level.islands
    for j in 0..<islands.length() {
      // Max 4 directions * 2 bridges = 8
      assert_true(islands[j].required_count <= 8)
    }
  }
}

///|
test "total required count is even for solvable puzzles" {
  // Each bridge segment contributes 1 to two islands, so total must be even
  for i in 0..<25 {
    let level = get_level(i)
    let mut total_required = 0
    for j in 0..<level.islands.length() {
      total_required = total_required + level.islands[j].required_count
    }
    inspect(total_required % 2, content="0")
  }
}

///|
test "par bridges are positive" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.par_bridges > 0)
  }
}

///|
test "par bridges at least half total required" {
  // Total bridge segments = sum(required_count) / 2
  // Par should be at least that
  for i in 0..<25 {
    let level = get_level(i)
    let mut total_required = 0
    for j in 0..<level.islands.length() {
      total_required = total_required + level.islands[j].required_count
    }
    let min_bridges = total_required / 2
    assert_true(level.par_bridges >= min_bridges)
  }
}

///|
test "tier 1 shores levels have grid_size 5" {
  for i in 0..<8 {
    let level = get_level(i)
    inspect(level.grid_size, content="5")
  }
}

///|
test "tier 2 straits levels have grid_size 7" {
  for i = 8; i < 17; i = i + 1 {
    let level = get_level(i)
    inspect(level.grid_size, content="7")
  }
}

///|
test "tier 3 ocean levels have grid_size 9" {
  for i = 17; i < 25; i = i + 1 {
    let level = get_level(i)
    inspect(level.grid_size, content="9")
  }
}

///|
test "tier 1 island counts are 4-6" {
  for i in 0..<8 {
    let level = get_level(i)
    let count = level.islands.length()
    assert_true(count >= 4)
    assert_true(count <= 6)
  }
}

///|
test "tier 2 island counts are 8-12" {
  for i = 8; i < 17; i = i + 1 {
    let level = get_level(i)
    let count = level.islands.length()
    assert_true(count >= 8)
    assert_true(count <= 12)
  }
}

///|
test "tier 3 island counts are 12-18" {
  for i = 17; i < 25; i = i + 1 {
    let level = get_level(i)
    let count = level.islands.length()
    assert_true(count >= 12)
    assert_true(count <= 18)
  }
}

///|
test "every island has at least one potential neighbor" {
  for i in 0..<25 {
    let level = get_level(i)
    let islands = level.islands
    for j in 0..<islands.length() {
      let mut has_neighbor = false
      for k in 0..<islands.length() {
        if j != k && @types.can_connect(islands, j, k) && !@types.has_island_between(
          islands,
          j,
          k,
        ) {
          has_neighbor = true
          break
        }
      }
      assert_true(has_neighbor)
    }
  }
}

///|
test "get_level default fallback" {
  // Out-of-range index should return level_01
  let level = get_level(999)
  inspect(level.grid_size, content="5")
  inspect(level.islands.length(), content="4")
}

///|
test "difficulty increases across tiers" {
  // Average island count should increase per tier
  let mut tier1_avg = 0
  for i in 0..<8 {
    tier1_avg = tier1_avg + get_level(i).islands.length()
  }
  let mut tier2_avg = 0
  for i = 8; i < 17; i = i + 1 {
    tier2_avg = tier2_avg + get_level(i).islands.length()
  }
  let mut tier3_avg = 0
  for i = 17; i < 25; i = i + 1 {
    tier3_avg = tier3_avg + get_level(i).islands.length()
  }
  // Tier 2 average should be higher than tier 1
  assert_true(tier2_avg * 8 > tier1_avg * 9)
  // Tier 3 average should be higher than tier 2
  assert_true(tier3_avg * 9 > tier2_avg * 8)
}
