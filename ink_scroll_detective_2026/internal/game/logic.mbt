///|
/// Sets the HUD message text and resets its display timer to `ttl` seconds.
fn @types.Game::set_message(
  game : @types.Game,
  text : String,
  ttl : Float,
) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
/// Deactivates all incident slots and zeroes their fields.
fn @types.Game::clear_incidents(game : @types.Game) -> Unit {
  for incident in game.incidents {
    incident.active = false
    incident.x = 0
    incident.y = 0
    incident.culprit = 0
    incident.timer = 0.0
    incident.severity = 1
    incident.pulse_t = 0.0
  }
}

///|
/// Resets the full case state: clues, suspects, chain progress, incidents, timers, and message.
fn @types.Game::reset_case(game : @types.Game) -> Unit {
  for clue in game.clues {
    clue.discovered = false
    clue.glow_t = 0.0
  }

  for suspect in game.suspects {
    suspect.deduction_unlocked = false
    suspect.suspicion = 0.0
  }

  for i in 0..<game.chain_progress.length() {
    game.chain_progress[i] = 0
  }
  for i in 0..<game.evidence_score.length() {
    game.evidence_score[i] = 0
  }

  game.clear_incidents()

  game.state = Playing
  game.cursor_x = @types.city_cols / 2
  game.cursor_y = @types.city_rows / 2
  game.marked_suspect = -1
  game.trust = @types.trust_max
  game.score = 0
  game.case_time = @types.time_limit_s
  game.spawn_t = 1.8
  game.focus_t = 0.0
  game.focus_cd = 0.0
  game.city_time = 0.0
  game.solved_incidents = 0
  game.failed_incidents = 0
  game.wrong_accusations = 0
  game.clue_found = 0

  game.set_message("Case opened. Gather clues and stop incidents.", 2.2)
}

///|
/// Returns the index of the suspect whose home district is at `(cell_x, cell_y)`, or -1.
fn @types.Game::suspect_index_at_cell(
  game : @types.Game,
  cell_x : Int,
  cell_y : Int,
) -> Int {
  for i in 0..<game.suspects.length() {
    if game.suspects[i].home_x == cell_x && game.suspects[i].home_y == cell_y {
      return i
    }
  }
  -1
}

///|
/// Returns the index of a clue at the given cell; optionally filters to undiscovered only.
fn @types.Game::clue_index_at_cell(
  game : @types.Game,
  cell_x : Int,
  cell_y : Int,
  undiscovered_only : Bool,
) -> Int {
  for i in 0..<game.clues.length() {
    if game.clues[i].x != cell_x || game.clues[i].y != cell_y {
      continue
    }
    if undiscovered_only && game.clues[i].discovered {
      continue
    }
    return i
  }
  -1
}

///|
/// Returns the index of an active incident at the given cell, or -1 if none.
fn @types.Game::incident_index_at_cell(
  game : @types.Game,
  cell_x : Int,
  cell_y : Int,
) -> Int {
  for i in 0..<game.incidents.length() {
    if game.incidents[i].active &&
      game.incidents[i].x == cell_x &&
      game.incidents[i].y == cell_y {
      return i
    }
  }
  -1
}

///|
/// Returns the number of fully completed evidence chains for `suspect`.
fn @types.Game::completed_chains(game : @types.Game, suspect : Int) -> Int {
  if suspect < 0 || suspect >= @types.suspect_count {
    return 0
  }

  let mut done = 0
  for chain in 0..<@types.chains_per_suspect {
    let slot = @types.chain_slot(suspect, chain)
    if game.chain_progress[slot] >= @types.clue_steps_per_chain {
      done = done + 1
    }
  }
  done
}

///|
/// Returns the total confidence score for `suspect` based on evidence, chains, and deduction.
fn @types.Game::suspect_confidence(game : @types.Game, suspect : Int) -> Int {
  if suspect < 0 || suspect >= @types.suspect_count {
    return 0
  }

  let mut value = game.evidence_score[suspect] +
    game.completed_chains(suspect) * 8
  if game.suspects[suspect].deduction_unlocked {
    value = value + 8
  }
  value
}

///|
/// Recalculates each suspect's suspicion float from their current confidence score.
fn @types.Game::update_suspect_suspicion(game : @types.Game) -> Unit {
  for i in 0..<game.suspects.length() {
    let conf = Float::from_int(game.suspect_confidence(i))
    game.suspects[i].suspicion = @types.clamp01(conf / 42.0)
  }
}

///|
/// Unlocks the deduction for `suspect` if enough chains are complete; awards score and trust.
fn @types.Game::unlock_deduction_if_ready(
  game : @types.Game,
  suspect : Int,
) -> Unit {
  if suspect < 0 || suspect >= @types.suspect_count {
    return
  }
  if game.suspects[suspect].deduction_unlocked {
    return
  }

  if game.completed_chains(suspect) >= @types.deduction_chains_to_unlock {
    game.suspects[suspect].deduction_unlocked = true
    game.score = game.score + @types.score_deduction_unlock
    game.trust = @types.minf(
      @types.trust_max,
      game.trust + @types.trust_gain_deduction,
    )
    game.set_message(
      "Deduction unlocked: " + game.suspects[suspect].name + ".",
      1.8,
    )
  }
}

///|
/// Discovers a clue at `clue_index`: awards evidence, advances chain progress, and triggers deduction check.
fn @types.Game::discover_clue(game : @types.Game, clue_index : Int) -> Unit {
  if clue_index < 0 || clue_index >= game.clues.length() {
    return
  }
  if game.clues[clue_index].discovered {
    return
  }

  let suspect = game.clues[clue_index].suspect
  let chain = game.clues[clue_index].chain
  let slot = @types.chain_slot(suspect, chain)

  game.clues[clue_index].discovered = true
  game.clues[clue_index].glow_t = 1.35

  let mut evidence_gain = @types.evidence_per_clue
  if game.focus_t > 0.0 {
    evidence_gain = evidence_gain + @types.evidence_focus_bonus
  }

  game.evidence_score[suspect] = game.evidence_score[suspect] + evidence_gain
  if game.chain_progress[slot] < @types.clue_steps_per_chain {
    game.chain_progress[slot] = game.chain_progress[slot] + 1
  }

  game.clue_found = game.clue_found + 1
  game.score = game.score + @types.score_clue + evidence_gain * 2
  game.trust = @types.minf(
    @types.trust_max,
    game.trust + @types.trust_gain_clue,
  )

  if game.chain_progress[slot] == @types.clue_steps_per_chain {
    game.score = game.score + @types.score_chain_complete
    game.trust = @types.minf(
      @types.trust_max,
      game.trust + @types.trust_gain_chain,
    )
    game.set_message(
      "Chain sealed for " + game.suspects[suspect].name + ".",
      1.6,
    )
  } else {
    game.set_message(
      "Clue archived on " + game.suspects[suspect].name + ".",
      1.3,
    )
  }

  game.unlock_deduction_if_ready(suspect)
}

///|
/// Returns the index of a free incident slot, or the slot with the highest remaining timer.
fn @types.Game::alloc_incident_slot(game : @types.Game) -> Int {
  for i, slot in game.incidents {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_timer = game.incidents[0].timer
    for i in 1..<game.incidents.length() {
      if game.incidents[i].timer > best_timer {
        best = i
        best_timer = game.incidents[i].timer
      }
    }
    best
  }
}

///|
/// Spawns a new incident at a random unoccupied cell with severity-scaled timer.
fn @types.Game::spawn_incident(game : @types.Game) -> Unit {
  let slot = game.alloc_incident_slot()
  let roll = @types.randi(0, 99)
  let severity = if roll < 48 { 1 } else if roll < 82 { 2 } else { 3 }

  let culprit = @types.randi(0, @types.suspect_count - 1)

  let mut cell_x = @types.randi(0, @types.city_cols - 1)
  let mut cell_y = @types.randi(0, @types.city_rows - 1)
  let mut tries = 0
  while tries < @types.district_count {
    if game.incident_index_at_cell(cell_x, cell_y) < 0 &&
      game.suspect_index_at_cell(cell_x, cell_y) < 0 {
      break
    }
    cell_x = (cell_x + 2 + tries) % @types.city_cols
    cell_y = (cell_y + 1 + tries * 2) % @types.city_rows
    tries = tries + 1
  }

  game.incidents[slot].active = true
  game.incidents[slot].x = cell_x
  game.incidents[slot].y = cell_y
  game.incidents[slot].culprit = culprit
  game.incidents[slot].severity = severity
  game.incidents[slot].timer = @types.maxf(
    6.0,
    @types.incident_timer_for_severity(severity) + @types.randf(-1.4, 1.6),
  )
  game.incidents[slot].pulse_t = 0.0

  let district_id = @types.cell_index(cell_x, cell_y)
  game.set_message(
    "Incident at district #" + district_id.to_string() + ".",
    1.3,
  )
}

///|
/// Ticks all active incident timers; deactivates and penalises on timeout.
fn @types.Game::update_incidents(game : @types.Game, dt : Float) -> Unit {
  let slowdown : Float = if game.focus_t > 0.0 { 0.72 } else { 1.0 }

  for incident in game.incidents {
    if !incident.active {
      continue
    }

    let sev_scale = Float::from_int(incident.severity - 1)
    incident.pulse_t = incident.pulse_t + dt * (1.0 + sev_scale * 0.6)
    incident.timer = incident.timer - dt * slowdown * (1.0 + sev_scale * 0.25)

    if incident.timer <= 0.0 {
      incident.active = false
      game.failed_incidents = game.failed_incidents + 1
      game.score = (0).max(game.score - 24 - incident.severity * 10)
      game.trust = @types.maxf(
        0.0,
        game.trust -
        @types.trust_penalty_missed_incident -
        Float::from_int(incident.severity) * 2.1,
      )
      game.set_message("Incident unresolved. City trust slips.", 1.6)
    }
  }
}

///|
/// Returns the cumulative trust drain pressure from all currently active incidents.
fn @types.Game::incident_pressure(game : @types.Game) -> Float {
  let mut pressure : Float = 0.0
  for incident in game.incidents {
    if incident.active {
      pressure = pressure + Float::from_int(incident.severity) * 0.34
    }
  }
  pressure
}

///|
/// Updates each district's heat value based on cursor, incidents, undiscovered clues, and focus.
fn @types.Game::update_district_pulses(game : @types.Game, dt : Float) -> Unit {
  game.city_time = game.city_time + dt

  for i in 0..<game.pulses.length() {
    let x = i % @types.city_cols
    let y = i / @types.city_cols

    let mut heat : Float = 0.24 +
      0.18 * @math.sinf(game.city_time * 0.9 + game.pulses[i].drift)

    if x == game.cursor_x && y == game.cursor_y {
      heat = heat + 0.15
    }

    for incident in game.incidents {
      if !incident.active {
        continue
      }

      let dx0 = x - incident.x
      let adx = if dx0 < 0 { -dx0 } else { dx0 }
      let dy0 = y - incident.y
      let ady = if dy0 < 0 { -dy0 } else { dy0 }

      if adx == 0 && ady == 0 {
        heat = heat + 0.42 + Float::from_int(incident.severity) * 0.09
      } else if adx + ady == 1 {
        heat = heat + 0.12
      }
    }

    if game.clue_index_at_cell(x, y, true) >= 0 {
      heat = heat + 0.1
    }

    if game.focus_t > 0.0 {
      let dx1 = x - game.cursor_x
      let adx = if dx1 < 0 { -dx1 } else { dx1 }
      let dy1 = y - game.cursor_y
      let ady = if dy1 < 0 { -dy1 } else { dy1 }
      if adx + ady <= 1 {
        heat = heat + 0.24
      }
    }

    game.pulses[i].heat = @types.clamp01(heat)
  }
}

///|
/// Moves the cursor by the current frame input delta, clamping within grid bounds.
fn @types.Game::move_cursor(game : @types.Game) -> Unit {
  if game.input_dx == 0 && game.input_dy == 0 {
    return
  }

  game.cursor_x = (game.cursor_x + game.input_dx).clamp(
    min=0,
    max=@types.city_cols - 1,
  )
  game.cursor_y = (game.cursor_y + game.input_dy).clamp(
    min=0,
    max=@types.city_rows - 1,
  )
}

///|
/// Activates focus or shows cooldown message when the focus key is pressed.
fn @types.Game::handle_focus_input(game : @types.Game) -> Unit {
  if !game.input_focus_press {
    return
  }

  if game.focus_cd <= 0.0 {
    game.focus_t = @types.focus_duration
    game.focus_cd = @types.focus_cooldown
    game.set_message("Focus engaged.", 0.9)
  } else {
    game.set_message(
      "Focus cooling: " + game.focus_cd.to_int().to_string() + "s",
      0.8,
    )
  }
}

///|
/// Marks or clears the marked suspect when K is pressed at a suspect or empty cell.
fn @types.Game::handle_cancel_or_mark(game : @types.Game) -> Unit {
  if !game.input_cancel_press {
    return
  }

  let suspect = game.suspect_index_at_cell(game.cursor_x, game.cursor_y)
  if suspect >= 0 {
    game.marked_suspect = suspect
    game.set_message(
      "Marked suspect: " + game.suspects[suspect].name + ".",
      1.5,
    )
  } else if game.marked_suspect >= 0 {
    game.marked_suspect = -1
    game.set_message("Marked suspect cleared.", 1.1)
  } else {
    game.set_message("No suspect at cursor.", 1.0)
  }
}

///|
/// Attempts to resolve an incident using the marked suspect; handles correct, blocked, and wrong cases.
fn @types.Game::attempt_incident_resolution(
  game : @types.Game,
  incident_index : Int,
) -> Unit {
  if incident_index < 0 || incident_index >= game.incidents.length() {
    return
  }

  if game.marked_suspect < 0 {
    game.trust = @types.maxf(0.0, game.trust - 1.8)
    game.set_message("Mark a suspect with K before accusing.", 1.4)
    return
  }

  let accused = game.marked_suspect
  let culprit = game.incidents[incident_index].culprit
  let severity = game.incidents[incident_index].severity

  if accused == culprit {
    let mut effective_confidence = game.suspect_confidence(accused)
    if game.suspects[accused].deduction_unlocked {
      effective_confidence = effective_confidence + 4
    }
    if game.focus_t > 0.0 {
      effective_confidence = effective_confidence + 6
    }

    if effective_confidence >= @types.incident_need_score(severity) {
      game.incidents[incident_index].active = false
      game.solved_incidents = game.solved_incidents + 1
      game.score = game.score +
        @types.score_incident_resolve +
        severity * 70 +
        effective_confidence
      game.trust = @types.minf(
        @types.trust_max,
        game.trust + @types.trust_gain_resolve + Float::from_int(severity),
      )
      game.set_message(
        "Incident resolved. Culprit: " + game.suspects[accused].name + ".",
        1.8,
      )
    } else {
      game.wrong_accusations = game.wrong_accusations + 1
      game.trust = @types.maxf(
        0.0,
        game.trust - @types.trust_penalty_wrong_accuse * 0.4,
      )
      game.score = (0).max(game.score - @types.score_wrong_accuse_penalty / 2)
      game.set_message("Evidence chain incomplete. Accusation blocked.", 1.7)
    }
  } else {
    game.wrong_accusations = game.wrong_accusations + 1
    game.score = (0).max(
      game.score - @types.score_wrong_accuse_penalty - severity * 35,
    )
    game.trust = @types.maxf(
      0.0,
      game.trust -
      @types.trust_penalty_wrong_accuse -
      Float::from_int(severity) * 2.2,
    )
    game.incidents[incident_index].timer = @types.maxf(
      1.0,
      game.incidents[incident_index].timer - 4.0,
    )
    game.set_message("Wrong accusation. Trust drops hard.", 1.8)
  }
}

///|
/// Prints a confidence/chains/deduction summary for `suspect` as a HUD message.
fn @types.Game::inspect_suspect(game : @types.Game, suspect : Int) -> Unit {
  if suspect < 0 || suspect >= @types.suspect_count {
    return
  }

  let chains = game.completed_chains(suspect)
  let conf = game.suspect_confidence(suspect)
  let unlock_word = if game.suspects[suspect].deduction_unlocked {
    "deduction ready"
  } else {
    "deduction locked"
  }

  game.set_message(
    game.suspects[suspect].name +
    ": confidence " +
    conf.to_string() +
    ", chains " +
    chains.to_string() +
    ", " +
    unlock_word +
    ".",
    1.6,
  )
}

///|
/// Dispatches J input: resolve incident, discover clue, inspect suspect, or show no-lead message.
fn @types.Game::handle_inspect(game : @types.Game) -> Unit {
  if !game.input_inspect_press {
    return
  }

  let incident = game.incident_index_at_cell(game.cursor_x, game.cursor_y)
  if incident >= 0 {
    game.attempt_incident_resolution(incident)
    return
  }

  let clue = game.clue_index_at_cell(game.cursor_x, game.cursor_y, true)
  if clue >= 0 {
    game.discover_clue(clue)
    return
  }

  let suspect = game.suspect_index_at_cell(game.cursor_x, game.cursor_y)
  if suspect >= 0 {
    game.inspect_suspect(suspect)
    return
  }

  game.set_message("No lead in this district.", 1.0)
}

///|
/// Decrements the glow timer for all discovered clues with active glow.
fn @types.Game::update_clue_glow(game : @types.Game, dt : Float) -> Unit {
  for clue in game.clues {
    if clue.glow_t > 0.0 {
      clue.glow_t = @types.maxf(0.0, clue.glow_t - dt)
    }
  }
}

///|
/// Counts down the spawn timer and spawns a new incident when it reaches zero.
fn @types.Game::update_spawn_timer(game : @types.Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t > 0.0 {
    return
  }

  game.spawn_incident()

  let solved_scale = Float::from_int(game.solved_incidents) * 0.08
  let mut next_spawn = @types.incident_spawn_base -
    solved_scale +
    @types.randf(-0.6, 0.9)
  next_spawn = @types.maxf(@types.incident_spawn_floor, next_spawn)

  if game.focus_t > 0.0 {
    next_spawn = next_spawn + 0.6
  }

  game.spawn_t = next_spawn
}

///|
/// Ticks focus timer, focus cooldown, case timer, and trust decay per frame.
fn @types.Game::update_runtime_meters(game : @types.Game, dt : Float) -> Unit {
  if game.focus_t > 0.0 {
    game.focus_t = @types.maxf(0.0, game.focus_t - dt)
  }
  if game.focus_cd > 0.0 {
    game.focus_cd = @types.maxf(0.0, game.focus_cd - dt)
  }

  game.case_time = @types.maxf(0.0, game.case_time - dt)

  let focus_factor : Float = if game.focus_t > 0.0 { 0.78 } else { 1.0 }
  game.trust = @types.maxf(
    0.0,
    game.trust -
    dt * (@types.trust_decay_base + game.incident_pressure()) * focus_factor,
  )
}

///|
/// Saves best score and transitions to game-over state with a reason message.
fn @types.Game::transition_to_game_over(
  game : @types.Game,
  reason : String,
) -> Unit {
  if game.score > game.best_score {
    game.best_score = game.score
  }
  game.state = GameOver
  game.set_message(reason + " Press J or R to restart.", 99.0)
}

///|
/// Handles one tick in Title state: animates district pulses and starts case on J.
fn @types.Game::update_title_state(game : @types.Game, dt : Float) -> Unit {
  game.update_district_pulses(dt)

  if game.input_inspect_press {
    game.reset_case()
  }
}

///|
/// Handles one tick in Playing state: processes all input, timers, and checks win/loss conditions.
fn @types.Game::update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.state = Paused
    game.set_message("Investigation paused.", 99.0)
    return
  }

  game.move_cursor()
  game.handle_cancel_or_mark()
  game.handle_focus_input()
  game.handle_inspect()

  game.update_runtime_meters(dt)
  game.update_spawn_timer(dt)
  game.update_incidents(dt)
  game.update_clue_glow(dt)
  game.update_district_pulses(dt)
  game.update_suspect_suspicion()

  if game.trust <= 0.0 {
    game.transition_to_game_over("City trust collapsed.")
  } else if game.case_time <= 0.0 {
    game.transition_to_game_over("Case file expired.")
  }
}

///|
/// Handles one tick in Paused state: animates district pulses and resumes on P or K.
fn @types.Game::update_paused_state(game : @types.Game, dt : Float) -> Unit {
  game.update_district_pulses(dt)

  if game.input_pause_press || game.input_cancel_press {
    game.state = Playing
    game.set_message("Investigation resumed.", 1.1)
  }
}

///|
/// Handles one tick in GameOver state: animates district pulses and handles restart or title.
fn @types.Game::update_game_over_state(game : @types.Game, dt : Float) -> Unit {
  game.update_district_pulses(dt)

  if game.input_inspect_press {
    game.reset_case()
  } else if game.input_cancel_press {
    game.state = Title
    game.set_message("Press J to reopen the case.", 99.0)
  }
}

///|
/// Advances one frame of detective gameplay and state transitions.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.update_input()

  let step = @types.clampf(dt, 0.0, 0.05)

  if game.input_restart_press {
    game.reset_case()
  }

  if game.message_t > 0.0 {
    game.message_t = @types.maxf(0.0, game.message_t - step)
  }

  match game.state {
    Title => game.update_title_state(step)
    Playing => game.update_playing_state(step)
    Paused => game.update_paused_state(step)
    GameOver => game.update_game_over_state(step)
  }
}
