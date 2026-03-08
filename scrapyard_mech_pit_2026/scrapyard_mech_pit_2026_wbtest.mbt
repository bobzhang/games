///|
fn make_scraps() -> Array[Scrap] {
  Array::makei(max_scrap, fn(_i) {
    { active: false, x: 0.0F, y: 0.0F, value: 0 }
  })
}

///|
test "apply_choice routes upgrades to expected slot" {
  let weapon_pick = apply_choice(2, 0, 0, 0, 0, 0)
  assert_eq(weapon_pick.0, 2)

  let chassis_pick = apply_choice(5, 1, 0, 0, 0, 0)
  assert_eq(chassis_pick.1, 2)

  let booster_pick = apply_choice(8, 1, 1, 0, 0, 0)
  assert_eq(booster_pick.2, 2)

  let plating_pick = apply_choice(9, 1, 1, 1, 2, 3)
  assert_eq(plating_pick.3, 3)

  let overclock_pick = apply_choice(10, 1, 1, 1, 2, 3)
  assert_eq(overclock_pick.4, 4)
}

///|
test "tuning preserves intended build identities" {
  assert_true(weapon_fire_cd(2, 0) < weapon_fire_cd(0, 0))
  assert_true(weapon_fire_cd(1, 0) > weapon_fire_cd(2, 0))
  assert_eq(weapon_damage(2, 0).to_int(), 8)
  assert_true(max_hp(2, 0) > 110.0F)
  assert_true(magnet_range(2) > magnet_range(0))
}

///|
test "spawn_scrap uses first inactive slot" {
  let scraps = make_scraps()
  scraps[0].active = true
  scraps[0].value = 99

  spawn_scrap(scraps, 120.0F, 180.0F, 7)

  assert_true(scraps[0].active)
  assert_eq(scraps[0].value, 99)
  assert_true(scraps[1].active)
  assert_eq(scraps[1].x.to_int(), 120)
  assert_eq(scraps[1].y.to_int(), 180)
  assert_eq(scraps[1].value, 7)
}
