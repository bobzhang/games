// Enemy AI and behavior

///|
/// Updates all active enemy AI, movement, firing, and turret logic.
pub fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let px = game.player.x
  let py = game.player.y
  let pz = game.player.z

  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !e.active {
      continue
    }

    // Shield regen for enemies that have shields
    // Capital ship phase: no shield regen below 66% HP
    let capital_lost_shields = e.kind == @types.enemy_capital &&
      e.hp < e.max_hp * @types.capital_phase_shield_loss
    if e.shield_hp < e.max_shield_hp &&
      e.max_shield_hp > 0.0 &&
      !capital_lost_shields {
      e.shield_hp += 1.0 * dt
      if e.shield_hp > e.max_shield_hp {
        e.shield_hp = e.max_shield_hp
      }
    }

    // Direction to player
    let dx = px - e.x
    let dy = py - e.y
    let dz = pz - e.z
    let dist = @types.distance3d(e.x, e.y, e.z, px, py, pz)

    // AI state machine
    game.update_ai_state(i, dist, dt)

    // Evasion override: if this enemy is the player's locked target, evade
    // Only small craft (fighters, interceptors) evade - capital ships and bombers are too large
    let is_targeted = game.target_idx == i && game.target_lock_timer > 1.0
    let is_small_craft = e.kind == @types.enemy_fighter ||
      e.kind == @types.enemy_interceptor
    if is_small_craft && is_targeted && game.ai_difficulty >= 1 {
      game.apply_evasion_behavior(i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_fighter {
      game.update_fighter_ai(i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_interceptor {
      game.update_interceptor_ai(i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_bomber {
      game.update_bomber_ai(i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_cruiser {
      game.update_cruiser_ai(i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_capital {
      game.update_capital_ai(i, dx, dy, dz, dist, dt)
    }

    // Formation flying: wing-pair cohesion
    if e.squad_id >= 0 && game.ai_difficulty >= 1 {
      game.apply_wing_pair_cohesion(i, dt)
    }

    // Move
    e.x += e.vx * dt
    e.y += e.vy * dt
    e.z += e.vz * dt

    // Wrap
    e.x = @types.wrap_coord(e.x)
    e.y = @types.wrap_coord(e.y)
    e.z = @types.wrap_coord(e.z)

    // Fire timer with difficulty-scaled rates and firing cone
    e.fire_timer -= dt
    if e.fire_timer <= 0.0 && dist < 150.0 {
      // Only fire in combat states
      let in_combat = e.ai_state == Attack ||
        e.ai_state == Chase ||
        e.ai_state == FireBurst
      if in_combat && is_in_firing_cone(e, dx, dy, dz, dist) {
        game.enemy_fire(i, dx, dy, dz, dist)
        let base_rate : Float = if e.kind == @types.enemy_fighter {
          @types.fighter_fire_rate
        } else if e.kind == @types.enemy_interceptor {
          @types.interceptor_fire_rate
        } else if e.kind == @types.enemy_bomber {
          @types.bomber_fire_rate
        } else if e.kind == @types.enemy_cruiser {
          @types.cruiser_fire_rate
        } else {
          @types.capital_fire_rate
        }
        let rate = difficulty_adjusted_fire_rate(base_rate, game.ai_difficulty)
        e.fire_timer = rate + @types.rand_rangef(game, -0.3, 0.5)
      } else {
        e.fire_timer = 0.5
      }
    }

    // Capital ship turrets (phase transitions affect turret count)
    if e.kind == @types.enemy_capital && dist < 200.0 {
      let hp_pct = e.hp / e.max_hp
      let in_slow_phase = hp_pct < @types.capital_phase_slow
      let in_death_spiral = hp_pct < @types.capital_phase_death_spiral
      e.turret_timer_1 -= dt
      e.turret_timer_2 -= dt
      // Turret 1 always fires unless in death spiral
      if e.turret_timer_1 <= 0.0 && !in_death_spiral {
        game.capital_turret_fire(i, dx, dy, dz, dist, 1)
        e.turret_timer_1 = 1.5 + @types.rand_rangef(game, 0.0, 1.0)
      }
      // Turret 2 stops below 33% HP
      if e.turret_timer_2 <= 0.0 && !in_slow_phase {
        game.capital_turret_fire(i, dx, dy, dz, dist, 2)
        e.turret_timer_2 = 2.0 + @types.rand_rangef(game, 0.0, 1.0)
      }
      // Death spiral: spinning, trailing fire
      if in_death_spiral {
        e.yaw += 1.5 * dt
        if game.frame_counter % 4 == 0 {
          @types.spawn_particles(game, e.x, e.y, e.z, 2, 255, 150, 50)
        }
      } else if in_slow_phase {
        // Slow phase: reduced speed, smoke
        e.vx *= 0.98
        e.vy *= 0.98
        e.vz *= 0.98
        if game.frame_counter % 8 == 0 {
          @types.spawn_particles(game, e.x, e.y, e.z, 1, 80, 80, 80)
        }
      }
    }
  }
}

///|
/// Returns true if target is within the enemy's forward firing cone.
fn is_in_firing_cone(
  e : @types.Enemy,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
) -> Bool {
  if dist < 0.1 {
    return true
  }
  // Enemy forward direction from its yaw/pitch
  let efwd = @types.forward_dir(e.yaw, e.pitch)
  let inv_dist : Float = 1.0F / dist
  let to_target_x = dx * inv_dist
  let to_target_y = dy * inv_dist
  let to_target_z = dz * inv_dist
  let dot = @types.dot3d(
    efwd.0,
    efwd.1,
    efwd.2,
    to_target_x,
    to_target_y,
    to_target_z,
  )
  // cos(30 deg) ~ 0.866; using the cone constant
  dot > @math.cosf(@types.enemy_fire_cone_half)
}

///|
/// Returns true if enemy has overshot the player (enemy is now in front of target).
fn has_overshot_target(
  e : @types.Enemy,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
) -> Bool {
  if dist > @types.overshoot_distance {
    return false
  }
  // Check if the enemy's velocity is carrying it away from the player
  let efwd = @types.forward_dir(e.yaw, e.pitch)
  let dot = @types.dot3d(efwd.0, efwd.1, efwd.2, dx, dy, dz)
  // If forward direction points away from target (negative dot), we overshot
  dot < 0.0
}

///|
fn @types.Game::update_ai_state(
  game : @types.Game,
  idx : Int,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  e.ai_timer -= dt

  if e.ai_timer > 0.0 {
    return
  }

  let hp_pct = e.hp / e.max_hp
  let is_fighter_type = e.kind == @types.enemy_fighter ||
    e.kind == @types.enemy_interceptor

  // State transitions
  match e.ai_state {
    Idle =>
      if dist < e.detect_range {
        e.ai_state = Chase
        e.ai_timer = 1.0
      } else {
        e.ai_state = Patrol
        e.ai_timer = 2.0
      }
    Patrol =>
      if dist < e.detect_range {
        e.ai_state = Chase
        e.ai_timer = 0.5
      } else {
        e.ai_timer = @types.rand_rangef(game, 1.0, 3.0)
      }
    Chase =>
      if hp_pct < e.flee_threshold {
        e.ai_state = Flee
        e.ai_timer = 2.0
      } else if is_fighter_type && dist < @types.fighter_attack_range {
        // Fighters enter dogfight attack run instead of generic Attack
        e.ai_state = LineUp
        e.ai_timer = @types.rand_rangef(game, 1.5, 3.0)
      } else if dist < @types.fighter_attack_range {
        e.ai_state = Attack
        e.ai_timer = @types.rand_rangef(game, 1.0, 3.0)
      } else if dist > e.detect_range * 1.5 {
        e.ai_state = Patrol
        e.ai_timer = 1.0
      } else {
        e.ai_timer = 0.5
      }
    Attack =>
      if hp_pct < e.flee_threshold {
        e.ai_state = Flee
        e.ai_timer = 2.0
      } else if hp_pct < @types.fighter_evade_hp_pct &&
        @types.rand_bool(game, 0.4) {
        e.ai_state = Evade
        e.ai_timer = @types.rand_rangef(game, 1.5, 3.0)
      } else if dist > @types.fighter_attack_range * 1.5 {
        e.ai_state = Chase
        e.ai_timer = 0.5
      } else {
        e.ai_timer = @types.rand_rangef(game, 0.8, 2.0)
      }
    Evade =>
      if hp_pct < e.flee_threshold {
        e.ai_state = Flee
        e.ai_timer = 2.0
      } else if dist > 60.0 {
        e.ai_state = Chase
        e.ai_timer = 1.0
      } else {
        e.ai_timer = @types.rand_rangef(game, 1.0, 2.0)
      }
    Flee =>
      if dist > 200.0 {
        e.ai_state = Patrol
        e.ai_timer = 3.0
      } else {
        e.ai_timer = 1.0
      }
    Formation =>
      if dist < e.detect_range * 0.8 {
        e.ai_state = Chase
        e.ai_timer = 0.5
      } else {
        e.ai_timer = 1.0
      }
    // Dogfight attack-run states
    LineUp =>
      if hp_pct < e.flee_threshold {
        e.ai_state = Flee
        e.ai_timer = 2.0
      } else if dist < @types.attack_run_trail_dist * 0.5 {
        // Close enough, commit to firing pass
        e.ai_state = FireBurst
        e.ai_timer = @types.fire_burst_duration
      } else if dist > @types.fighter_attack_range * 2.0 {
        e.ai_state = Chase
        e.ai_timer = 0.5
      } else {
        e.ai_timer = 0.3
      }
    FireBurst => {
      // Timer expired or we overshot
      e.ai_state = BreakAway
      e.ai_timer = @types.break_away_duration
    }
    BreakAway => {
      e.ai_state = Reposition
      e.ai_timer = @types.reposition_duration
    }
    Reposition => {
      // Loop complete, start a new approach
      e.ai_state = Chase
      e.ai_timer = 0.5
    }
    OvershootRecover =>
      // Pull away then re-engage
      if dist > 50.0 {
        e.ai_state = Chase
        e.ai_timer = 0.5
      } else {
        e.ai_timer = 0.5
      }
    PincerFlank =>
      if hp_pct < e.flee_threshold {
        e.ai_state = Flee
        e.ai_timer = 2.0
      } else if dist < @types.fighter_attack_range * 0.6 {
        e.ai_state = FireBurst
        e.ai_timer = @types.fire_burst_duration
      } else {
        e.ai_timer = 0.5
      }
  }
}

///|
/// Returns the speed for an enemy kind, applying mission difficulty scaling.
fn enemy_speed_scaled(game : @types.Game, kind : Int) -> Float {
  let base : Float = if kind == @types.enemy_fighter {
    @types.fighter_speed
  } else if kind == @types.enemy_interceptor {
    @types.interceptor_speed
  } else if kind == @types.enemy_bomber {
    @types.bomber_speed
  } else if kind == @types.enemy_cruiser {
    @types.cruiser_speed
  } else {
    @types.capital_speed
  }
  base * @types.mission_difficulty_speed_mult(game.current_mission)
}

///|
/// Updates facing direction from velocity for an enemy.
fn update_enemy_facing(e : @types.Enemy) -> Unit {
  let vel_len = @types.length3d(e.vx, e.vy, e.vz)
  if vel_len > 1.0 {
    e.yaw = @math.atan2f(e.vx, e.vz)
    e.pitch = @math.atan2f(e.vy, (e.vx * e.vx + e.vz * e.vz).sqrt())
  }
}

///|
fn @types.Game::update_fighter_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = enemy_speed_scaled(game, e.kind)

  match e.ai_state {
    Patrol => {
      // Patrol: move toward patrol point
      let pdx = e.patrol_x - e.x
      let pdy = e.patrol_y - e.y
      let pdz = e.patrol_z - e.z
      let pdist = @types.length3d(pdx, pdy, pdz)
      if pdist > 5.0 {
        let norm = @types.normalize3d(pdx, pdy, pdz)
        e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.5, 1.5 * dt)
        e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.5, 1.5 * dt)
        e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.5, 1.5 * dt)
      } else {
        e.vx = @types.lerpf(e.vx, 0.0, 1.0 * dt)
        e.vy = @types.lerpf(e.vy, 0.0, 1.0 * dt)
        e.vz = @types.lerpf(e.vz, 0.0, 1.0 * dt)
      }
    }
    Chase => {
      // Chase: approach player
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 2.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 2.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 2.0 * dt)
    }
    Attack =>
      if dist > 60.0 {
        let norm = @types.normalize3d(dx, dy, dz)
        e.vx = @types.lerpf(e.vx, norm.0 * spd, 2.0 * dt)
        e.vy = @types.lerpf(e.vy, norm.1 * spd, 2.0 * dt)
        e.vz = @types.lerpf(e.vz, norm.2 * spd, 2.0 * dt)
      } else if dist < 15.0 {
        let norm = @types.normalize3d(-dx, -dy, -dz)
        e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.3, 3.0 * dt)
        e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.3, 3.0 * dt)
        e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.3, 3.0 * dt)
      } else {
        let norm = @types.normalize3d(dx, dy, dz)
        let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)
        let orbit = @types.normalize3d(
          cross.0 + norm.0 * 0.3,
          cross.1 + norm.1 * 0.3,
          cross.2 + norm.2 * 0.3,
        )
        e.vx = @types.lerpf(e.vx, orbit.0 * spd, 2.0 * dt)
        e.vy = @types.lerpf(e.vy, orbit.1 * spd, 2.0 * dt)
        e.vz = @types.lerpf(e.vz, orbit.2 * spd, 2.0 * dt)
      }
    // --- Dogfight attack-run states ---
    LineUp => {
      // Maneuver to get behind the player, approaching from the rear
      // Target a point behind the player (opposite of player's velocity)
      let pvx = game.player.vx
      let pvy = game.player.vy
      let pvz = game.player.vz
      let pv_len = @types.length3d(pvx, pvy, pvz)
      let trail_x : Float = if pv_len > 1.0 {
        game.player.x - pvx / pv_len * @types.attack_run_trail_dist
      } else {
        game.player.x -
        dx / @types.maxf(dist, 1.0) * @types.attack_run_trail_dist
      }
      let trail_y : Float = if pv_len > 1.0 {
        game.player.y - pvy / pv_len * @types.attack_run_trail_dist
      } else {
        game.player.y
      }
      let trail_z : Float = if pv_len > 1.0 {
        game.player.z - pvz / pv_len * @types.attack_run_trail_dist
      } else {
        game.player.z -
        dz / @types.maxf(dist, 1.0) * @types.attack_run_trail_dist
      }
      let tdx = trail_x - e.x
      let tdy = trail_y - e.y
      let tdz = trail_z - e.z
      let trail_norm = @types.normalize3d(tdx, tdy, tdz)
      e.vx = @types.lerpf(e.vx, trail_norm.0 * spd * 1.1, 2.5 * dt)
      e.vy = @types.lerpf(e.vy, trail_norm.1 * spd * 1.1, 2.5 * dt)
      e.vz = @types.lerpf(e.vz, trail_norm.2 * spd * 1.1, 2.5 * dt)
      // Check for overshoot during line-up
      if has_overshot_target(e, dx, dy, dz, dist) {
        e.ai_state = OvershootRecover
        e.ai_timer = 2.0
      }
    }
    FireBurst => {
      // Committed firing pass: fly straight toward target at speed
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.2, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.2, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.2, 3.0 * dt)
      // Check for overshoot
      if has_overshot_target(e, dx, dy, dz, dist) {
        e.ai_state = OvershootRecover
        e.ai_timer = 2.0
      }
    }
    BreakAway => {
      // Hard break turn: sharp direction change away from target
      let norm = @types.normalize3d(-dx, -dy, -dz)
      // Add perpendicular component for a dramatic break
      let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)
      let side : Float = if idx % 2 == 0 { 1.0 } else { -1.0 }
      let break_dir = @types.normalize3d(
        norm.0 + cross.0 * side * 0.8,
        norm.1 + 0.3,
        norm.2 + cross.2 * side * 0.8,
      )
      e.vx = @types.lerpf(e.vx, break_dir.0 * spd * 1.4, 4.0 * dt)
      e.vy = @types.lerpf(e.vy, break_dir.1 * spd * 1.4, 4.0 * dt)
      e.vz = @types.lerpf(e.vz, break_dir.2 * spd * 1.4, 4.0 * dt)
    }
    Reposition => {
      // Loop back: climb away then turn back toward target
      let norm = @types.normalize3d(dx, dy, dz)
      // Fly a wide arc: away with upward pull, gradually curving back
      let progress : Float = 1.0F - e.ai_timer / @types.reposition_duration
      let back_blend = progress * progress // start pulling back toward target
      let away_x = -norm.0 * (1.0F - back_blend) + norm.0 * back_blend
      let away_y = 0.4F * (1.0F - back_blend) + norm.1 * back_blend
      let away_z = -norm.2 * (1.0F - back_blend) + norm.2 * back_blend
      let dir = @types.normalize3d(away_x, away_y, away_z)
      e.vx = @types.lerpf(e.vx, dir.0 * spd, 2.0 * dt)
      e.vy = @types.lerpf(e.vy, dir.1 * spd, 2.0 * dt)
      e.vz = @types.lerpf(e.vz, dir.2 * spd, 2.0 * dt)
    }
    OvershootRecover => {
      // Pull up and away from target, then re-engage
      let norm = @types.normalize3d(-dx, -dy + 10.0, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.3, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.3, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.3, 3.0 * dt)
    }
    PincerFlank => {
      // Flanking from the opposite side: move to a point perpendicular to player
      let norm = @types.normalize3d(dx, dy, dz)
      let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)
      let side : Float = if e.formation_index % 2 == 0 { 1.0 } else { -1.0 }
      let flank_dir = @types.normalize3d(
        cross.0 * side + norm.0 * 0.4,
        norm.1 * 0.2,
        cross.2 * side + norm.2 * 0.4,
      )
      e.vx = @types.lerpf(e.vx, flank_dir.0 * spd * 1.1, 2.5 * dt)
      e.vy = @types.lerpf(e.vy, flank_dir.1 * spd * 1.1, 2.5 * dt)
      e.vz = @types.lerpf(e.vz, flank_dir.2 * spd * 1.1, 2.5 * dt)
    }
    Evade => {
      let norm = @types.normalize3d(dx, dy, dz)
      let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)
      let jink_dir = Float::from_int(game.frame_counter % 60)
      let jx = cross.0 * @math.sinf(jink_dir * 0.2) + norm.0 * -0.3
      let jy = @math.cosf(jink_dir * 0.15) * 0.5
      let jz = cross.2 * @math.sinf(jink_dir * 0.2) + norm.2 * -0.3
      let jnorm = @types.normalize3d(jx, jy, jz)
      e.vx = @types.lerpf(e.vx, jnorm.0 * spd * 1.2, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, jnorm.1 * spd * 1.2, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, jnorm.2 * spd * 1.2, 3.0 * dt)
    }
    Flee => {
      let norm = @types.normalize3d(-dx, -dy, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.5, 2.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.5, 2.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.5, 2.0 * dt)
    }
    _ => {
      e.vx = @types.lerpf(e.vx, 0.0, 0.5 * dt)
      e.vy = @types.lerpf(e.vy, 0.0, 0.5 * dt)
      e.vz = @types.lerpf(e.vz, 0.0, 0.5 * dt)
    }
  }

  // Update facing
  update_enemy_facing(e)
  ignore(game)
  ignore(dist)
}

///|
fn @types.Game::update_interceptor_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = enemy_speed_scaled(game, e.kind)

  // Interceptors: fast hit-and-run with dogfight states
  match e.ai_state {
    Patrol | Idle => {
      let pdx = e.patrol_x - e.x
      let pdy = e.patrol_y - e.y
      let pdz = e.patrol_z - e.z
      let pdist = @types.length3d(pdx, pdy, pdz)
      if pdist > 5.0 {
        let norm = @types.normalize3d(pdx, pdy, pdz)
        e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.4, 2.0 * dt)
        e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.4, 2.0 * dt)
        e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.4, 2.0 * dt)
      }
    }
    Chase | Attack => {
      // Full speed toward player
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 3.0 * dt)
      // If very close, trigger overshoot
      if has_overshot_target(e, dx, dy, dz, dist) {
        e.ai_state = OvershootRecover
        e.ai_timer = 1.5
      }
    }
    LineUp => {
      // Interceptors line up faster due to speed
      let pvx = game.player.vx
      let pvy = game.player.vy
      let pvz = game.player.vz
      let pv_len = @types.length3d(pvx, pvy, pvz)
      let trail_dist = @types.attack_run_trail_dist * 0.7
      let tx : Float = if pv_len > 1.0 {
        game.player.x - pvx / pv_len * trail_dist
      } else {
        game.player.x
      }
      let ty : Float = if pv_len > 1.0 {
        game.player.y - pvy / pv_len * trail_dist
      } else {
        game.player.y
      }
      let tz : Float = if pv_len > 1.0 {
        game.player.z - pvz / pv_len * trail_dist
      } else {
        game.player.z
      }
      let tdx = tx - e.x
      let tdy = ty - e.y
      let tdz = tz - e.z
      let tn = @types.normalize3d(tdx, tdy, tdz)
      e.vx = @types.lerpf(e.vx, tn.0 * spd * 1.3, 3.5 * dt)
      e.vy = @types.lerpf(e.vy, tn.1 * spd * 1.3, 3.5 * dt)
      e.vz = @types.lerpf(e.vz, tn.2 * spd * 1.3, 3.5 * dt)
    }
    FireBurst => {
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.4, 4.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.4, 4.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.4, 4.0 * dt)
      if has_overshot_target(e, dx, dy, dz, dist) {
        e.ai_state = OvershootRecover
        e.ai_timer = 1.5
      }
    }
    BreakAway => {
      let norm = @types.normalize3d(-dx, -dy + 5.0, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.5, 4.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.5, 4.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.5, 4.0 * dt)
    }
    Reposition => {
      let norm = @types.normalize3d(dx, dy, dz)
      let progress : Float = 1.0F - e.ai_timer / @types.reposition_duration
      let blend = progress * progress
      let dir = @types.normalize3d(
        -norm.0 * (1.0F - blend) + norm.0 * blend,
        0.3F * (1.0F - blend),
        -norm.2 * (1.0F - blend) + norm.2 * blend,
      )
      e.vx = @types.lerpf(e.vx, dir.0 * spd * 1.2, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, dir.1 * spd * 1.2, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, dir.2 * spd * 1.2, 3.0 * dt)
    }
    OvershootRecover => {
      let norm = @types.normalize3d(-dx, -dy + 8.0, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.3, 4.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.3, 4.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.3, 4.0 * dt)
    }
    PincerFlank => {
      let norm = @types.normalize3d(dx, dy, dz)
      let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)
      let side : Float = if e.formation_index % 2 == 0 { 1.0 } else { -1.0 }
      let fd = @types.normalize3d(
        cross.0 * side + norm.0 * 0.5,
        0.0,
        cross.2 * side + norm.2 * 0.5,
      )
      e.vx = @types.lerpf(e.vx, fd.0 * spd * 1.2, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, fd.1 * spd * 1.2, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, fd.2 * spd * 1.2, 3.0 * dt)
    }
    Evade => {
      let norm = @types.normalize3d(-dx, -dy + 5.0, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.3, 4.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.3, 4.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.3, 4.0 * dt)
    }
    Flee => {
      let norm = @types.normalize3d(-dx, -dy, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.5, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.5, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.5, 3.0 * dt)
    }
    _ => ()
  }

  update_enemy_facing(e)
  ignore(game)
  ignore(dist)
}

///|
fn @types.Game::update_bomber_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = enemy_speed_scaled(game, e.kind)

  // Bombers are slow but try to get firing angles. They stay at medium range.
  if e.ai_state == Patrol || e.ai_state == Idle {
    let pdx = e.patrol_x - e.x
    let pdy = e.patrol_y - e.y
    let pdz = e.patrol_z - e.z
    let pdist = @types.length3d(pdx, pdy, pdz)
    if pdist > 5.0 {
      let norm = @types.normalize3d(pdx, pdy, pdz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.3, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.3, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.3, 1.0 * dt)
    }
  } else if e.ai_state == Chase {
    // Slow approach
    let norm = @types.normalize3d(dx, dy, dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.5 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.5 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.5 * dt)
  } else if e.ai_state == Attack {
    // Hold distance at ~60 units
    if dist > 80.0 {
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.0 * dt)
    } else if dist < 40.0 {
      let norm = @types.normalize3d(-dx, -dy, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.5 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.5 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.5 * dt)
    } else {
      // Drift and fire
      e.vx = @types.lerpf(e.vx, 0.0, 0.5 * dt)
      e.vy = @types.lerpf(e.vy, 0.0, 0.5 * dt)
      e.vz = @types.lerpf(e.vz, 0.0, 0.5 * dt)
    }
  } else if e.ai_state == Evade || e.ai_state == Flee {
    let norm = @types.normalize3d(-dx, -dy, -dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.2, 1.5 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.2, 1.5 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.2, 1.5 * dt)
  }

  // Face player
  e.yaw = @math.atan2f(dx, dz)
  e.pitch = @math.atan2f(dy, @math.hypotf(dx, dz))
  ignore(game)
  ignore(dist)
}

///|
fn @types.Game::update_cruiser_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = enemy_speed_scaled(game, e.kind)

  // Cruisers slowly approach and hold distance
  if e.ai_state == Patrol || e.ai_state == Idle {
    // Drift slowly
    e.vx = @types.lerpf(e.vx, 0.0, 0.3 * dt)
    e.vy = @types.lerpf(e.vy, 0.0, 0.3 * dt)
    e.vz = @types.lerpf(e.vz, 0.0, 0.3 * dt)
  } else if e.ai_state == Chase || e.ai_state == Attack {
    if dist > 60.0 {
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.0 * dt)
    } else if dist < 30.0 {
      let norm = @types.normalize3d(-dx, -dy, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.5, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.5, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.5, 1.0 * dt)
    } else {
      // Hold position
      e.vx = @types.lerpf(e.vx, 0.0, 0.5 * dt)
      e.vy = @types.lerpf(e.vy, 0.0, 0.5 * dt)
      e.vz = @types.lerpf(e.vz, 0.0, 0.5 * dt)
    }
  } else if e.ai_state == Evade || e.ai_state == Flee {
    let norm = @types.normalize3d(-dx, -dy, -dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.0 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.0 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.0 * dt)
  }

  // Face player
  e.yaw = @math.atan2f(dx, dz)
  e.pitch = @math.atan2f(dy, @math.hypotf(dx, dz))
  ignore(game)
  ignore(dist)
}

///|
fn @types.Game::update_capital_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = enemy_speed_scaled(game, e.kind)

  // Capital ships are slow and mostly stationary. They rely on turrets.
  if dist > 100.0 {
    // Very slowly approach
    let norm = @types.normalize3d(dx, dy, dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.5, 0.5 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.3, 0.5 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.5, 0.5 * dt)
  } else {
    // Hold position, slight drift
    e.vx = @types.lerpf(e.vx, 0.0, 0.3 * dt)
    e.vy = @types.lerpf(e.vy, 0.0, 0.3 * dt)
    e.vz = @types.lerpf(e.vz, 0.0, 0.3 * dt)
  }

  // Slowly rotate to face player
  let target_yaw = @math.atan2f(dx, dz)
  e.yaw = @types.lerpf(e.yaw, target_yaw, 0.5 * dt)
  e.pitch = @types.lerpf(
    e.pitch,
    @math.atan2f(dy, @math.hypotf(dx, dz)),
    0.3 * dt,
  )
  ignore(game)
  ignore(dist)
}

///|
fn @types.Game::enemy_fire(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
) -> Unit {
  let e = game.enemies[idx]
  let pidx = @types.alloc_projectile(game)
  if pidx < 0 {
    return
  }
  let proj = game.projectiles[pidx]

  // Lead targeting for smarter aim
  let lead = @types.lead_target(
    e.x,
    e.y,
    e.z,
    game.player.x,
    game.player.y,
    game.player.z,
    game.player.vx,
    game.player.vy,
    game.player.vz,
    80.0,
  )

  let spd : Float = 80.0
  proj.active = true
  proj.from_player = false
  proj.x = e.x + lead.0 * e.size
  proj.y = e.y + lead.1 * e.size
  proj.z = e.z + lead.2 * e.size
  proj.vx = lead.0 * spd
  proj.vy = lead.1 * spd
  proj.vz = lead.2 * spd
  proj.piercing = false

  if e.kind == @types.enemy_bomber {
    // Bombers: always plasma but better at higher difficulty
    proj.kind = Plasma
    proj.damage = @types.bomber_damage
    proj.life = 4.0
    proj.target_idx = -1
    proj.size = 0.2
    proj.fuel = 0.0
  } else if e.kind == @types.enemy_capital {
    // Capital ships: missiles at long range (difficulty 2+), lasers at close range
    if dist > 100.0 && game.ai_difficulty >= 2 {
      proj.kind = Missile
      proj.damage = @types.capital_damage + @types.capital_damage
      proj.life = 6.0
      proj.target_idx = -1
      proj.size = 0.15
      proj.fuel = @types.missile_fuel
    } else {
      proj.kind = Laser
      proj.damage = @types.capital_damage
      proj.life = 4.0
      proj.target_idx = -1
      proj.size = 0.12
      proj.fuel = 0.0
    }
  } else if e.kind == @types.enemy_cruiser &&
    dist > 50.0 &&
    game.ai_difficulty >= 1 {
    // Cruisers: plasma at long range on higher difficulty
    proj.kind = Plasma
    proj.damage = @types.cruiser_damage + @types.cruiser_damage
    proj.life = 4.0
    proj.target_idx = -1
    proj.size = 0.15
    proj.fuel = 0.0
  } else {
    proj.kind = Laser
    let dmg : Float = if e.kind == @types.enemy_fighter {
      @types.fighter_damage
    } else if e.kind == @types.enemy_interceptor {
      @types.interceptor_damage
    } else {
      @types.cruiser_damage
    }
    // Higher difficulty enemies deal more damage
    let acc = @types.ai_difficulty_accuracy(game.ai_difficulty)
    proj.damage = dmg + dmg * acc
    proj.life = 3.0
    proj.target_idx = -1
    proj.size = 0.08
    proj.fuel = 0.0
  }
  ignore(idx)
  ignore(dist)
  ignore(dx)
  ignore(dy)
  ignore(dz)
}

///|
fn @types.Game::capital_turret_fire(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  turret : Int,
) -> Unit {
  let e = game.enemies[idx]
  let pidx = @types.alloc_projectile(game)
  if pidx < 0 {
    return
  }
  let proj = game.projectiles[pidx]
  let norm = @types.normalize3d(dx, dy, dz)

  // Turret offset based on turret number
  let turret_off_x : Float = if turret == 1 { 3.0 } else { -3.0 }
  let turret_off_y : Float = if turret == 1 { 1.0 } else { -1.0 }

  let spd : Float = 90.0
  proj.active = true
  proj.kind = Laser
  proj.from_player = false
  proj.x = e.x + turret_off_x
  proj.y = e.y + turret_off_y
  proj.z = e.z
  proj.vx = norm.0 * spd
  proj.vy = norm.1 * spd
  proj.vz = norm.2 * spd
  proj.damage = @types.capital_damage * 0.6
  proj.life = 3.5
  proj.target_idx = -1
  proj.size = 0.1
  proj.fuel = 0.0
  proj.piercing = false
  ignore(dist)
}

///|
/// Applies `damage` to the enemy at `idx`, absorbing with shields first, and handles destruction.
pub fn damage_enemy(game : @types.Game, idx : Int, damage : Float) -> Unit {
  let e = game.enemies[idx]

  // Apply damage to shield first
  let mut remaining_damage = damage
  if e.shield_hp > 0.0 {
    let absorbed = @types.minf(e.shield_hp, remaining_damage)
    e.shield_hp -= absorbed
    remaining_damage = remaining_damage - absorbed
    @types.spawn_shield_hit(game, e.x, e.y, e.z, 3)
  }

  e.hp -= remaining_damage
  e.damage_flash = @types.damage_flash_duration

  // Spawn floating damage number
  @types.spawn_damage_number(
    game,
    e.x,
    e.y + e.size,
    e.z,
    damage.to_int(),
    255,
    255,
    100,
  )

  if e.hp <= 0.0 {
    e.active = false

    // Score with combo multiplier
    let base_score = e.score_value
    let combo_score = (Float::from_int(base_score) * game.combo_multiplier).to_int()
    game.score += combo_score
    game.total_kills += 1
    game.mission_kills += 1
    game.enemies_remaining -= 1
    game.player.kills += 1
    if game.enemies_remaining < 0 {
      game.enemies_remaining = 0
    }

    // Register combo
    @types.register_kill_combo(game)

    // Kill feed
    let type_name = @types.enemy_type_name(e.kind)
    let feed_text = "\{type_name} +\{combo_score}"
    let fr : Int = if e.kind == @types.enemy_capital { 255 } else { 200 }
    let fg : Int = if e.kind == @types.enemy_capital { 255 } else { 200 }
    @types.add_kill_feed(game, feed_text, fr, fg, 100)

    // Directional explosion using velocity as impact direction
    let exp_count : Int = if e.kind == @types.enemy_capital {
      50
    } else if e.kind == @types.enemy_cruiser {
      30
    } else if e.kind == @types.enemy_bomber {
      20
    } else {
      15
    }
    let r : Int = if e.kind == @types.enemy_fighter { 255 } else { 200 }
    let g : Int = if e.kind == @types.enemy_fighter { 150 } else { 100 }
    // Use direction from player to enemy as explosion direction
    let exp_dx = e.x - game.player.x
    let exp_dy = e.y - game.player.y
    let exp_dz = e.z - game.player.z
    @types.spawn_directional_explosion(
      game,
      e.x,
      e.y,
      e.z,
      exp_dx,
      exp_dy,
      exp_dz,
      exp_count,
      r,
      g,
      50,
    )

    // Burning debris with fire trails
    let debris_count : Int = if e.kind == @types.enemy_capital {
      5
    } else if e.kind == @types.enemy_cruiser {
      4
    } else {
      3
    }
    let dr : Int = if e.kind == @types.enemy_fighter { 220 } else { 150 }
    let dg : Int = if e.kind == @types.enemy_fighter { 60 } else { 80 }
    @types.spawn_burning_debris(game, e.x, e.y, e.z, debris_count, dr, dg, 60)

    // Shock rings for large enemy deaths
    if e.kind == @types.enemy_capital {
      @types.spawn_shock_ring(game, e.x, e.y, e.z, 60.0, 2.0, 255, 180, 50)
      @types.spawn_shock_ring(game, e.x, e.y, e.z, 40.0, 1.5, 255, 100, 30)
    } else if e.kind == @types.enemy_cruiser {
      @types.spawn_shock_ring(game, e.x, e.y, e.z, 30.0, 1.2, 255, 150, 50)
    }

    // Chance to drop power-up
    if @types.rand_bool(game, 0.25) {
      let pu_idx = @types.alloc_powerup(game)
      if pu_idx >= 0 {
        let pu = game.powerups[pu_idx]
        pu.active = true
        pu.kind = @types.powerup_kind_from_int(@types.rand_range(game, 0, 3))
        pu.x = e.x
        pu.y = e.y
        pu.z = e.z
        pu.bob_timer = 0.0
        pu.spin_angle = 0.0
        pu.life = 30.0
      }
    }

    // Camera shake for large kills
    if e.kind == @types.enemy_capital {
      game.camera_shake = @types.maxf(game.camera_shake, 1.5)
      game.screen_flash = 0.5
      game.flash_r = 255
      game.flash_g = 200
      game.flash_b = 100
    } else if e.kind == @types.enemy_cruiser {
      game.camera_shake = @types.maxf(game.camera_shake, 0.8)
    }

    // Check if target was destroyed
    if game.target_idx == idx {
      game.target_idx = -1
    }

    // Update objectives
    @types.check_objective_progress(game, DestroyAll, 1)
    @types.check_objective_progress(game, DestroyCount, 1)
  }
}

///|
/// Updates all active asteroids including movement, rotation, and collision detection.
pub fn update_asteroids(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.asteroids.length() {
    let a = game.asteroids[i]
    if !a.active {
      continue
    }
    // Move
    a.x += a.vx * dt
    a.y += a.vy * dt
    a.z += a.vz * dt
    // Rotate
    a.rot_x += a.rot_speed * dt
    a.rot_y += a.rot_speed * 0.7 * dt
    a.rot_z += a.rot_speed * 0.4 * dt
    // Wrap
    a.x = @types.wrap_coord(a.x)
    a.y = @types.wrap_coord(a.y)
    a.z = @types.wrap_coord(a.z)
    // Check collision with player
    let dist = @types.distance3d(
      a.x,
      a.y,
      a.z,
      game.player.x,
      game.player.y,
      game.player.z,
    )
    if dist < a.size + 1.5 {
      damage_player(game, 20.0)
      a.hp -= 30.0
      if a.hp <= 0.0 {
        game.destroy_asteroid(i)
      }
    }

    // Check collision with enemies
    for j in 0..<game.enemies.length() {
      let e = game.enemies[j]
      if !e.active {
        continue
      }
      let edist = @types.distance3d(a.x, a.y, a.z, e.x, e.y, e.z)
      if edist < a.size + e.size * 0.5 {
        e.hp -= 10.0
        a.hp -= 10.0
        if e.hp <= 0.0 {
          damage_enemy(game, j, 0.0)
        }
        if a.hp <= 0.0 {
          game.destroy_asteroid(i)
          break
        }
      }
    }
  }
}

///|
fn @types.Game::destroy_asteroid(game : @types.Game, idx : Int) -> Unit {
  let a = game.asteroids[idx]
  a.active = false
  game.score += @types.asteroid_score
  @types.spawn_explosion(game, a.x, a.y, a.z, 10, 150, 130, 100)

  // Break into smaller asteroids if breakable
  if a.breakable && a.size_tier != @types.asteroid_small {
    let new_tier : Int = if a.size_tier == @types.asteroid_large {
      @types.asteroid_medium
    } else {
      @types.asteroid_small
    }
    let new_size : Float = if new_tier == @types.asteroid_medium {
      @types.asteroid_medium_size
    } else {
      @types.asteroid_small_size
    }
    let new_hp : Float = if new_tier == @types.asteroid_medium {
      @types.asteroid_medium_hp
    } else {
      @types.asteroid_small_hp
    }

    for c in 0..<@types.asteroid_break_count {
      let cidx = @types.alloc_asteroid(game)
      if cidx < 0 {
        break
      }
      let child = game.asteroids[cidx]
      child.active = true
      child.x = a.x + @types.rand_rangef(game, -1.0, 1.0)
      child.y = a.y + @types.rand_rangef(game, -1.0, 1.0)
      child.z = a.z + @types.rand_rangef(game, -1.0, 1.0)
      child.vx = a.vx + @types.rand_rangef(game, -5.0, 5.0)
      child.vy = a.vy + @types.rand_rangef(game, -3.0, 3.0)
      child.vz = a.vz + @types.rand_rangef(game, -5.0, 5.0)
      child.rot_x = @types.rand_rangef(game, 0.0, 6.28)
      child.rot_y = @types.rand_rangef(game, 0.0, 6.28)
      child.rot_z = @types.rand_rangef(game, 0.0, 6.28)
      child.rot_speed = @types.rand_rangef(game, 0.5, 2.0)
      child.hp = new_hp
      child.size = new_size
      child.size_tier = new_tier
      child.breakable = new_tier != @types.asteroid_small
      ignore(c)
    }
  }
}

///|
/// Applies `damage` to the asteroid at `idx` and destroys it if health reaches zero.
pub fn damage_asteroid(game : @types.Game, idx : Int, damage : Float) -> Unit {
  let a = game.asteroids[idx]
  a.hp -= damage
  if a.hp <= 0.0 {
    game.destroy_asteroid(idx)
  }
}

// ============================================================
// AI Improvements: Formation flying, evasion, weapon selection
// ============================================================

///|
/// Applies break-turn evasion when this enemy is the player's locked target.
/// Instead of barrel-rolling, fighters do a hard break turn: sharp perpendicular
/// direction change that makes them much harder to track.
fn @types.Game::apply_evasion_behavior(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = enemy_speed_scaled(game, e.kind)
  let evasion_skill = @types.ai_difficulty_evasion(game.ai_difficulty)
  let time_val = Float::from_int(game.frame_counter) * 0.1 +
    Float::from_int(idx) * 2.7

  let norm = @types.normalize3d(dx, dy, dz)
  let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)

  // Hard break turn: pick a sharp perpendicular direction and commit
  // Switch direction every ~1.5 seconds for unpredictability
  let break_phase = (game.frame_counter / 90 + idx) % 4
  let break_x : Float = match break_phase {
    0 => cross.0
    1 => -cross.0
    2 => cross.0 * 0.5 + 0.5
    _ => -cross.0 * 0.5 - 0.5
  }
  let break_y : Float = match break_phase {
    0 => 0.4
    1 => -0.3
    2 => 0.6
    _ => -0.5
  }
  let break_z : Float = match break_phase {
    0 => cross.2
    1 => -cross.2
    2 => cross.2 * 0.5
    _ => -cross.2 * 0.5
  }

  // Higher evasion skill means sharper breaks
  let break_strength : Float = 0.6F + evasion_skill * 0.8F
  // Oscillation overlay for extra jinking
  let jitter_x = @math.sinf(time_val * 5.0) * evasion_skill * 0.3
  let jitter_y = @math.cosf(time_val * 4.2) * evasion_skill * 0.2

  // Blend: mostly break turn with slight approach/retreat
  let approach : Float = if dist > 80.0 {
    0.3
  } else if dist < 20.0 {
    -0.6
  } else {
    0.0
  }

  let evade_dir = @types.normalize3d(
    break_x * break_strength + norm.0 * approach + jitter_x,
    break_y * break_strength + norm.1 * approach + jitter_y,
    break_z * break_strength + norm.2 * approach,
  )

  let target_spd = spd * 1.4
  e.vx = @types.lerpf(e.vx, evade_dir.0 * target_spd, 4.0 * dt)
  e.vy = @types.lerpf(e.vy, evade_dir.1 * target_spd, 4.0 * dt)
  e.vz = @types.lerpf(e.vz, evade_dir.2 * target_spd, 4.0 * dt)

  update_enemy_facing(e)
  ignore(game)
  ignore(dist)
}

///|
/// Applies wing-pair formation cohesion and pincer role assignment.
/// In a pair, one fighter engages (attacks) while the wingman flanks from the
/// opposite side. The roles swap when the flanker gets close enough.
fn @types.Game::apply_wing_pair_cohesion(
  game : @types.Game,
  idx : Int,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  if e.kind != @types.enemy_fighter && e.kind != @types.enemy_interceptor {
    return
  }
  if e.ai_state == Flee || e.ai_state == Evade || e.ai_state == OvershootRecover {
    return
  }

  let partner_form_idx = if e.formation_index % 2 == 0 {
    e.formation_index + 1
  } else {
    e.formation_index - 1
  }

  let mut partner_idx = -1
  for j in 0..<game.enemies.length() {
    if j == idx {
      continue
    }
    let other = game.enemies[j]
    if other.active &&
      other.squad_id == e.squad_id &&
      other.formation_index == partner_form_idx {
      partner_idx = j
      break
    }
  }

  if partner_idx < 0 {
    return
  }

  let partner = game.enemies[partner_idx]
  let pdx = partner.x - e.x
  let pdy = partner.y - e.y
  let pdz = partner.z - e.z
  let pdist = @types.length3d(pdx, pdy, pdz)

  let desired_dist : Float = 12.0
  if pdist < 3.0 || pdist > 60.0 {
    return
  }

  // Pincer role assignment at higher difficulty
  // Even formation_index = attacker, odd = flanker
  if game.ai_difficulty >= 2 {
    let is_flanker = e.formation_index % 2 == 1
    let partner_attacking = partner.ai_state == Attack ||
      partner.ai_state == FireBurst ||
      partner.ai_state == LineUp
    if is_flanker && partner_attacking {
      // Wingman enters pincer flanking mode
      if e.ai_state == Chase || e.ai_state == Attack || e.ai_state == LineUp {
        e.ai_state = PincerFlank
        e.ai_timer = 2.0
      }
    }
  }

  let strength : Float = Float::from_int(game.ai_difficulty + 1) * 0.08
  if pdist < desired_dist * 0.5 {
    let norm = @types.normalize3d(-pdx, -pdy, -pdz)
    e.vx = e.vx + norm.0 * strength * 10.0 * dt
    e.vy = e.vy + norm.1 * strength * 10.0 * dt
    e.vz = e.vz + norm.2 * strength * 10.0 * dt
  } else if pdist > desired_dist * 1.5 {
    let norm = @types.normalize3d(pdx, pdy, pdz)
    e.vx = e.vx + norm.0 * strength * 8.0 * dt
    e.vy = e.vy + norm.1 * strength * 8.0 * dt
    e.vz = e.vz + norm.2 * strength * 8.0 * dt
  }

  // Match partner velocity slightly
  let vel_blend : Float = strength * 0.3
  e.vx = @types.lerpf(e.vx, partner.vx, vel_blend * dt)
  e.vy = @types.lerpf(e.vy, partner.vy, vel_blend * dt)
  e.vz = @types.lerpf(e.vz, partner.vz, vel_blend * dt)
}

///|
/// Adjusts fire rate based on AI difficulty. Higher difficulty fires faster.
fn difficulty_adjusted_fire_rate(base_rate : Float, difficulty : Int) -> Float {
  let reduction = @types.ai_difficulty_accuracy(difficulty)
  let adjusted : Float = base_rate - base_rate * reduction
  let minimum : Float = base_rate * 0.5
  if adjusted > minimum {
    adjusted
  } else {
    minimum
  }
}
