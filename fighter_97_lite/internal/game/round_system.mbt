///|
fn wrap_index(value : Int, size : Int) -> Int {
  let mut v = value
  while v < 0 {
    v += size
  }
  while v >= size {
    v -= size
  }
  v
}

///|
fn @types.Game::reset_round_fighters(game : @types.Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  let a1 = @types.fighter_archetype(game, p1)
  let a2 = @types.fighter_archetype(game, p2)

  p1.x = @types.center_line_x - 220.0
  p2.x = @types.center_line_x + 220.0
  p1.y = @types.floor_y
  p2.y = @types.floor_y
  p1.facing = @types.facing_right
  p2.facing = @types.facing_left

  p1.health = @types.health_max
  p2.health = @types.health_max
  p1.guard_meter = @types.fighter_total_guard(a1)
  p2.guard_meter = @types.fighter_total_guard(a2)

  p1.is_cpu = false
  p2.is_cpu = game.mode_vs_cpu

  @types.reset_fighter_round_state(p1)
  @types.reset_fighter_round_state(p2)
}

///|
fn @types.Game::assign_selected_characters(game : @types.Game) -> Unit {
  game.fighters[0].archetype_index = game.select_cursor_p1.clamp(
    min=0,
    max=@types.roster_count - 1,
  )
  game.fighters[1].archetype_index = game.select_cursor_p2.clamp(
    min=0,
    max=@types.roster_count - 1,
  )

  game.fighters[0].round_wins = 0
  game.fighters[1].round_wins = 0
  game.fighters[0].super_meter = 0
  game.fighters[1].super_meter = 0
}

///|
fn @types.Game::start_round_intro(game : @types.Game) -> Unit {
  game.state = StateIntro
  game.intro_timer = @types.intro_duration
  game.round_timer = if game.mode_training {
    -1.0
  } else {
    @types.round_time_start
  }
  game.winner_slot = @types.winner_none
  game.announcer_text = if game.mode_training {
    "TRAINING"
  } else {
    "ROUND \{game.round_index}"
  }
  game.announcer_timer = if game.mode_training { 0.8 } else { 1.0 }
  game.training_adv_text = ""
  game.training_adv_timer = 0.0
  game.dramatic_freeze = 0
  game.reset_round_fighters()
}

///|
fn @types.Game::start_match(game : @types.Game) -> Unit {
  game.round_index = 1
  game.assign_selected_characters()
  game.start_round_intro()
}

///|
fn @types.Game::start_next_round(game : @types.Game) -> Unit {
  game.round_index += 1

  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if game.winner_slot == 0 {
    p1.super_meter = (p1.super_meter + 12).clamp(min=0, max=@types.super_max)
    p2.super_meter = (p2.super_meter + 24).clamp(min=0, max=@types.super_max)
  } else if game.winner_slot == 1 {
    p1.super_meter = (p1.super_meter + 24).clamp(min=0, max=@types.super_max)
    p2.super_meter = (p2.super_meter + 12).clamp(min=0, max=@types.super_max)
  } else {
    p1.super_meter = (p1.super_meter + 18).clamp(min=0, max=@types.super_max)
    p2.super_meter = (p2.super_meter + 18).clamp(min=0, max=@types.super_max)
  }

  game.start_round_intro()
}

///|
fn @types.Game::choose_round_winner(game : @types.Game) -> Int {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if p1.health <= 0 && p2.health <= 0 {
    return @types.winner_draw
  }
  if p1.health <= 0 {
    return 1
  }
  if p2.health <= 0 {
    return 0
  }

  if p1.health > p2.health {
    0
  } else if p2.health > p1.health {
    1
  } else {
    @types.winner_draw
  }
}

///|
fn @types.Game::enter_round_over(game : @types.Game, winner : Int) -> Unit {
  game.state = StateRoundOver
  game.round_over_timer = @types.round_over_duration
  game.winner_slot = winner

  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if winner == 0 {
    p1.round_wins += 1
    p1.action = ActionVictory
    p1.action_elapsed = 0.0
    p1.action_frame = 0
    p2.action = ActionKnockdown
    p2.knockdown = 80
    game.announcer_text = "P1 WINS THE ROUND"
    game.announcer_timer = 1.8
  } else if winner == 1 {
    p2.round_wins += 1
    p2.action = ActionVictory
    p2.action_elapsed = 0.0
    p2.action_frame = 0
    p1.action = ActionKnockdown
    p1.knockdown = 80
    game.announcer_text = "P2 WINS THE ROUND"
    game.announcer_timer = 1.8
  } else {
    game.announcer_text = "DOUBLE KO"
    game.announcer_timer = 1.8
  }
}

///|
fn @types.Game::enter_match_over(game : @types.Game) -> Unit {
  game.state = StateMatchOver
  game.match_over_timer = @types.match_over_duration

  if game.fighters[0].round_wins > game.fighters[1].round_wins {
    game.winner_slot = 0
    game.announcer_text = "P1 VICTORY"
  } else if game.fighters[1].round_wins > game.fighters[0].round_wins {
    game.winner_slot = 1
    game.announcer_text = "P2 VICTORY"
  } else {
    game.winner_slot = @types.winner_draw
    game.announcer_text = "MATCH DRAW"
  }
  game.announcer_timer = 3.4
}

///|
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  game.title_blink += dt * @types.title_blink_speed
  game.bg_scroll += dt * 12.0

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = StateSelect
    game.select_blink = 0.0
    game.p1_confirmed = false
    game.p2_confirmed = false
  }

  if @raylib.is_key_pressed(@raylib.KeyF1) {
    game.debug_overlay = not(game.debug_overlay)
  }
}

///|
fn @types.Game::update_select(game : @types.Game, dt : Float) -> Unit {
  game.select_blink += dt * @types.select_blink_speed
  game.bg_scroll += dt * 10.0

  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.mode_training = not(game.mode_training)
    if game.mode_training {
      game.mode_vs_cpu = true
      game.p2_confirmed = true
    } else {
      game.p2_confirmed = false
    }
  }

  if @raylib.is_key_pressed(@raylib.KeySpace) {
    game.mode_vs_cpu = not(game.mode_vs_cpu)
    if game.mode_vs_cpu {
      game.p2_confirmed = true
    } else {
      game.p2_confirmed = false
    }
  }

  if game.mode_training {
    game.mode_vs_cpu = true
  }

  if @raylib.is_key_pressed(@raylib.KeyA) {
    game.select_cursor_p1 = wrap_index(
      game.select_cursor_p1 - 1,
      @types.roster_count,
    )
    game.p1_confirmed = false
  }
  if @raylib.is_key_pressed(@raylib.KeyD) {
    game.select_cursor_p1 = wrap_index(
      game.select_cursor_p1 + 1,
      @types.roster_count,
    )
    game.p1_confirmed = false
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.select_cursor_p2 = wrap_index(
      game.select_cursor_p2 - 1,
      @types.roster_count,
    )
    if not(game.mode_vs_cpu) {
      game.p2_confirmed = false
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.select_cursor_p2 = wrap_index(
      game.select_cursor_p2 + 1,
      @types.roster_count,
    )
    if not(game.mode_vs_cpu) {
      game.p2_confirmed = false
    }
  }

  if game.mode_vs_cpu {
    game.p2_confirmed = true
  }

  if @raylib.is_key_pressed(@raylib.KeyF) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.p1_confirmed = true
  }

  if not(game.mode_vs_cpu) {
    if @raylib.is_key_pressed(@raylib.KeyU) ||
      @raylib.is_key_pressed(@raylib.KeyEnter) {
      game.p2_confirmed = true
    }
  }

  if @raylib.is_key_pressed(@raylib.KeyBackspace) {
    game.p1_confirmed = false
    if not(game.mode_vs_cpu) {
      game.p2_confirmed = false
    }
  }

  if game.p1_confirmed && game.p2_confirmed {
    game.start_match()
  }

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StateTitle
  }
}

///|
fn @types.Game::update_intro(game : @types.Game, dt : Float) -> Unit {
  game.bg_scroll += dt * 20.0
  @effects.update_camera(game, dt)
  @effects.update_particles(game, dt)

  game.intro_timer -= dt
  if game.intro_timer <= 0.0 {
    game.intro_timer = 0.0
    game.state = StateFight
    game.announcer_text = if game.mode_training { "TRAINING" } else { "FIGHT!" }
    game.announcer_timer = if game.mode_training { 0.8 } else { 0.9 }

    let p1 = game.fighters[0]
    let p2 = game.fighters[1]
    if p1.action == ActionIntro {
      p1.action = ActionIdle
      p1.action_elapsed = 0.0
      p1.action_frame = 0
    }
    if p2.action == ActionIntro {
      p2.action = ActionIdle
      p2.action_elapsed = 0.0
      p2.action_frame = 0
    }
  }
}

///|
fn @types.Game::recover_fighter_resources(
  game : @types.Game,
  dt : Float,
) -> Unit {
  for i in 0..<@types.max_players {
    let fighter = game.fighters[i]
    let archetype = @types.fighter_archetype(game, fighter)

    if fighter.action != ActionBlockstun && fighter.action != ActionHitstun {
      @types.add_guard(fighter, @types.guard_recover_per_sec * dt, archetype)
    }
  }
}

///|
fn @types.Game::update_training_resources(
  game : @types.Game,
  dt : Float,
) -> Unit {
  for i in 0..<@types.max_players {
    let fighter = game.fighters[i]
    let archetype = @types.fighter_archetype(game, fighter)

    if fighter.health <= 0 {
      fighter.health = 1
    } else if fighter.health < @types.health_max {
      fighter.health = (fighter.health +
      (@types.training_health_regen_per_sec * dt).to_int()).clamp(
        min=1,
        max=@types.health_max,
      )
    }

    fighter.super_meter = @types.super_max
    @types.add_guard(
      fighter,
      @types.guard_recover_per_sec * dt * 2.8,
      archetype,
    )
  }
}

///|
fn @types.Game::reset_training_fight(game : @types.Game) -> Unit {
  game.reset_round_fighters()
  for slot in 0..<@types.max_players {
    let fighter = game.fighters[slot]
    let archetype = @types.fighter_archetype(game, fighter)
    fighter.health = @types.health_max
    fighter.guard_meter = @types.fighter_total_guard(archetype)
    fighter.super_meter = @types.super_max
    set_idle_state(fighter)
    fighter.input = @types.InputState::new()
  }
  game.round_timer = -1.0
  game.dramatic_freeze = 0
  game.camera_shake = 0.0
  game.announcer_text = "RESET"
  game.announcer_timer = 0.32
  game.training_adv_text = ""
  game.training_adv_timer = 0.0
}

///|
fn @types.Game::update_fight(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = StatePause
    game.pause_blink = 0.0
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StateSelect
    game.p1_confirmed = false
    game.p2_confirmed = false
    return
  }

  if game.mode_training && @raylib.is_key_pressed(@raylib.KeyR) {
    game.reset_training_fight()
    return
  }

  game.bg_scroll += dt * 30.0
  game.update_inputs(dt)

  if game.dramatic_freeze > 0 {
    game.dramatic_freeze -= 1
    @effects.update_camera(game, dt)
    @effects.update_particles(game, dt)
    return
  }

  game.update_facing()

  for slot in 0..<@types.max_players {
    game.update_fighter_core(slot, dt)
  }

  game.resolve_push_collision()
  game.update_facing()

  let threw = game.update_throws()
  if not(threw) {
    game.update_combat()
  }
  game.recover_fighter_resources(dt)
  if game.mode_training {
    game.update_training_resources(dt)
  }

  @effects.update_particles(game, dt)
  @effects.update_camera(game, dt)

  if game.mode_training {
    return
  }

  game.round_timer -= dt
  if game.round_timer < 0.0 {
    game.round_timer = 0.0
  }

  if game.fighters[0].health <= 0 ||
    game.fighters[1].health <= 0 ||
    game.round_timer <= 0.0 {
    let winner = game.choose_round_winner()
    game.enter_round_over(winner)
  }
}

///|
fn @types.Game::update_round_over(game : @types.Game, dt : Float) -> Unit {
  game.bg_scroll += dt * 16.0
  @effects.update_particles(game, dt)
  @effects.update_camera(game, dt)

  for slot in 0..<@types.max_players {
    let fighter = game.fighters[slot]
    update_fighter_recovery_state(fighter)
    update_stun_and_knockdown(fighter)
    update_fighter_action_frame(fighter, dt)
    let archetype = @types.fighter_archetype(game, fighter)
    integrate_fighter_physics(fighter, archetype, dt)
  }

  game.round_over_timer -= dt
  if game.round_over_timer > 0.0 {
    return
  }

  if game.fighters[0].round_wins >= @types.max_round_wins ||
    game.fighters[1].round_wins >= @types.max_round_wins {
    game.enter_match_over()
  } else {
    game.start_next_round()
  }
}

///|
fn @types.Game::update_match_over(game : @types.Game, dt : Float) -> Unit {
  game.bg_scroll += dt * 12.0
  @effects.update_particles(game, dt)
  @effects.update_camera(game, dt)

  game.match_over_timer -= dt
  if game.match_over_timer < 0.0 {
    game.match_over_timer = 0.0
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    game.match_over_timer <= 0.0 {
    game.state = StateSelect
    game.p1_confirmed = false
    game.p2_confirmed = false
  }
}

///|
fn @types.Game::update_pause(game : @types.Game, dt : Float) -> Unit {
  game.pause_blink += dt * 4.5
  @effects.update_particles(game, dt)
  @effects.update_camera(game, dt)

  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = StateFight
  }

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StateSelect
    game.p1_confirmed = false
    game.p2_confirmed = false
  }
}

///|
fn @types.Game::update_announcer(game : @types.Game, dt : Float) -> Unit {
  if game.announcer_timer > 0.0 {
    game.announcer_timer -= dt
    if game.announcer_timer < 0.0 {
      game.announcer_timer = 0.0
      game.announcer_text = ""
    }
  }

  if game.stage_flash > 0.0 {
    game.stage_flash -= dt
    if game.stage_flash < 0.0 {
      game.stage_flash = 0.0
    }
  }

  if game.hud_flash > 0.0 {
    game.hud_flash -= dt
    if game.hud_flash < 0.0 {
      game.hud_flash = 0.0
    }
  }

  if game.training_adv_timer > 0.0 {
    game.training_adv_timer -= dt
    if game.training_adv_timer < 0.0 {
      game.training_adv_timer = 0.0
      game.training_adv_text = ""
    }
  }
}

///|
/// Advances one frame of state, round, and match logic.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_count += 1
  game.update_announcer(dt)

  match game.state {
    StateTitle => game.update_title(dt)
    StateSelect => game.update_select(dt)
    StateIntro => game.update_intro(dt)
    StateFight => game.update_fight(dt)
    StateRoundOver => game.update_round_over(dt)
    StateMatchOver => game.update_match_over(dt)
    StatePause => game.update_pause(dt)
  }
}
