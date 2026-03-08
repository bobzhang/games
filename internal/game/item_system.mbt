///|
/// Update all active items: emerging animation, physics, movement.
fn update_items(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.items.length() {
    let it = game.items[i]
    if not(it.active) {
      continue
    }
    if it.emerging {
      // Slide upward out of block
      it.y = it.y - 80.0 * dt
      if it.y <= it.emerge_target_y {
        it.y = it.emerge_target_y
        it.emerging = false
        // Start moving
        match it.kind {
          Mushroom | OneUp => it.vx = @types.mushroom_speed
          Star => {
            it.vx = @types.star_speed
            it.vy = @types.star_bounce_vel
          }
          _ => ()
        }
      }
      continue
    }
    // Physics
    match it.kind {
      Mushroom | OneUp => {
        // Gravity
        it.vy = it.vy + @types.gravity_high * dt
        if it.vy > @types.max_fall_speed {
          it.vy = @types.max_fall_speed
        }
        // Move X
        it.x = it.x + it.vx * dt
        // Wall collision
        let hw : Float = 20.0
        let left_tx = @types.world_to_tile_x(it.x - hw)
        let right_tx = @types.world_to_tile_x(it.x + hw)
        let mid_ty = @types.world_to_tile_y(it.y - 20.0)
        if it.vx > 0.0 && @types.is_solid(@types.get_tile(game, right_tx, mid_ty)) {
          it.vx = -it.vx
        } else if it.vx < 0.0 &&
          @types.is_solid(@types.get_tile(game, left_tx, mid_ty)) {
          it.vx = -it.vx
        }
        // Move Y
        it.y = it.y + it.vy * dt
        it.on_ground = false
        let foot_ty = @types.world_to_tile_y(it.y)
        let check_left = @types.world_to_tile_x(it.x - hw + 2.0)
        let check_right = @types.world_to_tile_x(it.x + hw - 2.0)
        for tx in check_left..=check_right {
          if @types.is_solid(@types.get_tile(game, tx, foot_ty)) {
            let tile_top = @types.tile_to_world_y(foot_ty)
            if it.y >= tile_top {
              it.y = tile_top
              it.vy = 0.0
              it.on_ground = true
            }
          }
        }
      }
      Star => {
        // Star bounces
        it.vy = it.vy + @types.gravity_high * 0.5 * dt
        if it.vy > @types.max_fall_speed {
          it.vy = @types.max_fall_speed
        }
        it.x = it.x + it.vx * dt
        it.y = it.y + it.vy * dt
        // Wall bounce
        let hw : Float = 20.0
        let left_tx = @types.world_to_tile_x(it.x - hw)
        let right_tx = @types.world_to_tile_x(it.x + hw)
        let mid_ty = @types.world_to_tile_y(it.y - 20.0)
        if it.vx > 0.0 && @types.is_solid(@types.get_tile(game, right_tx, mid_ty)) {
          it.vx = -it.vx
        } else if it.vx < 0.0 &&
          @types.is_solid(@types.get_tile(game, left_tx, mid_ty)) {
          it.vx = -it.vx
        }
        // Floor bounce
        let foot_ty = @types.world_to_tile_y(it.y)
        let check_left = @types.world_to_tile_x(it.x - hw + 2.0)
        let check_right = @types.world_to_tile_x(it.x + hw - 2.0)
        for tx in check_left..=check_right {
          if @types.is_solid(@types.get_tile(game, tx, foot_ty)) {
            let tile_top = @types.tile_to_world_y(foot_ty)
            if it.y >= tile_top {
              it.y = tile_top
              it.vy = @types.star_bounce_vel
            }
          }
        }
      }
      _ => ()
    }
    // Remove if off-screen below
    if it.y > Float::from_int(game.map_height * @types.tile_size + 200) {
      it.active = false
    }
  }
}

///|
/// Update all active fireballs.
fn update_fireballs(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.fireballs.length() {
    let fb = game.fireballs[i]
    if not(fb.active) {
      continue
    }
    // Gravity
    fb.vy = fb.vy + @types.fireball_gravity * dt
    // Move
    fb.x = fb.x + fb.vx * dt
    fb.y = fb.y + fb.vy * dt
    // Floor bounce
    let foot_ty = @types.world_to_tile_y(fb.y)
    let foot_tx = @types.world_to_tile_x(fb.x)
    if @types.is_solid(@types.get_tile(game, foot_tx, foot_ty)) {
      let tile_top = @types.tile_to_world_y(foot_ty)
      fb.y = tile_top
      fb.vy = @types.fireball_bounce_vel
    }
    // Wall collision — destroy fireball
    let mid_ty = @types.world_to_tile_y(fb.y - 8.0)
    let wall_tx = @types.world_to_tile_x(
      fb.x + (if fb.vx > 0.0 { 6.0 } else { -6.0 }),
    )
    if @types.is_solid(@types.get_tile(game, wall_tx, mid_ty)) {
      fb.active = false
      spawn_fireball_poof(game, fb.x, fb.y)
      continue
    }
    // Off-screen check
    if fb.y > Float::from_int(game.map_height * @types.tile_size + 100) ||
      fb.x < game.camera_x - 100.0 ||
      fb.x > game.camera_x + Float::from_int(@types.screen_w) + 100.0 {
      fb.active = false
      continue
    }
    // Enemy hit check
    check_fireball_enemy_hit(game, i)
  }
}

///|
fn check_fireball_enemy_hit(game : @types.Game, fb_index : Int) -> Unit {
  let fb = game.fireballs[fb_index]
  let fb_r : Float = 8.0
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) || e.dead {
      continue
    }
    let ehw = e.width / 2.0
    let e_left = e.x - ehw
    let e_right = e.x + ehw
    let e_top = e.y - e.height
    let e_bottom = e.y
    if fb.x + fb_r > e_left && fb.x - fb_r < e_right && fb.y + fb_r > e_top &&
      fb.y - fb_r < e_bottom {
      // Hit!
      e.dead = true
      e.dead_timer = 0.0
      e.vy = -250.0
      e.vx = if fb.vx > 0.0 { 80.0 } else { -80.0 }
      fb.active = false
      game.score = game.score + 200
      spawn_score_popup(game, e.x, e.y - e.height, "200")
      spawn_fireball_poof(game, fb.x, fb.y)
      return
    }
  }
}

///|
fn spawn_fireball_poof(game : @types.Game, wx : Float, wy : Float) -> Unit {
  let mut count = 0
  for i in 0..<game.particles.length() {
    if count >= 4 {
      break
    }
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = wx + @types.rand_rangef(game, -6.0, 6.0)
      p.y = wy + @types.rand_rangef(game, -6.0, 6.0)
      p.vx = @types.rand_rangef(game, -60.0, 60.0)
      p.vy = @types.rand_rangef(game, -80.0, -20.0)
      p.life = 0.25
      p.max_life = 0.25
      p.size = @types.rand_rangef(game, 3.0, 7.0)
      p.color = @raylib.Color::new(252, 148, 0, 255)
      p.has_gravity = false
      count = count + 1
    }
  }
}
