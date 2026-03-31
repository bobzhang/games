///|
test "weapon_name returns correct names" {
  inspect(@weapons.weapon_name(Laser), content="LASER")
  inspect(@weapons.weapon_name(Shotgun), content="SHOTGUN")
  inspect(@weapons.weapon_name(Missile), content="MISSILE")
  inspect(@weapons.weapon_name(Railgun), content="RAILGUN")
  inspect(@weapons.weapon_name(Flak), content="FLAK")
  inspect(@weapons.weapon_name(Beam), content="BEAM")
}

///|
test "mod_name returns correct names" {
  inspect(@weapons.mod_name(Piercing), content="PIERCING")
  inspect(@weapons.mod_name(Homing), content="HOMING")
  inspect(@weapons.mod_name(Explosive), content="EXPLOSIVE")
  inspect(@weapons.mod_name(Freezing), content="FREEZING")
}

///|
test "utility_name returns correct names" {
  inspect(@weapons.utility_name(ShieldDrain), content="SHIELD DRAIN")
  inspect(@weapons.utility_name(Vampire), content="VAMPIRE")
  inspect(@weapons.utility_name(HeatSink), content="HEAT SINK")
  inspect(@weapons.utility_name(Accelerator), content="ACCELERATOR")
}

///|
test "update_weapon_timer decrements" {
  let w = @types.new_weapon(Laser)
  w.fire_timer = 0.5
  @weapons.update_weapon_timer(w, 0.2)
  inspect(w.fire_timer > 0.0, content="true")
  inspect(w.fire_timer < 0.5, content="true")
}

///|
test "fire_weapon respects heat limit" {
  let game = @types.new_game()
  game.ship.heat = 98.0 // Close to max_heat (100)
  let weapon = game.ship.weapon
  weapon.fire_timer = 0.0 // Ready to fire
  // Laser heat_cost is 5.0, which would exceed 100
  @weapons.fire_weapon(game, weapon, game.ship.pos, 0.0)
  // Should not have fired due to heat
  inspect(game.stats.shots_fired, content="0")
}

///|
test "fire_weapon respects fire timer" {
  let game = @types.new_game()
  game.ship.weapon.fire_timer = 1.0 // Not ready
  @weapons.fire_weapon(game, game.ship.weapon, game.ship.pos, 0.0)
  inspect(game.stats.shots_fired, content="0")
}
