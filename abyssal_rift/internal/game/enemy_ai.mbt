///|
pub fn update_enemy_ai(game : @types.Game, e : @types.Enemy, dt : Float) -> Unit {
  let p = game.player
  let stats = @data.get_enemy_stats(e.kind, game.floor_num)
  // Update phase for oscillation
  e.phase += dt
  e.attack_cooldown -= dt
  e.anim_timer += dt
  if e.anim_timer > 0.25 {
    e.anim_timer = 0.0
    e.anim_frame = if e.anim_frame == 0 { 1 } else { 0 }
  }
  // Distance to player
  let d2 = @types.dist2(e.x, e.y, p.x, p.y)
  let dist_to_player = @types.dist(e.x, e.y, p.x, p.y)
  match e.kind {
    Skeleton | Slime | SlimeSmall | Golem | Spider => {
      // Melee chaser AI
      if dist_to_player < stats.sight_range {
        e.state = Chase
        let (dx, dy) = @types.normalize(p.x - e.x, p.y - e.y)
        e.facing_x = dx
        e.facing_y = dy
        e.vx = dx * stats.speed
        e.vy = dy * stats.speed
        // Attack when in range
        if d2 < stats.attack_range * stats.attack_range && e.attack_cooldown <= 0.0 {
          e.state = Attack(0.3)
          e.attack_cooldown = stats.attack_cooldown
          e.vx = 0.0
          e.vy = 0.0
        }
      } else {
        e.state = Idle
        e.vx *= 0.9
        e.vy *= 0.9
      }
    }
    Archer => {
      // Ranged: keep distance, shoot
      if dist_to_player < stats.sight_range {
        let (dx, dy) = @types.normalize(p.x - e.x, p.y - e.y)
        e.facing_x = dx
        e.facing_y = dy
        if dist_to_player < 120.0 {
          // Too close - flee
          e.vx = -dx * stats.speed * 1.2
          e.vy = -dy * stats.speed * 1.2
        } else if dist_to_player > 200.0 {
          // Too far - approach
          e.vx = dx * stats.speed * 0.6
          e.vy = dy * stats.speed * 0.6
        } else {
          // Strafe
          e.vx = -dy * stats.speed * 0.5
          e.vy = dx * stats.speed * 0.5
        }
        // Shoot
        if e.attack_cooldown <= 0.0 {
          e.attack_cooldown = stats.attack_cooldown
          let idx = @types.alloc_projectile(game.projectiles)
          let proj = game.projectiles[idx]
          proj.active = true
          proj.x = e.x
          proj.y = e.y
          proj.vx = dx * 300.0
          proj.vy = dy * 300.0
          proj.damage = stats.damage
          proj.is_player = false
          proj.lifetime = 3.0
          proj.radius = 5.0
          proj.piercing = false
          proj.homing = false
          proj.is_crit = false
        }
      } else {
        e.vx *= 0.9
        e.vy *= 0.9
      }
    }
    Bat => {
      // Erratic fast chaser
      if dist_to_player < stats.sight_range {
        let (dx, dy) = @types.normalize(p.x - e.x, p.y - e.y)
        e.facing_x = dx
        e.facing_y = dy
        let osc_x = Float::from_double(@math.sin((e.phase * 8.0).to_double())) * 100.0
        let osc_y = Float::from_double(@math.cos((e.phase * 6.0).to_double())) * 100.0
        e.vx = dx * stats.speed + osc_x
        e.vy = dy * stats.speed + osc_y
        if d2 < stats.attack_range * stats.attack_range && e.attack_cooldown <= 0.0 {
          e.attack_cooldown = stats.attack_cooldown
          // Direct damage on contact
          damage_player(game, stats.damage)
        }
      } else {
        e.vx *= 0.95
        e.vy *= 0.95
      }
    }
  }
  ignore(dt)
}
