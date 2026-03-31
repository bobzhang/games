///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  game.anim_timer = game.anim_timer + dt
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
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
  let dt = @raylib.get_frame_time()
  game.title_gear_angle = game.title_gear_angle + dt * 0.5
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.selected_tier = match game.selected_tier {
      Gears => Workshop
      Trains => Gears
      Workshop => Trains
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.selected_tier = match game.selected_tier {
      Gears => Trains
      Trains => Workshop
      Workshop => Gears
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.selected_level = @types.tier_level_offset(game.selected_tier)
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let offset = @types.tier_level_offset(game.selected_tier)
  let count = @types.tier_level_count(game.selected_tier)
  let current = game.selected_level - offset
  let cols = 5
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    let next = current + 1
    if next < count {
      game.selected_level = offset + next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    let prev = current - 1
    if prev >= 0 {
      game.selected_level = offset + prev
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let next = current + cols
    if next < count {
      game.selected_level = offset + next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    let prev = current - cols
    if prev >= 0 {
      game.selected_level = offset + prev
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_level(game, game.selected_level)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  let level = @levels.get_level(index)
  game.current_level = Some(level)
  game.selected_level = index
  game.play_state = Placing
  game.placed_gears = []
  game.belts = []
  game.connections = []
  game.belt_start = None
  game.sim_time = 0.0
  game.message = ""
  game.message_timer = 0.0
  // Pre-place the input gear
  let input_kind : @types.GearKind = match level.input.radius {
    1 => Small
    3 => Large
    _ => Medium
  }
  let input_gear = @types.new_gear(level.input.pos, input_kind)
  input_gear.rpm = level.input.rpm
  input_gear.dir = level.input.dir
  game.placed_gears.push(input_gear)
  // Set default selected gear
  if level.available_gears.length() > 0 {
    game.selected_gear_kind = level.available_gears[0]
  }
  game.screen = Playing
  // Run initial simulation
  @mechanics.simulate(game)
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Update gear animations
  @mechanics.update_gear_angles(game, dt)
  game.sim_time = game.sim_time + dt
  // Handle mouse hover
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  game.hover_peg = @types.screen_to_grid(mx, my)
  // Gear selection keys
  handle_gear_selection(game)
  // Place gear on left click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    handle_left_click(game)
  }
  // Remove gear on right click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    handle_right_click(game)
  }
  // Restart level
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.selected_level)
  }
  // Back to menu
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
  // Go to results on Enter when solved
  if game.play_state == Solved && @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = Results
  }
}

///|
fn handle_gear_selection(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  if @raylib.is_key_pressed(@raylib.KeyOne) &&
    level.available_gears.length() > 0 {
    game.selected_gear_kind = level.available_gears[0]
    game.belt_start = None
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) &&
    level.available_gears.length() > 1 {
    game.selected_gear_kind = level.available_gears[1]
    game.belt_start = None
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) &&
    level.available_gears.length() > 2 {
    game.selected_gear_kind = level.available_gears[2]
    game.belt_start = None
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) &&
    level.available_gears.length() > 3 {
    game.selected_gear_kind = level.available_gears[3]
    game.belt_start = None
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) &&
    level.available_gears.length() > 4 {
    game.selected_gear_kind = level.available_gears[4]
    game.belt_start = None
  }
}

///|
fn handle_left_click(game : @types.Game) -> Unit {
  if game.play_state == Solved {
    return
  }
  let pos = match game.hover_peg {
    Some(p) => p
    None => return
  }
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Don't allow placing on input gear position
  if pos == level.input.pos {
    @types.set_message(game, "Cannot replace input gear", 1.5)
    return
  }
  if game.selected_gear_kind == Belt {
    // Belt placement: two clicks
    match game.belt_start {
      None => {
        // First click: start of belt
        if @types.find_gear_at(game.placed_gears, pos) >= 0 {
          game.belt_start = Some(pos)
          @types.set_message(game, "Click second gear for belt", 2.0)
        } else {
          @types.set_message(game, "Belt must connect to a gear", 1.5)
        }
      }
      Some(start) => {
        // Second click: end of belt
        if pos == start {
          game.belt_start = None
          return
        }
        if @types.find_gear_at(game.placed_gears, pos) >= 0 {
          let belt = @types.new_belt(start, pos)
          game.belts.push(belt)
          game.belt_start = None
          @mechanics.simulate(game)
          @types.set_message(game, "Belt connected!", 1.0)
        } else {
          @types.set_message(game, "Belt must connect to a gear", 1.5)
        }
      }
    }
  } else {
    // Normal gear placement
    if @mechanics.can_place_gear(game, pos, game.selected_gear_kind) {
      let gear = @types.new_gear(pos, game.selected_gear_kind)
      game.placed_gears.push(gear)
      @mechanics.simulate(game)
      if game.play_state == Solved {
        @types.set_message(game, "Puzzle Solved!", 3.0)
      }
    } else {
      // Check reason
      let existing = @types.find_gear_at(game.placed_gears, pos)
      if existing >= 0 {
        @types.set_message(game, "Peg already occupied", 1.0)
      } else {
        let used = @types.count_placed_gears(game.placed_gears)
        if used >= level.gear_budget {
          @types.set_message(game, "Budget exceeded!", 1.0)
        } else {
          @types.set_message(game, "Cannot place here", 1.0)
        }
      }
    }
  }
}

///|
fn handle_right_click(game : @types.Game) -> Unit {
  if game.play_state == Solved {
    return
  }
  let pos = match game.hover_peg {
    Some(p) => p
    None => return
  }
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Don't allow removing input gear
  if pos == level.input.pos {
    @types.set_message(game, "Cannot remove input gear", 1.0)
    return
  }
  let idx = @types.find_gear_at(game.placed_gears, pos)
  if idx >= 0 {
    game.placed_gears[idx].active = false
    // Also remove any belts connected to this position
    for i in 0..<game.belts.length() {
      if game.belts[i].active &&
        (game.belts[i].from_pos == pos || game.belts[i].to_pos == pos) {
        game.belts[i].active = false
      }
    }
    game.play_state = Placing
    @mechanics.simulate(game)
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    let next = game.selected_level + 1
    if next < @types.total_levels {
      start_level(game, next)
    } else {
      game.screen = TierSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.selected_level)
  }
}
