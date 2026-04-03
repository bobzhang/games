///|
test "get_level returns all 20 levels" {
  for i in 0..<20 {
    let def = @levels.get_level(i)
    inspect(def is Some(_), content="true")
  }
}

///|
test "get_level returns None for invalid id" {
  inspect(@levels.get_level(20) is None, content="true")
  inspect(@levels.get_level(-1) is None, content="true")
}

///|
test "all levels have correct id" {
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    assert_eq(def.id, i)
  }
}

///|
test "all levels have correct grid dimensions" {
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    assert_eq(def.grid.length(), 8)
    for row in 0..<8 {
      assert_eq(def.grid[row].length(), 10)
    }
  }
}

///|
test "all levels have at least one source" {
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    let mut has_source = false
    for row in 0..<8 {
      for col in 0..<10 {
        if def.grid[row][col] is Source {
          has_source = true
        }
      }
    }
    inspect(has_source, content="true")
  }
}

///|
test "all levels have at least one temple" {
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    let mut has_temple = false
    for row in 0..<8 {
      for col in 0..<10 {
        if def.grid[row][col] is Temple(_) {
          has_temple = true
        }
      }
    }
    inspect(has_temple, content="true")
  }
}

///|
test "tier 1 levels have tier 1" {
  for i in 0..<7 {
    guard @levels.get_level(i) is Some(def) else { return }
    assert_eq(def.tier, 1)
  }
}

///|
test "tier 2 levels have tier 2" {
  for i in 7..<14 {
    guard @levels.get_level(i) is Some(def) else { return }
    assert_eq(def.tier, 2)
  }
}

///|
test "tier 3 levels have tier 3" {
  for i in 14..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    assert_eq(def.tier, 3)
  }
}

///|
test "all_level_defs returns 20 levels" {
  let defs = @levels.all_level_defs()
  assert_eq(defs.length(), 20)
}

///|
test "level_name returns correct names" {
  inspect(@levels.level_name(0), content="First Light")
  inspect(@levels.level_name(19), content="Grand Nexus")
  inspect(@levels.level_name(99), content="Unknown")
}

///|
test "gold threshold >= silver threshold" {
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    inspect(def.gold_threshold >= def.silver_threshold, content="true")
  }
}

///|
test "waystone budget positive" {
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    inspect(def.waystone_budget > 0, content="true")
  }
}

///|
test "par waystones <= budget" {
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    inspect(def.par_waystones <= def.waystone_budget, content="true")
  }
}

///|
test "each level has unique name" {
  let names : Array[String] = []
  for i in 0..<20 {
    guard @levels.get_level(i) is Some(def) else { return }
    for j in 0..<names.length() {
      inspect(names[j] == def.name, content="false")
    }
    names.push(def.name)
  }
}
