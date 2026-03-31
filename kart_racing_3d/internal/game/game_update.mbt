// Main game update dispatcher

///|
/// Updates all game systems for the current frame based on the active game state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  match game.state {
    Menu => game.update_menu(dt)
    KartSelect => game.update_kart_select(dt)
    TrackPreview => game.update_track_preview(dt)
    Countdown => game.update_countdown(dt)
    Racing => game.update_racing(dt)
    Paused => game.update_paused(dt)
    RaceComplete => game.update_race_complete(dt)
    CupComplete => game.update_cup_complete(dt)
  }
}

///|
fn @types.Game::update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = @types.cups_count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor >= @types.cups_count {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_cup = game.menu_cursor
    game.current_race = 0
    game.state = KartSelect
    game.kart_select_cursor = 0
    game.selected_kart_type = 0
    game.selected_character = 0
  }
}

///|
fn @types.Game::update_kart_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  // Navigate kart types
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.selected_kart_type -= 1
    if game.selected_kart_type < 0 {
      game.selected_kart_type = @types.kart_type_count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.selected_kart_type += 1
    if game.selected_kart_type >= @types.kart_type_count {
      game.selected_kart_type = 0
    }
  }
  // Navigate characters with up/down
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.selected_character -= 1
    if game.selected_character < 0 {
      game.selected_character = @types.max_karts - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.selected_character += 1
    if game.selected_character >= @types.max_karts {
      game.selected_character = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Move to track preview
    game.state = TrackPreview
    game.preview_timer = 0.0
    game.preview_rotation = 0.0
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Menu
  }
}

///|
fn @types.Game::update_track_preview(game : @types.Game, dt : Float) -> Unit {
  game.preview_timer += dt
  game.preview_rotation += dt * 0.5
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    game.preview_timer > 5.0 {
    reset_cup_points(game)
    game.start_race()
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = KartSelect
  }
}

///|
fn @types.Game::start_race(game : @types.Game) -> Unit {
  load_track(game, game.current_cup, game.current_race)
  game.state = Countdown
  game.countdown_timer = @types.countdown_total
}

///|
fn @types.Game::update_countdown(game : @types.Game, dt : Float) -> Unit {
  game.countdown_timer -= dt
  game.update_camera_chase(dt)
  if game.countdown_timer <= 0.0 {
    game.state = Racing
    game.race_time = 0.0
    game.lap_start_time = 0.0
  }
}

///|
fn @types.Game::update_racing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Paused
    return
  }
  game.race_time += dt
  game.current_lap_time = game.race_time - game.lap_start_time
  // Update global effects
  game.update_lightning_effect(dt)
  game.update_star_effects(dt)
  // Update all systems
  update_player_kart(game, dt)
  update_ai_karts(game, dt)
  // Waypoint tracking and surface detection for all karts
  for i in 0..<@types.max_karts {
    update_kart_waypoint(game, i)
    game.update_kart_surface(i)
    game.update_kart_wrong_way(i, dt)
  }
  check_kart_collisions(game)
  update_positions(game)
  // Hazard system: update timer and apply hazard effects to all karts
  game.update_hazards(dt)
  game.check_fall_reset()
  // Track player position changes for HUD callout
  let player_place = game.karts[@types.player_kart].place
  if player_place != game.prev_player_place {
    game.place_change_timer = 2.0
    game.place_change_place = player_place
    game.prev_player_place = player_place
  }
  if game.place_change_timer > 0.0 {
    game.place_change_timer -= dt
  }
  // Track item pickup flash
  let old_item = game.karts[@types.player_kart].held_powerup
  check_powerup_collisions(game)
  if game.karts[@types.player_kart].held_powerup != old_item &&
    game.karts[@types.player_kart].held_powerup != NoPowerup {
    game.item_pickup_flash_timer = 1.0
  }
  if game.item_pickup_flash_timer > 0.0 {
    game.item_pickup_flash_timer -= dt
  }
  // Track drift boost release for text display
  if game.drift_boost_text_timer > 0.0 {
    game.drift_boost_text_timer -= dt
  }
  // Decay lap flash timer
  if game.lap_flash_timer > 0.0 {
    game.lap_flash_timer -= dt
  }
  // Decay hit flash timer
  if game.hit_flash_timer > 0.0 {
    game.hit_flash_timer -= dt
  }
  // Decay skid mark lifetimes
  game.update_skid_marks(dt)
  // Emit skid marks and drift smoke for drifting karts
  game.emit_drift_skid_marks()
  update_projectiles(game, dt)
  update_dropped_items(game, dt)
  check_dropped_item_collisions(game)
  update_projectile_homing(game, dt)
  update_item_box_respawns(game, dt)
  game.update_camera_chase(dt)
  // Emit track-based particles (boost pads, etc.)
  game.emit_surface_particles()
  // Check race end
  if player_finished(game) || all_karts_finished(game) {
    // Auto-finish any remaining karts
    for i in 0..<@types.max_karts {
      let kart = game.karts[i]
      if kart.active && !kart.finished {
        kart.finished = true
        kart.finish_time = game.race_time + Float::from_int(kart.place) * 2.0
      }
    }
    update_positions(game)
    apply_race_results(game)
    game.state = RaceComplete
    game.results_scroll = 0.0
  }
}

///|
fn @types.Game::update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Racing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.state = Menu
  }
}

///|
fn @types.Game::update_race_complete(game : @types.Game, dt : Float) -> Unit {
  game.results_scroll += dt
  game.update_camera_chase(dt)
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_race += 1
    if game.current_race >= @types.races_per_cup {
      game.state = CupComplete
      game.results_scroll = 0.0
    } else {
      game.start_race()
    }
  }
}

///|
fn @types.Game::update_cup_complete(game : @types.Game, dt : Float) -> Unit {
  game.results_scroll += dt
  ignore(dt)
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = Menu
  }
}

///|
fn @types.Game::update_camera_chase(game : @types.Game, dt : Float) -> Unit {
  let kart = game.karts[@types.player_kart]
  if !kart.active {
    return
  }
  // Target camera position behind the kart
  let behind_x = kart.x - @math.sinf(kart.angle) * @types.camera_dist
  let behind_z = kart.z - @math.cosf(kart.angle) * @types.camera_dist
  let behind_y = kart.y + @types.camera_height
  // Add drift camera offset (shift to the side when drifting)
  let drift_offset : Float = if kart.drift_left {
    -@types.camera_drift_offset
  } else if kart.drift_right {
    @types.camera_drift_offset
  } else {
    0.0
  }
  let perp_x = @math.cosf(kart.angle) * drift_offset
  let perp_z = -@math.sinf(kart.angle) * drift_offset
  let target_x = behind_x + perp_x
  let target_z = behind_z + perp_z
  // Smooth interpolation
  let smooth = @types.camera_smooth * dt
  let s = @types.clampf(smooth, 0.0, 1.0)
  game.camera_x = @types.lerpf(game.camera_x, target_x, s)
  game.camera_y = @types.lerpf(game.camera_y, behind_y, s)
  game.camera_z = @types.lerpf(game.camera_z, target_z, s)
  // Look at a point ahead of the kart
  let look_ahead : Float = 3.0
  game.camera_look_x = kart.x + @math.sinf(kart.angle) * look_ahead
  game.camera_look_y = kart.y + 0.5
  game.camera_look_z = kart.z + @math.cosf(kart.angle) * look_ahead
  // Dynamic FOV: widen during boosts
  let target_fov : Float = if kart.boost_timer > 0.0 || kart.star_timer > 0.0 {
    @types.camera_fovy + @types.camera_boost_fov_add
  } else {
    @types.camera_fovy
  }
  game.camera_fov = @types.lerpf(game.camera_fov, target_fov, s)
  // Camera shake when stunned or on rough surfaces
  if kart.spin_timer > 0.0 || kart.stunned_timer > 0.0 {
    game.camera_shake = @types.lerpf(game.camera_shake, 0.3, 0.1)
  } else if kart.on_surface_type == Dirt {
    game.camera_shake = @types.lerpf(game.camera_shake, 0.05, 0.1)
  } else {
    game.camera_shake = @types.lerpf(game.camera_shake, 0.0, 0.1)
  }
  if game.camera_shake > 0.01 {
    let shake_x = @types.rand_rangef(
      game,
      -game.camera_shake,
      game.camera_shake,
    )
    let shake_y = @types.rand_rangef(
      game,
      -game.camera_shake,
      game.camera_shake,
    )
    game.camera_x = game.camera_x + shake_x
    game.camera_y = game.camera_y + shake_y
  }
}

// Update kart surface detection

///|
fn @types.Game::update_kart_surface(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  if !kart.active {
    return
  }
  kart.on_surface_type = @types.detect_surface_type(game, kart.x, kart.z)
  // Boost pad effect
  if kart.on_surface_type == BoostPad && kart.on_ground {
    if kart.boost_timer < 0.3 {
      kart.boost_timer = 0.3
      kart.boost_power = @types.boost_speed_add * 0.5
    }
  }
}

// Update wrong way detection

///|
fn @types.Game::update_kart_wrong_way(
  game : @types.Game,
  kart_idx : Int,
  dt : Float,
) -> Unit {
  let kart = game.karts[kart_idx]
  if !kart.active || kart.finished {
    return
  }
  kart.wrong_way = @types.is_wrong_way(game, kart)
  if kart.wrong_way {
    kart.wrong_way_timer += dt
  } else {
    kart.wrong_way_timer = 0.0
  }
}

// Update global lightning effect

///|
fn @types.Game::update_lightning_effect(game : @types.Game, dt : Float) -> Unit {
  if game.lightning_active {
    game.lightning_timer -= dt
    if game.lightning_timer <= 0.0 {
      game.lightning_active = false
      // Restore all karts from lightning
      for i in 0..<@types.max_karts {
        game.karts[i].lightning_timer = 0.0
      }
    }
  }
}

// Update star effects

///|
fn @types.Game::update_star_effects(game : @types.Game, dt : Float) -> Unit {
  game.star_rainbow_timer += dt * 5.0
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active {
      continue
    }
    if kart.star_timer > 0.0 {
      kart.star_timer -= dt
      kart.invincible_timer = kart.star_timer
      // Spawn star sparkle particles
      if game.frame_counter % 4 == 0 {
        let r = 200 + @types.rand_range(game, 0, 55)
        let g = 150 + @types.rand_range(game, 0, 105)
        let b = 50 + @types.rand_range(game, 0, 205)
        @types.spawn_typed_particles(
          game,
          @types.particle_star_sparkle,
          kart.x,
          kart.y + 0.5,
          kart.z,
          2,
          r,
          g,
          b,
          0.06,
          0.3,
        )
      }
    }
  }
}

// Emit surface-based particles (dust on dirt, sparks on boost pads)

///|
fn @types.Game::emit_surface_particles(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active || !kart.on_ground {
      continue
    }
    if kart.speed < 3.0 {
      continue
    }
    // Dust on dirt/grass
    if kart.on_surface_type == Dirt || kart.on_surface_type == Grass {
      if game.frame_counter % 6 == i % 6 {
        let dc : (Int, Int, Int) = if kart.on_surface_type == Dirt {
          (160, 130, 80)
        } else {
          (80, 140, 60)
        }
        @types.spawn_typed_particles(
          game,
          @types.particle_dust,
          kart.x,
          kart.y + 0.1,
          kart.z,
          1,
          dc.0,
          dc.1,
          dc.2,
          0.08,
          0.5,
        )
      }
    }
    // Sparks on boost pad
    if kart.on_surface_type == BoostPad {
      if game.frame_counter % 3 == i % 3 {
        @types.spawn_typed_particles(
          game,
          @types.particle_boost_flame,
          kart.x,
          kart.y + 0.05,
          kart.z,
          1,
          255,
          220,
          50,
          0.05,
          0.3,
        )
      }
    }
    // Ice spray on ice surface
    if kart.on_surface_type == SurfaceIce {
      if game.frame_counter % 8 == i % 8 {
        @types.spawn_typed_particles(
          game,
          @types.particle_splash,
          kart.x,
          kart.y + 0.05,
          kart.z,
          1,
          200,
          220,
          255,
          0.04,
          0.4,
        )
      }
    }
  }
}

// Update skid mark lifetimes

///|
fn @types.Game::update_skid_marks(game : @types.Game, dt : Float) -> Unit {
  let max = game.skid_marks.length()
  let total = game.skid_mark_count.clamp(min=0, max~)
  for idx in 0..<total {
    let real_idx = if game.skid_mark_count > max {
      (game.skid_mark_count - max + idx) % max
    } else {
      idx
    }
    let mark = game.skid_marks[real_idx]
    let new_life = mark.5 - dt
    if new_life > 0.0 {
      game.skid_marks[real_idx] = (
        mark.0,
        mark.1,
        mark.2,
        mark.3,
        mark.4,
        new_life,
        mark.6,
      )
    } else {
      game.skid_marks[real_idx] = (
        mark.0,
        mark.1,
        mark.2,
        mark.3,
        mark.4,
        0.0,
        mark.6,
      )
    }
  }
}

// Emit skid marks under drifting karts

///|
fn @types.Game::emit_drift_skid_marks(game : @types.Game) -> Unit {
  // Only emit every few frames to avoid flooding
  if game.frame_counter % 4 != 0 {
    return
  }
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active || !kart.on_ground {
      continue
    }
    if !kart.drift_left && !kart.drift_right {
      continue
    }
    if kart.speed < 4.0 {
      continue
    }
    let sin_a = @math.sinf(kart.angle)
    let cos_a = @math.cosf(kart.angle)
    let wx_off = @types.kart_width * 0.55
    let wz_rear = @types.kart_length * 0.32
    // Left rear wheel position
    let rl_x = kart.x - sin_a * wz_rear + cos_a * wx_off
    let rl_z = kart.z - cos_a * wz_rear - sin_a * wx_off
    // Right rear wheel position
    let rr_x = kart.x - sin_a * wz_rear - cos_a * wx_off
    let rr_z = kart.z - cos_a * wz_rear + sin_a * wx_off
    // Previous position (approximate by going backward along angle)
    let back : Float = kart.speed * 0.06
    let prev_rl_x = rl_x - sin_a * back
    let prev_rl_z = rl_z - cos_a * back
    let prev_rr_x = rr_x - sin_a * back
    let prev_rr_z = rr_z - cos_a * back
    // Add skid marks for both rear wheels
    @types.add_skid_mark(game, prev_rl_x, prev_rl_z, rl_x, rl_z, kart.y, 3.0)
    @types.add_skid_mark(game, prev_rr_x, prev_rr_z, rr_x, rr_z, kart.y, 3.0)
  }
}

// Hazard system: update timer and apply segment hazard effects to karts

///|
/// Returns true when the LavaBurst hazard is in its active (dangerous) phase.
fn is_lava_burst_active(hazard_timer : Float) -> Bool {
  let cycle = hazard_timer % @types.lava_burst_period
  cycle < @types.lava_burst_active_duration
}

///|
/// Updates the global hazard timer and applies hazard effects to all active karts
/// based on the segment they currently occupy.
fn @types.Game::update_hazards(game : @types.Game, dt : Float) -> Unit {
  game.hazard_timer += dt
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  // Spawn falling rocks once if needed
  if game.falling_rocks_count == 0 {
    game.spawn_falling_rocks()
  }
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active || kart.finished || !kart.on_ground {
      continue
    }
    if kart.spin_timer > 0.0 || kart.stunned_timer > 0.0 {
      continue
    }
    let seg_idx = kart.waypoint_idx
    if seg_idx < 0 || seg_idx >= wc {
      continue
    }
    let seg = game.segments[seg_idx]
    match seg.hazard {
      LavaBurst =>
        if is_lava_burst_active(game.hazard_timer) {
          // Kart is on an active lava burst segment
          if kart.invincible_timer <= 0.0 && kart.star_timer <= 0.0 {
            if kart.shield_timer > 0.0 {
              kart.shield_timer = 0.0
            } else {
              kart.speed = kart.speed * @types.lava_burst_speed_penalty
              kart.spin_timer = @types.lava_burst_spin_time
            }
            @types.spawn_particles(
              game, kart.x, kart.y + 0.3, kart.z, 8, 255, 80, 20,
            )
            if i == @types.player_kart {
              game.hit_flash_timer = 0.5
              game.camera_shake = 0.4
            }
          }
        }
      FallingRocks => game.check_falling_rock_collision(i)
      WaterCurrent => {
        // Apply sideways force based on segment perpendicular direction
        let wp0 = game.waypoints[seg_idx]
        let wp1 = game.waypoints[(seg_idx + 1) % wc]
        let dx = wp1.x - wp0.x
        let dz = wp1.z - wp0.z
        let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
        if dist > 0.01 {
          // Perpendicular direction (push sideways)
          let px = -dz / dist
          let pz = dx / dist
          kart.x = kart.x + px * @types.water_current_force * dt
          kart.z = kart.z + pz * @types.water_current_force * dt
        }
      }
      IceSheet => {
        // Override traction: near-zero grip, minimal steering
        kart.speed = kart.speed *
          (1.0 - (1.0 - @types.ice_sheet_grip) * dt * 2.0)
        kart.steer = kart.steer * @types.ice_sheet_steer_mult
        // Cancel any active drift on ice sheet
        if kart.drift_left || kart.drift_right {
          kart.drift_left = false
          kart.drift_right = false
          kart.drift_timer = 0.0
          kart.drift_level = DriftNone
          kart.drift_angle = 0.0
        }
      }
      Shortcut => {
        // Speed bonus for staying on the narrow shortcut
        let effective_max = @types.get_kart_max_speed(kart)
        let boosted = effective_max * @types.shortcut_speed_bonus
        if kart.speed < boosted && kart.speed > 3.0 {
          kart.speed = @types.lerpf(kart.speed, boosted, dt * 2.0)
        }
      }
      NoHazard => ()
    }
  }
}

///|
/// Spawns falling rock obstacle positions for all FallingRocks segments.
fn @types.Game::spawn_falling_rocks(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  let mut count = 0
  for i in 0..<wc {
    let seg = game.segments[i]
    if seg.hazard != FallingRocks {
      continue
    }
    let wp0 = game.waypoints[i]
    let wp1 = game.waypoints[(i + 1) % wc]
    let half_w = @types.road_half * seg.width_mult
    for r in 0..<@types.falling_rocks_max {
      if count >= game.falling_rocks.length() {
        break
      }
      // Place rocks at random positions along and across the segment
      let t = (Float::from_int(r) + 0.5) / Float::from_int(@types.falling_rocks_max)
      let cx = @types.lerpf(wp0.x, wp1.x, t)
      let cz = @types.lerpf(wp0.z, wp1.z, t)
      // Offset across the road using perpendicular
      let dx = wp1.x - wp0.x
      let dz = wp1.z - wp0.z
      let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
      if dist > 0.01 {
        let px = -dz / dist
        let pz = dx / dist
        // Alternate sides with some variation
        let side : Float = if r % 2 == 0 { 1.0 } else { -1.0 }
        let offset = side * half_w * 0.4
        let rx = cx + px * offset
        let rz = cz + pz * offset
        game.falling_rocks[count] = (i, rx, rz, true)
        count += 1
      }
    }
  }
  game.falling_rocks_count = count
}

///|
/// Checks if a kart collides with any falling rock obstacle and applies effects.
fn @types.Game::check_falling_rock_collision(
  game : @types.Game,
  kart_idx : Int,
) -> Unit {
  let kart = game.karts[kart_idx]
  let seg_idx = kart.waypoint_idx
  for r in 0..<game.falling_rocks_count {
    let rock = game.falling_rocks[r]
    if !rock.3 || rock.0 != seg_idx {
      continue
    }
    let dist = @types.distance2d(kart.x, kart.z, rock.1, rock.2)
    if dist < @types.falling_rock_radius + @types.kart_width * 0.5 {
      if kart.invincible_timer > 0.0 || kart.star_timer > 0.0 {
        // Destroy the rock
        game.falling_rocks[r] = (rock.0, rock.1, rock.2, false)
        @types.spawn_particles(
          game, rock.1, kart.y + 0.5, rock.2, 6, 100, 90, 80,
        )
        continue
      }
      if kart.shield_timer > 0.0 {
        kart.shield_timer = 0.0
        game.falling_rocks[r] = (rock.0, rock.1, rock.2, false)
        continue
      }
      kart.speed = kart.speed * @types.falling_rock_speed_penalty
      kart.spin_timer = @types.falling_rock_spin_time
      @types.spawn_particles(
        game, kart.x, kart.y + 0.5, kart.z, 8, 120, 100, 80,
      )
      if kart_idx == @types.player_kart {
        game.hit_flash_timer = 0.5
        game.camera_shake = 0.35
      }
      // Destroy the rock on hit
      game.falling_rocks[r] = (rock.0, rock.1, rock.2, false)
      break
    }
  }
}

///|
/// Checks if any kart has fallen too far off track and respawns them at the
/// last waypoint with a time penalty. Primarily relevant for Rainbow Road.
fn @types.Game::check_fall_reset(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  // Only check tracks that have hazards or narrow/elevated segments (Rainbow Road etc.)
  let has_fall_risk = {
    let mut found = false
    for i in 0..<wc {
      if game.segments[i].width_mult < 0.7 {
        found = true
        break
      }
    }
    found
  }
  if !has_fall_risk {
    return
  }
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active || kart.finished {
      continue
    }
    // Check distance from the nearest waypoint
    let mut best_dist = 99999.0F
    for w in 0..<wc {
      let wp = game.waypoints[w]
      let d = @types.distance2d(kart.x, kart.z, wp.x, wp.z)
      if d < best_dist {
        best_dist = d
      }
    }
    // Also check if kart has fallen below the track
    let ground_y = get_ground_height(game, kart.x, kart.z)
    let fell_off = kart.y < ground_y - 5.0
    if best_dist > @types.fall_reset_distance || fell_off {
      // Respawn at last waypoint
      let wp_idx = kart.waypoint_idx.clamp(min=0, max=wc - 1)
      let wp = game.waypoints[wp_idx]
      kart.x = wp.x
      kart.y = wp.y + 0.5
      kart.z = wp.z
      kart.speed = @types.fall_reset_speed
      kart.vy = 0.0
      kart.on_ground = true
      kart.spin_timer = 0.0
      kart.stunned_timer = 0.0
      // Time penalty for player
      if i == @types.player_kart {
        game.race_time += @types.fall_reset_time_penalty
        game.hit_flash_timer = 1.0
        game.camera_shake = 0.5
      }
      @types.spawn_particles(game, kart.x, kart.y + 0.5, kart.z, 10, 255, 255, 200)
    }
  }
}
