///|
test "gravity pull direction" {
  // Planet to the right of probe should pull rightward
  let probe_pos = @types.vec2f(100.0, 300.0)
  let planet_pos = @types.vec2f(500.0, 300.0)
  let accel = @types.gravity_accel(probe_pos, planet_pos, 2.0)
  // Acceleration should be positive x (toward planet)
  inspect(accel.x > 0.0, content="true")
  // Y should be approximately zero (same height)
  inspect(@types.absf(accel.y) < 0.01, content="true")
}

///|
test "gravity magnitude decreases with distance" {
  let probe_pos = @types.vec2f(0.0, 0.0)
  let near_planet = @types.vec2f(100.0, 0.0)
  let far_planet = @types.vec2f(200.0, 0.0)
  let accel_near = @types.gravity_accel(probe_pos, near_planet, 1.0)
  let accel_far = @types.gravity_accel(probe_pos, far_planet, 1.0)
  // Near planet should have stronger pull
  inspect(
    @types.vec2f_len(accel_near) > @types.vec2f_len(accel_far),
    content="true",
  )
}

///|
test "straight line trajectory no planets" {
  // With no planets, probe should travel in a straight line
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(100.0, 300.0)
  probe.vel = @types.vec2f(3.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = @physics.simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="Continue")
  // Probe should have moved right
  inspect(probe.pos.x > 100.0, content="true")
  // Y should stay at 300
  inspect(probe.pos.y, content="300")
}

///|
test "planet collision detection" {
  let probe = @types.new_probe()
  // Place probe very close to planet so it collides after one tick
  probe.pos = @types.vec2f(225.0, 300.0)
  probe.vel = @types.vec2f(-3.0, 0.0)
  probe.active = true
  // Planet at 200,300 with radius 30 - probe will land inside
  let planets = [@types.make_planet(200.0, 300.0, 1.0, 30.0)]
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = @physics.simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="HitPlanet")
}

///|
test "station arrival detection" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(695.0, 300.0)
  probe.vel = @types.vec2f(3.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(700.0, 300.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = @physics.simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="ReachedStation")
}

///|
test "out of bounds detection" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(-60.0, 300.0)
  probe.vel = @types.vec2f(-1.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(400.0, 300.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = @physics.simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="OutOfBounds")
}

///|
test "gravity assist bends trajectory" {
  // Probe moving right, planet above should bend trajectory upward
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(100.0, 300.0)
  probe.vel = @types.vec2f(3.0, 0.0)
  probe.active = true
  let planets = [@types.make_planet(200.0, 200.0, 3.0, 20.0)]
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  // Simulate several ticks
  for _i in 0..<20 {
    let _ = @physics.simulate_tick(probe, planets, station, waypoints, _i)
  }
  // After gravity assist, probe should have gained negative y velocity (upward)
  inspect(probe.vel.y < 0.0, content="true")
}

///|
test "waypoint collection" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(98.0, 300.0)
  probe.vel = @types.vec2f(3.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints = [@types.make_waypoint(100.0, 300.0, 20.0)]
  inspect(waypoints[0].collected, content="false")
  let _ = @physics.simulate_tick(probe, planets, station, waypoints, 1)
  inspect(waypoints[0].collected, content="true")
}

///|
test "max ticks detection" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(400.0, 300.0)
  probe.vel = @types.vec2f(0.1, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = @physics.simulate_tick(
    probe, planets, station, waypoints, @types.max_ticks,
  )
  inspect(result, content="MaxTicks")
}

///|
test "preview computation produces positions" {
  let start = @types.vec2f(100.0, 300.0)
  let planets = [@types.make_planet(400.0, 300.0, 2.0, 30.0)]
  let station = @types.make_station(700.0, 300.0, 25.0)
  let preview = @physics.compute_preview(start, 0.0, planets, station)
  inspect(preview.length() > 0, content="true")
  // First position should be near start
  inspect(preview[0].x > 100.0, content="true")
}
