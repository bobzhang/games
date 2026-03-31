///|
pub fn update_player_combat(
  game : @types.Game,
  input : InputState,
  dt : Float,
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
        let recovery = @data.get_recovery_time(p.weapon, p.combo_count) *
          speed_mult
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
  // Berserker / GlassCannon / Assassin synergy multiplier
  let mut bonus_mult : Float = 1.0
  if p.passives.contains(Berserker) {
    let hp_ratio = Float::from_int(p.hp) / Float::from_int(p.max_hp)
    if hp_ratio < 0.3 {
      bonus_mult += 0.3
    }
  }
  if p.passives.contains(GlassCannon) {
    bonus_mult += 0.5
  }
  // Assassin synergy: CritUp + Daggers
  let assassin_crit_bonus : Float = if p.passives.contains(CritUp) &&
    p.weapon == Daggers {
    0.10
  } else {
    0.0
  }
  // Destroyer synergy: DamageUp + GlassCannon
  let syn = game.synergies
  if syn.destroyer {
    bonus_mult += 0.25
  }
  // Pact: BloodPrice +25% damage
  if @types.has_pact(p, BloodPrice) {
    bonus_mult += 0.25
  }
  // Pact: CursedStrength +40% damage
  if @types.has_pact(p, CursedStrength) {
    bonus_mult += 0.40
  }
  if stats.is_ranged {
    // Multishot synergy: spawn multiple arrows in a spread for Bow
    let shot_count = if syn.multishot && p.weapon == Bow {
      syn.multishot_count
    } else {
      1
    }
    // Base angle from facing direction
    let base_angle = Float::from_double(
      @math.atan2(p.facing_y.to_double(), p.facing_x.to_double()),
    )
    // Spread angle: 15 degrees total, in radians
    let spread_rad : Float = 15.0 / 180.0 * 3.14159
    for shot in 0..<shot_count {
      let angle_offset : Float = if shot_count > 1 {
        let t = Float::from_int(shot) / Float::from_int(shot_count - 1) - 0.5
        t * spread_rad
      } else {
        0.0
      }
      let angle = base_angle + angle_offset
      let dir_x = Float::from_double(@math.cos(angle.to_double()))
      let dir_y = Float::from_double(@math.sin(angle.to_double()))
      let idx = @types.alloc_projectile(game.projectiles)
      let proj = game.projectiles[idx]
      proj.active = true
      proj.x = p.x + dir_x * 20.0
      proj.y = p.y + dir_y * 20.0
      proj.vx = dir_x * stats.projectile_speed
      proj.vy = dir_y * stats.projectile_speed
      proj.damage = (Float::from_int(stats.base_damage) *
      p.damage_mult *
      bonus_mult).to_int()
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
      proj.is_crit = roll <
        p.crit_chance + stats.crit_bonus + assassin_crit_bonus
      if proj.is_crit {
        proj.damage = (Float::from_int(proj.damage) * 1.5).to_int()
      }
    }
  } else {
    // Melee: check enemies in arc
    let range = stats.range
    let damage = (Float::from_int(stats.base_damage) *
    p.damage_mult *
    bonus_mult).to_int()
    let (s, roll) = @types.rng_next(game.rng_state)
    game.rng_state = s
    let is_crit = roll < p.crit_chance + stats.crit_bonus + assassin_crit_bonus
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
      let hit_range = range +
        @data.get_enemy_stats(e.kind, game.floor_num).radius
      if d2 <= hit_range * hit_range {
        // Cleave synergy: skip arc check and hit all enemies in range
        if syn.cleave {
          apply_damage_to_enemy(game, i, final_damage, is_crit, stats.knockback)
        } else {
          // Check angle (within arc)
          let dx = e.x - p.x
          let dy = e.y - p.y
          let (ndx, ndy) = @types.normalize(dx, dy)
          let dot = ndx * p.facing_x + ndy * p.facing_y
          let half_arc = stats.arc_angle / 2.0 / 180.0 * 3.14159
          let arc_cos = Float::from_double(@math.cos(half_arc.to_double()))
          if dot >= arc_cos || stats.arc_angle >= 360.0 {
            apply_damage_to_enemy(
              game,
              i,
              final_damage,
              is_crit,
              stats.knockback,
            )
          }
        }
      }
    }
  }
}
