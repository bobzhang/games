///|
test "zero velocity probe stays in place with no gravity" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(400.0, 300.0)
  probe.vel = @types.vec2f(0.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="Continue")
  inspect(probe.pos.x, content="400")
  inspect(probe.pos.y, content="300")
}

///|
test "probe at boundary edge triggers out of bounds" {
  let probe = @types.new_probe()
  // Place probe just past the margin boundary
  probe.pos = @types.vec2f(@types.space_width + 51.0, 300.0)
  probe.vel = @types.vec2f(1.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(400.0, 300.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="OutOfBounds")
}

///|
test "probe at negative boundary triggers out of bounds" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(-51.0, 300.0)
  probe.vel = @types.vec2f(-1.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(400.0, 300.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="OutOfBounds")
}

///|
test "probe at top boundary triggers out of bounds" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(400.0, -51.0)
  probe.vel = @types.vec2f(0.0, -1.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(400.0, 300.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="OutOfBounds")
}

///|
test "probe at bottom boundary triggers out of bounds" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(400.0, @types.space_height + 51.0)
  probe.vel = @types.vec2f(0.0, 1.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(400.0, 300.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="OutOfBounds")
}

///|
test "inactive probe returns continue without moving" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(100.0, 100.0)
  probe.vel = @types.vec2f(5.0, 5.0)
  probe.active = false
  let planets = [@types.make_planet(100.0, 100.0, 5.0, 50.0)]
  let station = @types.make_station(100.0, 100.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="Continue")
}

///|
test "multi-planet gravity cancels when symmetric" {
  // Two identical planets on opposite sides should roughly cancel out
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(400.0, 300.0)
  probe.vel = @types.vec2f(0.0, 0.0)
  probe.active = true
  let planets = [
    @types.make_planet(200.0, 300.0, 2.0, 20.0),
    @types.make_planet(600.0, 300.0, 2.0, 20.0),
  ]
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let _ = simulate_tick(probe, planets, station, waypoints, 1)
  // Probe should barely move (symmetric gravity cancels)
  inspect(@types.absf(probe.pos.x - 400.0) < 1.0, content="true")
  inspect(@types.absf(probe.pos.y - 300.0) < 1.0, content="true")
}

///|
test "multi-planet net gravity pulls toward heavier planet" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(400.0, 300.0)
  probe.vel = @types.vec2f(0.0, 0.0)
  probe.active = true
  // Left planet is heavier
  let planets = [
    @types.make_planet(200.0, 300.0, 5.0, 20.0),
    @types.make_planet(600.0, 300.0, 1.0, 20.0),
  ]
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let _ = simulate_tick(probe, planets, station, waypoints, 1)
  // Probe should move left (toward heavier planet)
  inspect(probe.pos.x < 400.0, content="true")
}

///|
test "station reached takes priority over max ticks" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(698.0, 300.0)
  probe.vel = @types.vec2f(3.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(700.0, 300.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  // Even at max ticks, station arrival should be detected first
  let result = simulate_tick(
    probe, planets, station, waypoints, @types.max_ticks,
  )
  inspect(result, content="ReachedStation")
}

///|
test "planet collision at exact radius boundary" {
  let probe = @types.new_probe()
  // Place probe so it ends up inside planet radius after velocity update
  probe.pos = @types.vec2f(231.0, 300.0)
  probe.vel = @types.vec2f(-2.0, 0.0)
  probe.active = true
  let planets = [@types.make_planet(200.0, 300.0, 1.0, 30.0)]
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let waypoints : Array[@types.Waypoint] = []
  let result = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(result, content="HitPlanet")
  inspect(probe.active, content="false")
}

///|
test "multiple waypoints can be collected in sequence" {
  let probe = @types.new_probe()
  probe.pos = @types.vec2f(95.0, 300.0)
  probe.vel = @types.vec2f(10.0, 0.0)
  probe.active = true
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let wp1 = @types.make_waypoint(100.0, 300.0, 20.0)
  let wp2 = @types.make_waypoint(200.0, 300.0, 20.0)
  let waypoints = [wp1, wp2]
  // First tick: collect wp1
  let _ = simulate_tick(probe, planets, station, waypoints, 1)
  inspect(waypoints[0].collected, content="true")
  inspect(waypoints[1].collected, content="false")
  // Continue ticking until reaching wp2
  for i in 2..<20 {
    let _ = simulate_tick(probe, planets, station, waypoints, i)
  }
  inspect(waypoints[1].collected, content="true")
}

///|
test "preview with no planets produces straight line" {
  let start = @types.vec2f(100.0, 300.0)
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let preview = compute_preview(start, 0.0, planets, station)
  assert_true(preview.length() > 0)
  // All positions should be at y=300 (horizontal straight line)
  for i in 0..<preview.length() {
    inspect(@types.absf(preview[i].y - 300.0) < 0.01, content="true")
    // x should increase monotonically
    if i > 0 {
      inspect(preview[i].x > preview[i - 1].x, content="true")
    }
  }
}

///|
test "preview stops when hitting planet" {
  let start = @types.vec2f(100.0, 300.0)
  let planets = [@types.make_planet(200.0, 300.0, 1.0, 30.0)]
  let station = @types.make_station(9999.0, 9999.0, 25.0)
  let preview = compute_preview(start, 0.0, planets, station)
  // Preview should stop before reaching full preview_ticks
  assert_true(preview.length() > 0)
  assert_true(preview.length() < @types.preview_ticks)
}

///|
test "preview stops when reaching station" {
  let start = @types.vec2f(100.0, 300.0)
  let planets : Array[@types.Planet] = []
  let station = @types.make_station(200.0, 300.0, 30.0)
  let preview = compute_preview(start, 0.0, planets, station)
  assert_true(preview.length() > 0)
  assert_true(preview.length() < @types.preview_ticks)
}

///|
test "gravity between two close planets creates stronger pull" {
  let pos = @types.vec2f(400.0, 300.0)
  let close = @types.vec2f(410.0, 300.0)
  let far = @types.vec2f(500.0, 300.0)
  let accel_close = @types.gravity_accel(pos, close, 1.0)
  let accel_far = @types.gravity_accel(pos, far, 1.0)
  // Close planet should produce stronger acceleration
  inspect(
    @types.vec2f_len(accel_close) > @types.vec2f_len(accel_far),
    content="true",
  )
}

///|
test "gravity at very small distance returns zero to prevent singularity" {
  let pos = @types.vec2f(100.0, 100.0)
  let same = @types.vec2f(100.0, 100.0)
  let accel = @types.gravity_accel(pos, same, 5.0)
  inspect(accel.x, content="0")
  inspect(accel.y, content="0")
}
