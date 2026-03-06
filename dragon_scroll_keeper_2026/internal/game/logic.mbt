///|
/// Sets the HUD message string and its display lifetime in seconds.
fn @types.Game::set_message(
  game : @types.Game,
  text : String,
  ttl : Float,
) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
/// Resets every raider slot to its default inactive state.
fn @types.Game::clear_raiders(game : @types.Game) -> Unit {
  for i in 0..<game.raiders.length() {
    game.raiders[i] = Raider()
  }
}

///|
/// Resets every flame slot to its default inactive state.
fn @types.Game::clear_flames(game : @types.Game) -> Unit {
  for i in 0..<game.flames.length() {
    game.flames[i] = Flame()
  }
}

///|
/// Zeroes the severity of every breach and resets their raider and ember spawn cooldowns to fresh random values.
fn @types.Game::clear_breaches(game : @types.Game) -> Unit {
  for breach in game.breaches {
    breach.severity = 0.0
    breach.raider_cd = @types.randf(0.8, 1.6)
    breach.ember_cd = @types.randf(0.7, 1.4)
  }
}

///|
/// Repositions the keeper to the vault room centre and resets all keeper fields including stamina, ink shields, facing direction, and cooldown timers to their starting values.
fn @types.Game::reset_keeper(game : @types.Game) -> Unit {
  game.keeper.room = @types.vault_room
  game.keeper.x = @types.chamber_center_x()
  game.keeper.y = @types.chamber_center_y()
  game.keeper.facing_x = 1.0
  game.keeper.facing_y = 0.0
  game.keeper.stamina = @types.keeper_stamina_max
  game.keeper.extinguisher_mode = false
  game.keeper.action_cd = 0.0
  game.keeper.shield_cd = 0.0
  game.keeper.shield_t = 0.0
  game.keeper.ink_shields = @types.ink_shield_stock_start
}

///|
/// Increases the severity of the specified room's breach by `amount` (clamped to the max), and primes the raider and ember cooldowns if they are nearly expired.
fn @types.Game::raise_breach(
  game : @types.Game,
  room : Int,
  amount : Float,
) -> Unit {
  let idx = room.clamp(min=0, max=@types.chamber_count - 1)
  game.breaches[idx].severity = @types.clampf(
    game.breaches[idx].severity + amount,
    0.0,
    @types.breach_severity_max,
  )

  if game.breaches[idx].raider_cd <= 0.1 {
    game.breaches[idx].raider_cd = @types.randf(0.25, 0.95)
  }
  if game.breaches[idx].ember_cd <= 0.1 {
    game.breaches[idx].ember_cd = @types.randf(0.35, 1.10)
  }
}

///|
/// Clears all entities, resets the keeper and all session stats to wave-1 starting values, transitions to the Playing state, and raises initial breaches to begin the first wave.
fn @types.Game::start_new_run(game : @types.Game) -> Unit {
  game.clear_breaches()
  game.clear_raiders()
  game.clear_flames()
  game.reset_keeper()

  game.state = Playing
  game.wave = 1
  game.wave_t = 0.0
  game.wave_goal_t = @types.wave_duration(1)
  game.breach_event_cd = 1.4
  game.scroll_integrity = @types.scroll_integrity_max
  game.seal_charges = @types.seal_charges_start
  game.score = 0
  game.raiders_defeated = 0
  game.flames_cleared = 0
  game.seals_done = 0
  game.set_message(
    "Wave 1 begins. Seal breaches before the archive burns.", 2.4,
  )

  game.raise_breach(@types.vault_room, 26.0)
  game.raise_breach(@types.randi(0, @types.chamber_count - 1), 20.0)
}

///|
/// Clears all entities, resets the keeper and session state, transitions to the Title state, and sets the title-screen idle message.
fn @types.Game::return_to_title(game : @types.Game) -> Unit {
  game.clear_breaches()
  game.clear_raiders()
  game.clear_flames()
  game.reset_keeper()

  game.state = Title
  game.wave = 1
  game.wave_t = 0.0
  game.wave_goal_t = @types.wave_duration(1)
  game.breach_event_cd = 1.4
  game.scroll_integrity = @types.scroll_integrity_max
  game.seal_charges = @types.seal_charges_start
  game.set_message("Press J to begin guarding the dragon scroll vault.", 99.0)
}

///|
/// Transitions to the GameOver state (idempotent), updates best score, and sets the game-over message including the failure reason.
fn @types.Game::enter_game_over(game : @types.Game, reason : String) -> Unit {
  if game.state == GameOver {
    return
  }

  game.state = GameOver
  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.set_message(reason + " Press J or R to restart.", 99.0)
}

///|
/// Returns the index of the first inactive raider slot, or -1 if all slots are occupied.
fn @types.Game::alloc_raider(game : @types.Game) -> Int {
  for i, slot in game.raiders {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Returns the index of the first inactive flame slot, or -1 if all slots are occupied.
fn @types.Game::alloc_flame(game : @types.Game) -> Int {
  for i, slot in game.flames {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Allocates a raider slot, positions it near the specified room's breach anchor with wave-scaled HP, and returns whether the spawn succeeded.
fn @types.Game::spawn_raider_from_room(game : @types.Game, room : Int) -> Bool {
  let slot = game.alloc_raider()
  if slot < 0 {
    return false
  }

  let clamped_room = room.clamp(min=0, max=@types.chamber_count - 1)
  let start_x = @types.clampf(
    @types.breach_anchor_x(clamped_room) + @types.randf(-18.0, 18.0),
    @types.chamber_left + 20.0,
    @types.chamber_right() - 20.0,
  )
  let start_y = @types.clampf(
    @types.breach_anchor_y(clamped_room) + @types.randf(-22.0, 22.0),
    @types.chamber_top + 20.0,
    @types.chamber_bottom() - 20.0,
  )
  let wavef = Float::from_int(game.wave - 1)
  let hp = @types.raider_hp_base +
    wavef * @types.raider_hp_wave_bonus +
    @types.randf(-6.0, 9.0)

  game.raiders[slot] = {
    active: true,
    room: clamped_room,
    x: start_x,
    y: start_y,
    hp,
    max_hp: hp,
    panic_t: 0.0,
    attack_cd: @types.randf(0.35, 0.95),
  }
  true
}

///|
/// Allocates a flame slot, clamping the position inside chamber bounds and the intensity to [10, 120], and returns whether the spawn succeeded.
fn @types.Game::spawn_flame(
  game : @types.Game,
  room : Int,
  x : Float,
  y : Float,
  intensity : Float,
) -> Bool {
  let slot = game.alloc_flame()
  if slot < 0 {
    return false
  }

  let clamped_room = room.clamp(min=0, max=@types.chamber_count - 1)

  game.flames[slot] = {
    active: true,
    room: clamped_room,
    x: @types.clampf(
      x,
      @types.chamber_left + 18.0,
      @types.chamber_right() - 18.0,
    ),
    y: @types.clampf(
      y,
      @types.chamber_top + 18.0,
      @types.chamber_bottom() - 18.0,
    ),
    intensity: @types.clampf(intensity, 10.0, 120.0),
    spread_cd: @types.randf(0.8, 1.6),
  }
  true
}

///|
/// Deactivates a raider, increments the defeat counter, adds the score bonus, and partially replenishes the keeper's ink shield stock.
fn @types.Game::defeat_raider(
  game : @types.Game,
  idx : Int,
  score_bonus : Int,
) -> Unit {
  if idx < 0 || idx >= game.raiders.length() || !game.raiders[idx].active {
    return
  }

  game.raiders[idx] = Raider()
  game.raiders_defeated = game.raiders_defeated + 1
  game.score = game.score + score_bonus
  game.keeper.ink_shields = @types.minf(
    @types.ink_shield_stock_max,
    game.keeper.ink_shields + 0.16,
  )
}

///|
/// Returns the index of the nearest breach with positive severity in the given room within squared distance `max_d2`, or -1 if none qualify.
fn @types.Game::nearest_open_breach_index(
  game : @types.Game,
  room : Int,
  x : Float,
  y : Float,
  max_d2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.breaches.length() {
    if game.breaches[i].room != room || game.breaches[i].severity <= 0.0 {
      continue
    }

    let d2 = @types.dist2(
      x,
      y,
      @types.breach_anchor_x(game.breaches[i].room),
      @types.breach_anchor_y(game.breaches[i].room),
    )
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
/// Returns the index of the nearest active raider in the given room within squared distance `max_d2`, or -1 if none qualify.
fn @types.Game::nearest_raider_index(
  game : @types.Game,
  room : Int,
  x : Float,
  y : Float,
  max_d2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.raiders.length() {
    if !game.raiders[i].active || game.raiders[i].room != room {
      continue
    }

    let d2 = @types.dist2(x, y, game.raiders[i].x, game.raiders[i].y)
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
/// Returns the index of the nearest active flame in the given room within squared distance `max_d2`, or -1 if none qualify.
fn @types.Game::nearest_flame_index(
  game : @types.Game,
  room : Int,
  x : Float,
  y : Float,
  max_d2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.flames.length() {
    if !game.flames[i].active || game.flames[i].room != room {
      continue
    }

    let d2 = @types.dist2(x, y, game.flames[i].x, game.flames[i].y)
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
/// Moves the keeper by input axes at the appropriate speed, updates the facing direction, clamps position to chamber bounds, and handles room transitions through doorways on the left or right wall.
fn @types.Game::update_keeper_motion(game : @types.Game, dt : Float) -> Unit {
  let mut speed = @types.keeper_speed
  if game.keeper.extinguisher_mode {
    speed = speed * @types.keeper_mode_speed_scale
  }

  if game.input_x.abs() > 0.01 || game.input_y.abs() > 0.01 {
    game.keeper.facing_x = game.input_x
    game.keeper.facing_y = game.input_y
  }

  let mut next_x = game.keeper.x + game.input_x * speed * dt
  let next_y = @types.clampf(
    game.keeper.y + game.input_y * speed * dt,
    @types.chamber_top + @types.keeper_radius,
    @types.chamber_bottom() - @types.keeper_radius,
  )

  game.keeper.y = next_y

  let left_wall = @types.chamber_left + @types.keeper_radius
  let right_wall = @types.chamber_right() - @types.keeper_radius

  if next_x < left_wall {
    if game.input_x < 0.0 &&
      game.keeper.room > 0 &&
      (game.keeper.y - @types.door_center_y).abs() <= @types.door_half_h {
      game.keeper.room = game.keeper.room - 1
      next_x = right_wall - 1.0
      game.set_message("Entered " + @types.room_name(game.keeper.room), 0.45)
    } else {
      next_x = left_wall
    }
  } else if next_x > right_wall {
    if game.input_x > 0.0 &&
      game.keeper.room < @types.chamber_count - 1 &&
      (game.keeper.y - @types.door_center_y).abs() <= @types.door_half_h {
      game.keeper.room = game.keeper.room + 1
      next_x = left_wall + 1.0
      game.set_message("Entered " + @types.room_name(game.keeper.room), 0.45)
    } else {
      next_x = right_wall
    }
  }

  game.keeper.x = next_x
}

///|
/// Decrements the action, shield cooldown, and shield duration timers, and regenerates stamina at the rate appropriate for the keeper's current mode.
fn @types.Game::update_keeper_timers_and_resources(
  game : @types.Game,
  dt : Float,
) -> Unit {
  if game.keeper.action_cd > 0.0 {
    game.keeper.action_cd = @types.maxf(0.0, game.keeper.action_cd - dt)
  }
  if game.keeper.shield_cd > 0.0 {
    game.keeper.shield_cd = @types.maxf(0.0, game.keeper.shield_cd - dt)
  }
  if game.keeper.shield_t > 0.0 {
    game.keeper.shield_t = @types.maxf(0.0, game.keeper.shield_t - dt)
  }

  let regen = if game.keeper.extinguisher_mode {
    @types.keeper_stamina_regen_mode
  } else {
    @types.keeper_stamina_regen
  }

  game.keeper.stamina = @types.minf(
    @types.keeper_stamina_max,
    game.keeper.stamina + regen * dt,
  )
}

///|
/// Toggles the keeper between extinguisher mode and combat/sealing mode, and posts a brief status message.
fn @types.Game::toggle_extinguisher_mode(game : @types.Game) -> Unit {
  game.keeper.extinguisher_mode = !game.keeper.extinguisher_mode
  if game.keeper.extinguisher_mode {
    game.set_message("Extinguisher mode active.", 0.7)
  } else {
    game.set_message("Combat and sealing mode active.", 0.7)
  }
}

///|
/// Spends stamina to strike the nearest raider in attack range, dealing wave-scaled damage, panicking it briefly, and defeating it with a score bonus when HP reaches zero.
fn @types.Game::perform_attack_action(game : @types.Game) -> Unit {
  if game.keeper.stamina < @types.stamina_attack_cost {
    game.set_message("Stamina too low for a strike.", 0.55)
    return
  }

  let range2 = @types.attack_range * @types.attack_range
  let idx = game.nearest_raider_index(
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    range2,
  )

  if idx < 0 {
    game.set_message("No raider in reach.", 0.45)
    return
  }

  game.keeper.stamina = @types.maxf(
    0.0,
    game.keeper.stamina - @types.stamina_attack_cost,
  )
  game.keeper.action_cd = @types.keeper_action_cd

  let damage = @types.attack_damage +
    Float::from_int(game.wave - 1) * @types.attack_damage_wave_bonus
  game.raiders[idx].hp = game.raiders[idx].hp - damage
  game.raiders[idx].panic_t = 0.30
  game.score = game.score + 8

  if game.raiders[idx].hp <= 0.0 {
    game.defeat_raider(idx, 44 + game.wave * 4)
  }
}

///|
/// Spends a seal charge and stamina to reduce the nearest breach's severity by a wave-scaled amount; awards score and replenishes ink shields when the breach is fully sealed.
fn @types.Game::perform_seal_action(game : @types.Game) -> Unit {
  if game.seal_charges <= 0 {
    game.set_message("No seal charges left for this wave.", 0.65)
    return
  }
  if game.keeper.stamina < @types.stamina_seal_cost {
    game.set_message("Stamina too low to inscribe a seal.", 0.6)
    return
  }

  let range2 = @types.attack_range * @types.attack_range
  let idx = game.nearest_open_breach_index(
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    range2,
  )

  if idx < 0 {
    game.set_message("Move closer to a breach to seal it.", 0.5)
    return
  }

  game.seal_charges = game.seal_charges - 1
  game.keeper.stamina = @types.maxf(
    0.0,
    game.keeper.stamina - @types.stamina_seal_cost,
  )
  game.keeper.action_cd = @types.keeper_action_cd + 0.05

  let seal_power = @types.breach_seal_power +
    Float::from_int(game.wave - 1) * @types.breach_seal_wave_bonus
  game.breaches[idx].severity = @types.maxf(
    0.0,
    game.breaches[idx].severity - seal_power,
  )
  game.score = game.score + 28

  if game.breaches[idx].severity <= 0.0 {
    game.seals_done = game.seals_done + 1
    game.score = game.score + 90 + game.wave * 10
    game.keeper.ink_shields = @types.minf(
      @types.ink_shield_stock_max,
      game.keeper.ink_shields + 0.45,
    )
    game.set_message("Breach sealed. Ink shield reserve increased.", 1.0)
  } else {
    game.set_message("Breach pressure reduced.", 0.55)
  }
}

///|
/// Spends stamina to reduce the nearest flame's intensity by the extinguisher power; awards score and clears the flame slot when intensity reaches zero.
fn @types.Game::perform_extinguish_action(game : @types.Game) -> Unit {
  if game.keeper.stamina < @types.stamina_extinguish_cost {
    game.set_message("Stamina too low to use extinguisher.", 0.55)
    return
  }

  let range2 = @types.extinguisher_range * @types.extinguisher_range
  let idx = game.nearest_flame_index(
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    range2,
  )

  if idx < 0 {
    game.set_message("No flame in extinguisher range.", 0.45)
    return
  }

  game.keeper.stamina = @types.maxf(
    0.0,
    game.keeper.stamina - @types.stamina_extinguish_cost,
  )
  game.keeper.action_cd = @types.keeper_action_cd
  game.flames[idx].intensity = game.flames[idx].intensity -
    @types.extinguisher_power
  game.score = game.score + 16

  if game.flames[idx].intensity <= 0.0 {
    game.flames[idx] = Flame()
    game.flames_cleared = game.flames_cleared + 1
    game.score = game.score + 36 + game.wave * 3
    game.set_message("Flame extinguished.", 0.5)
  }
}

///|
/// Dispatches the action button press to extinguish, seal, or attack depending on the keeper's current mode and the targets within range.
fn @types.Game::handle_action_input(game : @types.Game) -> Unit {
  if !game.input_action_press || game.keeper.action_cd > 0.0 {
    return
  }

  if game.keeper.extinguisher_mode {
    game.perform_extinguish_action()
    return
  }

  let breach_idx = game.nearest_open_breach_index(
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    @types.attack_range * @types.attack_range,
  )

  if breach_idx >= 0 && game.seal_charges > 0 {
    game.perform_seal_action()
  } else {
    game.perform_attack_action()
  }
}

///|
/// Consumes one ink shield stock to activate a burst that damages all raiders and quenches flames within the shield radius, partially restores scroll integrity, and awards score for each hit.
fn @types.Game::trigger_ink_shield(game : @types.Game) -> Unit {
  if !game.input_shield_press {
    return
  }

  if game.keeper.shield_cd > 0.0 {
    game.set_message(
      "Ink burst cooling down " +
      game.keeper.shield_cd.to_int().to_string() +
      "s",
      0.6,
    )
    return
  }

  if game.keeper.ink_shields < 1.0 {
    game.set_message("No ink shield stock.", 0.5)
    return
  }

  game.keeper.ink_shields = game.keeper.ink_shields - 1.0
  game.keeper.shield_cd = @types.ink_shield_cooldown
  game.keeper.shield_t = @types.ink_shield_duration

  let radius2 = @types.ink_shield_radius * @types.ink_shield_radius
  let mut raider_hits = 0
  let mut flame_hits = 0

  for i in 0..<game.raiders.length() {
    if !game.raiders[i].active || game.raiders[i].room != game.keeper.room {
      continue
    }

    if @types.dist2(
        game.keeper.x,
        game.keeper.y,
        game.raiders[i].x,
        game.raiders[i].y,
      ) >
      radius2 {
      continue
    }

    game.raiders[i].hp = game.raiders[i].hp - @types.ink_shield_damage
    game.raiders[i].panic_t = 1.3
    raider_hits = raider_hits + 1

    if game.raiders[i].hp <= 0.0 {
      game.defeat_raider(i, 30 + game.wave * 3)
    }
  }

  for i in 0..<game.flames.length() {
    if !game.flames[i].active || game.flames[i].room != game.keeper.room {
      continue
    }

    if @types.dist2(
        game.keeper.x,
        game.keeper.y,
        game.flames[i].x,
        game.flames[i].y,
      ) >
      radius2 {
      continue
    }

    game.flames[i].intensity = game.flames[i].intensity -
      @types.ink_shield_fire_quench
    flame_hits = flame_hits + 1

    if game.flames[i].intensity <= 0.0 {
      game.flames[i] = Flame()
      game.flames_cleared = game.flames_cleared + 1
      game.score = game.score + 20
    }
  }

  game.scroll_integrity = @types.minf(
    @types.scroll_integrity_max,
    game.scroll_integrity + 3.5,
  )
  game.score = game.score + 18 + raider_hits * 4 + flame_hits * 3
  game.set_message("Ink shield burst released.", 0.7)
}

///|
/// Advances the wave timer and, when the wave duration elapses, increments the wave counter, replenishes seal charges and ink shields, restores stamina and scroll integrity, awards wave-completion score, and raises two new breaches.
fn @types.Game::update_wave_progress(game : @types.Game, dt : Float) -> Unit {
  game.wave_t = game.wave_t + dt

  if game.wave_t < game.wave_goal_t {
    return
  }

  game.wave = game.wave + 1
  game.wave_t = 0.0
  game.wave_goal_t = @types.wave_duration(game.wave)
  game.seal_charges = (game.seal_charges + @types.seal_charges_wave_gain).clamp(
    min=0,
    max=@types.seal_charges_max,
  )
  game.keeper.ink_shields = @types.minf(
    @types.ink_shield_stock_max,
    game.keeper.ink_shields + 1.0,
  )
  game.keeper.stamina = @types.keeper_stamina_max
  game.scroll_integrity = @types.minf(
    @types.scroll_integrity_max,
    game.scroll_integrity + 5.0,
  )
  game.score = game.score +
    140 +
    game.wave * 22 +
    game.scroll_integrity.to_int()

  game.raise_breach(
    @types.randi(0, @types.chamber_count - 1),
    34.0 + Float::from_int(game.wave),
  )
  game.raise_breach(
    @types.randi(0, @types.chamber_count - 1),
    16.0 + Float::from_int(game.wave),
  )

  game.set_message(
    "Wave " + game.wave.to_string() + " surges. Charges replenished.",
    1.4,
  )
}

///|
/// Fires periodic breach events to raise pressure in random rooms, grows existing breaches by wave-scaled rate, spawns raiders and flames from breaches on their cooldowns, and returns the total scroll integrity drain for this frame.
fn @types.Game::update_breach_system(game : @types.Game, dt : Float) -> Float {
  game.breach_event_cd = game.breach_event_cd - dt

  if game.breach_event_cd <= 0.0 {
    let mut events = 1
    if game.wave >= 6 {
      events = events + 1
    }
    if game.wave >= 12 {
      events = events + 1
    }

    for _i in 0..<events {
      let room = @types.randi(0, @types.chamber_count - 1)
      let pressure = @types.randf(12.0, 25.0) +
        Float::from_int(game.wave - 1) * 1.6
      game.raise_breach(room, pressure)
    }

    game.breach_event_cd = @types.maxf(
        @types.breach_event_cd_floor,
        @types.breach_event_cd_base - Float::from_int(game.wave - 1) * 0.22,
      ) +
      @types.randf(-0.25, 0.35)
  }

  let mut integrity_loss : Float = 0.0

  for breach in game.breaches {
    let severity = breach.severity
    if severity <= 0.0 {
      continue
    }

    let pressure = severity / @types.breach_severity_max
    integrity_loss = integrity_loss +
      pressure * @types.breach_integrity_drain * dt

    breach.severity = @types.clampf(
      severity + Float::from_int(game.wave - 1) * @types.breach_wave_growth * dt,
      0.0,
      @types.breach_severity_max,
    )

    breach.raider_cd = breach.raider_cd - dt * (1.0 + pressure * 0.8)
    if breach.raider_cd <= 0.0 {
      ignore(game.spawn_raider_from_room(breach.room))
      breach.raider_cd = @types.maxf(
        @types.raider_spawn_cd_floor,
        @types.raider_spawn_cd_base -
        Float::from_int(game.wave - 1) * 0.09 -
        pressure * 0.8 +
        @types.randf(-0.08, 0.16),
      )
    }

    breach.ember_cd = breach.ember_cd - dt * (1.0 + pressure * 0.5)
    if breach.ember_cd <= 0.0 {
      ignore(
        game.spawn_flame(
          breach.room,
          @types.breach_anchor_x(breach.room) + @types.randf(-26.0, 26.0),
          @types.breach_anchor_y(breach.room) + @types.randf(-24.0, 24.0),
          28.0 + pressure * 34.0,
        ),
      )
      breach.ember_cd = @types.maxf(
        @types.flame_spawn_cd_floor,
        @types.flame_spawn_cd_base -
        Float::from_int(game.wave - 1) * 0.08 -
        pressure * 0.55 +
        @types.randf(-0.10, 0.20),
      )
    }
  }

  integrity_loss
}

///|
/// Moves all active raiders toward their room goal (or away from the keeper when panicked), advances them through doorways, inflicts integrity damage when they reach the vault core, drains keeper stamina on contact, and returns the total integrity loss for this frame.
fn @types.Game::update_raiders(game : @types.Game, dt : Float) -> Float {
  let mut integrity_loss : Float = 0.0
  let wavef = Float::from_int(game.wave - 1)
  let speed_base = @types.raider_speed_base +
    wavef * @types.raider_speed_wave_bonus

  for raider in game.raiders {
    if !raider.active {
      continue
    }

    if raider.attack_cd > 0.0 {
      raider.attack_cd = @types.maxf(0.0, raider.attack_cd - dt)
    }
    if raider.panic_t > 0.0 {
      raider.panic_t = @types.maxf(0.0, raider.panic_t - dt)
    }

    let mut goal_x = @types.raider_goal_x(raider.room)
    let mut goal_y = @types.raider_goal_y(raider.room)
    let mut move_speed = speed_base

    if raider.panic_t > 0.0 && raider.room == game.keeper.room {
      goal_x = raider.x + (raider.x - game.keeper.x)
      goal_y = raider.y + (raider.y - game.keeper.y)
      move_speed = move_speed * 1.25
    }

    let dx = goal_x - raider.x
    let dy = goal_y - raider.y
    let d2 = dx * dx + dy * dy

    if d2 > 0.01 {
      let inv : Float = Float::from_int(1) / d2.sqrt()
      raider.x = raider.x + dx * inv * move_speed * dt
      raider.y = raider.y + dy * inv * move_speed * dt
    }

    raider.x = @types.clampf(
      raider.x,
      @types.chamber_left + @types.raider_radius,
      @types.chamber_right() - @types.raider_radius,
    )
    raider.y = @types.clampf(
      raider.y,
      @types.chamber_top + @types.raider_radius,
      @types.chamber_bottom() - @types.raider_radius,
    )

    if raider.room < @types.vault_room &&
      raider.x >= @types.chamber_right() - 10.0 &&
      (raider.y - @types.door_center_y).abs() <= @types.door_half_h {
      raider.room = raider.room + 1
      raider.x = @types.chamber_left + 12.0
    } else if raider.room > @types.vault_room &&
      raider.x <= @types.chamber_left + 10.0 &&
      (raider.y - @types.door_center_y).abs() <= @types.door_half_h {
      raider.room = raider.room - 1
      raider.x = @types.chamber_right() - 12.0
    }

    if raider.room == @types.vault_room &&
      @types.dist2(
        raider.x,
        raider.y,
        @types.vault_core_x(),
        @types.vault_core_y(),
      ) <=
      52.0 * 52.0 &&
      raider.attack_cd <= 0.0 {
      integrity_loss = integrity_loss +
        @types.raider_vault_strike +
        wavef * 0.45
      raider.attack_cd = @types.randf(0.68, 1.14)
    }

    if raider.room == game.keeper.room &&
      @types.dist2(raider.x, raider.y, game.keeper.x, game.keeper.y) <=
      (@types.keeper_radius + @types.raider_radius + 4.0) *
      (@types.keeper_radius + @types.raider_radius + 4.0) &&
      raider.attack_cd <= 0.0 {
      game.keeper.stamina = @types.maxf(
        0.0,
        game.keeper.stamina - @types.raider_keeper_stamina_hit,
      )
      integrity_loss = integrity_loss + 0.7
      raider.attack_cd = 0.9
    }
  }

  integrity_loss
}

///|
/// Decays flame intensity each frame, feeds adjacent breach severity, spreads child flames when spread cooldown elapses, deactivates spent flames, and returns the total scroll integrity drain weighted by room and flame intensity.
fn @types.Game::update_flames(game : @types.Game, dt : Float) -> Float {
  let mut integrity_loss : Float = 0.0

  for i in 0..<game.flames.length() {
    if !game.flames[i].active {
      continue
    }

    game.flames[i].intensity = @types.maxf(
      0.0,
      game.flames[i].intensity - @types.flame_decay * dt,
    )
    if game.flames[i].intensity <= 0.5 {
      game.flames[i] = Flame()
      continue
    }

    let room = game.flames[i].room
    let room_mul = if room == @types.vault_room {
      @types.flame_integrity_vault_mul
    } else {
      @types.flame_integrity_side_mul
    }
    integrity_loss = integrity_loss + game.flames[i].intensity * room_mul * dt

    game.breaches[room].severity = @types.clampf(
      game.breaches[room].severity +
      game.flames[i].intensity * @types.flame_breach_feed * dt,
      0.0,
      @types.breach_severity_max,
    )

    game.flames[i].spread_cd = game.flames[i].spread_cd -
      dt * (1.0 + Float::from_int(game.wave - 1) * 0.04)

    if game.flames[i].spread_cd <= 0.0 {
      if game.flames[i].intensity >= 16.0 {
        ignore(
          game.spawn_flame(
            room,
            game.flames[i].x + @types.randf(-54.0, 54.0),
            game.flames[i].y + @types.randf(-42.0, 42.0),
            game.flames[i].intensity * 0.58,
          ),
        )
      }

      game.flames[i].spread_cd = @types.maxf(
        @types.flame_spread_cd_floor,
        @types.flame_spread_cd_base -
        Float::from_int(game.wave - 1) * 0.08 +
        @types.randf(-0.18, 0.24),
      )
    }
  }

  integrity_loss
}

///|
/// Handles the Title state: starts a new run when any of the action, shield, or restart inputs is pressed.
fn @types.Game::update_title_state(game : @types.Game) -> Unit {
  if game.input_action_press ||
    game.input_shield_press ||
    game.input_restart_press {
    game.start_new_run()
  }
}

///|
/// Runs one Playing-state tick: handles pause and mode-toggle input, updates keeper timers/motion/abilities, advances wave progress, accumulates integrity loss from breaches/raiders/flames (reduced by active ink shield), and triggers game over when scroll integrity reaches zero.
fn @types.Game::update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.state = Paused
    game.set_message("Paused. P to resume, K for title.", 99.0)
    return
  }

  if game.input_cancel_press {
    game.toggle_extinguisher_mode()
  }

  game.update_keeper_timers_and_resources(dt)
  game.update_keeper_motion(dt)
  game.trigger_ink_shield()
  game.handle_action_input()

  game.update_wave_progress(dt)

  let mut integrity_loss : Float = 0.0
  integrity_loss = integrity_loss + game.update_breach_system(dt)
  integrity_loss = integrity_loss + game.update_raiders(dt)
  integrity_loss = integrity_loss + game.update_flames(dt)

  if game.keeper.shield_t > 0.0 {
    integrity_loss = integrity_loss *
      (Float::from_int(1) - @types.ink_shield_integrity_block)
  }

  game.scroll_integrity = @types.maxf(
    0.0,
    game.scroll_integrity - integrity_loss,
  )

  if game.scroll_integrity <= 0.0 {
    game.enter_game_over("The dragon scroll archive was lost.")
  }
}

///|
/// Handles the Paused state: resumes play on pause input, returns to title on cancel, and starts a new run on action or restart input.
fn @types.Game::update_paused_state(game : @types.Game) -> Unit {
  if game.input_pause_press {
    game.state = Playing
    game.set_message("Defense resumed.", 0.8)
    return
  }

  if game.input_cancel_press {
    game.return_to_title()
    return
  }

  if game.input_action_press || game.input_restart_press {
    game.start_new_run()
  }
}

///|
/// Handles the GameOver state: starts a new run on action or restart input, or returns to title on cancel input.
fn @types.Game::update_game_over_state(game : @types.Game) -> Unit {
  if game.input_action_press || game.input_restart_press {
    game.start_new_run()
    return
  }

  if game.input_cancel_press {
    game.return_to_title()
  }
}

///|
/// Advances the game simulation by one frame using the current input state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  let step = @types.clampf(dt, 0.0, 0.05)
  game.time_s = game.time_s + step

  if game.message_t > 0.0 {
    game.message_t = @types.maxf(0.0, game.message_t - step)
  }

  game.update_input()

  match game.state {
    Title => game.update_title_state()
    Playing => game.update_playing_state(step)
    Paused => game.update_paused_state()
    GameOver => game.update_game_over_state()
  }
}
