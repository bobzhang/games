///|
/// Sets the on-screen hint text and its display duration.
fn @types.Game::set_hint(
  game : @types.Game,
  text : String,
  ttl : Float,
) -> Unit {
  game.hint = text
  game.info_t = ttl
}

///|
/// Deactivates all smoke instances and resets their fields to defaults.
fn @types.Game::clear_smokes(game : @types.Game) -> Unit {
  for smoke in game.smokes {
    smoke.active = false
    smoke.x = 0.0
    smoke.y = 0.0
    smoke.radius = @types.smoke_radius_base
    smoke.life = 0.0
  }
}

///|
/// Deactivates all guards and resets their position, velocity, and AI state to defaults.
fn @types.Game::clear_guards(game : @types.Game) -> Unit {
  for guard_val in game.guards {
    guard_val.active = false
    guard_val.x = 0.0
    guard_val.y = 0.0
    guard_val.vx = 0.0
    guard_val.vy = 0.0
    guard_val.dir_deg = 0.0
    guard_val.patrol_a_x = 0.0
    guard_val.patrol_a_y = 0.0
    guard_val.patrol_b_x = 0.0
    guard_val.patrol_b_y = 0.0
    guard_val.to_b = true
    guard_val.speed = @types.guard_speed_base
    guard_val.cone_range = @types.guard_cone_range_base
    guard_val.cone_half_angle = @types.guard_cone_half_angle_base
    guard_val.alert_t = 0.0
    guard_val.investigate_t = 0.0
    guard_val.target_x = 0.0
    guard_val.target_y = 0.0
  }
}

///|
/// Deactivates all traps and resets their position, radius, and timers to defaults.
fn @types.Game::clear_traps(game : @types.Game) -> Unit {
  for trap in game.traps {
    trap.active = false
    trap.x = 0.0
    trap.y = 0.0
    trap.radius = 0.0
    trap.blink_t = 0.0
    trap.cooldown = 0.0
  }
}

///|
/// Deactivates all parcels and resets their position and pulse to defaults.
fn @types.Game::clear_parcels(game : @types.Game) -> Unit {
  for parcel in game.parcels {
    parcel.active = false
    parcel.delivered = false
    parcel.x = 0.0
    parcel.y = 0.0
    parcel.pulse = 0.0
  }
}

///|
/// Returns a random point within the world bounds inset by `margin`.
fn random_world_point(margin : Float) -> (Float, Float) {
  (
    @types.randf(@types.world_left + margin, @types.world_right - margin),
    @types.randf(@types.world_top + margin, @types.world_bottom - margin),
  )
}

///|
/// Returns true if `(x, y)` is at least `min_dist` away from every active exit.
fn @types.Game::far_from_exits(
  game : @types.Game,
  x : Float,
  y : Float,
  min_dist : Float,
) -> Bool {
  let min_d2 = min_dist * min_dist
  for exit in game.exits {
    if not(exit.active) {
      continue
    }
    if @types.dist2(x, y, exit.x, exit.y) < min_d2 {
      return false
    }
  }
  true
}

///|
/// Returns true if `(x, y)` is at least `min_dist` away from the player spawn point.
fn far_from_spawn(x : Float, y : Float, min_dist : Float) -> Bool {
  @types.dist2(x, y, @types.player_spawn_x(), @types.player_spawn_y()) >=
  min_dist * min_dist
}

///|
/// Returns true if `(x, y)` is at least `min_dist` away from all active parcels with indices 0 to `upto-1`.
fn @types.Game::far_from_active_parcels(
  game : @types.Game,
  x : Float,
  y : Float,
  min_dist : Float,
  upto : Int,
) -> Bool {
  let min_d2 = min_dist * min_dist
  for i in 0..<upto {
    if not(game.parcels[i].active) {
      continue
    }
    if @types.dist2(x, y, game.parcels[i].x, game.parcels[i].y) < min_d2 {
      return false
    }
  }
  true
}

///|
/// Clears existing parcels and places `count` new ones at valid random world positions, with a fallback grid layout if placement fails.
fn @types.Game::setup_parcels(game : @types.Game, count : Int) -> Unit {
  game.clear_parcels()

  for i in 0..<count {
    let mut placed = false

    for _attempt in 0..<64 {
      let p = random_world_point(@types.parcel_spawn_margin)
      if not(game.far_from_exits(p.0, p.1, 116.0)) {
        continue
      }
      if not(far_from_spawn(p.0, p.1, 150.0)) {
        continue
      }
      if not(game.far_from_active_parcels(p.0, p.1, 82.0, i)) {
        continue
      }

      game.parcels[i].active = true
      game.parcels[i].delivered = false
      game.parcels[i].x = p.0
      game.parcels[i].y = p.1
      game.parcels[i].pulse = @types.randf(0.0, 6.0)
      placed = true
      break
    }

    if not(placed) {
      let fx = @types.world_left + 130.0 + Float::from_int(i % 4) * 270.0
      let fy = @types.world_top + 140.0 + Float::from_int(i / 4) * 190.0
      game.parcels[i].active = true
      game.parcels[i].delivered = false
      game.parcels[i].x = @types.clampf(
        fx,
        @types.world_left + 100.0,
        @types.world_right - 100.0,
      )
      game.parcels[i].y = @types.clampf(
        fy,
        @types.world_top + 100.0,
        @types.world_bottom - 100.0,
      )
      game.parcels[i].pulse = @types.randf(0.0, 6.0)
    }
  }
}

///|
/// Clears existing guards and spawns `count` new patrol guards with speed, cone range, and cone angle scaled by `wave`.
fn @types.Game::setup_guards(
  game : @types.Game,
  wave : Int,
  count : Int,
) -> Unit {
  game.clear_guards()

  let wavef = Float::from_int(wave - 1)
  let cone_add = Float::from_int((wave - 1).clamp(min=0, max=8)) * 1.6

  for i in 0..<count {
    let p0 = random_world_point(@types.guard_spawn_margin)
    let mut p1 = random_world_point(@types.guard_spawn_margin)

    if @types.dist2(p0.0, p0.1, p1.0, p1.1) < 140.0 * 140.0 {
      p1 = (
        @types.clampf(
          p0.0 + @types.randf(-240.0, 240.0),
          @types.world_left + @types.guard_spawn_margin,
          @types.world_right - @types.guard_spawn_margin,
        ),
        @types.clampf(
          p0.1 + @types.randf(-220.0, 220.0),
          @types.world_top + @types.guard_spawn_margin,
          @types.world_bottom - @types.guard_spawn_margin,
        ),
      )
    }

    game.guards[i].active = true
    game.guards[i].x = p0.0
    game.guards[i].y = p0.1
    game.guards[i].vx = 0.0
    game.guards[i].vy = 0.0
    game.guards[i].dir_deg = @types.heading_deg(p1.0 - p0.0, p1.1 - p0.1)
    game.guards[i].patrol_a_x = p0.0
    game.guards[i].patrol_a_y = p0.1
    game.guards[i].patrol_b_x = p1.0
    game.guards[i].patrol_b_y = p1.1
    game.guards[i].to_b = true
    game.guards[i].speed = @types.guard_speed_base +
      wavef * @types.guard_speed_wave_gain +
      @types.randf(-8.0, 8.0)
    game.guards[i].cone_range = @types.guard_cone_range_base +
      wavef * @types.guard_cone_range_wave_gain +
      @types.randf(-18.0, 22.0)
    game.guards[i].cone_half_angle = @types.guard_cone_half_angle_base +
      cone_add
    game.guards[i].alert_t = 0.0
    game.guards[i].investigate_t = 0.0
    game.guards[i].target_x = p1.0
    game.guards[i].target_y = p1.1
  }
}

///|
/// Clears existing traps and places `count` new traps at random world positions away from exits and spawn, with a fallback grid layout if placement fails.
fn @types.Game::setup_traps(
  game : @types.Game,
  _wave : Int,
  count : Int,
) -> Unit {
  game.clear_traps()

  for i in 0..<count {
    let mut placed = false

    for _attempt in 0..<48 {
      let p = random_world_point(@types.trap_spawn_margin)
      if not(game.far_from_exits(p.0, p.1, 88.0)) {
        continue
      }
      if not(far_from_spawn(p.0, p.1, 112.0)) {
        continue
      }

      game.traps[i].active = true
      game.traps[i].x = p.0
      game.traps[i].y = p.1
      game.traps[i].radius = @types.trap_radius_base + @types.randf(-3.0, 5.0)
      game.traps[i].blink_t = @types.randf(0.0, 8.0)
      game.traps[i].cooldown = @types.randf(0.0, 0.6)
      placed = true
      break
    }

    if not(placed) {
      game.traps[i].active = true
      game.traps[i].x = @types.world_left +
        120.0 +
        Float::from_int(i % 6) * 200.0
      game.traps[i].y = @types.world_top +
        120.0 +
        Float::from_int(i / 6) * 120.0
      game.traps[i].radius = @types.trap_radius_base
      game.traps[i].blink_t = @types.randf(0.0, 6.0)
      game.traps[i].cooldown = @types.randf(0.0, 0.5)
    }
  }
}

///|
/// Initialises all wave-level state: resets player position, computes delivery targets and timer, and spawns parcels, guards, and traps for `wave`.
fn @types.Game::setup_wave(game : @types.Game, wave : Int) -> Unit {
  game.state = Play
  game.wave = wave
  game.delivered_wave = 0
  game.wave_clock = 0.0
  game.alarm_flash = 0.0

  game.player.x = @types.player_spawn_x()
  game.player.y = @types.player_spawn_y()
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.facing_deg = -90.0
  game.player.stealth = @types.player_stealth_max
  game.player.carrying_parcel = -1

  game.target_deliveries = (@types.wave_target_base + (wave - 1) / 2).clamp(
    min=@types.wave_target_base,
    max=@types.max_delivery_target,
  )

  let parcel_count = (game.target_deliveries + 2).clamp(
    min=game.target_deliveries,
    max=@types.max_parcels,
  )
  let guard_count = (2 + wave).clamp(min=2, max=@types.max_guards)
  let trap_count = (4 + wave * 2).clamp(min=4, max=@types.max_traps)

  game.smoke_stock = (@types.smoke_stock_base + (wave - 1) / 2).clamp(
    min=@types.smoke_stock_base,
    max=@types.max_smokes,
  )

  game.time_left = @types.maxf(
    @types.wave_min_time,
    @types.wave_time_base -
    Float::from_int(wave - 1) * @types.wave_time_decay +
    Float::from_int(game.target_deliveries) * 3.2,
  )

  game.setup_parcels(parcel_count)
  game.setup_guards(wave, guard_count)
  game.setup_traps(wave, trap_count)
  game.clear_smokes()

  if wave == 1 {
    game.set_hint("Collect parcels, then deliver them at glowing exits.", 4.0)
  } else {
    game.set_hint("Wave \{wave}: more guards and traps are active.", 2.6)
  }
}

///|
/// Resets score, total deliveries, and fail reason, then starts the first wave of a new run.
fn @types.Game::start_new_run(game : @types.Game) -> Unit {
  game.score = 0
  game.delivered_total = 0
  game.fail_reason = ""
  game.player.health = @types.player_health_max
  game.setup_wave(1)
}

///|
/// Awards wave-completion score (including time bonus), partially restores player health, updates best wave, and begins the next wave.
fn @types.Game::advance_wave(game : @types.Game) -> Unit {
  let time_bonus = (@types.maxf(0.0, game.time_left) *
  @types.wave_clear_time_score_mult).to_int()
  game.score = game.score +
    @types.wave_clear_score_base +
    game.wave * @types.wave_clear_score_wave_bonus +
    time_bonus

  game.player.health = @types.minf(
    @types.player_health_max,
    game.player.health + @types.wave_clear_health_recover,
  )

  let next_wave = game.wave + 1
  if next_wave > game.best_wave {
    game.best_wave = next_wave
  }

  game.setup_wave(next_wave)
}

///|
/// Transitions the game to the Retry state, records the failure reason, and updates the best wave tracker.
fn @types.Game::fail_mission(game : @types.Game, reason : String) -> Unit {
  if game.wave > game.best_wave {
    game.best_wave = game.wave
  }
  game.state = Retry
  game.fail_reason = reason
  game.player.carrying_parcel = -1
  game.alarm_flash = 0.0
}

///|
/// Returns the index of a free smoke slot, or the slot with the least remaining life if none are available.
fn @types.Game::alloc_smoke_slot(game : @types.Game) -> Int {
  for i, slot in game.smokes {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut oldest = 0
    let mut life = game.smokes[0].life
    for i in 1..<game.smokes.length() {
      if game.smokes[i].life < life {
        life = game.smokes[i].life
        oldest = i
      }
    }

    oldest
  }
}

///|
/// Deploys a smoke decoy at the player's current position, consuming one smoke charge and briefly raising the alarm flash.
fn @types.Game::deploy_smoke(game : @types.Game) -> Unit {
  if game.smoke_stock <= 0 {
    game.set_hint("No smoke decoys left this wave.", 1.2)
    return
  }

  let idx = game.alloc_smoke_slot()
  game.smokes[idx].active = true
  game.smokes[idx].x = game.player.x
  game.smokes[idx].y = game.player.y
  game.smokes[idx].radius = @types.smoke_radius_base +
    Float::from_int(game.wave - 1) * 2.0
  game.smokes[idx].life = @types.smoke_life_secs
  game.smoke_stock = game.smoke_stock - 1

  game.alarm_flash = @types.maxf(game.alarm_flash, 0.25)
  game.set_hint("Smoke decoy deployed.", 0.9)
}

///|
/// Returns the index of the closest active, undelivered parcel within squared distance `max_d2` of the player, or -1 if none qualify.
fn @types.Game::nearest_parcel(game : @types.Game, max_d2 : Float) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.parcels.length() {
    if not(game.parcels[i].active) || game.parcels[i].delivered {
      continue
    }

    let d2 = @types.dist2(
      game.player.x,
      game.player.y,
      game.parcels[i].x,
      game.parcels[i].y,
    )
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
/// Returns the index of the closest active exit within squared distance `max_d2` of the player, or -1 if none qualify.
fn @types.Game::nearest_exit(game : @types.Game, max_d2 : Float) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.exits.length() {
    if not(game.exits[i].active) {
      continue
    }

    let d2 = @types.dist2(
      game.player.x,
      game.player.y,
      game.exits[i].x,
      game.exits[i].y,
    )
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
/// Handles the player's interact action: delivers a carried parcel to a nearby exit, drops it if no exit is close, or picks up the nearest parcel.
fn @types.Game::try_interact(game : @types.Game) -> Unit {
  if game.player.carrying_parcel >= 0 {
    let exit_idx = game.nearest_exit(
      (@types.interaction_range + @types.exit_radius) *
      (@types.interaction_range + @types.exit_radius),
    )

    if exit_idx >= 0 {
      let pidx = game.player.carrying_parcel
      if pidx >= 0 &&
        game.parcels[pidx].active &&
        not(game.parcels[pidx].delivered) {
        game.parcels[pidx].active = false
        game.parcels[pidx].delivered = true
        game.player.carrying_parcel = -1
        game.delivered_wave = game.delivered_wave + 1
        game.delivered_total = game.delivered_total + 1
        game.score = game.score + 110 + game.wave * 24
        game.player.stealth = @types.minf(
          @types.player_stealth_max,
          game.player.stealth + 10.0,
        )
        game.set_hint(
          "Parcel delivered (\{game.delivered_wave}/\{game.target_deliveries}).",
          1.2,
        )
      }
      return
    }

    let pidx = game.player.carrying_parcel
    if pidx >= 0 {
      let drop_x = @types.clampf(
        game.player.x +
        @math.cosf(game.player.facing_deg * @types.deg_to_rad) * 24.0,
        @types.world_left + 60.0,
        @types.world_right - 60.0,
      )
      let drop_y = @types.clampf(
        game.player.y +
        @math.sinf(game.player.facing_deg * @types.deg_to_rad) * 24.0,
        @types.world_top + 60.0,
        @types.world_bottom - 60.0,
      )

      game.parcels[pidx].x = drop_x
      game.parcels[pidx].y = drop_y
      game.player.carrying_parcel = -1
      game.set_hint("Parcel dropped.", 0.8)
    }
    return
  }

  let parcel_idx = game.nearest_parcel(
    @types.interaction_range * @types.interaction_range,
  )
  if parcel_idx >= 0 {
    game.player.carrying_parcel = parcel_idx
    game.set_hint("Parcel picked up. Reach any marked exit.", 1.2)
  } else {
    game.set_hint("No parcel in reach.", 0.5)
  }
}

///|
/// Moves the player based on current input, applies sprint burn and carry penalty, updates facing direction, and returns the noise pressure generated this frame.
fn @types.Game::update_player_motion(game : @types.Game, dt : Float) -> Float {
  let ix = game.input.move_x
  let iy = game.input.move_y
  let moving = ix * ix + iy * iy > 0.0001

  let mut speed = @types.player_base_speed
  if game.player.carrying_parcel >= 0 {
    speed = speed * @types.player_carry_speed_mult
  }

  let mut pressure : Float = 0.0

  if moving && game.input.sprint_hold {
    speed = speed * @types.player_sprint_mult
    pressure = pressure + @types.sprint_noise_pressure
    game.player.stealth = @types.clampf(
      game.player.stealth - @types.sprint_stealth_burn * dt,
      0.0,
      @types.player_stealth_max,
    )
  }

  game.player.vx = ix * speed
  game.player.vy = iy * speed

  game.player.x = game.player.x + game.player.vx * dt
  game.player.y = game.player.y + game.player.vy * dt

  game.player.x = @types.clampf(
    game.player.x,
    @types.world_left + @types.player_radius,
    @types.world_right - @types.player_radius,
  )
  game.player.y = @types.clampf(
    game.player.y,
    @types.world_top + @types.player_radius,
    @types.world_bottom - @types.player_radius,
  )

  if moving {
    game.player.facing_deg = @types.heading_deg(ix, iy)
  }

  if game.player.carrying_parcel >= 0 {
    let pidx = game.player.carrying_parcel
    if pidx >= 0 && game.parcels[pidx].active {
      let follow_x = game.player.x -
        @math.cosf(game.player.facing_deg * @types.deg_to_rad) * 8.0
      let follow_y = game.player.y -
        @math.sinf(game.player.facing_deg * @types.deg_to_rad) * 8.0
      game.parcels[pidx].x = follow_x
      game.parcels[pidx].y = follow_y
    }
  }

  pressure
}

///|
/// Advances each active smoke's lifetime and deactivates it when expired.
fn @types.Game::update_smokes(game : @types.Game, dt : Float) -> Unit {
  for smoke in game.smokes {
    if not(smoke.active) {
      continue
    }

    smoke.life = smoke.life - dt
    if smoke.life <= 0.0 {
      smoke.active = false
      smoke.life = 0.0
    }
  }
}

///|
/// Returns a multiplier that reduces detection pressure when the player is inside an active smoke cloud (returns `smoke_cover_factor`), or 1.0 otherwise.
fn @types.Game::player_smoke_cover(game : @types.Game) -> Float {
  let mut factor : Float = 1.0

  for smoke in game.smokes {
    if not(smoke.active) {
      continue
    }

    if @types.dist2(game.player.x, game.player.y, smoke.x, smoke.y) <=
      smoke.radius * smoke.radius {
      factor = @types.minf(factor, @types.smoke_cover_factor)
    }
  }

  factor
}

///|
/// Returns `(found, cx, cy, d2)` for the active smoke nearest to `(x, y)`, or `(false, 0, 0, 0)` if no active smokes exist.
fn @types.Game::nearest_smoke_target(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Bool, Float, Float, Float) {
  let mut found = false
  let mut best_x : Float = 0.0
  let mut best_y : Float = 0.0
  let mut best_d2 : Float = 0.0

  for smoke in game.smokes {
    if not(smoke.active) {
      continue
    }

    let d2 = @types.dist2(x, y, smoke.x, smoke.y)
    if not(found) || d2 < best_d2 {
      found = true
      best_x = smoke.x
      best_y = smoke.y
      best_d2 = d2
    }
  }

  (found, best_x, best_y, best_d2)
}

///|
/// Sets every active guard's alert timer to at least `alert_time` and directs them toward the player's current position.
fn @types.Game::alert_all_guards(
  game : @types.Game,
  alert_time : Float,
) -> Unit {
  for guard_val in game.guards {
    if guard_val.active {
      guard_val.alert_t = @types.maxf(guard_val.alert_t, alert_time)
      guard_val.target_x = game.player.x
      guard_val.target_y = game.player.y
    }
  }
}

///|
/// Steps each active guard's patrol, alert, investigate, and smoke-lure AI; moves guards toward their current target; and returns the total detection pressure accumulated this frame.
fn @types.Game::update_guards(game : @types.Game, dt : Float) -> Float {
  let mut pressure : Float = 0.0
  let wave_scale : Float = (1.0 : Float) +
    Float::from_int(game.wave - 1) * (0.08 : Float)

  for guard_val in game.guards {
    if not(guard_val.active) {
      continue
    }

    guard_val.alert_t = @types.maxf(0.0, guard_val.alert_t - dt)
    guard_val.investigate_t = @types.maxf(0.0, guard_val.investigate_t - dt)

    let smoke = game.nearest_smoke_target(guard_val.x, guard_val.y)

    let mut tx = if guard_val.to_b {
      guard_val.patrol_b_x
    } else {
      guard_val.patrol_a_x
    }
    let mut ty = if guard_val.to_b {
      guard_val.patrol_b_y
    } else {
      guard_val.patrol_a_y
    }
    let mut move_speed = guard_val.speed

    if smoke.0 &&
      smoke.3 <= @types.guard_smoke_lure_range * @types.guard_smoke_lure_range {
      tx = smoke.1
      ty = smoke.2
      move_speed = guard_val.speed * 1.2
      guard_val.investigate_t = @types.guard_investigate_hold
      guard_val.target_x = smoke.1
      guard_val.target_y = smoke.2
    } else if guard_val.alert_t > 0.0 {
      tx = game.player.x
      ty = game.player.y
      move_speed = guard_val.speed * @types.guard_alert_speed_mult
      guard_val.target_x = game.player.x
      guard_val.target_y = game.player.y
    } else if guard_val.investigate_t > 0.0 {
      tx = guard_val.target_x
      ty = guard_val.target_y
      move_speed = guard_val.speed * 1.12
    } else if @types.dist2(guard_val.x, guard_val.y, tx, ty) <= 18.0 * 18.0 {
      guard_val.to_b = not(guard_val.to_b)
      tx = if guard_val.to_b {
        guard_val.patrol_b_x
      } else {
        guard_val.patrol_a_x
      }
      ty = if guard_val.to_b {
        guard_val.patrol_b_y
      } else {
        guard_val.patrol_a_y
      }
    }

    let dx = tx - guard_val.x
    let dy = ty - guard_val.y
    let len2 = dx * dx + dy * dy

    if len2 > 1.0 {
      let inv : Float = (1.0 : Float) / len2.sqrt()
      guard_val.vx = dx * inv * move_speed
      guard_val.vy = dy * inv * move_speed
    } else {
      guard_val.vx = 0.0
      guard_val.vy = 0.0
    }

    guard_val.x = guard_val.x + guard_val.vx * dt
    guard_val.y = guard_val.y + guard_val.vy * dt

    guard_val.x = @types.clampf(
      guard_val.x,
      @types.world_left + @types.guard_spawn_margin * 0.4,
      @types.world_right - @types.guard_spawn_margin * 0.4,
    )
    guard_val.y = @types.clampf(
      guard_val.y,
      @types.world_top + @types.guard_spawn_margin * 0.4,
      @types.world_bottom - @types.guard_spawn_margin * 0.4,
    )

    if guard_val.vx.abs() + guard_val.vy.abs() > 0.1 {
      guard_val.dir_deg = @types.heading_deg(guard_val.vx, guard_val.vy)
    }

    let pdx = game.player.x - guard_val.x
    let pdy = game.player.y - guard_val.y
    let p_d2 = pdx * pdx + pdy * pdy

    if p_d2 <= guard_val.cone_range * guard_val.cone_range {
      let p_dist = @types.maxf(p_d2, 0.0001).sqrt()
      let ang_to_player = @types.heading_deg(pdx, pdy)
      let delta = @types.angle_delta_deg(ang_to_player, guard_val.dir_deg)

      if delta <= guard_val.cone_half_angle {
        let dist_factor : Float = (1.0 : Float) - p_dist / guard_val.cone_range
        let ang_factor : Float = (1.0 : Float) -
          delta / guard_val.cone_half_angle
        let intensity = @types.clampf(dist_factor * ang_factor, 0.0, 1.0)

        pressure = pressure +
          (
            @types.guard_detection_base +
            @types.guard_detection_peak * intensity
          ) *
          wave_scale

        guard_val.alert_t = @types.maxf(
          guard_val.alert_t,
          @types.guard_alert_hold + intensity * 0.6,
        )
        guard_val.target_x = game.player.x
        guard_val.target_y = game.player.y
      }
    }
  }

  pressure
}

///|
/// Advances each active trap's blink and cooldown timers; deals damage, drains stealth, and alerts guards when the player overlaps a trap whose cooldown has expired; returns the total trap pressure this frame.
fn @types.Game::update_traps(game : @types.Game, dt : Float) -> Float {
  let mut pressure : Float = 0.0

  for trap in game.traps {
    if not(trap.active) {
      continue
    }

    trap.blink_t = trap.blink_t + dt * (2.0 + Float::from_int(game.wave) * 0.18)
    trap.cooldown = @types.maxf(0.0, trap.cooldown - dt)

    let rr = trap.radius + @types.player_radius
    if @types.dist2(game.player.x, game.player.y, trap.x, trap.y) <= rr * rr {
      pressure = pressure + @types.trap_pressure

      if trap.cooldown <= 0.0 {
        trap.cooldown = @types.trap_trigger_cooldown

        let damage = @types.trap_damage_base +
          Float::from_int(game.wave - 1) * @types.trap_damage_wave_gain
        game.player.health = game.player.health - damage
        game.player.stealth = @types.maxf(0.0, game.player.stealth - 24.0)

        game.alarm_flash = 1.0
        game.set_hint("Trap triggered. Guards heard that.", 1.3)
        game.alert_all_guards(1.0)
      }
    }
  }

  pressure
}

///|
/// Advances the pulse animation phase on all active parcels.
fn @types.Game::update_parcel_pulses(game : @types.Game, dt : Float) -> Unit {
  for parcel in game.parcels {
    if not(parcel.active) {
      continue
    }
    parcel.pulse = parcel.pulse + dt * 3.2
  }
}

///|
/// Runs one frame of active gameplay: advances timers, processes smoke and interact actions, moves the player, updates smokes and guards and traps, applies stealth and health consequences, and checks for wave completion or failure.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.wave_clock = game.wave_clock + dt
  game.time_left = game.time_left - dt
  game.alarm_flash = @types.maxf(0.0, game.alarm_flash - dt * 1.8)
  game.info_t = @types.maxf(0.0, game.info_t - dt)

  if game.input.smoke_press {
    game.deploy_smoke()
  }

  if game.input.interact_press {
    game.try_interact()
  }

  let mut pressure = game.update_player_motion(dt)
  game.update_smokes(dt)

  pressure = pressure + game.update_guards(dt)
  pressure = pressure + game.update_traps(dt)
  pressure = pressure * game.player_smoke_cover()

  if pressure > 0.1 {
    game.player.stealth = @types.clampf(
      game.player.stealth - pressure * dt,
      0.0,
      @types.player_stealth_max,
    )
    if pressure > 14.0 {
      game.alarm_flash = @types.maxf(game.alarm_flash, 0.45)
    }
  } else {
    game.player.stealth = @types.clampf(
      game.player.stealth + @types.stealth_recovery_per_sec * dt,
      0.0,
      @types.player_stealth_max,
    )
  }

  if game.player.stealth <= 0.0 && pressure > 0.2 {
    game.player.health = game.player.health -
      @types.stealth_break_damage_per_sec * dt
    game.alarm_flash = @types.maxf(game.alarm_flash, 0.6)
  }

  game.player.health = @types.clampf(
    game.player.health,
    0.0,
    @types.player_health_max,
  )

  game.update_parcel_pulses(dt)

  if game.player.health <= 0.0 {
    game.fail_mission("You were overwhelmed by guard pressure.")
    return
  }

  if game.time_left <= 0.0 {
    game.fail_mission("Courier timer expired.")
    return
  }

  if game.delivered_wave >= game.target_deliveries {
    game.advance_wave()
  }
}

///|
/// Advances the game simulation by one frame using the current input state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.update_input()
  match game.state {
    Title => if game.input.start_press { game.start_new_run() }
    Play => game.update_play(dt)
    Retry => if game.input.retry_press { game.start_new_run() }
  }
}
