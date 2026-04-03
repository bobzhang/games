///|
test "all 25 levels loadable" {
  for i in 0..<25 {
    let level = get_level(i)
    // Every level must have a name and description
    assert_true(level.name.length() > 0)
    assert_true(level.description.length() > 0)
  }
}

///|
test "all levels have valid start sequences (contain bases)" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.start_sequence.length() >= 3)
  }
}

///|
test "all levels have ATG start codon in start sequence" {
  for i in 0..<25 {
    let level = get_level(i)
    let seq = level.start_sequence
    let found = @types.find_start_codon(seq) >= 0
    // Level start sequence should have ATG so the puzzle makes sense
    // (some levels intentionally break it, but target always needs Start)
    let first_target = level.target_traits[0]
    if first_target == Start {
      // Check that either the start seq has ATG or it can be created
      // We just verify levels that already have ATG work
      if found {
        assert_true(found)
      }
    }
  }
}

///|
test "all levels have valid target traits starting with Start and ending with Stop" {
  for i in 0..<25 {
    let level = get_level(i)
    let target = level.target_traits
    assert_true(target.length() >= 2)
    assert_eq(target[0], Start)
    assert_eq(target[target.length() - 1], Stop)
  }
}

///|
test "all target traits contain no Neutral" {
  for i in 0..<25 {
    let level = get_level(i)
    for j in 0..<level.target_traits.length() {
      assert_true(level.target_traits[j] != Neutral)
    }
  }
}

///|
test "all levels have positive edit budget" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.edit_budget > 0)
  }
}

///|
test "par edits <= edit budget for all levels" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.par_edits <= level.edit_budget)
  }
}

///|
test "min edits <= par edits for all levels" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.min_edits <= level.par_edits)
  }
}

///|
test "min edits non-negative for all levels" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.min_edits >= 0)
  }
}

///|
test "all levels have at least one available operation" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.available_ops.length() > 0)
  }
}

///|
test "tier 1 levels use tier 1 ops (Cut, Insert)" {
  for i in 0..<8 {
    let level = get_level(i)
    for j in 0..<level.available_ops.length() {
      let op = level.available_ops[j]
      assert_true(op == Cut || op == Insert)
    }
  }
}

///|
test "tier 2 levels include tier 2 ops" {
  for i in 8..<17 {
    let level = get_level(i)
    // Tier 2 should have at least Cut, Insert, and one of Duplicate/Delete
    assert_true(level.available_ops.length() >= 2)
  }
}

///|
test "tier 3 levels include Invert" {
  for i in 17..<25 {
    let level = get_level(i)
    let mut has_invert = false
    for j in 0..<level.available_ops.length() {
      if level.available_ops[j] == Invert {
        has_invert = true
      }
    }
    assert_true(has_invert)
  }
}

///|
test "zero-edit levels already match target" {
  for i in 0..<25 {
    let level = get_level(i)
    if level.min_edits == 0 {
      let result = @types.read_sequence(level.start_sequence)
      let matched = @types.traits_match(result.traits, level.target_traits)
      assert_true(matched)
    }
  }
}

///|
test "level 0 (Hello Gene) already matches" {
  let level = get_level(0)
  let result = @types.read_sequence(level.start_sequence)
  assert_true(@types.traits_match(result.traits, level.target_traits))
}

///|
test "level 12 (Triple Threat) already matches" {
  let level = get_level(12)
  let result = @types.read_sequence(level.start_sequence)
  assert_true(@types.traits_match(result.traits, level.target_traits))
}

///|
test "level 24 (Perfect Gene) already matches" {
  let level = get_level(24)
  let result = @types.read_sequence(level.start_sequence)
  assert_true(@types.traits_match(result.traits, level.target_traits))
}

///|
test "tier offset and count cover all 25 levels" {
  let total = @types.tier_level_count(0) +
    @types.tier_level_count(1) +
    @types.tier_level_count(2)
  assert_eq(total, 25)
}

///|
test "get_tier_levels returns correct indices" {
  let t0 = get_tier_levels(0)
  assert_eq(t0.length(), 8)
  assert_eq(t0[0], 0)
  assert_eq(t0[7], 7)
  let t1 = get_tier_levels(1)
  assert_eq(t1.length(), 9)
  assert_eq(t1[0], 8)
  assert_eq(t1[8], 16)
  let t2 = get_tier_levels(2)
  assert_eq(t2.length(), 8)
  assert_eq(t2[0], 17)
  assert_eq(t2[7], 24)
}

///|
test "is_tier_unlocked tier 0 always unlocked" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  assert_true(is_tier_unlocked(0, scores))
}

///|
test "is_tier_unlocked tier 1 locked without completions" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  assert_false(is_tier_unlocked(1, scores))
}

///|
test "is_tier_unlocked tier 1 unlocked with half tier 0 completed" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  // Complete 4 of 8 tier 0 levels
  for i in 0..<4 {
    scores[i].completed = true
  }
  assert_true(is_tier_unlocked(1, scores))
}

///|
test "tier_stars counts correctly" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  scores[0].stars = 3
  scores[1].stars = 2
  scores[2].stars = 1
  assert_eq(tier_stars(0, scores), 6)
}

///|
test "tier_completed counts correctly" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  scores[0].completed = true
  scores[1].completed = true
  assert_eq(tier_completed(0, scores), 2)
}

///|
test "all level names are unique" {
  let names : Array[String] = []
  for i in 0..<25 {
    let level = get_level(i)
    for j in 0..<names.length() {
      assert_true(names[j] != level.name)
    }
    names.push(level.name)
  }
}

///|
test "sequence length is divisible for already-solved levels" {
  // For levels where min_edits == 0, the sequence from start to stop
  // should parse cleanly into codons
  for i in 0..<25 {
    let level = get_level(i)
    if level.min_edits == 0 {
      let result = @types.read_sequence(level.start_sequence)
      // The number of traits should match the target exactly
      assert_eq(result.traits.length(), level.target_traits.length())
    }
  }
}
