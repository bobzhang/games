///|
test "level_count returns 20" {
  inspect(@levels.level_count(), content="20")
}

///|
test "get_level returns valid levels for all IDs" {
  for i in 0..<@levels.level_count() {
    let level = @levels.get_level(i)
    inspect(level.id, content="\{i}")
    assert_true(level.species.length() >= 2)
    assert_true(level.par_tiles > 0)
    assert_true(level.bonus_space > 0)
    assert_true(level.tier >= 1 && level.tier <= 3)
  }
}

///|
test "tier 1 levels have 2-3 species" {
  for i in 0..<7 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="1")
    assert_true(level.species.length() >= 2 && level.species.length() <= 3)
  }
}

///|
test "tier 2 levels have 4-5 species" {
  for i in 7..<14 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="2")
    assert_true(level.species.length() >= 4 && level.species.length() <= 5)
  }
}

///|
test "tier 3 levels have 5-6 species" {
  for i in 14..<20 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="3")
    assert_true(level.species.length() >= 5 && level.species.length() <= 6)
  }
}

///|
test "get_level with invalid ID returns level 0" {
  let level = @levels.get_level(999)
  inspect(level.id, content="0")
  let level2 = @levels.get_level(-1)
  inspect(level2.id, content="0")
}

///|
test "all levels have unique IDs" {
  let ids : Array[Int] = []
  for i in 0..<@levels.level_count() {
    let level = @levels.get_level(i)
    assert_true(ids.contains(level.id) == false)
    ids.push(level.id)
  }
}

///|
test "preset terrain coords are within grid bounds" {
  for i in 0..<@levels.level_count() {
    let level = @levels.get_level(i)
    for pt in level.preset_terrain {
      assert_true(pt.0 >= 0 && pt.0 < @types.grid_cols)
      assert_true(pt.1 >= 0 && pt.1 < @types.grid_rows)
    }
  }
}

///|
test "preset fence coords are within grid bounds" {
  for i in 0..<@levels.level_count() {
    let level = @levels.get_level(i)
    for pf in level.preset_fences {
      assert_true(pf.0 >= 0 && pf.0 < @types.grid_cols)
      assert_true(pf.1 >= 0 && pf.1 < @types.grid_rows)
    }
  }
}
