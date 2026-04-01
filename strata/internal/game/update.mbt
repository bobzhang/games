///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @raylib.get_frame_time()
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
    }
  }
  game.anim_timer = game.anim_timer + dt
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
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
    game.current_tier = Surface
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Bedrock
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = DeepCore
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let range = @types.tier_level_range(game.current_tier)
  let count = range.1 - range.0 + 1
  // Number key selection
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
  for i in 0..<@types.mini(count, keys.length()) {
    if @raylib.is_key_pressed(keys[i]) {
      start_level(game, range.0 + i)
      return
    }
  }
  // Mouse click selection
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = 5
    let cell_w = 200
    let cell_h = 100
    let start_x = (@types.screen_width - cols * cell_w) / 2
    let start_y = 100
    let mut idx = 0
    for j = range.0; j <= range.1; j = j + 1 {
      let col = idx % cols
      let row = idx / cols
      let bx = start_x + col * cell_w + 10
      let by = start_y + row * (cell_h + 20) + 10
      let bw = cell_w - 20
      let bh = cell_h - 10
      if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
        start_level(game, j)
        return
      }
      idx += 1
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  game.current_level = level_idx
  let level = @levels.get_level(level_idx)
  // Initialize empty slots
  let num_slots = level.rocks.length()
  let slots : Array[@types.RockKind?] = Array::new(capacity=num_slots)
  for _i in 0..<num_slots {
    slots.push(None)
  }
  game.slots = slots
  // Copy rocks to tray (shuffled)
  let tray : Array[@types.RockKind] = Array::new(capacity=num_slots)
  for i in 0..<level.rocks.length() {
    tray.push(level.rocks[i])
  }
  // Simple shuffle using frame_count as seed
  let mut seed = game.frame_count + level_idx * 137
  for i = tray.length() - 1; i > 0; i = i - 1 {
    seed = seed * 1103515245 + 12345
    let sv = seed / 65536
    let j = (if sv < 0 { -sv } else { sv }) % (i + 1)
    let tmp = tray[i]
    tray[i] = tray[j]
    tray[j] = tmp
  }
  game.tray = tray
  // Reset state
  game.play_state = Arranging
  game.moves = 0
  game.selected_tray = -1
  game.selected_slot = -1
  game.any_incorrect = false
  game.undo_stack = []
  game.anim_timer = 0.0
  game.message = ""
  game.message_timer = 0.0
  // Reset clue satisfaction
  for i in 0..<level.clues.length() {
    level.clues[i].satisfied = false
  }
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if @types.pop_undo(game) {
      game.moves = @types.maxi(0, game.moves - 1)
      @types.set_message(game, "Undo!", 1.0)
      // Re-validate
      let level = @levels.get_level(game.current_level)
      let _ = @geology.validate_all(level.clues, game.slots)
    }
    return
  }
  if game.play_state != Arranging {
    return
  }
  // Check/submit with Enter
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if @types.all_slots_filled(game.slots) {
      check_solution(game)
    } else {
      @types.set_message(game, "Fill all slots first!", 2.0)
    }
    return
  }
  // Handle keyboard input for tray selection (number keys)
  handle_tray_keys(game)
  // Handle keyboard input for slot selection (arrow keys + placement)
  handle_slot_keys(game)
  // Handle mouse input
  handle_mouse_input(game)
  // Auto-validate clues after each change
  let level = @levels.get_level(game.current_level)
  let _ = @geology.validate_all(level.clues, game.slots)
}

///|
fn handle_tray_keys(game : @types.Game) -> Unit {
  // Number keys 1-9 select tray items (shifted by whether a tray item is already selected)
  if game.selected_tray >= 0 {
    // A tray item is selected, number keys place it in slots
    return
  }
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
  for i in 0..<@types.mini(game.tray.length(), keys.length()) {
    if @raylib.is_key_pressed(keys[i]) {
      game.selected_tray = i
      game.selected_slot = -1
      @types.set_message(
        game,
        "Selected " +
        @types.rock_name(game.tray[i]) +
        " - press Up/Down to choose slot, Enter to place",
        2.0,
      )
      return
    }
  }
}

///|
fn handle_slot_keys(game : @types.Game) -> Unit {
  let num_slots = game.slots.length()
  if game.selected_tray >= 0 {
    // Tray item selected - arrow keys to pick slot, Enter to place
    if @raylib.is_key_pressed(@raylib.KeyUp) {
      if game.selected_slot < 0 {
        game.selected_slot = 0
      } else {
        game.selected_slot = @types.mini(game.selected_slot + 1, num_slots - 1)
      }
    }
    if @raylib.is_key_pressed(@raylib.KeyDown) {
      if game.selected_slot < 0 {
        game.selected_slot = num_slots - 1
      } else {
        game.selected_slot = @types.maxi(game.selected_slot - 1, 0)
      }
    }
    if @raylib.is_key_pressed(@raylib.KeyEnter) &&
      game.selected_slot >= 0 &&
      game.selected_slot < num_slots {
      place_from_tray(game, game.selected_tray, game.selected_slot)
      return
    }
    // Escape deselects
    if @raylib.is_key_pressed(@raylib.KeyTab) {
      game.selected_tray = -1
      game.selected_slot = -1
    }
  } else if game.selected_slot >= 0 {
    // Slot selected (for swapping) - arrow keys to move, Enter to swap
    if @raylib.is_key_pressed(@raylib.KeyUp) {
      game.selected_slot = @types.mini(game.selected_slot + 1, num_slots - 1)
    }
    if @raylib.is_key_pressed(@raylib.KeyDown) {
      game.selected_slot = @types.maxi(game.selected_slot - 1, 0)
    }
    if @raylib.is_key_pressed(@raylib.KeyTab) {
      game.selected_slot = -1
    }
  }
}

///|
fn handle_mouse_input(game : @types.Game) -> Unit {
  if !@raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    return
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Check tray click
  let tray_idx = get_tray_at_mouse(game, mx, my)
  if tray_idx >= 0 {
    if game.selected_tray >= 0 && game.selected_tray == tray_idx {
      // Deselect
      game.selected_tray = -1
    } else {
      game.selected_tray = tray_idx
      game.selected_slot = -1
    }
    return
  }
  // Check slot click
  let slot_idx = get_slot_at_mouse(game, mx, my)
  if slot_idx >= 0 {
    if game.selected_tray >= 0 {
      // Place from tray
      place_from_tray(game, game.selected_tray, slot_idx)
    } else {
      // Click on slot: select/deselect for swapping or return to tray
      match game.slots[slot_idx] {
        Some(_) =>
          if game.selected_slot >= 0 && game.selected_slot != slot_idx {
            // Swap two slots
            swap_slots(game, game.selected_slot, slot_idx)
          } else if game.selected_slot == slot_idx {
            // Return to tray
            return_to_tray(game, slot_idx)
          } else {
            game.selected_slot = slot_idx
            game.selected_tray = -1
          }
        None =>
          if game.selected_slot >= 0 {
            // Move from filled slot to empty slot
            move_to_empty_slot(game, game.selected_slot, slot_idx)
          }
      }
    }
    return
  }
}

///|
fn get_tray_at_mouse(game : @types.Game, mx : Int, my : Int) -> Int {
  let tx = @types.tray_x
  let ty = @types.tray_y
  let rock_w = 120
  let rock_h = 45
  let gap = 10
  for i in 0..<game.tray.length() {
    let rx = tx + i * (rock_w + gap)
    let ry = ty
    if mx >= rx && mx <= rx + rock_w && my >= ry && my <= ry + rock_h {
      return i
    }
  }
  -1
}

///|
fn get_slot_at_mouse(game : @types.Game, mx : Int, my : Int) -> Int {
  let sx = @types.section_x
  let sy = @types.section_y
  let sw = @types.slot_width
  let sh = @types.slot_height
  let num_slots = game.slots.length()
  for i in 0..<num_slots {
    let display_row = num_slots - 1 - i
    let slot_y = sy + display_row * sh
    if mx >= sx && mx <= sx + sw && my >= slot_y && my <= slot_y + sh {
      return i
    }
  }
  -1
}

///|
fn place_from_tray(game : @types.Game, tray_idx : Int, slot_idx : Int) -> Unit {
  if tray_idx < 0 || tray_idx >= game.tray.length() {
    return
  }
  if slot_idx < 0 || slot_idx >= game.slots.length() {
    return
  }
  // Save undo state
  @types.save_undo(game)
  let rock = game.tray[tray_idx]
  // If slot already has a rock, return it to tray
  match game.slots[slot_idx] {
    Some(existing) => game.tray.push(existing)
    None => ()
  }
  // Place rock
  game.slots[slot_idx] = Some(rock)
  // Remove from tray
  let new_tray : Array[@types.RockKind] = []
  for i in 0..<game.tray.length() {
    if i != tray_idx {
      new_tray.push(game.tray[i])
    }
  }
  game.tray = new_tray
  game.moves += 1
  game.selected_tray = -1
  game.selected_slot = -1
}

///|
fn swap_slots(game : @types.Game, slot_a : Int, slot_b : Int) -> Unit {
  @types.save_undo(game)
  let tmp = game.slots[slot_a]
  game.slots[slot_a] = game.slots[slot_b]
  game.slots[slot_b] = tmp
  game.moves += 1
  game.selected_slot = -1
}

///|
fn return_to_tray(game : @types.Game, slot_idx : Int) -> Unit {
  match game.slots[slot_idx] {
    Some(rock) => {
      @types.save_undo(game)
      game.tray.push(rock)
      game.slots[slot_idx] = None
      game.moves += 1
      game.selected_slot = -1
    }
    None => ()
  }
}

///|
fn move_to_empty_slot(game : @types.Game, from : Int, to : Int) -> Unit {
  match game.slots[from] {
    Some(_) => {
      @types.save_undo(game)
      game.slots[to] = game.slots[from]
      game.slots[from] = None
      game.moves += 1
      game.selected_slot = -1
    }
    None => ()
  }
}

///|
fn check_solution(game : @types.Game) -> Unit {
  game.play_state = Checking
  let level = @levels.get_level(game.current_level)
  let satisfied = @geology.validate_all(level.clues, game.slots)
  if satisfied == level.clues.length() {
    // Solved!
    game.play_state = Solved
    // Calculate stars
    let mut stars = 1 // 1 star for correct
    if game.moves <= level.par_moves {
      stars = 2 // 2 stars for within par
    }
    if game.moves <= level.par_moves && !game.any_incorrect {
      stars = 3 // 3 stars for par + no mistakes
    }
    // Update score
    let score = game.scores[game.current_level]
    if !score.completed || stars > score.stars {
      score.stars = stars
    }
    score.completed = true
    if game.moves < score.best_moves {
      score.best_moves = game.moves
    }
    game.screen = Results
  } else {
    game.play_state = Failed
    game.any_incorrect = true
    @types.set_message(
      game,
      satisfied.to_string() +
      "/" +
      level.clues.length().to_string() +
      " clues satisfied. Keep trying!",
      3.0,
    )
    // Reset to arranging so player can continue
    game.play_state = Arranging
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  if game.play_state == Solved && @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    let next = game.current_level + 1
    if next < @types.total_levels {
      start_level(game, next)
    } else {
      game.screen = TierSelect
    }
  }
}
