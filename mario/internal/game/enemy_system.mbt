///|
/// Update all active enemies: physics, AI, collisions.
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let active_zone_left = game.camera_x - 100.0
  let active_zone_right = game.camera_x + Float::from_int(@types.screen_w) + 100.0
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    // Dead enemies: animate then remove
    if e.dead {
      e.dead_timer = e.dead_timer + dt
      if e.squished {
        // Squished goomba stays briefly then disappears
        if e.dead_timer > 0.5 {
          e.active = false
        }
      } else {
        // Flipped enemy falls off screen
        e.vy = e.vy + 1200.0 * dt
        e.y = e.y + e.vy * dt
        if e.dead_timer > 3.0 {
          e.active = false
        }
      }
      continue
    }
    // Only activate enemies near the camera
    if e.x < active_zone_left - 200.0 || e.x > active_zone_right + 200.0 {
      continue
    }
    // Gravity
    e.vy = e.vy + @types.gravity_high * dt
    if e.vy > @types.max_fall_speed {
      e.vy = @types.max_fall_speed
    }
    // Horizontal movement
    e.x = e.x + e.vx * dt
    // Animation
    e.anim_timer = e.anim_timer + dt
    if e.anim_timer > 0.2 {
      e.anim_timer = 0.0
      e.anim_frame = if e.anim_frame == 0 { 1 } else { 0 }
    }
    // Wall collision
    let ehw = e.width / 2.0
    let e_left = e.x - ehw
    let e_right = e.x + ehw
    let e_top = e.y - e.height
    let min_tx = @types.world_to_tile_x(e_left)
    let max_tx = @types.world_to_tile_x(e_right - 1.0)
    let min_ty = @types.world_to_tile_y(e_top)
    let max_ty = @types.world_to_tile_y(e.y - 1.0)
    for ty in min_ty..=max_ty {
      for tx in min_tx..=max_tx {
        if @types.is_solid(@types.get_tile(game, tx, ty)) {
          let tile_left = @types.tile_to_world_x(tx)
          let tile_right = tile_left + @types.tile_sizef
          if e.vx > 0.0 && e.x + ehw > tile_left && e.x - ehw < tile_left {
            e.x = tile_left - ehw
            e.vx = -e.vx
          } else if e.vx < 0.0 && e.x - ehw < tile_right && e.x + ehw > tile_right {
            e.x = tile_right + ehw
            e.vx = -e.vx
          }
        }
      }
    }
    // Vertical movement
    e.y = e.y + e.vy * dt
    e.on_ground = false
    // Floor collision
    let foot_ty = @types.world_to_tile_y(e.y)
    let left_tx = @types.world_to_tile_x(e.x - ehw + 2.0)
    let right_tx = @types.world_to_tile_x(e.x + ehw - 2.0)
    for tx in left_tx..=right_tx {
      if @types.is_solid(@types.get_tile(game, tx, foot_ty)) {
        let tile_top = @types.tile_to_world_y(foot_ty)
        if e.y >= tile_top && e.y - e.vy * dt <= tile_top + 4.0 {
          e.y = tile_top
          e.vy = 0.0
          e.on_ground = true
        }
      }
    }
    // Edge detection for non-shell walking enemies — turn at ledges
    if e.on_ground && e.kind != KoopaShell {
      let check_x = if e.vx < 0.0 {
        e.x - ehw - 2.0
      } else {
        e.x + ehw + 2.0
      }
      let check_ty = @types.world_to_tile_y(e.y + 2.0)
      let ground_ahead = @types.get_tile(
        game,
        @types.world_to_tile_x(check_x),
        check_ty,
      )
      if not(@types.is_solid(ground_ahead)) {
        e.vx = -e.vx
      }
    }
    // Kill if fell into pit
    if e.y > Float::from_int(game.map_height * @types.tile_size + 200) {
      e.active = false
    }
    // Shell-on-enemy collision
    if e.kind == KoopaShell && e.shell_moving {
      check_shell_enemy_hits(game, i)
    }
  }
}

///|
fn check_shell_enemy_hits(game : @types.Game, shell_index : Int) -> Unit {
  let shell = game.enemies[shell_index]
  let shw = shell.width / 2.0
  let s_left = shell.x - shw
  let s_right = shell.x + shw
  let s_top = shell.y - shell.height
  let s_bottom = shell.y
  for i in 0..<game.enemies.length() {
    if i == shell_index {
      continue
    }
    let e = game.enemies[i]
    if not(e.active) || e.dead {
      continue
    }
    let ehw = e.width / 2.0
    let e_left = e.x - ehw
    let e_right = e.x + ehw
    let e_top = e.y - e.height
    let e_bottom = e.y
    if s_right > e_left && s_left < e_right && s_bottom > e_top &&
      s_top < e_bottom {
      // Shell kills the enemy
      e.dead = true
      e.dead_timer = 0.0
      e.vy = -300.0
      e.vx = if shell.vx > 0.0 { 100.0 } else { -100.0 }
      game.score = game.score + 200
      spawn_score_popup(game, e.x, e.y - e.height, "200")
    }
  }
}
