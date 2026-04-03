///|
test "basic reaction: fire + water = steam" {
  let result = react(Fire, Water)
  assert_eq(result, Transform(Steam))
}

///|
test "basic reaction: water + earth = mud" {
  let result = react(Water, Earth)
  assert_eq(result, Transform(Mud))
}

///|
test "basic reaction: fire + earth = magma" {
  let result = react(Fire, Earth)
  assert_eq(result, Transform(Magma))
}

///|
test "basic reaction: air + water = ice" {
  let result = react(Air, Water)
  assert_eq(result, Transform(Ice))
}

///|
test "basic reaction: fire + air = lightning" {
  let result = react(Fire, Air)
  assert_eq(result, Transform(Lightning))
}

///|
test "basic reaction: earth + air = dust" {
  let result = react(Earth, Air)
  assert_eq(result, Transform(Dust))
}

///|
test "basic reaction: light + shadow = void" {
  let result = react(Light, Shadow)
  assert_eq(result, Transform(Void))
}

///|
test "compound reaction: ice + fire = steam" {
  let result = react(Ice, Fire)
  assert_eq(result, Transform(Steam))
}

///|
test "compound reaction: lightning + water = storm" {
  let result = react(Lightning, Water)
  assert_eq(result, Transform(Storm))
}

///|
test "compound reaction: magma + water = obsidian" {
  let result = react(Magma, Water)
  assert_eq(result, Transform(Obsidian))
}

///|
test "compound reaction: steam + earth = clay" {
  let result = react(Steam, Earth)
  assert_eq(result, Transform(Clay))
}

///|
test "compound reaction: dust + water = mud" {
  let result = react(Dust, Water)
  assert_eq(result, Transform(Mud))
}

///|
test "destruction: adding incompatible to compound" {
  // Adding shadow to steam should destroy
  let result = react(Steam, Shadow)
  assert_eq(result, Destroy)
}

///|
test "destruction: adding fire to storm" {
  let result = react(Storm, Fire)
  assert_eq(result, Destroy)
}

///|
test "multi-step chain: fire+water->steam, steam+earth->clay" {
  let step1 = react(Fire, Water)
  assert_eq(step1, Transform(Steam))
  let step2 = react(Steam, Earth)
  assert_eq(step2, Transform(Clay))
}

///|
test "multi-step chain: fire+air->lightning, lightning+water->storm" {
  let step1 = react(Fire, Air)
  assert_eq(step1, Transform(Lightning))
  let step2 = react(Lightning, Water)
  assert_eq(step2, Transform(Storm))
}

///|
test "multi-step chain: fire+earth->magma, magma+water->obsidian" {
  let step1 = react(Fire, Earth)
  assert_eq(step1, Transform(Magma))
  let step2 = react(Magma, Water)
  assert_eq(step2, Transform(Obsidian))
}

///|
test "symmetric reactions: both orders work" {
  // Fire + Water == Water + Fire
  let r1 = react(Fire, Water)
  let r2 = react(Water, Fire)
  assert_eq(r1, r2)
}
