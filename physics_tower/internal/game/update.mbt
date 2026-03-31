///|
/// Main update dispatch -- called once per frame from the main loop.
pub fn update(game : @types.Game, dt : Float) -> Unit {
  game.frame_count = game.frame_count + 1
  // Decay message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update destruction effects
  @destruction.update_destruction(game, dt)
  // Update star animation timer
  if game.star_anim_timer > 0.0 {
    game.star_anim_timer = game.star_anim_timer + dt
  }
  match game.screen {
    Title => update_title(game)
    Build => update_build(game, dt)
    Test => update_test(game, dt)
    Results => update_results(game)
    LevelSelect => update_level_select(game)
    Sandbox => update_sandbox(game, dt)
    Upgrades => update_upgrades(game)
    ChallengeSelect => update_challenge_select(game)
    Challenge => update_challenge(game, dt)
    ChallengeResults => update_challenge_results(game)
    StatsScreen => update_stats_screen(game)
    ReplayPlayback => update_replay_screen(game, dt)
  }
  // Clear sound queue at end of frame
  clear_sound_queue(game)
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.screen = LevelSelect
    show_message(game, "Select a level", 2.0)
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let levels = @content.get_levels()
  let worlds = @content.get_worlds()
  let current_w = game.current_world
  // Arrow keys to switch worlds
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if current_w + 1 < worlds.length() {
      let next_w = current_w + 1
      if @content.is_world_unlocked(next_w, game.statistics.stars_earned) {
        game.current_world = next_w
        push_sound(game, ButtonClick)
      } else {
        show_message(
          game,
          "Need " +
          worlds[next_w].stars_required.to_string() +
          " stars to unlock " +
          worlds[next_w].name,
          2.0,
        )
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if current_w > 0 {
      game.current_world = current_w - 1
      push_sound(game, ButtonClick)
    }
  }
  // Number keys select levels within current world
  let w = worlds[game.current_world]
  let world_start = w.level_start
  let world_end = w.level_end
  let world_count = world_end - world_start + 1
  for i in 0..<world_count {
    if i >= 9 {
      break
    }
    let key = @raylib.KeyOne + i
    if @raylib.is_key_pressed(key) {
      let level_idx = world_start + i
      if level_idx < levels.length() {
        game.current_level = level_idx
        start_level(game, levels[level_idx])
        push_sound(game, ButtonClick)
        return
      }
    }
  }
  // S for sandbox
  if @raylib.is_key_pressed(@raylib.KeyS) {
    start_sandbox(game)
    push_sound(game, ButtonClick)
    return
  }
  // U for upgrades
  if @raylib.is_key_pressed(@raylib.KeyU) {
    game.screen = Upgrades
    push_sound(game, ButtonClick)
    return
  }
  // C for challenges
  if @raylib.is_key_pressed(@raylib.KeyC) {
    game.screen = ChallengeSelect
    push_sound(game, ButtonClick)
    return
  }
  // Tab for statistics
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.screen = StatsScreen
    push_sound(game, ButtonClick)
    return
  }
  // Click on level
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    for i in 0..<world_count {
      let row = i / 2
      let col = i % 2
      let bx = 300 + col * 560
      let by = 160 + row * 120
      if @types.pointer_in_rect(mx, my, bx, by, 500, 100) {
        let level_idx = world_start + i
        if level_idx < levels.length() {
          game.current_level = level_idx
          start_level(game, levels[level_idx])
          push_sound(game, ButtonClick)
          return
        }
      }
    }
    // Sandbox button
    if @types.pointer_in_rect(mx, my, 100, 780, 340, 70) {
      start_sandbox(game)
      push_sound(game, ButtonClick)
    }
    // World navigation arrows
    if @types.pointer_in_rect(mx, my, 100, 50, 60, 50) {
      if game.current_world > 0 {
        game.current_world = game.current_world - 1
        push_sound(game, ButtonClick)
      }
    }
    if @types.pointer_in_rect(mx, my, @types.screen_w - 160, 50, 60, 50) {
      let next = game.current_world + 1
      if next < worlds.length() &&
        @content.is_world_unlocked(next, game.statistics.stars_earned) {
        game.current_world = next
        push_sound(game, ButtonClick)
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level : @types.Level) -> Unit {
  @physics.clear_world(game.world)
  @destruction.clear_destruction(game.destruction)
  game.screen = Build
  game.selected_piece = 0
  game.selected_blueprint = -1
  game.ghost_angle = 0.0
  game.test_phase = 0
  game.test_timer = 0.0
  game.tower_height = 0.0
  game.score = 0
  game.star_anim_timer = 0.0
  game.result_stars = 0
  game.challenge_state = None
  game.active_combos.clear()
  // Copy level inventory
  game.inventory.clear()
  for item in level.available_pieces {
    game.inventory.push(item)
  }
  // Set world index for themed physics
  game.current_world = level.world_index
  // Apply world gravity modifier
  let grav_mult = @content.world_gravity_mult(level.world_index)
  game.world.gravity = @types.gravity * grav_mult
  // Apply world friction modifier
  game.world.friction_mult = @content.world_friction_mult(level.world_index)
  // Start recording for replay
  start_recording(game)
  // Initialize tutorial for level 1
  if game.current_level == 0 && !(game.tutorial_shown) {
    init_tutorial(game)
  }
  show_message(game, level.name + ": " + level.description, 3.0)
}

///|
fn start_sandbox(game : @types.Game) -> Unit {
  @physics.clear_world(game.world)
  @destruction.clear_destruction(game.destruction)
  game.screen = Sandbox
  game.selected_piece = 0
  game.selected_blueprint = -1
  game.ghost_angle = 0.0
  game.test_phase = 0
  game.test_timer = 0.0
  game.tower_height = 0.0
  game.challenge_state = None
  game.inventory.clear()
  let sandbox_inv = @content.get_sandbox_inventory()
  for item in sandbox_inv {
    game.inventory.push(item)
  }
  show_message(game, "Sandbox Mode - Build freely!", 2.0)
}

///|
fn update_build(game : @types.Game, dt : Float) -> Unit {
  // Update tutorial if active
  if should_show_tutorial(game) {
    ignore(update_tutorial(game, dt))
  }
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  // Update ghost position (snapped to grid)
  game.ghost_x = @types.snap_to_grid(mx, @types.snap_grid)
  game.ghost_y = @types.snap_to_grid(my, @types.snap_grid)
  // Clamp ghost to build area
  game.ghost_x = @types.clampf(
    game.ghost_x,
    @types.build_area_left + 40.0,
    @types.build_area_right - 40.0,
  )
  game.ghost_y = @types.clampf(game.ghost_y, @types.build_area_top, @types.ground_y - 10.0)
  // Rotate with R or scroll
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.ghost_angle = game.ghost_angle + 1.5707963 // PI/2
    if game.ghost_angle > 6.28 {
      game.ghost_angle = game.ghost_angle - 6.2831853
    }
    push_sound(game, RotatePiece)
  }
  // Select piece with number keys or scroll
  handle_piece_selection(game)
  // Handle blueprint selection
  handle_blueprint_selection(game)
  // Place piece with left click (not in panel area)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if mx < Float::from_int(@types.panel_x) {
      if game.selected_blueprint >= 0 {
        try_place_blueprint(game)
      } else {
        try_place_piece(game)
      }
    }
  }
  // Undo with Z
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    remove_last_body(game)
  }
  // Toggle ghost tower with G
  if @raylib.is_key_pressed(@raylib.KeyG) {
    toggle_ghost(game)
  }
  // Save custom blueprint with F5
  if @raylib.is_key_pressed(@raylib.KeyF5) {
    let result = @blueprint.save_custom_blueprint(game, "Custom Tower")
    match result {
      Some(bp) => {
        @blueprint.load_custom_blueprints(game)
        show_message(
          game,
          "Saved blueprint: " + bp.name + " (" + bp.pieces.length().to_string() + " pieces)",
          2.0,
        )
      }
      None => show_message(game, "Nothing to save!", 1.0)
    }
  }
  // Update combos after any changes
  update_game_combos(game)
  // Start test with T or Enter
  if @raylib.is_key_pressed(@raylib.KeyT) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.world.bodies.length() > 0 {
      begin_test(game)
    } else {
      show_message(game, "Place some pieces first!", 1.5)
    }
  }
  // Back to level select with Escape
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_sandbox(game : @types.Game, dt : Float) -> Unit {
  // Sandbox is like build but also runs physics when T is pressed
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  game.ghost_x = @types.snap_to_grid(mx, @types.snap_grid)
  game.ghost_y = @types.snap_to_grid(my, @types.snap_grid)
  game.ghost_x = @types.clampf(
    game.ghost_x,
    @types.build_area_left + 40.0,
    @types.build_area_right - 40.0,
  )
  game.ghost_y = @types.clampf(game.ghost_y, @types.build_area_top, @types.ground_y - 10.0)
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.ghost_angle = game.ghost_angle + 1.5707963
    if game.ghost_angle > 6.28 {
      game.ghost_angle = game.ghost_angle - 6.2831853
    }
  }
  handle_piece_selection(game)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if mx < Float::from_int(@types.panel_x) {
      try_place_piece(game)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    remove_last_body(game)
  }
  // Toggle physics simulation with Space
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    @physics.step(game.world, dt)
    show_message(game, "Physics step", 0.5)
  }
  // Run continuous physics with T
  if @raylib.is_key_down(@raylib.KeyT) {
    @physics.step(game.world, dt)
  }
  // Wind test with W
  if @raylib.is_key_pressed(@raylib.KeyW) {
    @physics.start_wind(game.world, @types.wind_test_force)
    show_message(game, "Wind!", 1.0)
  }
  if @raylib.is_key_released(@raylib.KeyW) {
    @physics.stop_wind(game.world)
  }
  // Earthquake with E
  if @raylib.is_key_pressed(@raylib.KeyE) {
    @physics.start_earthquake(
      game.world,
      @types.quake_test_duration,
      @types.quake_test_intensity,
    )
    show_message(game, "Earthquake!", 1.0)
  }
  // Impact with I
  if @raylib.is_key_pressed(@raylib.KeyI) {
    @physics.fire_impact(game.world, @types.impact_force)
    show_message(game, "Impact!", 1.0)
  }
  // Clear with C
  if @raylib.is_key_pressed(@raylib.KeyC) {
    @physics.clear_world(game.world)
    show_message(game, "Cleared", 1.0)
  }
  // Reset velocities with V
  if @raylib.is_key_pressed(@raylib.KeyV) {
    @physics.reset_velocities(game.world)
    show_message(game, "Reset velocities", 1.0)
  }
  game.tower_height = @physics.measure_tower_height(game.world)
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_test(game : @types.Game, dt : Float) -> Unit {
  let levels = @content.get_levels()
  let level = levels[game.current_level]
  // Apply slow-motion from destruction
  let effective_dt = @destruction.effective_dt(game.destruction, dt)
  // Run physics each frame
  let sub_steps = 4
  let sub_dt = effective_dt / Float::from_int(sub_steps)
  for _s in 0..<sub_steps {
    @physics.step(game.world, sub_dt)
  }
  // Process destruction chain reactions
  @destruction.process_chain_reaction(game.world, game.destruction)
  @destruction.detect_breaks_and_spawn(game.world, game.destruction)
  // Emit sound events for breaks
  emit_break_sounds(game)
  emit_hazard_sounds(game)
  // Spawn visual effects for active hazards
  if @types.absf(game.world.wind_force) > 0.1 {
    @destruction.spawn_wind_particles(game.destruction, game.world.wind_force)
  }
  if game.world.quake_timer > 0.0 {
    @destruction.spawn_dust(game.destruction, game.world.ground_y)
    // Camera shake during earthquake
    @destruction.trigger_camera_shake(
      game.destruction,
      game.world.quake_intensity * 0.01,
    )
  }
  game.tower_height = @physics.measure_tower_height(game.world)
  game.test_timer = game.test_timer + dt
  // Advance through test phases
  if game.test_timer > @types.test_phase_duration {
    game.test_timer = 0.0
    // End current phase effects
    @physics.stop_wind(game.world)
    game.test_phase = game.test_phase + 1
    if game.test_phase >= level.test_kinds.length() {
      // All tests done, show results
      finish_test(game)
      return
    }
    // Start next phase
    start_test_phase(game, level.test_kinds[game.test_phase])
  }
  // If no test kinds, just run physics for a moment then finish
  if level.test_kinds.length() == 0 {
    if game.test_timer > 2.0 && @physics.is_settled(game.world) {
      finish_test(game)
    }
  }
  // Allow skip with Escape
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    finish_test(game)
  }
}

///|
fn begin_test(game : @types.Game) -> Unit {
  let levels = @content.get_levels()
  let level = levels[game.current_level]
  game.screen = Test
  game.test_phase = 0
  game.test_timer = 0.0
  @physics.reset_velocities(game.world)
  // Apply combo bonuses before test
  let combos = check_combos(game.world)
  apply_combo_bonuses(game.world, combos)
  // Apply world-specific wind multiplier during test phases
  // (handled in start_test_phase)
  // Record stats
  record_build(game)
  push_sound(game, StartTest)
  show_message(game, "Testing your tower!", 2.0)
  // Start first test phase if any
  if level.test_kinds.length() > 0 {
    start_test_phase(game, level.test_kinds[0])
  }
}

///|
fn start_test_phase(game : @types.Game, kind : @types.TestKind) -> Unit {
  let wind_mult = @content.world_wind_mult(game.current_world)
  match kind {
    Wind => {
      let dir : Float = if game.frame_count % 2 == 0 { 1.0 } else { -1.0 }
      @physics.start_wind(
        game.world,
        @types.wind_test_force * dir * wind_mult,
      )
      push_sound(game, WindStart)
      show_message(game, "WIND!", 1.5)
    }
    Earthquake => {
      @physics.start_earthquake(
        game.world,
        @types.quake_test_duration,
        @types.quake_test_intensity,
      )
      push_sound(game, EarthquakeStart)
      show_message(game, "EARTHQUAKE!", 1.5)
    }
    Impact => {
      @physics.fire_impact(game.world, @types.impact_force)
      push_sound(game, ImpactHit)
      show_message(game, "INCOMING!", 1.5)
    }
  }
}

///|
fn finish_test(game : @types.Game) -> Unit {
  @physics.stop_wind(game.world)
  game.screen = Results
  let active = @physics.count_active_bodies(game.world)
  let broken = @physics.count_broken_bodies(game.world)
  let total = active + broken
  let survival_pct = if total > 0 {
    active * 100 / total
  } else {
    0
  }
  let levels = @content.get_levels()
  let level = levels[game.current_level]
  let height = @physics.measure_tower_height(game.world)
  let passed = height >= level.target_height
  // Only award score and stars if test was passed
  if passed {
    let height_bonus = if height >= level.target_height { 500 } else { 0 }
    game.score = survival_pct * 10 + height_bonus
    game.total_score = game.total_score + game.score
    // Compute star rating
    game.result_stars = if game.score >= 800 {
      3
    } else if game.score >= 400 {
      2
    } else if game.score > 0 {
      1
    } else {
      0
    }
  } else {
    game.score = 0
    game.result_stars = 0
  }
  if height > game.best_height {
    game.best_height = height
  }
  game.star_anim_timer = 0.01
  // Record statistics
  record_breaks(game, broken)
  record_level_result(
    game, game.current_level, height, game.result_stars, passed,
  )
  // Stop recording replay
  stop_recording(game, height, game.score, passed)
  // Save as ghost tower if this is the best run
  if height > best_height_for_level(game, game.current_level) - 1.0 {
    save_ghost_tower(game)
  }
  // Sound events
  if passed {
    push_sound(game, TestPass)
    if game.result_stars > 0 {
      push_sound(game, StarEarned)
    }
  } else {
    push_sound(game, TestFail)
  }
  // Trigger slow-motion replay on dramatic collapses
  if broken >= 3 {
    @destruction.start_replay(game.destruction, 3.0)
  }
  let ht = (height + 0.5).to_int()
  let msg = "Height: " +
    ht.to_string() +
    "px  Survived: " +
    survival_pct.to_string() +
    "%  Score: " +
    game.score.to_string()
  show_message(game, msg, 10.0)
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    let levels = @content.get_levels()
    start_level(game, levels[game.current_level])
  }
  // P for replay playback
  if @raylib.is_key_pressed(@raylib.KeyP) {
    if has_replay(game) {
      @physics.clear_world(game.world)
      start_playback(game)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
  // Click handling
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = Float::from_int(@raylib.get_mouse_x())
    let my = Float::from_int(@raylib.get_mouse_y())
    // Retry button
    if @types.pointer_in_rect(mx, my, 460, 600, 240, 60) {
      let levels = @content.get_levels()
      start_level(game, levels[game.current_level])
    }
    // Next level button
    if @types.pointer_in_rect(mx, my, 740, 600, 240, 60) {
      let levels = @content.get_levels()
      if game.current_level + 1 < levels.length() {
        game.current_level = game.current_level + 1
        start_level(game, levels[game.current_level])
      } else {
        game.screen = LevelSelect
      }
    }
    // Replay button
    if @types.pointer_in_rect(mx, my, 1020, 600, 240, 60) {
      if has_replay(game) {
        @physics.clear_world(game.world)
        start_playback(game)
      }
    }
  }
}

///|
fn handle_piece_selection(game : @types.Game) -> Unit {
  let inv_len = game.inventory.length()
  if inv_len == 0 {
    return
  }
  // Tab to cycle
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.selected_piece = (game.selected_piece + 1) % inv_len
  }
  // Number keys
  for i in 0..<inv_len {
    if i >= 9 {
      break
    }
    let key = @raylib.KeyOne + i
    if @raylib.is_key_pressed(key) {
      game.selected_piece = i
    }
  }
  // Clamp
  if game.selected_piece >= inv_len {
    game.selected_piece = inv_len - 1
  }
}

///|
fn try_place_piece(game : @types.Game) -> Unit {
  if game.inventory.length() == 0 {
    show_message(game, "No pieces left!", 1.0)
    return
  }
  if game.selected_piece >= game.inventory.length() {
    return
  }
  let (kind, material, count) = game.inventory[game.selected_piece]
  if count <= 0 {
    show_message(game, "Out of that piece!", 1.0)
    return
  }
  // Place the piece
  let id = @physics.add_body(
    game.world,
    kind,
    material,
    game.ghost_x,
    game.ghost_y,
    game.ghost_angle,
  )
  @physics.auto_join(game.world, id)
  // Decrease inventory count
  game.inventory[game.selected_piece] = (kind, material, count - 1)
  // Record for replay and stats
  record_place(game, kind, material, game.ghost_x, game.ghost_y, game.ghost_angle)
  record_piece_placed(game, material)
  push_sound(game, PlacePiece)
  // Settle it with a few physics steps
  for _i in 0..<10 {
    @physics.step(game.world, 0.016)
  }
  game.tower_height = @physics.measure_tower_height(game.world)
}

///|
fn remove_last_body(game : @types.Game) -> Unit {
  let bodies = game.world.bodies
  if bodies.length() == 0 {
    return
  }
  let last = bodies[bodies.length() - 1]
  last.active = false
  // Return piece to inventory
  for i in 0..<game.inventory.length() {
    let (k, m, c) = game.inventory[i]
    if k == last.kind && m == last.material {
      game.inventory[i] = (k, m, c + 1)
      break
    }
  }
  // Remove joints referencing this body
  for joint in game.world.joints {
    if joint.body_a == last.id || joint.body_b == last.id {
      joint.active = false
    }
  }
  // Pop from array
  ignore(bodies.pop())
  show_message(game, "Removed piece", 0.5)
}

///|
fn update_upgrades(game : @types.Game) -> Unit {
  // Number keys 1-8 to purchase upgrades
  for i in 0..<game.upgrades.length() {
    if i >= 8 {
      break
    }
    let key = @raylib.KeyOne + i
    if @raylib.is_key_pressed(key) {
      if @upgrades.purchase_upgrade(game, i) {
        show_message(game, "Purchased: " + game.upgrades[i].name, 2.0)
      } else if game.upgrades[i].purchased {
        show_message(game, "Already owned!", 1.0)
      } else {
        show_message(game, "Not enough score!", 1.0)
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_challenge_select(game : @types.Game) -> Unit {
  let modes = @challenge.get_challenge_modes()
  for i in 0..<modes.length() {
    let key = @raylib.KeyOne + i
    if @raylib.is_key_pressed(key) {
      start_challenge_mode(game, modes[i])
      return
    }
  }
  // Click on challenge
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    for i in 0..<modes.length() {
      let bx = @types.screen_w / 2 - 300
      let by = 160 + i * 130
      if @types.pointer_in_rect(mx, my, bx, by, 600, 110) {
        start_challenge_mode(game, modes[i])
        return
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn start_challenge_mode(game : @types.Game, mode : @types.ChallengeMode) -> Unit {
  @physics.clear_world(game.world)
  @destruction.clear_destruction(game.destruction)
  game.screen = Challenge
  game.selected_piece = 0
  game.selected_blueprint = -1
  game.ghost_angle = 0.0
  game.tower_height = 0.0
  game.star_anim_timer = 0.0
  game.result_stars = 0
  game.challenge_state = Some(@types.new_challenge_state(mode))
  // Set up challenge inventory
  game.inventory.clear()
  let inv = @challenge.challenge_inventory()
  for item in inv {
    game.inventory.push(item)
  }
  show_message(game, @challenge.challenge_mode_name(mode) + " - GO!", 2.0)
}

///|
fn update_challenge(game : @types.Game, dt : Float) -> Unit {
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  // Update ghost position
  game.ghost_x = @types.snap_to_grid(mx, @types.snap_grid)
  game.ghost_y = @types.snap_to_grid(my, @types.snap_grid)
  game.ghost_x = @types.clampf(
    game.ghost_x,
    @types.build_area_left + 40.0,
    @types.build_area_right - 40.0,
  )
  game.ghost_y = @types.clampf(game.ghost_y, @types.build_area_top, @types.ground_y - 10.0)
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.ghost_angle = game.ghost_angle + 1.5707963
    if game.ghost_angle > 6.28 {
      game.ghost_angle = game.ghost_angle - 6.2831853
    }
  }
  handle_piece_selection(game)
  // Handle blueprint selection with B key
  handle_blueprint_selection(game)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if mx < Float::from_int(@types.panel_x) {
      if game.selected_blueprint >= 0 {
        try_place_blueprint(game)
      } else {
        try_place_piece(game)
      }
      // Track budget for budget mode
      match game.challenge_state {
        Some(cs) =>
          match cs.mode {
            BudgetMode => cs.budget_used = cs.budget_used + 1
            _ => ()
          }
        None => ()
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    remove_last_body(game)
  }
  // Run physics in survival mode
  match game.challenge_state {
    Some(cs) =>
      match cs.mode {
        Survival => {
          let sub_steps = 4
          let sub_dt = dt / Float::from_int(sub_steps)
          for _s in 0..<sub_steps {
            @physics.step(game.world, sub_dt)
          }
          @destruction.process_chain_reaction(game.world, game.destruction)
          @destruction.detect_breaks_and_spawn(game.world, game.destruction)
        }
        _ => ()
      }
    None => ()
  }
  game.tower_height = @physics.measure_tower_height(game.world)
  // Update challenge state
  match game.challenge_state {
    Some(cs) => {
      let ended = @challenge.update_challenge(cs, game.world, dt)
      if ended {
        game.total_score = game.total_score + cs.challenge_score
        game.result_stars = @challenge.challenge_stars(cs)
        game.star_anim_timer = 0.01
        game.screen = ChallengeResults
      }
    }
    None => ()
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = ChallengeSelect
  }
}

///|
fn update_challenge_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = ChallengeSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    match game.challenge_state {
      Some(cs) => start_challenge_mode(game, cs.mode)
      None => game.screen = ChallengeSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn handle_blueprint_selection(game : @types.Game) -> Unit {
  // B key toggles blueprint mode, then number keys select
  if @raylib.is_key_pressed(@raylib.KeyB) {
    if game.selected_blueprint >= 0 {
      // Deselect blueprint
      game.selected_blueprint = -1
      show_message(game, "Blueprint deselected", 0.5)
    } else {
      game.selected_blueprint = 0
      show_message(game, "Blueprint: " + game.blueprints[0].name, 1.0)
    }
  }
  // When in blueprint mode, Tab cycles blueprints
  if game.selected_blueprint >= 0 {
    if @raylib.is_key_pressed(@raylib.KeyTab) {
      game.selected_blueprint = (game.selected_blueprint + 1) %
        game.blueprints.length()
      let bp = game.blueprints[game.selected_blueprint]
      show_message(game, "Blueprint: " + bp.name, 0.5)
    }
  }
}

///|
fn try_place_blueprint(game : @types.Game) -> Unit {
  if game.selected_blueprint < 0 ||
    game.selected_blueprint >= game.blueprints.length() {
    return
  }
  let bp = game.blueprints[game.selected_blueprint]
  if !(@blueprint.can_afford_blueprint(bp, game)) {
    show_message(game, "Not enough pieces for blueprint!", 1.0)
    return
  }
  let placed = @blueprint.place_blueprint(bp, game, game.ghost_x, game.ghost_y)
  if placed > 0 {
    show_message(
      game,
      "Placed " + bp.name + " (" + placed.to_string() + " pieces)",
      1.0,
    )
    game.tower_height = @physics.measure_tower_height(game.world)
  }
}

///|
fn show_message(game : @types.Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
}
