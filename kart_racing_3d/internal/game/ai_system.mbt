// AI kart behavior with predictive cornering, pack racing, and hazard-aware routing

///|
/// Updates steering, drifting, item usage, and physics for all AI-controlled karts.
pub fn update_ai_karts(game : @types.Game, dt : Float) -> Unit {
  let player = game.karts[@types.player_kart]
  let player_progress = player.total_progress
  for i in 1..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active || kart.finished {
      continue
    }
    // Update timers
    update_ai_timers(kart, dt)
    // Stun/spin handling
    if kart.spin_timer > 0.0 {
      kart.spin_timer -= dt
      kart.angle = kart.angle + 8.0 * dt
      kart.speed = kart.speed * (1.0 - 2.0 * dt)
      if kart.speed < 0.0 {
        kart.speed = 0.0
      }
      apply_kart_physics(game, i, dt)
      continue
    }
    if kart.stunned_timer > 0.0 {
      kart.stunned_timer -= dt
      kart.speed = kart.speed * (1.0 - 3.0 * dt)
      apply_kart_physics(game, i, dt)
      continue
    }
    // Determine target waypoint with adaptive lookahead
    let wc = game.waypoint_count
    if wc < 2 {
      continue
    }
    let diff_stats = @types.ai_difficulty_stats[kart.ai_difficulty.clamp(
        min=0,
        max=3,
      )]
    // --- Improvement 1: Predictive Cornering ---
    let corner_info = ai_scan_corners(game, kart)
    let desired_entry_speed = corner_info.0
    let _sharpest_seg_idx = corner_info.1
    let sharpest_angle = corner_info.2
    let turn_sign = corner_info.3
    let dist_to_corner = corner_info.4
    // Compute braking distance: d = (v^2 - v_t^2) / (2 * a)
    let kart_max = @types.get_kart_max_speed(kart)
    let target_entry = desired_entry_speed * kart_max
    let brake_needed = if kart.speed > target_entry && target_entry > 0.0 {
      let brake_dist = (kart.speed * kart.speed - target_entry * target_entry) /
        (2.0 * @types.ai_brake_decel)
      dist_to_corner < brake_dist + 2.0
    } else {
      false
    }
    kart.ai_braking_for_corner = brake_needed && diff_stats.2 > 0.5
    kart.ai_corner_target_speed = target_entry
    // Determine corner phase: 0=approach, 1=apex, 2=exit
    if sharpest_angle > 20.0 {
      if dist_to_corner < 5.0 {
        kart.ai_corner_phase = 1 // at apex
      } else if kart.ai_braking_for_corner {
        kart.ai_corner_phase = 0 // approaching, braking
      } else if kart.ai_corner_phase == 1 {
        kart.ai_corner_phase = 2 // exiting
      }
    } else {
      kart.ai_corner_phase = 2 // straight, treat as exit (accelerate)
    }
    // Adaptive lookahead: shorter for tight corners, longer for straights
    let next_wp = @types.get_waypoint(game, (kart.waypoint_idx + 1) % wc)
    let next2_wp = @types.get_waypoint(game, (kart.waypoint_idx + 2) % wc)
    let cur_wp_pos = @types.get_waypoint(game, kart.waypoint_idx)
    let corner_angle = @types.angle_between_segments(
      cur_wp_pos, next_wp, next2_wp,
    )
    let look_ahead : Int = if corner_angle > 30.0 { 1 } else { 2 }
    // Blend primary (next wp) and secondary (lookahead wp) targets
    let primary_wp = @types.get_waypoint(game, (kart.waypoint_idx + 1) % wc)
    let secondary_wp = @types.get_waypoint(
      game, (kart.waypoint_idx + look_ahead) % wc,
    )
    let blend_x = primary_wp.x * 0.7 + secondary_wp.x * 0.3
    let blend_z = primary_wp.z * 0.7 + secondary_wp.z * 0.3
    // Apply racing line offset for more natural movement
    let perp = @types.get_track_perpendicular(game, kart.waypoint_idx)
    let mut line_offset = kart.ai_line_offset * diff_stats.2
    // --- Apex steering: at the sharpest point, steer toward inside of corner ---
    if kart.ai_corner_phase == 1 && sharpest_angle > 20.0 && diff_stats.2 > 0.6 {
      // turn_sign > 0 means left turn -> inside is right (negative perp)
      // turn_sign < 0 means right turn -> inside is left (positive perp)
      let apex_offset = if turn_sign > 0.0 {
        -@types.road_half * 0.6
      } else {
        @types.road_half * 0.6
      }
      line_offset = @types.lerpf(line_offset, apex_offset, diff_stats.2)
    }
    // --- Improvement 2: Pack Racing - overtake/block offsets ---
    if kart.ai_overtake_side.abs() > 0.1 {
      line_offset = line_offset + kart.ai_overtake_side * @types.ai_overtake_offset
    }
    // --- Improvement 3: Hazard avoidance offset ---
    if kart.ai_hazard_offset.abs() > 0.1 {
      line_offset = line_offset + kart.ai_hazard_offset
    }
    let target_x = blend_x + perp.0 * line_offset
    let target_z = blend_z + perp.1 * line_offset
    // Steering towards target with reaction delay
    let dx = target_x - kart.x
    let dz = target_z - kart.z
    let target_angle = @math.atan2f(dx, dz)
    let angle_delta = @types.angle_diff(kart.angle, target_angle)
    // Smooth steering with difficulty-based accuracy
    let steer_strength : Float = 3.0 * diff_stats.2
    let handling = @types.get_kart_handling(kart)
    let target_steer = @types.clampf(
      angle_delta * steer_strength,
      -handling,
      handling,
    )
    // Reaction time - lerp towards target steer
    let reaction = @types.clampf(1.0 - diff_stats.3 * 0.3, 0.2, 1.0)
    kart.steer = @types.lerpf(kart.steer, target_steer, reaction)
    // AI drift logic - better AI drifts on sharp turns
    let should_drift = angle_delta.abs() > 0.8 &&
      kart.speed > 12.0 &&
      diff_stats.2 > 0.7
    if should_drift {
      if !kart.drift_left && !kart.drift_right {
        if angle_delta > 0.0 {
          kart.drift_left = true
        } else {
          kart.drift_right = true
        }
        kart.drift_timer = 0.0
        kart.drift_level = DriftNone
      }
      kart.drift_timer += dt
      kart.drift_level = @types.calc_drift_level(kart.drift_timer)
    } else {
      // Release drift for boost
      if kart.drift_level != DriftNone {
        let drift_mult = @types.get_kart_drift_boost_mult(kart)
        let boost_power = @types.get_drift_boost_power(kart.drift_level) *
          drift_mult
        let boost_dur = @types.get_drift_boost_duration(kart.drift_level)
        kart.boost_timer = boost_dur
        kart.boost_power = boost_power
      }
      kart.drift_left = false
      kart.drift_right = false
      kart.drift_timer = 0.0
      kart.drift_level = DriftNone
    }
    // --- Improvement 2: Pack Racing - drafting, overtaking, blocking, avoidance ---
    ai_update_pack_racing(game, i, dt)
    // --- Improvement 3: Hazard-Aware Routing ---
    ai_update_hazard_avoidance(game, i, dt)
    // Rubber-banding: AI adjusts speed based on relative position to player
    let ai_progress = kart.total_progress
    let speed_mult = @types.calc_rubber_band_mult(
      ai_progress,
      player_progress,
      kart.ai_difficulty,
    )
    // Calculate target speed with predictive cornering
    let mut target_speed = kart_max * speed_mult
    // Predictive cornering: brake before corners based on braking distance
    if kart.ai_braking_for_corner {
      target_speed = @types.minf(target_speed, kart.ai_corner_target_speed)
    }
    // Exit acceleration: after corner apex, push harder
    let accel_mult : Float = if kart.ai_corner_phase == 2 {
      @types.ai_exit_accel_mult
    } else {
      1.0
    }
    // Drafting speed boost
    if kart.ai_draft_boost > 0.0 {
      target_speed = target_speed + kart.ai_draft_boost
    }
    // Hazard slowdown
    if kart.ai_hazard_slow > 0.0 {
      target_speed = target_speed * (1.0 - kart.ai_hazard_slow)
    }
    // Acceleration
    let kart_accel_stat = @types.get_kart_accel(kart)
    if kart.speed < target_speed {
      kart.speed = kart.speed + kart_accel_stat * 0.9 * accel_mult * dt
    } else if kart.ai_braking_for_corner {
      // Active braking for corners
      kart.speed = kart.speed - @types.ai_brake_decel * dt
      if kart.speed < target_speed * 0.8 {
        kart.speed = target_speed * 0.8
      }
    } else {
      kart.speed = kart.speed - @types.kart_friction * 0.5 * dt
    }
    // Surface consequences for AI
    let ai_surface = kart.on_surface_type
    if ai_surface == Grass && kart.on_ground {
      kart.speed = kart.speed - @types.grass_decel * dt
      if kart.speed < 0.0 {
        kart.speed = 0.0
      }
    } else if ai_surface == Dirt && kart.on_ground {
      kart.speed = kart.speed - @types.dirt_decel * dt
    } else if ai_surface == SurfaceIce && kart.on_ground {
      kart.steer = kart.steer * 0.5
    }
    kart.speed = @types.clampf(kart.speed, 0.0, kart_max * 1.15)
    // AI lateral velocity (simplified)
    if kart.on_ground {
      let steer_angle = kart.steer + kart.drift_angle
      let lateral_force = steer_angle * kart.speed * 0.06
      kart.lateral_vel = kart.lateral_vel + lateral_force * @types.lateral_build_rate * dt
      let lat_damp = @types.get_lateral_damp(kart.on_surface_type)
      kart.lateral_vel = kart.lateral_vel * (1.0 - lat_damp * dt)
      let max_lat : Float = kart.speed * 0.3
      kart.lateral_vel = @types.clampf(kart.lateral_vel, -max_lat, max_lat)
    } else {
      kart.lateral_vel = kart.lateral_vel * (1.0 - 1.0 * dt)
    }
    // Landing boost timer
    if kart.landing_boost_timer > 0.0 {
      kart.landing_boost_timer -= dt
    }
    // Boost timer
    if kart.boost_timer > 0.0 {
      kart.boost_timer -= dt
    }
    // Shield timer
    if kart.shield_timer > 0.0 {
      kart.shield_timer -= dt
    }
    // AI item usage strategy
    game.ai_use_item(i, dt)
    // Slight random variation for natural movement (scaled by difficulty)
    // Easy AI wobbles more; expert AI is very stable
    if game.frame_counter % 60 == i {
      let wobble : Float = 0.25 * (1.0 - diff_stats.2) + 0.05
      kart.steer = kart.steer + @types.rand_rangef(game, -wobble, wobble)
      // Occasionally update racing line offset - easy AI wanders wider
      let line_range : Float = 3.0 * (1.0 - diff_stats.2) + 0.5
      kart.ai_line_offset = @types.rand_rangef(game, -line_range, line_range)
    }
    // Jump ramp detection - only launch once per ramp segment
    if kart.on_ground &&
      @types.is_on_ramp(game, kart) &&
      kart.speed > 8.0 &&
      !kart.ramp_launched {
      kart.ramp_launched = true
      kart.vy = @types.jump_ramp_force
      kart.on_ground = false
      kart.air_timer = 0.0
    }
    // Reset ramp_launched when leaving ramp segment
    if !@types.is_on_ramp(game, kart) {
      kart.ramp_launched = false
    }
    apply_kart_physics(game, i, dt)
  }
}

///|
fn update_ai_timers(kart : @types.Kart, dt : Float) -> Unit {
  if kart.bounce_timer > 0.0 {
    kart.bounce_timer -= dt
  }
  if kart.invincible_timer > 0.0 && kart.star_timer <= 0.0 {
    kart.invincible_timer -= dt
  }
  if kart.lightning_timer > 0.0 {
    kart.lightning_timer -= dt
  }
  if kart.star_timer > 0.0 {
    kart.star_timer -= dt
    kart.invincible_timer = kart.star_timer
  }
  if !kart.on_ground {
    kart.air_timer += dt
  } else {
    kart.air_timer = 0.0
  }
  // Decay draft boost
  if kart.ai_draft_boost > 0.0 {
    kart.ai_draft_boost -= dt * @types.ai_draft_boost_power / @types.ai_draft_boost_duration
    if kart.ai_draft_boost < 0.0 {
      kart.ai_draft_boost = 0.0
    }
  }
  // Decay overtake timer
  if kart.ai_overtake_timer > 0.0 {
    kart.ai_overtake_timer -= dt
    if kart.ai_overtake_timer <= 0.0 {
      kart.ai_overtake_side = 0.0
    }
  }
  // Decay hazard offsets
  kart.ai_hazard_offset = kart.ai_hazard_offset * (1.0 - 2.0 * dt)
  if kart.ai_hazard_offset.abs() < 0.05 {
    kart.ai_hazard_offset = 0.0
  }
  kart.ai_hazard_slow = kart.ai_hazard_slow * (1.0 - 3.0 * dt)
  if kart.ai_hazard_slow < 0.01 {
    kart.ai_hazard_slow = 0.0
  }
}

// =====================================================================
// Improvement 1: Predictive Cornering
// =====================================================================

///|
/// Scans 3-5 segments ahead and returns corner info:
/// (desired_speed_fraction, sharpest_seg_idx, sharpest_angle_degrees, turn_sign, distance_to_corner)
fn ai_scan_corners(
  game : @types.Game,
  kart : @types.Kart,
) -> (Float, Int, Float, Float, Float) {
  let wc = game.waypoint_count
  if wc < 3 {
    return (1.0, 0, 0.0, 0.0, 100.0)
  }
  let mut sharpest_angle = 0.0F
  let mut sharpest_idx = kart.waypoint_idx
  let mut sharpest_turn_sign = 0.0F
  let mut dist_accum = 0.0F
  let mut dist_to_sharpest = 100.0F
  let scan_count = @types.ai_lookahead_segments
  for s in 0..<scan_count {
    let seg_idx = (kart.waypoint_idx + s) % wc
    let wp_a = @types.get_waypoint(game, seg_idx)
    let wp_b = @types.get_waypoint(game, (seg_idx + 1) % wc)
    let wp_c = @types.get_waypoint(game, (seg_idx + 2) % wc)
    let angle_deg = @types.angle_between_segments(wp_a, wp_b, wp_c)
    if s > 0 {
      dist_accum = dist_accum + @types.segment_length(game, (kart.waypoint_idx + s - 1) % wc)
    }
    if angle_deg > sharpest_angle {
      sharpest_angle = angle_deg
      sharpest_idx = (seg_idx + 1) % wc
      sharpest_turn_sign = @types.turn_direction(wp_a, wp_b, wp_c)
      dist_to_sharpest = dist_accum
    }
  }
  // Determine desired speed fraction based on corner sharpness
  let speed_frac : Float = if sharpest_angle > 45.0 {
    @types.ai_sharp_corner_speed
  } else if sharpest_angle > 20.0 {
    @types.ai_medium_corner_speed
  } else {
    @types.ai_gentle_corner_speed
  }
  (speed_frac, sharpest_idx, sharpest_angle, sharpest_turn_sign, dist_to_sharpest)
}

// =====================================================================
// Improvement 2: Pack Racing (drafting, overtaking, blocking, avoidance)
// =====================================================================

///|
/// Updates pack racing behavior: drafting, overtaking, blocking, and local avoidance.
fn ai_update_pack_racing(
  game : @types.Game,
  kart_idx : Int,
  dt : Float,
) -> Unit {
  let kart = game.karts[kart_idx]
  let diff_stats = @types.ai_difficulty_stats[kart.ai_difficulty.clamp(
      min=0,
      max=3,
    )]
  // Only higher-difficulty AI uses pack racing tactics
  if diff_stats.2 < 0.6 {
    return
  }
  let wc = game.waypoint_count
  if wc < 3 {
    return
  }
  // --- Slipstream / Drafting ---
  let mut drafting = false
  let kart_sin = @math.sinf(kart.angle)
  let kart_cos = @math.cosf(kart.angle)
  for j in 0..<@types.max_karts {
    if j == kart_idx {
      continue
    }
    let other = game.karts[j]
    if !other.active || other.finished {
      continue
    }
    // Vector from kart to other
    let to_x = other.x - kart.x
    let to_z = other.z - kart.z
    let dist = @types.distance2d(kart.x, kart.z, other.x, other.z)
    if dist < 1.0 || dist > @types.ai_draft_max_dist {
      continue
    }
    // Check if other is ahead (dot product with our forward vector > 0)
    let dot_fwd = to_x * kart_sin + to_z * kart_cos
    if dot_fwd < 0.0 {
      continue // other is behind us
    }
    // Check angle alignment: are we roughly behind them?
    let angle_to_other = @math.atan2f(to_x, to_z)
    let angle_diff_val = @types.angle_diff(kart.angle, angle_to_other).abs()
    if angle_diff_val < @types.ai_draft_max_angle {
      drafting = true
      break
    }
  }
  if drafting {
    kart.ai_draft_timer += dt
    if kart.ai_draft_timer >= @types.ai_draft_charge_time &&
      kart.ai_draft_boost <= 0.0 {
      // Draft boost activated
      kart.ai_draft_boost = @types.ai_draft_boost_power
      kart.ai_draft_timer = 0.0
      // Visual wind lines
      @types.spawn_typed_particles(
        game,
        @types.particle_dust,
        kart.x,
        kart.y + 0.4,
        kart.z,
        4,
        200,
        220,
        255,
        0.03,
        0.4,
      )
    }
  } else {
    // Decay draft timer when not tucked behind someone
    kart.ai_draft_timer = kart.ai_draft_timer * (1.0 - 2.0 * dt)
    if kart.ai_draft_timer < 0.05 {
      kart.ai_draft_timer = 0.0
    }
  }
  // --- Overtake Intents ---
  if kart.ai_overtake_timer <= 0.0 {
    // Find the nearest kart directly ahead and close
    let mut ahead_idx = -1
    let mut ahead_dist = 99999.0F
    for j in 0..<@types.max_karts {
      if j == kart_idx {
        continue
      }
      let other = game.karts[j]
      if !other.active || other.finished {
        continue
      }
      // Must be ahead in race progress but close spatially
      if other.total_progress <= kart.total_progress {
        continue
      }
      let d = @types.distance2d(kart.x, kart.z, other.x, other.z)
      if d < ahead_dist && d < 12.0 {
        ahead_dist = d
        ahead_idx = j
      }
    }
    if ahead_idx >= 0 && kart.speed > game.karts[ahead_idx].speed {
      // Determine overtake side based on upcoming corner direction
      let wp_a = @types.get_waypoint(game, kart.waypoint_idx)
      let wp_b = @types.get_waypoint(game, (kart.waypoint_idx + 1) % wc)
      let wp_c = @types.get_waypoint(game, (kart.waypoint_idx + 2) % wc)
      let turn = @types.turn_direction(wp_a, wp_b, wp_c)
      let turn_deg = @types.angle_between_segments(wp_a, wp_b, wp_c)
      if turn_deg > 15.0 {
        // Before a turn: overtake on inside
        // Left turn (turn > 0) -> inside is right -> overtake offset negative
        // Right turn (turn < 0) -> inside is left -> overtake offset positive
        kart.ai_overtake_side = if turn > 0.0 { -1.0 } else { 1.0 }
      } else {
        // Straight: overtake on side with more space
        let other = game.karts[ahead_idx]
        let perp = @types.get_track_perpendicular(game, kart.waypoint_idx)
        let to_other_x = other.x - kart.x
        let to_other_z = other.z - kart.z
        let side_dot = to_other_x * perp.0 + to_other_z * perp.1
        // Go to opposite side of where the other kart is
        kart.ai_overtake_side = if side_dot > 0.0 { -1.0 } else { 1.0 }
      }
      kart.ai_overtake_timer = @types.ai_overtake_duration
    }
  }
  // --- Defensive Blocking (leaders only) ---
  if kart.place <= 2 && kart.ai_overtake_timer <= 0.0 {
    // Check if a rival is closing from behind
    let mut closest_behind_idx = -1
    let mut closest_behind_dist = 99999.0F
    for j in 0..<@types.max_karts {
      if j == kart_idx {
        continue
      }
      let other = game.karts[j]
      if !other.active || other.finished {
        continue
      }
      // Must be behind but closing
      if other.total_progress >= kart.total_progress {
        continue
      }
      let d = @types.distance2d(kart.x, kart.z, other.x, other.z)
      if d < closest_behind_dist && d < 10.0 {
        closest_behind_dist = d
        closest_behind_idx = j
      }
    }
    if closest_behind_idx >= 0 {
      let rival = game.karts[closest_behind_idx]
      let perp = @types.get_track_perpendicular(game, kart.waypoint_idx)
      let to_rival_x = rival.x - kart.x
      let to_rival_z = rival.z - kart.z
      let side_dot = to_rival_x * perp.0 + to_rival_z * perp.1
      // Shift toward the rival to block
      let block_dir : Float = if side_dot > 0.0 { 1.0 } else { -1.0 }
      kart.ai_overtake_side = block_dir * @types.ai_block_offset / @types.ai_overtake_offset
      kart.ai_overtake_timer = 0.5 // short block bursts
    }
  }
  // --- Local Avoidance: steer away from very nearby karts ---
  let mut avoid_steer = 0.0F
  for j in 0..<@types.max_karts {
    if j == kart_idx {
      continue
    }
    let other = game.karts[j]
    if !other.active || other.finished {
      continue
    }
    let dist = @types.distance2d(kart.x, kart.z, other.x, other.z)
    if dist < @types.ai_avoidance_dist && dist > 0.1 {
      // Compute repulsion: perpendicular to our heading, away from other
      let to_other_x = other.x - kart.x
      let to_other_z = other.z - kart.z
      let perp_x = @math.cosf(kart.angle)
      let perp_z = -@math.sinf(kart.angle)
      let side = to_other_x * perp_x + to_other_z * perp_z
      let strength = @types.ai_avoidance_strength *
        (1.0 - dist / @types.ai_avoidance_dist)
      // Steer away from the other kart
      avoid_steer = avoid_steer + (if side > 0.0 { -strength } else { strength })
    }
  }
  if avoid_steer.abs() > 0.01 {
    let handling = @types.get_kart_handling(kart)
    kart.steer = kart.steer + @types.clampf(avoid_steer, -handling * 0.3, handling * 0.3)
  }
}

// =====================================================================
// Improvement 3: Hazard-Aware Routing
// =====================================================================

///|
/// Updates hazard detection and avoidance for an AI kart.
fn ai_update_hazard_avoidance(
  game : @types.Game,
  kart_idx : Int,
  dt : Float,
) -> Unit {
  let kart = game.karts[kart_idx]
  let diff_stats = @types.ai_difficulty_stats[kart.ai_difficulty.clamp(
      min=0,
      max=3,
    )]
  let wc = game.waypoint_count
  if wc < 3 {
    return
  }
  ignore(dt)
  // --- Hazard Lookahead: scan upcoming segments for hazards ---
  let scan_count = @types.ai_hazard_lookahead
  for s in 0..<scan_count {
    let seg_idx = (kart.waypoint_idx + s) % wc
    let seg = game.segments[seg_idx]
    match seg.hazard {
      LavaBurst => {
        // Estimate time to arrive at this segment
        let dist_to_seg = ai_estimate_dist_to_segment(game, kart, seg_idx)
        let time_to_arrive = if kart.speed > 1.0 {
          dist_to_seg / kart.speed
        } else {
          10.0
        }
        // Check if the burst will be active when we arrive
        let future_timer = game.hazard_timer + time_to_arrive
        let cycle = future_timer % @types.lava_burst_period
        let burst_active = cycle < @types.lava_burst_active_duration
        if burst_active && diff_stats.2 > 0.5 {
          // Slow down to time our passage during the safe window
          kart.ai_hazard_slow = @types.maxf(
            kart.ai_hazard_slow,
            @types.ai_hazard_speed_reduction * 0.4,
          )
        }
      }
      FallingRocks =>
        // Scan for actual rock positions, steer away from them
        ai_avoid_falling_rocks(game, kart, seg_idx)
      WaterCurrent =>
        if diff_stats.2 > 0.6 {
          // Pre-steer to counteract the current direction
          let wp0 = game.waypoints[seg_idx]
          let wp1 = game.waypoints[(seg_idx + 1) % wc]
          let seg_dx = wp1.x - wp0.x
          let seg_dz = wp1.z - wp0.z
          let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
          if dist > 0.01 {
            // Water pushes in perpendicular direction; pre-steer against it
            let px = -seg_dz / dist
            let pz = seg_dx / dist
            // Apply counter-offset proportional to current strength
            let counter_strength = @types.water_current_force * 0.3 * diff_stats.2
            kart.ai_hazard_offset = @types.lerpf(
              kart.ai_hazard_offset,
              -px * counter_strength,
              0.3,
            )
            ignore(pz)
          }
        }
      IceSheet =>
        if diff_stats.2 > 0.5 {
          // Reduce speed before entering ice
          let dist_to_seg = ai_estimate_dist_to_segment(game, kart, seg_idx)
          if dist_to_seg < 15.0 {
            kart.ai_hazard_slow = @types.maxf(
              kart.ai_hazard_slow,
              @types.ai_hazard_speed_reduction * 0.3,
            )
          }
        }
      Shortcut =>
        // Higher difficulty AI deliberately aims for shortcuts
        if diff_stats.2 > 0.85 && s <= 1 {
          // Steer toward shortcut center (reduce line offset)
          kart.ai_hazard_offset = @types.lerpf(kart.ai_hazard_offset, 0.0, 0.5)
        }
      NoHazard => ()
    }
  }
  // --- Obstacle Avoidance: scan for dropped items (bananas, oil slicks) in forward cone ---
  ai_avoid_dropped_items(game, kart)
}

///|
/// Estimates the distance from the kart to the start of a given segment.
fn ai_estimate_dist_to_segment(
  game : @types.Game,
  kart : @types.Kart,
  target_seg : Int,
) -> Float {
  let wc = game.waypoint_count
  let mut dist = 0.0F
  let mut seg = kart.waypoint_idx
  // Add partial distance through current segment
  let cur_wp = @types.get_waypoint(game, seg)
  let next_wp = @types.get_waypoint(game, (seg + 1) % wc)
  let seg_len = @types.distance2d(cur_wp.x, cur_wp.z, next_wp.x, next_wp.z)
  dist = dist + seg_len * (1.0 - kart.waypoint_progress)
  seg = (seg + 1) % wc
  // Accumulate full segment distances
  for _i in 0..<wc {
    if seg == target_seg {
      break
    }
    dist = dist + @types.segment_length(game, seg)
    seg = (seg + 1) % wc
  }
  dist
}

///|
/// Steers the AI kart away from falling rock positions in the given segment.
fn ai_avoid_falling_rocks(
  game : @types.Game,
  kart : @types.Kart,
  seg_idx : Int,
) -> Unit {
  for r in 0..<game.falling_rocks_count {
    let rock = game.falling_rocks[r]
    if !rock.3 || rock.0 != seg_idx {
      continue
    }
    let dist = @types.distance2d(kart.x, kart.z, rock.1, rock.2)
    if dist < @types.ai_obstacle_scan_dist {
      // Check if rock is in our forward cone
      let to_rock_x = rock.1 - kart.x
      let to_rock_z = rock.2 - kart.z
      let fwd_dot = to_rock_x * @math.sinf(kart.angle) + to_rock_z * @math.cosf(kart.angle)
      if fwd_dot > 0.0 {
        // Rock is ahead, steer away
        let perp_x = @math.cosf(kart.angle)
        let perp_z = -@math.sinf(kart.angle)
        let side = to_rock_x * perp_x + to_rock_z * perp_z
        let dodge_dir = if side > 0.0 {
          -@types.ai_obstacle_dodge_offset
        } else {
          @types.ai_obstacle_dodge_offset
        }
        let urgency = 1.0F - dist / @types.ai_obstacle_scan_dist
        kart.ai_hazard_offset = @types.lerpf(
          kart.ai_hazard_offset,
          dodge_dir * urgency,
          0.4,
        )
      }
    }
  }
}

///|
/// Scans for dropped items (bananas, oil slicks) in a forward cone and steers around them.
fn ai_avoid_dropped_items(game : @types.Game, kart : @types.Kart) -> Unit {
  let sin_a = @math.sinf(kart.angle)
  let cos_a = @math.cosf(kart.angle)
  let perp_x = cos_a
  let perp_z = -sin_a
  for item in game.dropped_items {
    if !item.active {
      continue
    }
    let to_x = item.x - kart.x
    let to_z = item.z - kart.z
    let dist = @types.distance2d(kart.x, kart.z, item.x, item.z)
    if dist > @types.ai_obstacle_scan_dist || dist < 0.5 {
      continue
    }
    // Check if in forward cone
    let fwd_dot = to_x * sin_a + to_z * cos_a
    if fwd_dot <= 0.0 {
      continue // behind us
    }
    // Check lateral angle
    let side_dot = to_x * perp_x + to_z * perp_z
    let angle_ratio = side_dot.abs() / dist
    if angle_ratio > 0.5 {
      continue // too far to the side, won't hit it
    }
    // Object is in our path, dodge it
    let dodge_dir = if side_dot > 0.0 {
      -@types.ai_obstacle_dodge_offset
    } else {
      @types.ai_obstacle_dodge_offset
    }
    let urgency = 1.0F - dist / @types.ai_obstacle_scan_dist
    kart.ai_hazard_offset = @types.lerpf(
      kart.ai_hazard_offset,
      dodge_dir * urgency,
      0.3,
    )
    break // dodge the closest threat
  }
}

// =====================================================================
// AI Item Usage Strategy
// =====================================================================

///|
fn @types.Game::ai_use_item(
  game : @types.Game,
  kart_idx : Int,
  dt : Float,
) -> Unit {
  let kart = game.karts[kart_idx]
  if kart.held_powerup == NoPowerup {
    return
  }
  kart.ai_use_item_timer -= dt
  if kart.ai_use_item_timer > 0.0 {
    return
  }
  let diff_stats = @types.ai_difficulty_stats[kart.ai_difficulty.clamp(
      min=0,
      max=3,
    )]
  let item = kart.held_powerup
  // Position-aware AI item strategy:
  // Leaders hold defensive items, back markers boost immediately, mid-pack attacks ahead
  let is_leader = kart.place <= 2
  let is_back = kart.place >= 5
  let should_use : Bool = if @types.is_boost_item(item) {
    if is_back {
      // Back markers use boost items immediately
      true
    } else {
      // Others use boost when track is straight
      let wc = game.waypoint_count
      let next_wp = @types.get_waypoint(game, (kart.waypoint_idx + 1) % wc)
      let dx = next_wp.x - kart.x
      let dz = next_wp.z - kart.z
      let turn = @types.angle_diff(kart.angle, @math.atan2f(dx, dz)).abs()
      turn < 0.5
    }
  } else if item == Shield {
    // Use shield when in danger (near opponents)
    game.has_nearby_opponent(kart_idx, 15.0)
  } else if item == Missile {
    if is_leader {
      // Leaders hold missiles as defense (don't fire unless threatened from behind)
      game.has_nearby_opponent_behind(kart_idx, 8.0)
    } else {
      // Mid-pack and back: fire at kart ahead when close
      let target = @types.find_target_ahead(game, kart_idx)
      if target >= 0 {
        @types.distance2d(
          kart.x,
          kart.z,
          game.karts[target].x,
          game.karts[target].z,
        ) <
        30.0
      } else {
        false
      }
    }
  } else if item == OilSlick || item == Banana {
    if is_leader {
      // Leaders hold defensive items - only drop when threatened
      game.has_nearby_opponent_behind(kart_idx, 6.0)
    } else {
      // Others drop when someone is close behind
      game.has_nearby_opponent_behind(kart_idx, 10.0)
    }
  } else if item == Lightning {
    // Use when in lower positions (more useful further back)
    kart.place >= 4
  } else {
    true
  }
  // Update trailing item visual for AI karts too
  kart.trailing_item_active = !should_use &&
    (item == Banana || item == OilSlick || item == Missile)
  if should_use {
    use_powerup(game, kart_idx)
    // Item use cooldown scales with difficulty: easy = longer waits, expert = short
    let reaction_base : Float = diff_stats.3
    let item_luck : Float = diff_stats.1
    let cooldown_min : Float = 1.5 + reaction_base
    let cooldown_max : Float = 4.0 + reaction_base * 2.0
    // Higher item luck reduces cooldown
    let luck_factor : Float = 1.5 - item_luck * 0.5
    kart.ai_use_item_timer = @types.rand_rangef(
      game,
      cooldown_min * luck_factor,
      cooldown_max * luck_factor,
    )
  } else {
    // Easy AI rechecks less often
    let recheck : Float = 0.5 + diff_stats.3 * 0.5
    kart.ai_use_item_timer = recheck
  }
}

// Check if any opponent is nearby

///|
fn @types.Game::has_nearby_opponent(
  game : @types.Game,
  kart_idx : Int,
  range : Float,
) -> Bool {
  let kart = game.karts[kart_idx]
  for i in 0..<@types.max_karts {
    if i == kart_idx {
      continue
    }
    let other = game.karts[i]
    if !other.active || other.finished {
      continue
    }
    if @types.distance2d(kart.x, kart.z, other.x, other.z) < range {
      return true
    }
  }
  false
}

// Check if any opponent is nearby behind

///|
fn @types.Game::has_nearby_opponent_behind(
  game : @types.Game,
  kart_idx : Int,
  range : Float,
) -> Bool {
  let kart = game.karts[kart_idx]
  for i in 0..<@types.max_karts {
    if i == kart_idx {
      continue
    }
    let other = game.karts[i]
    if !other.active || other.finished {
      continue
    }
    if other.total_progress >= kart.total_progress {
      continue
    }
    if @types.distance2d(kart.x, kart.z, other.x, other.z) < range {
      return true
    }
  }
  false
}
