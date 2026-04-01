///|
test "all 20 levels load" {
  let levels = @levels.get_all_levels()
  inspect(levels.length(), content="20")
}

///|
test "level targets have 36 cells" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].target.length(), content="36")
  }
}

///|
test "tier 1 levels are Beginner" {
  let levels = @levels.get_all_levels()
  for i in 0..<7 {
    inspect(levels[i].tier, content="Beginner")
  }
}

///|
test "tier 2 levels are Intermediate" {
  let levels = @levels.get_all_levels()
  for i in 7..<14 {
    inspect(levels[i].tier, content="Intermediate")
  }
}

///|
test "tier 3 levels are Advanced" {
  let levels = @levels.get_all_levels()
  for i in 14..<20 {
    inspect(levels[i].tier, content="Advanced")
  }
}

///|
test "level names are unique" {
  let levels = @levels.get_all_levels()
  let names : Array[String] = []
  for i in 0..<levels.length() {
    for j in 0..<names.length() {
      assert_true(names[j] != levels[i].name)
    }
    names.push(levels[i].name)
  }
}

///|
test "par_moves <= max_moves" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].par_moves <= levels[i].max_moves)
  }
}

///|
test "get_level returns correct level" {
  let lv = @levels.get_level(0)
  inspect(lv.name, content="First Glaze")
  let lv2 = @levels.get_level(19)
  inspect(lv2.name, content="Magnum Opus")
}

///|
test "level 1 target has DeepRed cells" {
  let lv = @levels.get_level(0)
  // Center cells should be DeepRed (adjacent reds merge)
  let idx = 1 * 6 + 2 // row 1, col 2
  inspect(lv.target[idx], content="FDeepRed")
}

///|
test "level 6 target has Purple from Red+Blue" {
  let lv = @levels.get_level(5)
  // Checkerboard of Red/Blue should produce Purple
  let idx = 1 * 6 + 1 // row 1, col 1 (Red, adjacent to Blue)
  inspect(lv.target[idx], content="FPurple")
}

///|
test "each level has at least one allowed glaze" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].allowed_glazes.length() > 0)
  }
}
