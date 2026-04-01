///|
test "make_all_levels returns 25 levels" {
  let levels = make_all_levels()
  inspect(levels.length(), content="25")
}

///|
test "first 8 levels are Lines tier" {
  let levels = make_all_levels()
  for i in 0..<8 {
    inspect(levels[i].tier, content="Lines")
  }
}

///|
test "levels 8-16 are Weave tier" {
  let levels = make_all_levels()
  for i in 8..<17 {
    inspect(levels[i].tier, content="Weave")
  }
}

///|
test "levels 17-24 are Art tier" {
  let levels = make_all_levels()
  for i in 17..<25 {
    inspect(levels[i].tier, content="Art")
  }
}

///|
test "all levels have positive par_strings" {
  let levels = make_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].par_strings > 0)
  }
}

///|
test "all levels have at least one target" {
  let levels = make_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].targets.length() > 0)
  }
}

///|
test "all levels have correct peg_count" {
  let levels = make_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].peg_count, content="24")
  }
}

///|
test "first level has single target at center" {
  let levels = make_all_levels()
  let first = levels[0]
  inspect(first.name, content="First Cross")
  inspect(first.targets.length(), content="1")
  inspect(first.par_strings, content="2")
  // Target at center of frame
  let t = first.targets[0]
  inspect(t.x, content="480")
  inspect(t.y, content="360")
}

///|
test "level names are non-empty" {
  let levels = make_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].name.length() > 0)
  }
}

///|
test "Lines tier target counts are 1-3" {
  let levels = make_all_levels()
  for i in 0..<8 {
    let count = levels[i].targets.length()
    assert_true(count >= 1 && count <= 3)
  }
}

///|
test "Weave tier has more targets than Lines" {
  let levels = make_all_levels()
  // Weave levels should have 4-6 targets
  for i in 8..<17 {
    let count = levels[i].targets.length()
    assert_true(count >= 4 && count <= 6)
  }
}

///|
test "Art tier has most targets" {
  let levels = make_all_levels()
  // Art levels should have 6-8 targets
  for i in 17..<25 {
    let count = levels[i].targets.length()
    assert_true(count >= 6 && count <= 8)
  }
}

///|
test "par_strings increase with difficulty" {
  let levels = make_all_levels()
  // Lines tier par: 2-4
  for i in 0..<8 {
    assert_true(levels[i].par_strings >= 2 && levels[i].par_strings <= 4)
  }
  // Weave tier par: 4-6
  for i in 8..<17 {
    assert_true(levels[i].par_strings >= 4 && levels[i].par_strings <= 6)
  }
  // Art tier par: 6-8
  for i in 17..<25 {
    assert_true(levels[i].par_strings >= 6 && levels[i].par_strings <= 8)
  }
}

///|
test "specific level names" {
  let levels = make_all_levels()
  inspect(levels[0].name, content="First Cross")
  inspect(levels[1].name, content="Twin Points")
  inspect(levels[8].name, content="Square")
  inspect(levels[17].name, content="Star Points")
  inspect(levels[24].name, content="Masterpiece")
}

///|
test "target positions are within frame bounds" {
  let levels = make_all_levels()
  for i in 0..<levels.length() {
    for j in 0..<levels[i].targets.length() {
      let t = levels[i].targets[j]
      // Targets should be within reasonable bounds of the frame
      // Frame center is 480, 360 with radius 280
      assert_true(t.x >= 100.0 && t.x <= 860.0)
      assert_true(t.y >= 80.0 && t.y <= 640.0)
    }
  }
}

///|
test "Twin Points has two vertical targets" {
  let levels = make_all_levels()
  let level = levels[1]
  inspect(level.targets.length(), content="2")
  // Both targets should have same x
  let dx = @types.absf(level.targets[0].x - level.targets[1].x)
  inspect(dx < 1.0, content="true")
  // Different y
  assert_true(level.targets[0].y != level.targets[1].y)
}

///|
test "Side by Side has two horizontal targets" {
  let levels = make_all_levels()
  let level = levels[2]
  inspect(level.targets.length(), content="2")
  // Both targets should have same y
  let dy = @types.absf(level.targets[0].y - level.targets[1].y)
  inspect(dy < 1.0, content="true")
  // Different x
  assert_true(level.targets[0].x != level.targets[1].x)
}

///|
test "Octagon has 8 targets" {
  let levels = make_all_levels()
  let octagon = levels[21]
  inspect(octagon.name, content="Octagon")
  inspect(octagon.targets.length(), content="8")
  inspect(octagon.par_strings, content="8")
}
