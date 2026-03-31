///|
/// Update all active enemies: physics, AI, collisions.
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let active_zone_left = game.camera_x - 100.0
  let active_zone_right = game.camera_x +
    Float::from_int(@types.screen_w) +
    100.0
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !(e.active) {
      continue
    }
    // Dead enemies: animate then remove
    if e.dead {
      e.dead_timer = e.dead_timer + dt
      if e.squished {
        // Squished goomba/beetle stays briefly then disappears
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
    // Special update for Firebar — no physics, just rotation
    if e.kind == Firebar {
      e.firebar_angle = e.firebar_angle + @types.firebar_rotation_speed * dt
      continue
    }
    // Special update for PiranhaPlant — timer-based extend/retract
    if e.kind == PiranhaPlant {
      e.pipe_timer = e.pipe_timer + dt
      if e.pipe_timer >= @types.piranha_cycle_time {
        e.pipe_timer = e.pipe_timer - @types.piranha_cycle_time
      }
      e.extended = e.pipe_timer < @types.piranha_extend_time
      // Animate when extended
      if e.extended {
        e.anim_timer = e.anim_timer + dt
        if e.anim_timer > 0.3 {
          e.anim_timer = 0.0
          e.anim_frame = if e.anim_frame == 0 { 1 } else { 0 }
        }
      }
      continue
    }
    // Special update for BowserLite — patrol and fire breath
    if e.kind == BowserLite {
      update_bowser_lite(game, e, dt)
      continue
    }
    // BuzzyBeetle hop timer
    if e.kind == BuzzyBeetle {
      e.hop_timer = e.hop_timer + dt
      if e.hop_timer >= @types.buzzy_beetle_hop_interval && e.on_ground {
        e.vy = @types.buzzy_beetle_hop_velocity
        e.on_ground = false
        e.hop_timer = 0.0
      }
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
    for ty in min_ty..<=max_ty {
      for tx in min_tx..<=max_tx {
        if @types.is_solid(@types.get_tile(game, tx, ty)) {
          let tile_left = @types.tile_to_world_x(tx)
          let tile_right = tile_left + @types.tile_sizef
          if e.vx > 0.0 && e.x + ehw > tile_left && e.x - ehw < tile_left {
            e.x = tile_left - ehw
            e.vx = -e.vx
          } else if e.vx < 0.0 &&
            e.x - ehw < tile_right &&
            e.x + ehw > tile_right {
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
    for tx in left_tx..<=right_tx {
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
      let check_x = if e.vx < 0.0 { e.x - ehw - 2.0 } else { e.x + ehw + 2.0 }
      let check_ty = @types.world_to_tile_y(e.y + 2.0)
      let ground_ahead = @types.get_tile(
        game,
        @types.world_to_tile_x(check_x),
        check_ty,
      )
      if !(@types.is_solid(ground_ahead)) {
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
  // Update Bowser fire breath projectiles
  update_bowser_fireballs(game, dt)
}

///|
/// Update BowserLite: patrol left/right, shoot fire.
fn update_bowser_lite(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
) -> Unit {
  // Gravity
  e.vy = e.vy + @types.gravity_high * dt
  if e.vy > @types.max_fall_speed {
    e.vy = @types.max_fall_speed
  }
  // Patrol: reverse direction at bounds
  e.x = e.x + e.vx * dt
  if e.x <= e.patrol_left {
    e.x = e.patrol_left
    e.vx = @utils.absf(e.vx)
  } else if e.x >= e.patrol_right {
    e.x = e.patrol_right
    e.vx = -@utils.absf(e.vx)
  }
  // Vertical movement + ground
  e.y = e.y + e.vy * dt
  e.on_ground = false
  let ehw = e.width / 2.0
  let foot_ty = @types.world_to_tile_y(e.y)
  let left_tx = @types.world_to_tile_x(e.x - ehw + 2.0)
  let right_tx = @types.world_to_tile_x(e.x + ehw - 2.0)
  for tx in left_tx..<=right_tx {
    if @types.is_solid(@types.get_tile(game, tx, foot_ty)) {
      let tile_top = @types.tile_to_world_y(foot_ty)
      if e.y >= tile_top && e.y - e.vy * dt <= tile_top + 4.0 {
        e.y = tile_top
        e.vy = 0.0
        e.on_ground = true
      }
    }
  }
  // Animation
  e.anim_timer = e.anim_timer + dt
  if e.anim_timer > 0.3 {
    e.anim_timer = 0.0
    e.anim_frame = if e.anim_frame == 0 { 1 } else { 0 }
  }
  // Fire breath cooldown
  e.fire_cooldown = e.fire_cooldown - dt
  if e.fire_cooldown <= 0.0 {
    e.fire_cooldown = @types.bowser_fire_rate
    // Spawn fire breath projectile
    spawn_bowser_fireball(game, e)
  }
}

///|
/// Spawn a Bowser fire breath projectile.
fn spawn_bowser_fireball(game : @types.Game, e : @types.Enemy) -> Unit {
  for i in 0..<game.bowser_fireballs.length() {
    if !(game.bowser_fireballs[i].active) {
      let bf = game.bowser_fireballs[i]
      bf.active = true
      let dir : Float = if e.vx >= 0.0 { 1.0 } else { -1.0 }
      bf.x = e.x + dir * 40.0
      bf.y = e.y - e.height / 2.0
      bf.vx = dir * @types.bowser_fire_speed
      return
    }
  }
}

///|
/// Update all Bowser fire breath projectiles.
fn update_bowser_fireballs(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.bowser_fireballs.length() {
    let bf = game.bowser_fireballs[i]
    if !(bf.active) {
      continue
    }
    bf.x = bf.x + bf.vx * dt
    // Off-screen check
    if bf.x < game.camera_x - 100.0 ||
      bf.x > game.camera_x + Float::from_int(@types.screen_w) + 100.0 {
      bf.active = false
      continue
    }
    // Wall collision — destroy
    let mid_ty = @types.world_to_tile_y(bf.y)
    let wall_tx = @types.world_to_tile_x(
      bf.x + (if bf.vx > 0.0 { 10.0 } else { -10.0 }),
    )
    if @types.is_solid(@types.get_tile(game, wall_tx, mid_ty)) {
      bf.active = false
      continue
    }
    // Player hit check
    check_bowser_fireball_player_hit(game, bf)
  }
}

///|
/// Check if a Bowser fireball hits the player.
fn check_bowser_fireball_player_hit(
  game : @types.Game,
  bf : @types.BowserFireball,
) -> Unit {
  let p = game.player
  if p.dead || p.invuln_timer > 0.0 {
    return
  }
  let ph = p.height()
  let p_left = p.x - @types.player_half_w
  let p_right = p.x + @types.player_half_w
  let p_top = p.y - ph
  let p_bottom = p.y
  let bf_hw : Float = 12.0
  let bf_hh : Float = 6.0
  if bf.x + bf_hw > p_left &&
    bf.x - bf_hw < p_right &&
    bf.y + bf_hh > p_top &&
    bf.y - bf_hh < p_bottom {
    bf.active = false
    start_shake(game, 6.0, 0.2)
    damage_player_from_enemy(game)
  }
}

///|
/// Damage the player from an enemy source (calls into player_system logic).
fn damage_player_from_enemy(game : @types.Game) -> Unit {
  let p = game.player
  if p.invuln_timer > 0.0 || p.dead {
    return
  }
  match p.power {
    Small => kill_player(game)
    Big => {
      p.power = Small
      p.invuln_timer = @types.invuln_duration
      p.shrink_timer = @types.shrink_duration
    }
    Fire => {
      p.power = Big
      p.invuln_timer = @types.invuln_duration
      p.shrink_timer = @types.shrink_duration
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
    if !(e.active) || e.dead {
      continue
    }
    let ehw = e.width / 2.0
    let e_left = e.x - ehw
    let e_right = e.x + ehw
    let e_top = e.y - e.height
    let e_bottom = e.y
    if s_right > e_left &&
      s_left < e_right &&
      s_bottom > e_top &&
      s_top < e_bottom {
      // Shell kills the enemy
      e.flash_timer = 0.1
      e.dead = true
      e.dead_timer = 0.0
      e.vy = -300.0
      e.vx = if shell.vx > 0.0 { 100.0 } else { -100.0 }
      game.score = game.score + 200
      spawn_score_popup(game, e.x, e.y - e.height, "200")
    }
  }
}
