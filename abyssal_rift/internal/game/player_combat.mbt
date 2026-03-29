///|
pub fn update_player_combat(
  game : @types.Game,
  input : InputState,
  dt : Float
) -> Unit {
  let p = game.player
  if p.dead || p.dash_timer > 0.0 {
    return
  }
  // Update combo timer
  p.combo_timer -= dt
  if p.combo_timer <= 0.0 {
    p.combo_count = 0
  }
  // Buffer attack input during non-idle states
  if input.attack_pressed {
    match p.attack_state {
      Idle => ()
      _ => p.attack_buffered = true
    }
  }
  // Update attack state
  match p.attack_state {
    Idle =>
      if input.attack_pressed || p.attack_buffered {
        p.attack_buffered = false
        let stats = @data.get_weapon_stats(p.weapon)
        let speed_mult : Float = if p.passives.contains(AttackSpeedUp) {
          0.85
        } else {
          1.0
        }
        let windup = @data.get_windup_time(p.weapon, p.combo_count) * speed_mult
        p.attack_state = Windup(windup)
        push_event(game, WeaponSwing(p.x, p.y, p.facing_x))
        ignore(stats)
      }
    Windup(t) => {
      let new_t = t - dt
      if new_t <= 0.0 {
        let speed_mult : Float = if p.passives.contains(AttackSpeedUp) {
          0.85
        } else {
          1.0
        }
        let active_t = @data.get_active_time(p.weapon) * speed_mult
        p.attack_state = Active(active_t)
        // Step-in movement during melee attack
        let step_stats = @data.get_weapon_stats(p.weapon)
        if !step_stats.is_ranged {
          p.vx += p.facing_x * 120.0
          p.vy += p.facing_y * 120.0
        }
        // Create hitbox during active phase
        spawn_player_attack_hitbox(game)
      } else {
        p.attack_state = Windup(new_t)
      }
    }
    Active(t) => {
      let new_t = t - dt
      if new_t <= 0.0 {
        let speed_mult : Float = if p.passives.contains(AttackSpeedUp) {
          0.85
        } else {
          1.0
        }
        let recovery = @data.get_recovery_time(p.weapon, p.combo_count) * speed_mult
        p.attack_state = Recovery(recovery)
      } else {
        p.attack_state = Active(new_t)
      }
    }
    Recovery(t) => {
      let new_t = t - dt
      if new_t <= 0.0 {
        p.attack_state = Idle
        let stats = @data.get_weapon_stats(p.weapon)
        p.combo_count = (p.combo_count + 1) % stats.combo_count
        p.combo_timer = @types.combo_window
      } else {
        p.attack_state = Recovery(new_t)
      }
    }
  }
}

///|
fn spawn_player_attack_hitbox(game : @types.Game) -> Unit {
  let p = game.player
  let stats = @data.get_weapon_stats(p.weapon)
  if stats.is_ranged {
    // Spawn projectile
    let idx = @types.alloc_projectile(game.projectiles)
    let proj = game.projectiles[idx]
    proj.active = true
    proj.x = p.x + p.facing_x * 20.0
    proj.y = p.y + p.facing_y * 20.0
    proj.vx = p.facing_x * stats.projectile_speed
    proj.vy = p.facing_y * stats.projectile_speed
    proj.damage = (Float::from_int(stats.base_damage) * p.damage_mult).to_int()
    proj.is_player = true
    proj.lifetime = 2.0
    proj.poison_on_hit = false
    // Staff projectiles are larger and piercing
    if p.weapon == Staff {
      proj.radius = 10.0
      proj.piercing = true
    } else {
      proj.radius = 6.0
      proj.piercing = false
    }
    proj.homing = p.weapon == Staff
    // Crit roll
    let (s, roll) = @types.rng_next(game.rng_state)
    game.rng_state = s
    proj.is_crit = roll < (p.crit_chance + stats.crit_bonus)
    if proj.is_crit {
      proj.damage = (Float::from_int(proj.damage) * 1.5).to_int()
    }
  } else {
    // Melee: check enemies in arc
    let range = stats.range
    let damage = (Float::from_int(stats.base_damage) * p.damage_mult).to_int()
    let (s, roll) = @types.rng_next(game.rng_state)
    game.rng_state = s
    let is_crit = roll < (p.crit_chance + stats.crit_bonus)
    let final_damage = if is_crit {
      (Float::from_int(damage) * 1.5).to_int()
    } else {
      damage
    }
    for i in 0..<game.enemies.length() {
      let e = game.enemies[i]
      if !e.active {
        continue
      }
      match e.state {
        Dead(_) => continue
        _ => ()
      }
      let d2 = @types.dist2(p.x, p.y, e.x, e.y)
      let hit_range = range + @data.get_enemy_stats(e.kind, game.floor_num).radius
      if d2 <= hit_range * hit_range {
        // Check angle (within arc)
        let dx = e.x - p.x
        let dy = e.y - p.y
        let (ndx, ndy) = @types.normalize(dx, dy)
        let dot = ndx * p.facing_x + ndy * p.facing_y
        let half_arc = stats.arc_angle / 2.0 / 180.0 * 3.14159
        let arc_cos = Float::from_double(@math.cos(half_arc.to_double()))
        if dot >= arc_cos || stats.arc_angle >= 360.0 {
          apply_damage_to_enemy(game, i, final_damage, is_crit, stats.knockback)
        }
      }
    }
  }
}
