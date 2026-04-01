///|
pub fn update(game : @types.Game) -> Unit {
  let dt : Float = @raylib.get_frame_time()
  game.frame_count += 1
  game.title_anim += dt
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    let idx = @types.tier_index(game.selected_tier)
    if idx < 2 {
      game.selected_tier = @types.index_to_tier(idx + 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    let idx = @types.tier_index(game.selected_tier)
    if idx > 0 {
      game.selected_tier = @types.index_to_tier(idx - 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if @levels.tier_unlocked(game.scores, game.selected_tier) {
      game.selected_level = 0
      game.screen = LevelSelect
    } else {
      game.message = "Complete more levels to unlock!"
      game.message_timer = 2.0
    }
  }
  // Mouse click on tier boxes
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i in 0..<3 {
      let bx = 200 + i * 320
      let by = 300
      let bw = 250
      let bh = 180
      if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
        let tier = @types.index_to_tier(i)
        if @levels.tier_unlocked(game.scores, tier) {
          game.selected_tier = tier
          game.selected_level = 0
          game.screen = LevelSelect
        } else {
          game.message = "Complete more levels to unlock!"
          game.message_timer = 2.0
        }
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.selected_level < @types.levels_per_tier - 1 {
      game.selected_level += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.selected_level > 0 {
      game.selected_level -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if game.selected_level + 4 < @types.levels_per_tier {
      game.selected_level += 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.selected_level - 4 >= 0 {
      game.selected_level -= 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_level(game)
  }
  // Mouse click on level boxes
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i in 0..<@types.levels_per_tier {
      let col = i % 4
      let row = i / 4
      let bx = 240 + col * 210
      let by = 250 + row * 180
      let bw = 180
      let bh = 150
      if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
        game.selected_level = i
        start_level(game)
      }
    }
  }
}

///|
fn start_level(game : @types.Game) -> Unit {
  let idx = @types.level_index(game.selected_tier, game.selected_level)
  let level = @levels.get_level(idx)
  game.current_level = Some(level)
  game.dominoes = @types.clone_dominoes(level.dominoes)
  game.events = []
  game.current_tick = 0
  game.max_tick = 0
  game.tick_timer = 0.0
  game.play_state = Editing
  game.selected_kind = Normal
  game.hover_orientation = E
  game.replay_mode = false
  game.replay_tick = 0
  game.replay_timer = 0.0
  game.dominoes_placed = 0
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    if game.play_state != Editing {
      // Reset level
      reset_level(game)
    } else {
      game.screen = LevelSelect
    }
    return
  }
  match game.play_state {
    Editing => update_editing(game)
    Running => update_running(game, dt)
    Stepping => update_stepping(game)
    Complete => update_complete(game, dt)
    Failed => update_failed(game)
  }
}

///|
fn update_editing(game : @types.Game) -> Unit {
  // Update hover position
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let gx = @types.screen_to_socket_x(mx)
  let gy = @types.screen_to_socket_y(my)
  game.hover_pos = @types.vec2i(gx, gy)
  game.show_hover = @types.in_grid(gx, gy)
  // Domino kind selection: 1-4
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_kind = Normal
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_kind = Heavy
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_kind = Splitter
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.selected_kind = Delay
  }
  // Rotate orientation
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.hover_orientation = @types.next_orientation(game.hover_orientation)
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.hover_orientation = @types.prev_orientation(game.hover_orientation)
  }
  // Place domino on left click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) && game.show_hover {
    place_domino(game, gx, gy)
  }
  // Remove domino on right click or backspace
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) &&
    game.show_hover {
    remove_domino(game, gx, gy)
  }
  if @raylib.is_key_pressed(@raylib.KeyBackspace) && game.show_hover {
    remove_domino(game, game.hover_pos.x, game.hover_pos.y)
  }
  // Speed control: 1-4 mapped to F1-F4 or arrow keys
  if @raylib.is_key_pressed(@raylib.KeyF1) {
    game.tick_speed = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyF2) {
    game.tick_speed = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyF3) {
    game.tick_speed = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyF4) {
    game.tick_speed = 4
  }
  // Start simulation
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    start_simulation(game)
  }
  // Step mode: Tab
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    start_simulation_stepping(game)
  }
}

///|
fn place_domino(game : @types.Game, gx : Int, gy : Int) -> Unit {
  let pos = @types.vec2i(gx, gy)
  // Check if socket is already occupied
  let existing = @types.find_domino_at(game.dominoes, pos)
  if existing >= 0 {
    // Can't place on existing domino
    game.message = "Socket occupied!"
    game.message_timer = 1.0
    return
  }
  // Check budget
  match game.current_level {
    None => ()
    Some(level) => {
      let remaining = @types.budget_remaining(
        level.budget,
        game.dominoes,
        game.selected_kind,
      )
      if remaining <= 0 {
        game.message = "No more " +
          @types.kind_name(game.selected_kind) +
          " dominoes!"
        game.message_timer = 1.5
        return
      }
    }
  }
  let d = @types.new_domino(
    pos,
    game.selected_kind,
    game.hover_orientation,
    false,
    false,
  )
  game.dominoes.push(d)
  game.dominoes_placed += 1
}

///|
fn remove_domino(game : @types.Game, gx : Int, gy : Int) -> Unit {
  let pos = @types.vec2i(gx, gy)
  let idx = @types.find_domino_at(game.dominoes, pos)
  if idx >= 0 {
    let d = game.dominoes[idx]
    if d.is_target || d.is_starter {
      game.message = "Can't remove fixed dominoes!"
      game.message_timer = 1.0
      return
    }
    // Remove by swapping with last
    let last = game.dominoes.length() - 1
    if idx != last {
      game.dominoes[idx] = game.dominoes[last]
    }
    ignore(game.dominoes.pop())
    game.dominoes_placed = @types.maxi(0, game.dominoes_placed - 1)
  }
}

///|
fn start_simulation(game : @types.Game) -> Unit {
  // Clone dominoes for simulation
  let sim_dominoes = @types.clone_dominoes(game.dominoes)
  let (events, max_tick) = @physics.simulate(sim_dominoes)
  // Update game dominoes with simulation results
  game.dominoes = sim_dominoes
  game.events = events
  game.max_tick = max_tick
  game.current_tick = 0
  game.tick_timer = 0.0
  game.play_state = Running
}

///|
fn start_simulation_stepping(game : @types.Game) -> Unit {
  // Clone dominoes for simulation
  let sim_dominoes = @types.clone_dominoes(game.dominoes)
  let (events, max_tick) = @physics.simulate(sim_dominoes)
  game.dominoes = sim_dominoes
  game.events = events
  game.max_tick = max_tick
  game.current_tick = 0
  game.tick_timer = 0.0
  game.play_state = Stepping
}

///|
fn update_running(game : @types.Game, dt : Float) -> Unit {
  let speed_mult = Float::from_int(game.tick_speed)
  game.tick_timer += dt * speed_mult
  let interval = @types.tick_interval_base
  if game.tick_timer >= interval {
    game.tick_timer -= interval
    game.current_tick += 1
    if game.current_tick >= game.max_tick {
      finish_simulation(game)
    }
  }
  // Speed control during run
  if @raylib.is_key_pressed(@raylib.KeyF1) {
    game.tick_speed = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyF2) {
    game.tick_speed = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyF3) {
    game.tick_speed = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyF4) {
    game.tick_speed = 4
  }
  // Update animations
  update_domino_animations(game, dt)
}

///|
fn update_stepping(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyTab) {
    game.current_tick += 1
    if game.current_tick >= game.max_tick {
      finish_simulation(game)
    }
  }
}

///|
fn finish_simulation(game : @types.Game) -> Unit {
  game.current_tick = game.max_tick
  let all_hit = @physics.all_targets_fallen(game.dominoes)
  let placed = @physics.count_placed(game.dominoes)
  if all_hit {
    game.play_state = Complete
    game.result_anim = 0.0
    // Calculate score
    match game.current_level {
      None => ()
      Some(level) => {
        let stars = @physics.calculate_stars(
          true,
          placed,
          game.max_tick,
          level.par_count,
          level.par_ticks,
        )
        let idx = level.id
        if idx < game.scores.length() {
          let score = game.scores[idx]
          score.completed = true
          score.dominoes_used = placed
          score.ticks_taken = game.max_tick
          if stars > score.stars {
            score.stars = stars
          }
        }
      }
    }
  } else {
    game.play_state = Failed
  }
}

///|
fn update_complete(game : @types.Game, dt : Float) -> Unit {
  game.result_anim += dt
  // Replay mode
  if game.replay_mode {
    game.replay_timer += dt * 0.5 // slow motion
    if game.replay_timer >= @types.tick_interval_base {
      game.replay_timer -= @types.tick_interval_base
      game.replay_tick += 1
      if game.replay_tick > game.max_tick {
        game.replay_tick = 0
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.replay_mode = !game.replay_mode
    game.replay_tick = 0
    game.replay_timer = 0.0
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Results
    game.result_anim = 0.0
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    reset_level(game)
  }
}

///|
fn update_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    reset_level(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    reset_level(game)
  }
}

///|
fn reset_level(game : @types.Game) -> Unit {
  match game.current_level {
    None => game.screen = LevelSelect
    Some(level) => {
      game.dominoes = @types.clone_dominoes(level.dominoes)
      game.events = []
      game.current_tick = 0
      game.max_tick = 0
      game.tick_timer = 0.0
      game.play_state = Editing
      game.replay_mode = false
      game.replay_tick = 0
      game.replay_timer = 0.0
      game.dominoes_placed = 0
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  game.result_anim += @raylib.get_frame_time()
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Next level or back to select
    if game.selected_level < @types.levels_per_tier - 1 {
      game.selected_level += 1
      start_level(game)
    } else {
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game)
  }
}

///|
fn update_domino_animations(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.dominoes.length() {
    let d = game.dominoes[i]
    if d.state == Toppling {
      if d.topple_tick <= game.current_tick {
        // Accelerating animation: faster at start, eases to end
        let speed_mult : Float = if d.anim_progress < 0.3 {
          @types.anim_speed * 1.5
        } else if d.anim_progress < 0.7 {
          @types.anim_speed * 1.2
        } else {
          @types.anim_speed * 0.8
        }
        d.anim_progress = @types.clampf(
          d.anim_progress + dt * speed_mult,
          0.0,
          1.0,
        )
      }
    } else if d.state == Fallen {
      d.anim_progress = 1.0
    }
  }
}
