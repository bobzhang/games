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
  match game.screen {
    Title => update_title(game)
    Build => update_build(game, dt)
    Test => update_test(game, dt)
    Results => update_results(game)
    LevelSelect => update_level_select(game)
    Sandbox => update_sandbox(game, dt)
  }
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
  // Number keys 1-9, 0 for 10
  for i in 0..<levels.length() {
    let key = if i < 9 {
      @raylib.KeyOne + i
    } else {
      @raylib.KeyZero
    }
    if @raylib.is_key_pressed(key) {
      game.current_level = i
      start_level(game, levels[i])
      return
    }
  }
  // S for sandbox
  if @raylib.is_key_pressed(@raylib.KeyS) {
    start_sandbox(game)
    return
  }
  // Click on level
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    for i in 0..<levels.length() {
      let row = i / 2
      let col = i % 2
      let bx = 300 + col * 560
      let by = 160 + row * 120
      if @types.pointer_in_rect(mx, my, bx, by, 500, 100) {
        game.current_level = i
        start_level(game, levels[i])
        return
      }
    }
    // Sandbox button
    if @types.pointer_in_rect(mx, my, 600, 780, 500, 80) {
      start_sandbox(game)
    }
  }
}

///|
fn start_level(game : @types.Game, level : @types.Level) -> Unit {
  @physics.clear_world(game.world)
  game.screen = Build
  game.selected_piece = 0
  game.ghost_angle = 0.0
  game.test_phase = 0
  game.test_timer = 0.0
  game.tower_height = 0.0
  game.score = 0
  // Copy level inventory
  game.inventory.clear()
  for item in level.available_pieces {
    game.inventory.push(item)
  }
  show_message(game, level.name + ": " + level.description, 3.0)
}

///|
fn start_sandbox(game : @types.Game) -> Unit {
  @physics.clear_world(game.world)
  game.screen = Sandbox
  game.selected_piece = 0
  game.ghost_angle = 0.0
  game.test_phase = 0
  game.test_timer = 0.0
  game.tower_height = 0.0
  game.inventory.clear()
  let sandbox_inv = @content.get_sandbox_inventory()
  for item in sandbox_inv {
    game.inventory.push(item)
  }
  show_message(game, "Sandbox Mode - Build freely!", 2.0)
}

///|
fn update_build(game : @types.Game, dt : Float) -> Unit {
  ignore(dt)
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
  }
  // Select piece with number keys or scroll
  handle_piece_selection(game)
  // Place piece with left click (not in panel area)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if mx < Float::from_int(@types.panel_x) {
      try_place_piece(game)
    }
  }
  // Undo with Z
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    remove_last_body(game)
  }
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
  // Run physics each frame
  let sub_steps = 4
  let sub_dt = dt / Float::from_int(sub_steps)
  for _s in 0..<sub_steps {
    @physics.step(game.world, sub_dt)
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
  show_message(game, "Testing your tower!", 2.0)
  // Start first test phase if any
  if level.test_kinds.length() > 0 {
    start_test_phase(game, level.test_kinds[0])
  }
}

///|
fn start_test_phase(game : @types.Game, kind : @types.TestKind) -> Unit {
  match kind {
    Wind => {
      let dir : Float = if game.frame_count % 2 == 0 { 1.0 } else { -1.0 }
      @physics.start_wind(game.world, @types.wind_test_force * dir)
      show_message(game, "WIND!", 1.5)
    }
    Earthquake => {
      @physics.start_earthquake(
        game.world,
        @types.quake_test_duration,
        @types.quake_test_intensity,
      )
      show_message(game, "EARTHQUAKE!", 1.5)
    }
    Impact => {
      @physics.fire_impact(game.world, @types.impact_force)
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
  let height_bonus = if height >= level.target_height { 500 } else { 0 }
  game.score = survival_pct * 10 + height_bonus
  if height > game.best_height {
    game.best_height = height
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
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
  // Click handling
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = Float::from_int(@raylib.get_mouse_x())
    let my = Float::from_int(@raylib.get_mouse_y())
    // Retry button
    if @types.pointer_in_rect(mx, my, 560, 600, 280, 60) {
      let levels = @content.get_levels()
      start_level(game, levels[game.current_level])
    }
    // Next level button
    if @types.pointer_in_rect(mx, my, 880, 600, 280, 60) {
      let levels = @content.get_levels()
      if game.current_level + 1 < levels.length() {
        game.current_level = game.current_level + 1
        start_level(game, levels[game.current_level])
      } else {
        game.screen = LevelSelect
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
fn show_message(game : @types.Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
}
