///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update timers
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  if game.hint_timer > 0.0 {
    game.hint_timer = game.hint_timer - dt
    if game.hint_timer <= 0.0 {
      game.hint_symbol = None
    }
  }
  game.anim_timer = game.anim_timer + dt
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    TabletSelect => update_tablet_select(game)
    Playing => update_playing(game)
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
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Fragments
    game.screen = TabletSelect
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Scrolls
    game.screen = TabletSelect
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = Monuments
    game.screen = TabletSelect
  } else if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_tablet_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let count = @types.tier_tablet_count(game.current_tier)
  let offset = @types.tier_tablet_offset(game.current_tier)
  // Number keys 1-9 to select tablet
  let keys = [
    @raylib.KeyOne,
    @raylib.KeyTwo,
    @raylib.KeyThree,
    @raylib.KeyFour,
    @raylib.KeyFive,
    @raylib.KeySix,
    @raylib.KeySeven,
    @raylib.KeyEight,
    @raylib.KeyNine,
  ]
  for i in 0..<@types.mini(count, 9) {
    if @raylib.is_key_pressed(keys[i]) {
      start_tablet(game, offset + i)
      return
    }
  }
}

///|
fn start_tablet(game : @types.Game, index : Int) -> Unit {
  let tablet = @levels.get_tablet(index)
  game.current_tablet_index = index
  game.current_mapping = @types.copy_mapping(tablet.given_mapping)
  game.guesses = 0
  game.wrong_count = 0
  game.selected_symbol = None
  game.undo_stack = []
  game.play_state = Decoding
  game.hint_symbol = None
  game.hint_timer = 0.0
  game.message = ""
  game.message_timer = 0.0
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TabletSelect
    return
  }
  let tablet = @levels.get_tablet(game.current_tablet_index)
  // Check if already solved
  if game.play_state == Solved {
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      game.screen = Results
    }
    return
  }
  // Handle hint (H key)
  if @raylib.is_key_pressed(@raylib.KeyH) {
    handle_hint(game, tablet)
    return
  }
  // Handle undo (Z key)
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    handle_undo(game, tablet)
    return
  }
  // Handle clear selected (X key)
  if @raylib.is_key_pressed(@raylib.KeyX) {
    handle_clear(game, tablet)
    return
  }
  // Handle mouse clicks on inscription symbols
  let mouse_x = @raylib.get_mouse_x()
  let mouse_y = @raylib.get_mouse_y()
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    // Check if clicked on a symbol in the inscription
    let clicked_sym = find_clicked_symbol(tablet, mouse_x, mouse_y)
    match clicked_sym {
      Some(sym) =>
        if !@types.is_given_symbol(tablet, sym) {
          game.selected_symbol = Some(sym)
        }
      None => {
        // Check if clicked on a letter in the palette
        let clicked_letter = find_clicked_letter(mouse_x, mouse_y)
        if clicked_letter >= 0 {
          handle_assign_letter(game, tablet, clicked_letter)
        }
      }
    }
  }
  // Keyboard letter assignment A-T
  let letter_keys = [
    @raylib.KeyA,
    @raylib.KeyB,
    @raylib.KeyC,
    @raylib.KeyD,
    @raylib.KeyE,
    @raylib.KeyF,
    @raylib.KeyG,
    @raylib.KeyH,
    @raylib.KeyI,
    @raylib.KeyJ,
    @raylib.KeyK,
    @raylib.KeyL,
    @raylib.KeyM,
    @raylib.KeyN,
    @raylib.KeyO,
    @raylib.KeyP,
    @raylib.KeyQ,
    @raylib.KeyR,
    @raylib.KeyS,
    @raylib.KeyT,
  ]
  for i in 0..<letter_keys.length() {
    if @raylib.is_key_pressed(letter_keys[i]) {
      // Don't intercept H, Z, X since they're handled above
      // H=7, Z not in A-T, X not in A-T
      // H is handled first above so we won't get here for H
      handle_assign_letter(game, tablet, i)
      break
    }
  }
}

///|
fn handle_assign_letter(
  game : @types.Game,
  tablet : @types.Tablet,
  letter_idx : Int,
) -> Unit {
  match game.selected_symbol {
    None => @types.set_message(game, "Select a symbol first", 1.5)
    Some(sym) => {
      if @types.is_given_symbol(tablet, sym) {
        @types.set_message(game, "Cannot change given mappings", 1.5)
        return
      }
      // Check if this letter is already used by another symbol
      let existing = @types.find_symbol_for_letter(
        game.current_mapping,
        letter_idx,
      )
      if existing >= 0 {
        let existing_sym = @types.symbol_from_index(existing)
        if existing_sym != sym {
          // Check if the existing mapping is given
          if @types.is_given_symbol(tablet, existing_sym) {
            @types.set_message(
              game, "Letter already used by a given symbol", 1.5,
            )
            return
          }
          // Clear the existing mapping
          let old_val = game.current_mapping.values[existing]
          game.undo_stack.push({ symbol_index: existing, old_value: old_val })
          @types.mapping_clear(game.current_mapping, existing_sym)
        }
      }
      // Save undo
      let si = @types.symbol_index(sym)
      let old_val = game.current_mapping.values[si]
      game.undo_stack.push({ symbol_index: si, old_value: old_val })
      // Apply mapping
      @types.mapping_set(game.current_mapping, sym, letter_idx)
      game.guesses = game.guesses + 1
      // Check if wrong
      if @decoder.check_mapping_wrong(
          game.current_mapping,
          tablet.solution_mapping,
          sym,
        ) {
        game.wrong_count = game.wrong_count + 1
        @types.set_message(game, "Wrong mapping!", 1.0)
      } else {
        @types.set_message(game, "Mapping set", 0.5)
      }
      // Check if fully decoded
      if @decoder.is_fully_decoded(
          game.current_mapping,
          tablet.solution_mapping,
          tablet.inscription,
        ) {
        game.play_state = Solved
        let stars = @decoder.compute_stars(
          tablet,
          game.guesses,
          game.wrong_count,
        )
        let score = game.scores[game.current_tablet_index]
        score.solved = true
        score.guesses_used = game.guesses
        score.wrong_count = game.wrong_count
        if stars > score.stars {
          score.stars = stars
        }
        @types.set_message(game, "DECODED! Press ENTER", 5.0)
      }
      // Clear selection
      game.selected_symbol = None
    }
  }
}

///|
fn handle_hint(game : @types.Game, tablet : @types.Tablet) -> Unit {
  let hint = @decoder.find_hint(tablet, game.current_mapping)
  match hint {
    None => @types.set_message(game, "No hints available", 1.0)
    Some(sym) => {
      let letter = @decoder.get_hint_letter(tablet, sym)
      game.hint_symbol = Some(sym)
      game.hint_timer = 3.0
      game.selected_symbol = Some(sym)
      let letter_str = @types.letter_from_index(letter)
      @types.set_message(
        game,
        "Hint: try letter " + letter_str + " for highlighted symbol",
        3.0,
      )
    }
  }
}

///|
fn handle_undo(game : @types.Game, tablet : @types.Tablet) -> Unit {
  if game.undo_stack.length() == 0 {
    @types.set_message(game, "Nothing to undo", 1.0)
    return
  }
  let entry = game.undo_stack.pop()
  match entry {
    Some(e) => {
      game.current_mapping.values[e.symbol_index] = e.old_value
      @types.set_message(game, "Undone", 0.5)
    }
    None => ()
  }
  ignore(tablet)
}

///|
fn handle_clear(game : @types.Game, tablet : @types.Tablet) -> Unit {
  match game.selected_symbol {
    None => @types.set_message(game, "Select a symbol to clear", 1.0)
    Some(sym) => {
      if @types.is_given_symbol(tablet, sym) {
        @types.set_message(game, "Cannot clear given mappings", 1.0)
        return
      }
      let si = @types.symbol_index(sym)
      let old_val = game.current_mapping.values[si]
      if old_val >= 0 {
        game.undo_stack.push({ symbol_index: si, old_value: old_val })
        @types.mapping_clear(game.current_mapping, sym)
        @types.set_message(game, "Mapping cleared", 0.5)
      }
      game.selected_symbol = None
    }
  }
}

///|
fn find_clicked_symbol(
  tablet : @types.Tablet,
  mouse_x : Int,
  mouse_y : Int,
) -> @types.Symbol? {
  let inscription = tablet.inscription
  let base_x = @types.tablet_x + 30
  let base_y = @types.tablet_y + 40
  let max_width = @types.tablet_width - 60
  let line_height = 90
  let mut cx = 0
  let mut cy = 0
  let size = @types.symbol_size.to_int()
  for i in 0..<inscription.symbols.length() {
    match inscription.symbols[i].symbol {
      None => {
        cx = cx + @types.word_gap
        if cx > max_width - @types.symbol_spacing {
          cx = 0
          cy = cy + line_height
        }
      }
      Some(sym) => {
        if cx > max_width - @types.symbol_spacing {
          cx = 0
          cy = cy + line_height
        }
        let sx = base_x + cx
        let sy = base_y + cy
        if mouse_x >= sx &&
          mouse_x <= sx + size &&
          mouse_y >= sy &&
          mouse_y <= sy + size {
          return Some(sym)
        }
        cx = cx + @types.symbol_spacing
      }
    }
  }
  None
}

///|
fn find_clicked_letter(mouse_x : Int, mouse_y : Int) -> Int {
  let px = @types.palette_x
  let py = @types.palette_y + 28
  let btn_size = @types.palette_btn_size
  let cols = @types.palette_cols
  for i in 0..<@types.symbol_count {
    let row = i / cols
    let col = i % cols
    let bx = px + col * (btn_size + 6)
    let by = py + row * (btn_size + 6)
    if mouse_x >= bx &&
      mouse_x <= bx + btn_size &&
      mouse_y >= by &&
      mouse_y <= by + btn_size {
      return i
    }
  }
  -1
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Go to next tablet if available
    let offset = @types.tier_tablet_offset(game.current_tier)
    let count = @types.tier_tablet_count(game.current_tier)
    let next = game.current_tablet_index + 1
    if next < offset + count {
      start_tablet(game, next)
    } else {
      game.screen = TabletSelect
    }
  } else if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TabletSelect
  }
}
