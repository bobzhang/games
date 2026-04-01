///|
test "all 20 levels load without error" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_true(level.name.length() > 0)
    assert_true(level.id == i)
  }
}

///|
test "get_all_levels returns 20 levels" {
  let levels = get_all_levels()
  inspect(levels.length(), content="20")
}

///|
test "all levels have valid grid dimensions" {
  for i in 0..<20 {
    let level = get_level(i)
    inspect(level.grid_cols, content="8")
    inspect(level.grid_rows, content="7")
  }
}

///|
test "all levels have at least one target" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_true(level.targets.length() > 0)
  }
}

///|
test "all target positions within grid bounds" {
  for i in 0..<20 {
    let level = get_level(i)
    for j in 0..<level.targets.length() {
      let t = level.targets[j]
      assert_true(t.col >= 0)
      assert_true(t.col < level.grid_cols)
      assert_true(t.row >= 0)
      assert_true(t.row < level.grid_rows)
    }
  }
}

///|
test "note budget is positive for all levels" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_true(level.note_budget > 0)
  }
}

///|
test "note budget is at least target count" {
  // Must have enough notes to hit all targets
  for i in 0..<20 {
    let level = get_level(i)
    assert_true(level.note_budget >= level.targets.length())
  }
}

///|
test "melody tier levels have zero harmony thresholds" {
  // Melody tier (levels 0-6) should not require harmony scoring
  for i in 0..<7 {
    let level = get_level(i)
    inspect(level.tier, content="Melody")
    inspect(level.harmony_threshold_2star, content="0")
    inspect(level.harmony_threshold_3star, content="0")
  }
}

///|
test "harmony tier levels have positive thresholds" {
  // Harmony tier (levels 7-13) should have harmony thresholds > 0
  for i in 7..<14 {
    let level = get_level(i)
    inspect(level.tier, content="Harmony")
    assert_true(level.harmony_threshold_2star > 0)
    assert_true(level.harmony_threshold_3star > 0)
  }
}

///|
test "counterpoint tier levels have positive thresholds" {
  // Counterpoint tier (levels 14-19) should have harmony thresholds > 0
  for i in 14..<20 {
    let level = get_level(i)
    inspect(level.tier, content="Counterpoint")
    assert_true(level.harmony_threshold_2star > 0)
    assert_true(level.harmony_threshold_3star > 0)
  }
}

///|
test "3 star threshold is higher than 2 star threshold" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_true(level.harmony_threshold_3star >= level.harmony_threshold_2star)
  }
}

///|
test "tier assignment matches level ranges" {
  for i in 0..<7 {
    inspect(get_level(i).tier, content="Melody")
  }
  for i in 7..<14 {
    inspect(get_level(i).tier, content="Harmony")
  }
  for i in 14..<20 {
    inspect(get_level(i).tier, content="Counterpoint")
  }
}

///|
test "level IDs are sequential" {
  for i in 0..<20 {
    inspect(get_level(i).id == i, content="true")
  }
}

///|
test "total levels constant is 20" {
  inspect(@types.total_levels, content="20")
}

///|
test "harmony tiers have extra budget beyond targets" {
  // Harmony/counterpoint levels need extra notes for chords
  for i in 7..<20 {
    let level = get_level(i)
    assert_true(level.note_budget > level.targets.length())
  }
}

///|
test "all level names are non-empty and unique" {
  let names : Array[String] = []
  for i in 0..<20 {
    let name = get_level(i).name
    assert_true(name.length() > 0)
    // Check uniqueness
    let mut duplicate = false
    for j in 0..<names.length() {
      if names[j] == name {
        duplicate = true
      }
    }
    inspect(duplicate, content="false")
    names.push(name)
  }
}
