///|
pub(all) enum TickResult {
  Continue
  HitPlanet
  ReachedStation
  OutOfBounds
  MaxTicks
} derive(Eq, Show)

///|
fn compute_total_gravity(
  pos : @types.Vec2f,
  planets : Array[@types.Planet],
) -> @types.Vec2f {
  let mut ax : Float = 0.0
  let mut ay : Float = 0.0
  for i in 0..<planets.length() {
    let p = planets[i]
    let accel = @types.gravity_accel(pos, p.pos, p.mass)
    ax += accel.x
    ay += accel.y
  }
  @types.vec2f(ax, ay)
}

///|
fn check_planet_collision(
  pos : @types.Vec2f,
  planets : Array[@types.Planet],
) -> Bool {
  for i in 0..<planets.length() {
    let p = planets[i]
    let dist = @types.vec2f_dist(pos, p.pos)
    if dist < p.radius {
      return true
    }
  }
  false
}

///|
fn check_station_arrival(pos : @types.Vec2f, station : @types.Station) -> Bool {
  let dist = @types.vec2f_dist(pos, station.pos)
  dist < station.radius
}

///|
fn check_bounds(pos : @types.Vec2f) -> Bool {
  let margin : Float = 50.0
  pos.x < -margin ||
  pos.x > @types.space_width + margin ||
  pos.y < -margin ||
  pos.y > @types.space_height + margin
}

///|
fn check_waypoints(
  pos : @types.Vec2f,
  waypoints : Array[@types.Waypoint],
) -> Unit {
  for i in 0..<waypoints.length() {
    let wp = waypoints[i]
    if !wp.collected {
      let dist = @types.vec2f_dist(pos, wp.pos)
      if dist < wp.radius {
        wp.collected = true
      }
    }
  }
}

///|
pub fn simulate_tick(
  probe : @types.Probe,
  planets : Array[@types.Planet],
  station : @types.Station,
  waypoints : Array[@types.Waypoint],
  tick : Int,
) -> TickResult {
  if !probe.active {
    return Continue
  }
  // Compute gravity acceleration
  let accel = compute_total_gravity(probe.pos, planets)
  // Update velocity
  probe.vel = @types.vec2f_add(probe.vel, accel)
  // Update position
  probe.pos = @types.vec2f_add(probe.pos, probe.vel)
  // Check waypoints
  check_waypoints(probe.pos, waypoints)
  // Check station arrival
  if check_station_arrival(probe.pos, station) {
    return ReachedStation
  }
  // Check planet collision
  if check_planet_collision(probe.pos, planets) {
    probe.active = false
    return HitPlanet
  }
  // Check bounds
  if check_bounds(probe.pos) {
    probe.active = false
    return OutOfBounds
  }
  // Check max ticks
  if tick >= @types.max_ticks {
    probe.active = false
    return MaxTicks
  }
  Continue
}

///|
pub fn compute_preview(
  start_pos : @types.Vec2f,
  angle : Float,
  planets : Array[@types.Planet],
  station : @types.Station,
) -> Array[@types.Vec2f] {
  let positions : Array[@types.Vec2f] = []
  let vel_x = @types.cosf(angle) * @types.launch_speed
  let vel_y = @types.sinf(angle) * @types.launch_speed
  let mut px = start_pos.x
  let mut py = start_pos.y
  let mut vx = vel_x
  let mut vy = vel_y
  for _tick in 0..<@types.preview_ticks {
    // Compute gravity
    let mut ax : Float = 0.0
    let mut ay : Float = 0.0
    for i in 0..<planets.length() {
      let p = planets[i]
      let dx = p.pos.x - px
      let dy = p.pos.y - py
      let dist_sq = dx * dx + dy * dy
      let dist = @types.sqrtf(dist_sq)
      if dist > 1.0 {
        let force_mag = @types.gravity_g * p.mass / dist_sq
        ax += dx / dist * force_mag
        ay += dy / dist * force_mag
      }
    }
    vx += ax
    vy += ay
    px += vx
    py += vy
    positions.push(@types.vec2f(px, py))
    // Stop preview if hit planet or station or out of bounds
    let mut hit = false
    for i in 0..<planets.length() {
      let p = planets[i]
      let dist = @types.sqrtf(
        (px - p.pos.x) * (px - p.pos.x) + (py - p.pos.y) * (py - p.pos.y),
      )
      if dist < p.radius {
        hit = true
      }
    }
    if hit {
      break
    }
    let st_dist = @types.sqrtf(
      (px - station.pos.x) * (px - station.pos.x) +
      (py - station.pos.y) * (py - station.pos.y),
    )
    if st_dist < station.radius {
      break
    }
    if px < -50.0 ||
      px > @types.space_width + 50.0 ||
      py < -50.0 ||
      py > @types.space_height + 50.0 {
      break
    }
  }
  positions
}
