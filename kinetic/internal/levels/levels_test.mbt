///|
test "all 25 levels are unique and have valid names" {
  let names : Array[String] = []
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.name.length() > 0)
    // Check name is unique
    for j in 0..<names.length() {
      assert_true(names[j] != level.name)
    }
    names.push(level.name)
  }
}

///|
test "all levels have input gear within grid bounds" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.input.pos.x >= 0)
    assert_true(level.input.pos.x < @types.grid_cols)
    assert_true(level.input.pos.y >= 0)
    assert_true(level.input.pos.y < @types.grid_rows)
  }
}

///|
test "all levels have positive input rpm" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.input.rpm > 0.0)
  }
}

///|
test "all levels have valid input radius" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(
      level.input.radius == 1 ||
      level.input.radius == 2 ||
      level.input.radius == 3,
    )
  }
}

///|
test "all levels have at least one output" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.outputs.length() >= 1)
  }
}

///|
test "all outputs are within grid bounds" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    for j in 0..<level.outputs.length() {
      let out = level.outputs[j]
      assert_true(out.pos.x >= 0)
      assert_true(out.pos.x < @types.grid_cols)
      assert_true(out.pos.y >= 0)
      assert_true(out.pos.y < @types.grid_rows)
    }
  }
}

///|
test "all outputs have positive target rpm" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    for j in 0..<level.outputs.length() {
      assert_true(level.outputs[j].target_rpm > 0.0)
    }
  }
}

///|
test "output positions do not overlap with input position" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    for j in 0..<level.outputs.length() {
      let out = level.outputs[j]
      assert_true(
        out.pos.x != level.input.pos.x || out.pos.y != level.input.pos.y,
      )
    }
  }
}

///|
test "output positions are mutually distinct" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    for j in 0..<level.outputs.length() {
      for k in (j + 1)..<level.outputs.length() {
        let a = level.outputs[j]
        let b = level.outputs[k]
        assert_true(a.pos.x != b.pos.x || a.pos.y != b.pos.y)
      }
    }
  }
}

///|
test "par gears is positive and within budget" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.par_gears > 0)
    assert_true(level.par_gears <= level.gear_budget)
  }
}

///|
test "gear budget is positive" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.gear_budget >= 2)
  }
}

///|
test "available gears list is non-empty" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.available_gears.length() >= 1)
  }
}

///|
test "tier 1 levels have correct tier tag" {
  for i in 0..<@types.tier1_count {
    let level = get_level(i)
    assert_eq(level.tier, Gears)
  }
}

///|
test "tier 2 levels have correct tier tag" {
  for i in @types.tier1_count..<(@types.tier1_count + @types.tier2_count) {
    let level = get_level(i)
    assert_eq(level.tier, Trains)
  }
}

///|
test "tier 3 levels have correct tier tag" {
  let start = @types.tier1_count + @types.tier2_count
  for i in start..<(start + @types.tier3_count) {
    let level = get_level(i)
    assert_eq(level.tier, Workshop)
  }
}

///|
test "tier counts sum to total levels" {
  assert_eq(
    @types.tier1_count + @types.tier2_count + @types.tier3_count,
    @types.total_levels,
  )
}

///|
test "all levels have non-empty hint" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.hint.length() > 0)
  }
}

///|
test "outputs are reachable: not at same position as input" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    let inp = level.input.pos
    for j in 0..<level.outputs.length() {
      let out = level.outputs[j]
      let dist_sq = @types.grid_dist_sq(inp, out.pos)
      // Output must be at least 1 grid cell away from input
      assert_true(dist_sq >= 1)
    }
  }
}

///|
test "fallback level is level_1_1" {
  // Out-of-range indices should fall back to level_1_1
  let fallback = get_level(999)
  let first = get_level(0)
  assert_eq(fallback.name, first.name)
  assert_eq(fallback.tier, first.tier)
}

///|
test "belt availability only in tier 2 and 3" {
  // Tier 1 levels should not have Belt in available_gears
  for i in 0..<@types.tier1_count {
    let level = get_level(i)
    let mut has_belt = false
    for k in 0..<level.available_gears.length() {
      if level.available_gears[k] == Belt {
        has_belt = true
      }
    }
    assert_true(!has_belt)
  }
}

///|
test "ratchet availability only in tier 3" {
  // Tier 1 and 2 levels should not have Ratchet in available_gears
  let tier12_end = @types.tier1_count + @types.tier2_count
  for i in 0..<tier12_end {
    let level = get_level(i)
    let mut has_ratchet = false
    for k in 0..<level.available_gears.length() {
      if level.available_gears[k] == Ratchet {
        has_ratchet = true
      }
    }
    assert_true(!has_ratchet)
  }
}

///|
test "par gears increases with level complexity" {
  // Within each tier, par gears should generally not decrease dramatically
  // Check that the last level in each tier has at least as high par as the first
  let tier1_first = get_level(0)
  let tier1_last = get_level(@types.tier1_count - 1)
  assert_true(tier1_last.par_gears >= tier1_first.par_gears)
  let tier2_first = get_level(@types.tier1_count)
  let tier2_last = get_level(@types.tier1_count + @types.tier2_count - 1)
  assert_true(tier2_last.par_gears >= tier2_first.par_gears)
  let tier3_start = @types.tier1_count + @types.tier2_count
  let tier3_first = get_level(tier3_start)
  let tier3_last = get_level(tier3_start + @types.tier3_count - 1)
  assert_true(tier3_last.par_gears >= tier3_first.par_gears)
}
