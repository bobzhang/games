///|
pub fn update_camera(game : @types.Game, dt : Float) -> Unit {
  let cam = game.camera
  let p = game.player
  // Target = player position with slight lead
  cam.target_x = p.x + p.vx * 0.08
  cam.target_y = p.y + p.vy * 0.08
  // Smooth follow
  let t = @types.clampf(@types.camera_lerp_speed * dt, 0.0, 1.0)
  cam.x = @types.lerpf(cam.x, cam.target_x, t)
  cam.y = @types.lerpf(cam.y, cam.target_y, t)
  // Screen shake
  if cam.shake_timer > 0.0 {
    cam.shake_timer -= dt
    let intensity = cam.shake_intensity * (cam.shake_timer / cam.shake_decay)
    let (s1, ox) = @types.rng_range(game.rng_state, -intensity, intensity)
    let (s2, oy) = @types.rng_range(s1, -intensity, intensity)
    game.rng_state = s2
    cam.offset_x = ox
    cam.offset_y = oy
  } else {
    cam.offset_x = 0.0
    cam.offset_y = 0.0
  }
}

///|
pub fn shake_camera(
  game : @types.Game,
  intensity : Float,
  duration : Float,
) -> Unit {
  let cam = game.camera
  if intensity >
    cam.shake_intensity * (cam.shake_timer / @types.maxf(cam.shake_decay, 0.01)) {
    cam.shake_intensity = intensity
    cam.shake_timer = duration
    cam.shake_decay = duration
  }
}

///|
pub fn get_raylib_camera(game : @types.Game) -> @raylib.Camera2D {
  let cam = game.camera
  @raylib.Camera2D::new(
    @raylib.Vector2::new(
      Float::from_int(@types.screen_w) / 2.0 + cam.offset_x,
      Float::from_int(@types.screen_h) / 2.0 + cam.offset_y,
    ),
    @raylib.Vector2::new(cam.x, cam.y),
    0.0,
    1.0,
  )
}
