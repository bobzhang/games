///|
test "blend single metal returns its own properties at medium temp" {
  let ingredients : Array[@types.Ingredient] = [{ metal: Iron, amount: 1, }]
  let result = @forge.blend(ingredients, Medium)
  inspect(result.hardness, content="80")
  inspect(result.flexibility, content="20")
  inspect(result.conductivity, content="30")
}

///|
test "blend empty returns zeros" {
  let ingredients : Array[@types.Ingredient] = []
  let result = @forge.blend(ingredients, Medium)
  inspect(result.hardness, content="0")
  inspect(result.flexibility, content="0")
  inspect(result.conductivity, content="0")
}

///|
test "blend two equal metals averages properties" {
  let ingredients : Array[@types.Ingredient] = [
    { metal: Iron, amount: 1, },
    { metal: Copper, amount: 1, },
  ]
  let result = @forge.blend(ingredients, Medium)
  // Iron(80,20,30) + Copper(25,50,90) average = (52.5, 35, 60)
  inspect(result.hardness, content="52.5")
  inspect(result.flexibility, content="35")
  inspect(result.conductivity, content="60")
}

///|
test "blend weighted by amount" {
  let ingredients : Array[@types.Ingredient] = [
    { metal: Iron, amount: 3, },
    { metal: Copper, amount: 1, },
  ]
  let result = @forge.blend(ingredients, Medium)
  // (80*3 + 25*1)/4 = 66.25, (20*3+50*1)/4 = 27.5, (30*3+90*1)/4 = 45
  inspect(result.hardness, content="66.25")
  inspect(result.flexibility, content="27.5")
  inspect(result.conductivity, content="45")
}

///|
test "high temperature amplifies hardness reduces flexibility" {
  let ingredients : Array[@types.Ingredient] = [{ metal: Iron, amount: 1, }]
  let result = @forge.blend(ingredients, High)
  // hardness: 80 * 1.15 = 92, flexibility: 20 * 0.85 = 17, cond: 30
  inspect(result.hardness, content="92")
  inspect(result.flexibility, content="17")
  inspect(result.conductivity, content="30")
}

///|
test "low temperature damps toward center" {
  let ingredients : Array[@types.Ingredient] = [{ metal: Iron, amount: 1, }]
  let result = @forge.blend(ingredients, Low)
  // hardness: 50 + (80-50)*0.95 = 78.5
  // flexibility: 50 + (20-50)*0.95 = 21.5
  // conductivity: 50 + (30-50)*0.95 = 31
  inspect(result.hardness, content="78.5")
  inspect(result.flexibility, content="21.5")
  inspect(result.conductivity, content="31")
}

///|
test "check_target passes when in range" {
  let result : @types.BlendResult = {
    hardness: 50.0,
    flexibility: 50.0,
    conductivity: 50.0,
  }
  let target : @types.TargetAlloy = {
    hardness: { min: 40.0, max: 60.0, },
    flexibility: { min: 40.0, max: 60.0, },
    conductivity: { min: 40.0, max: 60.0, },
  }
  inspect(@forge.check_target(result, target), content="true")
}

///|
test "check_target fails when out of range" {
  let result : @types.BlendResult = {
    hardness: 30.0,
    flexibility: 50.0,
    conductivity: 50.0,
  }
  let target : @types.TargetAlloy = {
    hardness: { min: 40.0, max: 60.0, },
    flexibility: { min: 40.0, max: 60.0, },
    conductivity: { min: 40.0, max: 60.0, },
  }
  inspect(@forge.check_target(result, target), content="false")
}

///|
test "distance_to_center is zero at exact center" {
  let result : @types.BlendResult = {
    hardness: 50.0,
    flexibility: 50.0,
    conductivity: 50.0,
  }
  let target : @types.TargetAlloy = {
    hardness: { min: 40.0, max: 60.0, },
    flexibility: { min: 40.0, max: 60.0, },
    conductivity: { min: 40.0, max: 60.0, },
  }
  inspect(@forge.distance_to_center(result, target), content="0")
}

///|
test "calculate_stars zero when out of range" {
  let result : @types.BlendResult = {
    hardness: 30.0,
    flexibility: 50.0,
    conductivity: 50.0,
  }
  let target : @types.TargetAlloy = {
    hardness: { min: 40.0, max: 60.0, },
    flexibility: { min: 40.0, max: 60.0, },
    conductivity: { min: 40.0, max: 60.0, },
  }
  inspect(@forge.calculate_stars(result, target, 2, 3), content="Zero")
}

///|
test "calculate_stars one when in range but over par" {
  let result : @types.BlendResult = {
    hardness: 50.0,
    flexibility: 50.0,
    conductivity: 50.0,
  }
  let target : @types.TargetAlloy = {
    hardness: { min: 40.0, max: 60.0, },
    flexibility: { min: 40.0, max: 60.0, },
    conductivity: { min: 40.0, max: 60.0, },
  }
  inspect(@forge.calculate_stars(result, target, 5, 3), content="One")
}

///|
test "calculate_stars three when at par and close to center" {
  let result : @types.BlendResult = {
    hardness: 50.0,
    flexibility: 50.0,
    conductivity: 50.0,
  }
  let target : @types.TargetAlloy = {
    hardness: { min: 40.0, max: 60.0, },
    flexibility: { min: 40.0, max: 60.0, },
    conductivity: { min: 40.0, max: 60.0, },
  }
  inspect(@forge.calculate_stars(result, target, 3, 3), content="Three")
}

///|
test "in_range boundary" {
  inspect(@forge.in_range(40.0, { min: 40.0, max: 60.0, }), content="true")
  inspect(@forge.in_range(60.0, { min: 40.0, max: 60.0, }), content="true")
  inspect(@forge.in_range(39.9, { min: 40.0, max: 60.0, }), content="false")
  inspect(@forge.in_range(60.1, { min: 40.0, max: 60.0, }), content="false")
}

///|
test "blend carbon and iron makes very hard alloy" {
  let ingredients : Array[@types.Ingredient] = [
    { metal: Iron, amount: 1, },
    { metal: Carbon, amount: 1, },
  ]
  let result = @forge.blend(ingredients, Medium)
  // Iron(80,20,30) + Carbon(95,5,10) = (87.5, 12.5, 20)
  inspect(result.hardness, content="87.5")
  inspect(result.flexibility, content="12.5")
  inspect(result.conductivity, content="20")
}

///|
test "blend gold and copper maximizes conductivity" {
  let ingredients : Array[@types.Ingredient] = [
    { metal: Gold, amount: 1, },
    { metal: Copper, amount: 1, },
  ]
  let result = @forge.blend(ingredients, Medium)
  // Gold(10,60,95) + Copper(25,50,90) = (17.5, 55, 92.5)
  inspect(result.hardness, content="17.5")
  inspect(result.flexibility, content="55")
  inspect(result.conductivity, content="92.5")
}

///|
test "high temp clamps hardness at 100" {
  let ingredients : Array[@types.Ingredient] = [{ metal: Carbon, amount: 1, }]
  let result = @forge.blend(ingredients, High)
  // Carbon hardness 95 * 1.15 = 109.25 -> clamped to 100
  inspect(result.hardness, content="100")
}
