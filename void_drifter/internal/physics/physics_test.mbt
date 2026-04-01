///|
test "circles_overlap detects collision" {
  inspect(
    @physics.circles_overlap(0.0, 0.0, 10.0, 5.0, 0.0, 10.0),
    content="true",
  )
  inspect(
    @physics.circles_overlap(0.0, 0.0, 5.0, 20.0, 0.0, 5.0),
    content="false",
  )
  // Touching edges - not overlapping (equal distance)
  inspect(
    @physics.circles_overlap(0.0, 0.0, 5.0, 10.0, 0.0, 5.0),
    content="false",
  )
}

///|
test "circles_overlap edge cases" {
  // Same position
  inspect(
    @physics.circles_overlap(5.0, 5.0, 1.0, 5.0, 5.0, 1.0),
    content="true",
  )
  // Very far apart
  inspect(
    @physics.circles_overlap(0.0, 0.0, 1.0, 1000.0, 1000.0, 1.0),
    content="false",
  )
}

///|
test "clamp_to_arena keeps position in bounds" {
  let pos = @types.vec2(-10.0, 500.0)
  @physics.clamp_to_arena(pos, 5.0, 100.0, 100.0)
  inspect(pos.x, content="5")
  inspect(pos.y, content="95")
}

///|
test "update_heat decays heat" {
  let ship = @types.new_ship(Laser)
  ship.heat = 50.0
  @physics.update_heat(ship, 1.0)
  // heat should decrease by heat_decay_rate * dt
  inspect(ship.heat < 50.0, content="true")
  inspect(ship.heat > 0.0, content="true")
}

///|
test "update_heat with heat_sink utility" {
  let ship = @types.new_ship(Laser)
  ship.heat = 50.0
  ship.utility_mod = Some(HeatSink)
  let initial_heat = ship.heat
  @physics.update_heat(ship, 1.0)
  let heat_sink_remaining = ship.heat
  // Reset
  ship.heat = initial_heat
  ship.utility_mod = None
  @physics.update_heat(ship, 1.0)
  let normal_remaining = ship.heat
  // Heat sink should decay more
  inspect(heat_sink_remaining < normal_remaining, content="true")
}

///|
test "update_shield_regen increments shield after delay" {
  let ship = @types.new_ship(Laser)
  ship.shield = 0
  // Not enough time yet
  @physics.update_shield_regen(ship, 1.0)
  inspect(ship.shield, content="0")
  // After full delay
  @physics.update_shield_regen(ship, 2.0)
  inspect(ship.shield, content="1")
}

///|
test "update_ship_physics applies drag" {
  let ship = @types.new_ship(Laser)
  ship.vel = @types.vec2(100.0, 0.0)
  @physics.update_ship_physics(ship, 0.016)
  // Velocity should decrease due to drag
  inspect(ship.vel.x < 100.0, content="true")
  // Position should advance
  inspect(ship.pos.x > @types.arena_default_width / 2.0, content="true")
}

///|
test "update_shake decays intensity" {
  let shake = @types.new_shake()
  shake.intensity = 10.0
  @physics.update_shake(shake)
  inspect(shake.intensity < 10.0, content="true")
  inspect(shake.intensity > 0.0, content="true")
  // Should have offsets
  // (they're random, so just check they exist or are zero after many iterations)
  for _i in 0..<100 {
    @physics.update_shake(shake)
  }
  inspect(shake.intensity, content="0")
}
