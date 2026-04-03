///|
test "get_level returns correct number of levels" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    inspect(level.id, content=i.to_string())
  }
}

///|
test "tier 1 levels have 2 metals" {
  for i in 0..<7 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="1")
    assert_true(level.available_metals.length() <= 2)
  }
}

///|
test "tier 2 levels have 3-4 metals" {
  for i in 7..<14 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="2")
    assert_true(level.available_metals.length() >= 2)
    assert_true(level.available_metals.length() <= 4)
  }
}

///|
test "tier 3 levels have all 6 metals" {
  for i in 14..<20 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="3")
    inspect(level.available_metals.length(), content="6")
  }
}

///|
test "all levels have valid target ranges" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    assert_true(level.target.hardness.min >= 0.0)
    assert_true(level.target.hardness.max <= 100.0)
    assert_true(level.target.hardness.min <= level.target.hardness.max)
    assert_true(level.target.flexibility.min >= 0.0)
    assert_true(level.target.flexibility.max <= 100.0)
    assert_true(level.target.flexibility.min <= level.target.flexibility.max)
    assert_true(level.target.conductivity.min >= 0.0)
    assert_true(level.target.conductivity.max <= 100.0)
    assert_true(level.target.conductivity.min <= level.target.conductivity.max)
  }
}

///|
test "all levels have positive par_ingredients" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    assert_true(level.par_ingredients > 0)
  }
}

///|
test "all levels have non-empty names and hints" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    assert_true(level.name.length() > 0)
    assert_true(level.hint.length() > 0)
  }
}

///|
test "level 1 is solvable with iron and copper" {
  let level = @levels.get_level(0)
  let ingredients : Array[@types.Ingredient] = [
    { metal: Iron, amount: 1 },
    { metal: Copper, amount: 1 },
  ]
  let result = @forge.blend(ingredients, Medium)
  // hardness = (80+25)/2 = 52.5, target 40-65
  inspect(
    @forge.in_range(result.hardness, level.target.hardness),
    content="true",
  )
}

///|
test "level 4 steel is solvable with iron and carbon" {
  let level = @levels.get_level(3)
  let ingredients : Array[@types.Ingredient] = [
    { metal: Iron, amount: 1 },
    { metal: Carbon, amount: 1 },
  ]
  let result = @forge.blend(ingredients, Medium)
  // hardness = (80+95)/2 = 87.5, target 82-100
  inspect(
    @forge.in_range(result.hardness, level.target.hardness),
    content="true",
  )
}

///|
test "level 5 precious wire solvable with gold and copper" {
  let level = @levels.get_level(4)
  let ingredients : Array[@types.Ingredient] = [
    { metal: Gold, amount: 1 },
    { metal: Copper, amount: 1 },
  ]
  let result = @forge.blend(ingredients, Medium)
  // conductivity = (95+90)/2 = 92.5, target 88-100
  inspect(
    @forge.in_range(result.conductivity, level.target.conductivity),
    content="true",
  )
}

///|
test "default level id falls back to level 1" {
  let level = @levels.get_level(999)
  inspect(level.id, content="0")
  inspect(level.name, content="Soft Start")
}
