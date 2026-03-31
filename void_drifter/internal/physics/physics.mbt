///|
pub fn update_ship_physics(ship : @types.Ship, dt : Float) -> Unit {
  // Apply drag
  ship.vel.x = ship.vel.x * ship.drag
  ship.vel.y = ship.vel.y * ship.drag
  // Integrate position
  ship.pos.x = ship.pos.x + ship.vel.x * dt
  ship.pos.y = ship.pos.y + ship.vel.y * dt
  // Dash physics
  if ship.dash_timer > 0.0 {
    ship.dash_timer = ship.dash_timer - dt
  }
  // Invincibility
  if ship.invincible_timer > 0.0 {
    ship.invincible_timer = ship.invincible_timer - dt
  }
  // Dash cooldown
  if ship.dash_cooldown > 0.0 {
    ship.dash_cooldown = ship.dash_cooldown - dt
  }
}

///|
pub fn update_projectile_physics(proj : @types.Projectile, dt : Float) -> Unit {
  if !(proj.active) {
    return
  }
  proj.pos.x = proj.pos.x + proj.vel.x * dt
  proj.pos.y = proj.pos.y + proj.vel.y * dt
  proj.lifetime = proj.lifetime - dt
  if proj.lifetime <= 0.0 {
    proj.active = false
  }
}

///|
pub fn update_enemy_physics(enemy : @types.Enemy, dt : Float) -> Unit {
  if !(enemy.active) {
    return
  }
  if enemy.frozen_timer > 0.0 {
    enemy.frozen_timer = enemy.frozen_timer - dt
    return
  }
  enemy.pos.x = enemy.pos.x + enemy.vel.x * dt
  enemy.pos.y = enemy.pos.y + enemy.vel.y * dt
}

///|
pub fn update_asteroid_physics(ast : @types.Asteroid, dt : Float) -> Unit {
  if !(ast.active) {
    return
  }
  ast.pos.x = ast.pos.x + ast.vel.x * dt
  ast.pos.y = ast.pos.y + ast.vel.y * dt
  ast.angle = ast.angle + ast.spin * dt
}

///|
pub fn clamp_to_arena(
  pos : @types.Vec2,
  radius : Float,
  w : Float,
  h : Float
) -> Unit {
  pos.x = @types.clampf(pos.x, radius, w - radius)
  pos.y = @types.clampf(pos.y, radius, h - radius)
}

///|
pub fn circles_overlap(
  ax : Float,
  ay : Float,
  ar : Float,
  bx : Float,
  by : Float,
  br : Float
) -> Bool {
  let dx = ax - bx
  let dy = ay - by
  let r = ar + br
  dx * dx + dy * dy < r * r
}

///|
pub fn apply_homing(
  proj : @types.Projectile,
  enemies : Array[@types.Enemy],
  dt : Float
) -> Unit {
  if proj.homing_strength <= 0.0 || !(proj.active) {
    return
  }
  // Find nearest enemy
  let mut nearest_dist : Float = 999999.0
  let mut nearest_x : Float = 0.0
  let mut nearest_y : Float = 0.0
  let mut found = false
  for i in 0..<enemies.length() {
    if enemies[i].active {
      let d = @types.vec2_dist_sq(proj.pos, enemies[i].pos)
      if d < nearest_dist {
        nearest_dist = d
        nearest_x = enemies[i].pos.x
        nearest_y = enemies[i].pos.y
        found = true
      }
    }
  }
  if found {
    let to_target = @types.vec2_normalize(
      @types.vec2_sub(@types.vec2(nearest_x, nearest_y), proj.pos),
    )
    let speed = @types.vec2_len(proj.vel)
    let current_dir = @types.vec2_normalize(proj.vel)
    let new_dir = @types.vec2_normalize(
      @types.vec2_add(
        current_dir,
        @types.vec2_scale(to_target, proj.homing_strength * dt),
      ),
    )
    proj.vel.x = new_dir.x * speed
    proj.vel.y = new_dir.y * speed
  }
}

///|
pub fn update_shake(shake : @types.ScreenShake) -> Unit {
  if shake.intensity > 0.1 {
    shake.offset_x = @types.rng_range(-shake.intensity, shake.intensity)
    shake.offset_y = @types.rng_range(-shake.intensity, shake.intensity)
    shake.intensity = shake.intensity * shake.decay
  } else {
    shake.intensity = 0.0
    shake.offset_x = 0.0
    shake.offset_y = 0.0
  }
}

///|
pub fn update_heat(ship : @types.Ship, dt : Float) -> Unit {
  if ship.heat > 0.0 {
    let decay = match ship.utility_mod {
      Some(HeatSink) => ship.heat_decay * @types.heat_sink_bonus
      _ => ship.heat_decay
    }
    ship.heat = @types.maxf(0.0, ship.heat - decay * dt)
  }
}

///|
pub fn update_shield_regen(ship : @types.Ship, dt : Float) -> Unit {
  if ship.shield < ship.max_shield {
    ship.shield_regen_timer = ship.shield_regen_timer + dt
    if ship.shield_regen_timer >= @types.shield_regen_delay {
      ship.shield = ship.shield + 1
      ship.shield_regen_timer = 0.0
    }
  }
}
