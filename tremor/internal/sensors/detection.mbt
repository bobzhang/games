///|
pub fn compute_reading(
  sensor : @types.Sensor,
  epicenter : @types.Vec2i,
  tile_kind : @types.TileKind,
) -> @types.SensorReading? {
  let dist = @types.dist_i(sensor.pos, epicenter)
  let range = @types.sensor_range(sensor.kind)
  if dist > range {
    return None
  }
  let base_unc = @types.sensor_uncertainty(sensor.kind)
  let extra = match tile_kind {
    Noisy => @types.noisy_extra_uncertainty
    _ => 0.0
  }
  let uncertainty = base_unc + extra
  let min_d = @types.maxf(0.0, dist - uncertainty)
  let max_d = dist + uncertainty
  let angle = match sensor.kind {
    Directional => @types.directional_angle
    _ => 360.0
  }
  Some({
    center: sensor.pos,
    min_dist: min_d,
    max_dist: max_d,
    direction: sensor.direction,
    angle,
    kind: sensor.kind,
  })
}

///|
pub fn compute_all_readings(
  sensors : Array[@types.Sensor],
  epicenter : @types.Vec2i,
  grid : Array[Array[@types.TileInfo]],
) -> Array[@types.SensorReading] {
  let result : Array[@types.SensorReading] = []
  for i in 0..<sensors.length() {
    let s = sensors[i]
    let tk = if s.pos.y >= 0 &&
      s.pos.y < grid.length() &&
      s.pos.x >= 0 &&
      s.pos.x < grid[0].length() {
      grid[s.pos.y][s.pos.x].kind
    } else {
      Empty
    }
    match compute_reading(s, epicenter, tk) {
      Some(r) => result.push(r)
      None => ()
    }
  }
  result
}

///|
pub fn point_in_ring(
  reading : @types.SensorReading,
  point : @types.Vec2i,
) -> Bool {
  let dist = @types.dist_i(reading.center, point)
  if dist < reading.min_dist || dist > reading.max_dist {
    return false
  }
  if reading.angle < 360.0 {
    return point_in_wedge(reading, point)
  }
  true
}

///|
pub fn point_in_wedge(
  reading : @types.SensorReading,
  point : @types.Vec2i,
) -> Bool {
  let dx = Float::from_int(point.x - reading.center.x)
  let dy = Float::from_int(point.y - reading.center.y)
  if dx == 0.0 && dy == 0.0 {
    return true
  }
  let point_angle = @types.atan2f(dy, dx)
  let center_angle = @types.compass_angle(reading.direction)
  let half_angle = reading.angle * @types.pi / 360.0
  let diff = normalize_angle(point_angle - center_angle)
  @types.absf(diff) <= half_angle
}

///|
pub fn normalize_angle(a : Float) -> Float {
  let mut angle = a
  while angle > @types.pi {
    angle = angle - @types.two_pi
  }
  while angle < -@types.pi {
    angle = angle + @types.two_pi
  }
  angle
}

///|
pub fn point_in_all_readings(
  readings : Array[@types.SensorReading],
  point : @types.Vec2i,
) -> Bool {
  if readings.length() == 0 {
    return false
  }
  for i in 0..<readings.length() {
    if !point_in_ring(readings[i], point) {
      return false
    }
  }
  true
}

///|
pub fn compute_overlap_tiles(
  readings : Array[@types.SensorReading],
) -> Array[@types.Vec2i] {
  let result : Array[@types.Vec2i] = []
  if readings.length() == 0 {
    return result
  }
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let pt = @types.vec2i(col, row)
      if point_in_all_readings(readings, pt) {
        result.push(pt)
      }
    }
  }
  result
}

///|
pub fn check_guess(
  guess : @types.Vec2i,
  epicenter : @types.Vec2i,
  tolerance : Float,
) -> Bool {
  let dist = @types.dist_i(guess, epicenter)
  dist <= tolerance
}

///|
pub fn check_all_epicenters(
  guess : @types.Vec2i,
  epicenters : Array[@types.Epicenter],
  tolerance : Float,
) -> Int {
  let mut found_index = -1
  for i in 0..<epicenters.length() {
    if !epicenters[i].found && check_guess(guess, epicenters[i].pos, tolerance) {
      found_index = i
      break
    }
  }
  found_index
}

///|
pub fn all_epicenters_found(epicenters : Array[@types.Epicenter]) -> Bool {
  for i in 0..<epicenters.length() {
    if !epicenters[i].found {
      return false
    }
  }
  true
}
