///|
test "basic reaction: fire + water = steam" {
  let result = react(@types.Fire, @types.Water)
  assert_eq!(result, @types.Transform(@types.Steam))
}

///|
test "basic reaction: water + earth = mud" {
  let result = react(@types.Water, @types.Earth)
  assert_eq!(result, @types.Transform(@types.Mud))
}

///|
test "basic reaction: fire + earth = magma" {
  let result = react(@types.Fire, @types.Earth)
  assert_eq!(result, @types.Transform(@types.Magma))
}

///|
test "basic reaction: air + water = ice" {
  let result = react(@types.Air, @types.Water)
  assert_eq!(result, @types.Transform(@types.Ice))
}

///|
test "basic reaction: fire + air = lightning" {
  let result = react(@types.Fire, @types.Air)
  assert_eq!(result, @types.Transform(@types.Lightning))
}

///|
test "basic reaction: earth + air = dust" {
  let result = react(@types.Earth, @types.Air)
  assert_eq!(result, @types.Transform(@types.Dust))
}

///|
test "basic reaction: light + shadow = void" {
  let result = react(@types.Light, @types.Shadow)
  assert_eq!(result, @types.Transform(@types.Void))
}

///|
test "compound reaction: ice + fire = steam" {
  let result = react(@types.Ice, @types.Fire)
  assert_eq!(result, @types.Transform(@types.Steam))
}

///|
test "compound reaction: lightning + water = storm" {
  let result = react(@types.Lightning, @types.Water)
  assert_eq!(result, @types.Transform(@types.Storm))
}

///|
test "compound reaction: magma + water = obsidian" {
  let result = react(@types.Magma, @types.Water)
  assert_eq!(result, @types.Transform(@types.Obsidian))
}

///|
test "compound reaction: steam + earth = clay" {
  let result = react(@types.Steam, @types.Earth)
  assert_eq!(result, @types.Transform(@types.Clay))
}

///|
test "compound reaction: dust + water = mud" {
  let result = react(@types.Dust, @types.Water)
  assert_eq!(result, @types.Transform(@types.Mud))
}

///|
test "destruction: adding incompatible to compound" {
  // Adding shadow to steam should destroy
  let result = react(@types.Steam, @types.Shadow)
  assert_eq!(result, @types.Destroy)
}

///|
test "destruction: adding fire to storm" {
  let result = react(@types.Storm, @types.Fire)
  assert_eq!(result, @types.Destroy)
}

///|
test "multi-step chain: fire+water->steam, steam+earth->clay" {
  let step1 = react(@types.Fire, @types.Water)
  assert_eq!(step1, @types.Transform(@types.Steam))
  let step2 = react(@types.Steam, @types.Earth)
  assert_eq!(step2, @types.Transform(@types.Clay))
}

///|
test "multi-step chain: fire+air->lightning, lightning+water->storm" {
  let step1 = react(@types.Fire, @types.Air)
  assert_eq!(step1, @types.Transform(@types.Lightning))
  let step2 = react(@types.Lightning, @types.Water)
  assert_eq!(step2, @types.Transform(@types.Storm))
}

///|
test "multi-step chain: fire+earth->magma, magma+water->obsidian" {
  let step1 = react(@types.Fire, @types.Earth)
  assert_eq!(step1, @types.Transform(@types.Magma))
  let step2 = react(@types.Magma, @types.Water)
  assert_eq!(step2, @types.Transform(@types.Obsidian))
}

///|
test "symmetric reactions: both orders work" {
  // Fire + Water == Water + Fire
  let r1 = react(@types.Fire, @types.Water)
  let r2 = react(@types.Water, @types.Fire)
  assert_eq!(r1, r2)
}
