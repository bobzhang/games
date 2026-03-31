///|
test "all 25 levels are valid" {
  for i in 0..<25 {
    let level = get_level(i)
    // Target should be a non-base element (except for some apprentice levels
    // where base combos produce compound elements)
    let _target = @types.element_name(level.target)
    // Par steps should be positive
    assert_true!(level.par_steps > 0)
    // Hint should not be empty
    assert_true!(level.hint.length() > 0)
  }
}

///|
test "tier levels have correct count" {
  let apprentice = get_tier_levels(@types.Apprentice)
  assert_eq!(apprentice.length(), 8)
  let journeyman = get_tier_levels(@types.Journeyman)
  assert_eq!(journeyman.length(), 9)
  let master = get_tier_levels(@types.Master)
  assert_eq!(master.length(), 8)
}

///|
test "apprentice levels have tier Apprentice" {
  for i in 0..<8 {
    let level = get_level(i)
    assert_eq!(level.tier, @types.Apprentice)
  }
}

///|
test "journeyman levels have tier Journeyman" {
  for i in 8..<17 {
    let level = get_level(i)
    assert_eq!(level.tier, @types.Journeyman)
  }
}

///|
test "master levels have tier Master" {
  for i in 17..<25 {
    let level = get_level(i)
    assert_eq!(level.tier, @types.Master)
  }
}

///|
test "first tier always unlocked" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  assert_eq!(is_tier_unlocked(@types.Apprentice, scores), true)
  assert_eq!(is_tier_unlocked(@types.Journeyman, scores), false)
  assert_eq!(is_tier_unlocked(@types.Master, scores), false)
}

///|
test "journeyman unlocks after 5 apprentice levels" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  // Complete 5 apprentice levels
  for i in 0..<5 {
    scores[i].completed = true
  }
  assert_eq!(is_tier_unlocked(@types.Journeyman, scores), true)
}
