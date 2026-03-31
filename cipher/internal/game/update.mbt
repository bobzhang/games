///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  let dt : Float = @raylib.get_frame_time()
  if game.message_flash_timer > 0.0 {
    game.message_flash_timer -= dt
  }
  if game.result_timer > 0.0 {
    game.result_timer -= dt
  }
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
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  let tiers : Array[@types.Tier] = [Recruit, Agent, Cryptographer]
  // Mouse selection
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let w = @types.screen_width
  for t in 0..<3 {
    let bx = w / 2 - 200
    let by = 140 + t * 160
    let bw = 400
    let bh = 130
    if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        game.selected_tier = tiers[t]
        game.screen = LevelSelect
        let (start, _) = @types.tier_level_range(tiers[t])
        game.selected_level = start
        return
      }
    }
  }
  // Keyboard nav
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.selected_tier = match game.selected_tier {
      Recruit => Agent
      Agent => Cryptographer
      Cryptographer => Cryptographer
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.selected_tier = match game.selected_tier {
      Recruit => Recruit
      Agent => Recruit
      Cryptographer => Agent
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
    let (start, _) = @types.tier_level_range(game.selected_tier)
    game.selected_level = start
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let tier = game.selected_tier
  let (start, end_) = @types.tier_level_range(tier)
  let count = end_ - start + 1
  let cols = if count <= 4 { count } else { 5 }
  let cell_w = 180
  let cell_h = 120
  let gap = 15
  let grid_w = cols * cell_w + (cols - 1) * gap
  let w = @types.screen_width
  let base_x = (w - grid_w) / 2
  let base_y = 100
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Mouse click on level
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    for i = 0; i < count; i = i + 1 {
      let col = i % cols
      let row = i / cols
      let bx = base_x + col * (cell_w + gap)
      let by = base_y + row * (cell_h + gap)
      if mx >= bx && mx < bx + cell_w && my >= by && my < by + cell_h {
        let level_id = start + i
        game.selected_level = level_id
        start_level(game, level_id)
        return
      }
    }
  }
  // Keyboard nav
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.selected_level < end_ {
      game.selected_level += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.selected_level > start {
      game.selected_level -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_level(game, game.selected_level)
  }
}

///|
fn start_level(game : @types.Game, level_id : Int) -> Unit {
  game.current_level = level_id
  game.screen = Playing
  @types.reset_for_level(game)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // If solved, go to results after brief pause
  if game.play_state == Solved {
    if game.result_timer <= 0.0 {
      game.screen = Results
    }
    return
  }
  let level = @levels.get_level(game.current_level)
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if game.undo_stack.length() > 0 {
      let entry = game.undo_stack.pop().unwrap()
      @types.undo_mapping(game.mapping, entry)
      game.patterns_dirty = true
    }
  }
  // Hint
  if @raylib.is_key_pressed(@raylib.KeyH) {
    let (ci, pi) = @crypto.get_hint_mapping(
      level.ciphertext,
      level.plaintext,
      game.mapping,
    )
    if ci != pi || game.mapping.cipher_to_plain[ci] != pi {
      let entry = @types.assign_mapping(game.mapping, ci, pi)
      game.undo_stack.push(entry)
      game.hints_used += 1
      game.swap_count += 1
      game.patterns_dirty = true
      check_solved(game, level)
    }
  }
  // Tool tab switching with number keys
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.active_tool = FrequencyChart
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.active_tool = LetterSwap
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.active_tool = PatternFinder
  }
  // Scroll
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel > 0.0 {
    game.scroll_offset = @types.maxi(0, game.scroll_offset - 40)
  }
  if wheel < 0.0 {
    game.scroll_offset += 40
  }
  // Mouse interaction
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    // Check tool tab clicks
    if my >= 55 && my < 85 {
      let tab_w = @types.tool_panel_w / 3
      if mx >= @types.tool_panel_x && mx < @types.tool_panel_x + @types.tool_panel_w {
        let tab = (mx - @types.tool_panel_x) / tab_w
        game.active_tool = match tab {
          0 => FrequencyChart
          1 => LetterSwap
          _ => PatternFinder
        }
      }
    }
    // Check message area clicks (select cipher letter)
    if mx >= @types.msg_area_x && mx < @types.msg_area_x + @types.msg_area_w && my >=
    @types.msg_area_y && my < @types.screen_height - 70 {
      handle_message_click(game, level, mx, my)
    }
    // Check alphabet strip clicks
    let strip_y = @types.screen_height - 65
    if my >= strip_y && my < strip_y + 44 {
      let strip_x = 40
      let cell_w = 42
      if mx >= strip_x && mx < strip_x + 26 * cell_w {
        let idx = (mx - strip_x) / cell_w
        if idx >= 0 && idx < 26 {
          if game.selected_cipher_letter >= 0 {
            // Assign this as cipher letter mapping
            handle_cipher_select(game, level, idx)
          } else {
            // Select cipher letter
            game.selected_cipher_letter = idx
            game.active_tool = LetterSwap
          }
        }
      }
    }
    // Check letter swap grid clicks (assign plain letter)
    if game.active_tool == LetterSwap && game.selected_cipher_letter >= 0 {
      let grid_y = 55 + 40 + 72
      let cell = 40
      let px = @types.tool_panel_x
      for i in 0..<26 {
        let col = i % 7
        let row = i / 7
        let gx = px + 15 + col * (cell + 4)
        let gy = grid_y + row * (cell + 4)
        if mx >= gx && mx < gx + cell && my >= gy && my < gy + cell {
          let entry = @types.assign_mapping(
            game.mapping,
            game.selected_cipher_letter,
            i,
          )
          game.undo_stack.push(entry)
          game.swap_count += 1
          game.selected_cipher_letter = -1
          game.patterns_dirty = true
          check_solved(game, level)
          break
        }
      }
    }
    // Hint button click
    let hint_y = 55 + (@types.screen_height - 125) - 70
    if mx >= @types.tool_panel_x + 10 &&
      mx < @types.tool_panel_x + @types.tool_panel_w - 10 &&
      my >= hint_y &&
      my < hint_y + 30 {
      let (ci, pi) = @crypto.get_hint_mapping(
        level.ciphertext,
        level.plaintext,
        game.mapping,
      )
      if ci != pi || game.mapping.cipher_to_plain[ci] != pi {
        let entry = @types.assign_mapping(game.mapping, ci, pi)
        game.undo_stack.push(entry)
        game.hints_used += 1
        game.swap_count += 1
        game.patterns_dirty = true
        check_solved(game, level)
      }
    }
    // Undo button click
    let undo_y = hint_y + 35
    if mx >= @types.tool_panel_x + 10 &&
      mx < @types.tool_panel_x + @types.tool_panel_w - 10 &&
      my >= undo_y &&
      my < undo_y + 30 {
      if game.undo_stack.length() > 0 {
        let entry = game.undo_stack.pop().unwrap()
        @types.undo_mapping(game.mapping, entry)
        game.patterns_dirty = true
      }
    }
  }
  // Right click to deselect
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    game.selected_cipher_letter = -1
  }
  // Keyboard letter input for mapping
  if game.selected_cipher_letter >= 0 {
    for i in 0..<26 {
      let key_code = @raylib.KeyA + i
      if @raylib.is_key_pressed(key_code) {
        let entry = @types.assign_mapping(
          game.mapping,
          game.selected_cipher_letter,
          i,
        )
        game.undo_stack.push(entry)
        game.swap_count += 1
        game.selected_cipher_letter = -1
        game.patterns_dirty = true
        check_solved(game, level)
        break
      }
    }
  }
}

///|
fn handle_message_click(
  game : @types.Game,
  level : @types.Level,
  mx : Int,
  my : Int
) -> Unit {
  let base_x = @types.msg_area_x
  let base_y = @types.msg_area_y + 20
  let cell_w = @types.char_cell_w
  let cell_h = @types.char_cell_h
  let max_cols = @types.msg_area_w / cell_w
  let row_height = cell_h * 2 + 50
  let ct = level.ciphertext
  let mut col = 0
  let mut row = 0
  for i in 0..<ct.length() {
    let c = @types.str_char_at(ct, i)
    let x = base_x + col * cell_w
    let cipher_y = base_y + row * row_height - game.scroll_offset
    if @types.is_upper(c) &&
      mx >= x &&
      mx < x + cell_w &&
      my >= cipher_y &&
      my < cipher_y + cell_h {
      let ci = @types.char_to_idx(c)
      if game.selected_cipher_letter == ci {
        game.selected_cipher_letter = -1
      } else {
        game.selected_cipher_letter = ci
        game.active_tool = LetterSwap
      }
      return
    }
    col += 1
    if c == ' ' || col >= max_cols {
      if c == ' ' || col > max_cols {
        col = 0
        row += 1
      }
    }
  }
}

///|
fn handle_cipher_select(
  game : @types.Game,
  level : @types.Level,
  plain_idx : Int
) -> Unit {
  let entry = @types.assign_mapping(
    game.mapping,
    game.selected_cipher_letter,
    plain_idx,
  )
  game.undo_stack.push(entry)
  game.swap_count += 1
  game.selected_cipher_letter = -1
  game.patterns_dirty = true
  check_solved(game, level)
}

///|
fn check_solved(game : @types.Game, level : @types.Level) -> Unit {
  if @types.check_solution(level.ciphertext, level.plaintext, game.mapping) {
    game.play_state = Solved
    game.message_flash_timer = 1.0
    game.result_timer = 1.5
    // Update score
    let stars = @types.calc_stars(
      game.swap_count,
      level.par_swaps,
      game.hints_used,
    )
    let score = game.level_scores[game.current_level]
    score.completed = true
    if stars > score.stars {
      score.stars = stars
    }
    if game.swap_count < score.best_swaps {
      score.best_swaps = game.swap_count
    }
    if game.hints_used == 0 {
      score.best_no_hints = true
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    let next = game.current_level + 1
    if next < @levels.total_levels() {
      start_level(game, next)
    } else {
      game.screen = LevelSelect
    }
  }
}
