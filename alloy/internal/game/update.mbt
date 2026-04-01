///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  match game.screen {
    Title => update_title(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
    Blending => update_blending(game, dt)
    LevelComplete => update_level_complete(game)
    LevelFailed => update_level_failed(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = 5
    let btn_w = 200
    let btn_h = 85
    let gap = 12
    let w = @types.screen_width
    let start_x = (w - cols * (btn_w + gap)) / 2
    let start_y = 90
    for i in 0..<@types.total_levels {
      let col = i % cols
      let row = i / cols
      let x = start_x + col * (btn_w + gap)
      let y = start_y + row * (btn_h + gap)
      if mx >= x && mx < x + btn_w && my >= y && my < y + btn_h {
        if @types.is_level_unlocked(game, i) {
          @levels.load_level(game, i)
          game.screen = Playing
          return
        }
      }
    }
  }
}

///|
fn update_playing(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  let level = @levels.get_level(game.current_level)
  // Keyboard shortcuts for adding metals (1-6)
  for i = 0; i < level.available_metals.length(); i = i + 1 {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      @types.add_ingredient(game, level.available_metals[i])
      return
    }
  }
  // Temperature toggle: T
  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.temperature = match game.temperature {
      Low => Medium
      Medium => High
      High => Low
    }
    return
  }
  // R for reset
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @levels.load_level(game, game.current_level)
    game.screen = Playing
    @types.set_message(game, "Crucible cleared", 1.0)
    return
  }
  // Space or Enter to blend
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.crucible.length() > 0 {
      @levels.attempt_blend(game)
      game.screen = Blending
    } else {
      @types.set_message(game, "Add metals first!", 1.5)
    }
    return
  }
  // Backspace to remove selected ingredient
  if @raylib.is_key_pressed(@raylib.KeyBackspace) {
    if game.selected_slot >= 0 && game.selected_slot < game.crucible.length() {
      @types.remove_ingredient(game, game.selected_slot)
    } else if game.crucible.length() > 0 {
      @types.remove_ingredient(game, game.crucible.length() - 1)
    }
    return
  }
  // Mouse interactions
  handle_mouse_playing(game, level)
}

///|
fn handle_mouse_playing(game : @types.Game, level : @types.LevelDef) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Update hover state
  game.hover_metal = -1
  game.hover_button = ""
  // Check metal palette hover/click (left side)
  let palette_x = 40
  let palette_y = 120
  let metal_h = 60
  for i = 0; i < level.available_metals.length(); i = i + 1 {
    let y = palette_y + i * metal_h
    if mx >= palette_x && mx < palette_x + 180 && my >= y && my < y + 50 {
      game.hover_metal = i
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        @types.add_ingredient(game, level.available_metals[i])
        return
      }
    }
  }
  // Check crucible slot hover/click
  let crucible_x = 480
  let crucible_y = 200
  let slot_h = 55
  for i in 0..<game.crucible.length() {
    let y = crucible_y + i * slot_h
    if mx >= crucible_x && mx < crucible_x + 260 && my >= y && my < y + 45 {
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        game.selected_slot = i
        return
      }
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
        @types.remove_ingredient(game, i)
        return
      }
    }
  }
  // Temperature buttons
  let temp_x = 480
  let temp_y = 560
  let temp_w = 80
  let temps : Array[@types.Temperature] = [Low, Medium, High]
  for i in 0..<3 {
    let x = temp_x + i * (temp_w + 8)
    if mx >= x && mx < x + temp_w && my >= temp_y && my < temp_y + 35 {
      game.hover_button = "temp_" + i.to_string()
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        game.temperature = temps[i]
        return
      }
    }
  }
  // Blend button
  let blend_x = 480
  let blend_y = 620
  let blend_w = 150
  let blend_h = 40
  if mx >= blend_x &&
    mx < blend_x + blend_w &&
    my >= blend_y &&
    my < blend_y + blend_h {
    game.hover_button = "blend"
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      if game.crucible.length() > 0 {
        @levels.attempt_blend(game)
        game.screen = Blending
      } else {
        @types.set_message(game, "Add metals first!", 1.5)
      }
      return
    }
  }
  // Reset button
  let reset_x = 650
  let reset_y = 620
  let reset_w = 100
  let reset_h = 40
  if mx >= reset_x &&
    mx < reset_x + reset_w &&
    my >= reset_y &&
    my < reset_y + reset_h {
    game.hover_button = "reset"
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      @levels.load_level(game, game.current_level)
      game.screen = Playing
      @types.set_message(game, "Crucible cleared", 1.0)
    }
  }
}

///|
fn update_blending(game : @types.Game, dt : Float) -> Unit {
  game.blend_timer = game.blend_timer + dt
  if game.blend_timer >= @types.blend_anim_duration {
    game.blend_animating = false
    @levels.finish_blend(game)
  }
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.current_level < @types.total_levels - 1 {
      @levels.load_level(game, game.current_level + 1)
      game.screen = Playing
    } else {
      game.screen = LevelSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    @levels.load_level(game, game.current_level)
    game.screen = Playing
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
