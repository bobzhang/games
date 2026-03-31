///|
/// Check if a point is within a guard's vision cone
pub fn point_in_vision_cone(
  grd : @types.Guard,
  target_x : Int,
  target_y : Int,
  tiles : Array[Array[@types.TileKind]]
) -> Bool {
  if !grd.active {
    return false
  }
  let dist = @types.grid_dist(grd.gx, grd.gy, target_x, target_y)
  // Check range - shadow tiles reduce effective range
  let mut effective_range = grd.vision_range
  if target_x >= 0 &&
    target_x < @types.grid_width &&
    target_y >= 0 &&
    target_y < @types.grid_height {
    match tiles[target_y][target_x] {
      Shadow => effective_range *= @types.shadow_vision_mult
      _ => ()
    }
  }
  if dist > effective_range {
    return false
  }
  if dist < 0.5 {
    return true
  }
  // Check angle
  let dx = Float::from_int(target_x - grd.gx)
  let dy = Float::from_int(target_y - grd.gy)
  let angle_to_target = @types.atan2f(dy, dx)
  let angle_diff = normalize_angle(angle_to_target - grd.facing_angle)
  let half_cone = grd.vision_cone / 2.0
  if @types.absf(angle_diff) > half_cone {
    return false
  }
  // Check line of sight
  @types.has_line_of_sight(tiles, grd.gx, grd.gy, target_x, target_y)
}

///|
/// Check if a point is in a camera's vision
pub fn point_in_camera_vision(
  cam : @types.Camera,
  target_x : Int,
  target_y : Int,
  tiles : Array[Array[@types.TileKind]]
) -> Bool {
  if !cam.active || !cam.powered {
    return false
  }
  let dist = @types.grid_dist(cam.gx, cam.gy, target_x, target_y)
  if dist > cam.vision_range {
    return false
  }
  if dist < 0.5 {
    return true
  }
  // Camera has a narrower cone (60 degrees)
  let dx = Float::from_int(target_x - cam.gx)
  let dy = Float::from_int(target_y - cam.gy)
  let angle_to_target = @types.atan2f(dy, dx)
  let angle_diff = normalize_angle(angle_to_target - cam.facing_angle)
  let half_cone : Float = @types.pi / 6.0
  if @types.absf(angle_diff) > half_cone {
    return false
  }
  @types.has_line_of_sight(tiles, cam.gx, cam.gy, target_x, target_y)
}

///|
/// Normalize angle to [-pi, pi]
pub fn normalize_angle(angle : Float) -> Float {
  let mut a = angle
  while a > @types.pi {
    a -= 2.0 * @types.pi
  }
  while a < -@types.pi {
    a += 2.0 * @types.pi
  }
  a
}

///|
/// Check if any guard or camera can see the player
pub fn check_player_visibility(game : @types.Game) -> Bool {
  let px = game.player.gx
  let py = game.player.gy
  let tiles = game.level.tiles
  // Check guards
  for i in 0..<game.level.guards.length() {
    if point_in_vision_cone(game.level.guards[i], px, py, tiles) {
      return true
    }
  }
  // Check cameras
  for i in 0..<game.level.cameras.length() {
    if point_in_camera_vision(game.level.cameras[i], px, py, tiles) {
      return true
    }
  }
  false
}

///|
/// Get detection speed multiplier based on tile type
pub fn detection_speed_at(tiles : Array[Array[@types.TileKind]], x : Int, y : Int) -> Float {
  if x >= 0 && x < @types.grid_width && y >= 0 && y < @types.grid_height {
    match tiles[y][x] {
      Shadow => @types.detection_rate_shadow
      _ => @types.detection_rate_light
    }
  } else {
    @types.detection_rate_light
  }
}
