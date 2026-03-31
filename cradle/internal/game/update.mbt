///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - 1.0 / 60.0
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
  // Click on tier cards
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mouse_x = @raylib.get_mouse_x()
    let mouse_y = @raylib.get_mouse_y()
    let tiers : Array[@types.Tier] = [Lines, Weave, Art]
    let card_w = 320
    let card_h = 400
    let gap = 40
    let start_x = (@types.screen_width - card_w * 3 - gap * 2) / 2
    let card_y = 130
    for i in 0..<3 {
      let cx = start_x + i * (card_w + gap)
      if mouse_x >= cx &&
        mouse_x <= cx + card_w &&
        mouse_y >= card_y &&
        mouse_y <= card_y + card_h {
        game.selected_tier = tiers[i]
        game.screen = LevelSelect
        return
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
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mouse_x = @raylib.get_mouse_x()
    let mouse_y = @raylib.get_mouse_y()
    let tier_start = @types.tier_start_level(game.selected_tier)
    let tier_count = @types.tier_level_count(game.selected_tier)
    let cols = 5
    let cell_w = 180
    let cell_h = 100
    let gap = 20
    let total_w = cols * cell_w + (cols - 1) * gap
    let start_x = (@types.screen_width - total_w) / 2
    let start_y = 120
    for i in 0..<tier_count {
      let level_idx = tier_start + i
      let col = i % cols
      let row = i / cols
      let cx = start_x + col * (cell_w + gap)
      let cy = start_y + row * (cell_h + gap)
      if mouse_x >= cx &&
        mouse_x <= cx + cell_w &&
        mouse_y >= cy &&
        mouse_y <= cy + cell_h {
        game.selected_level = level_idx
        @types.start_level(game, level_idx)
        return
      }
    }
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // ESC: back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.selected_peg = -1
    return
  }
  // R: restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @types.start_level(game, game.current_level)
    return
  }
  // Complete state: enter to go to results
  if game.play_state == Complete {
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      game.screen = Results
    }
    return
  }
  // Right click: remove last string
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if game.strings.length() > 0 {
      ignore(game.strings.pop())
      game.selected_peg = -1
      recalculate_intersections(game)
    }
    return
  }
  // Left click: peg selection
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mouse_x = Float::from_int(@raylib.get_mouse_x())
    let mouse_y = Float::from_int(@raylib.get_mouse_y())
    let mouse_pos = @types.vec2f(mouse_x, mouse_y)
    // Find closest peg within click range
    let mut closest = -1
    let mut closest_dist : Float = 25.0
    for i in 0..<game.pegs.length() {
      let d = @types.vec2f_dist(mouse_pos, game.pegs[i].pos)
      if d < closest_dist {
        closest_dist = d
        closest = i
      }
    }
    if closest >= 0 {
      if game.selected_peg < 0 {
        // Select first peg
        game.selected_peg = closest
      } else if closest == game.selected_peg {
        // Deselect
        game.selected_peg = -1
      } else {
        // Create string between selected and clicked peg
        if game.strings.length() < @types.max_strings {
          // Check if string already exists
          let mut exists = false
          for i in 0..<game.strings.length() {
            let s = game.strings[i]
            if (s.peg_a == game.selected_peg && s.peg_b == closest) ||
              (s.peg_a == closest && s.peg_b == game.selected_peg) {
              exists = true
              break
            }
          }
          if !exists {
            let new_string : @types.StringLine = {
              peg_a: game.selected_peg,
              peg_b: closest,
            }
            game.strings.push(new_string)
            game.selected_peg = -1
            recalculate_intersections(game)
            check_completion(game)
          } else {
            @types.set_message(game, "String already exists!", 1.5)
            game.selected_peg = -1
          }
        } else {
          @types.set_message(game, "Max strings reached!", 1.5)
          game.selected_peg = -1
        }
      }
    } else {
      // Clicked empty space: deselect
      game.selected_peg = -1
    }
  }
}

///|
fn recalculate_intersections(game : @types.Game) -> Unit {
  game.intersections = @geometry.compute_all_intersections(
    game.strings,
    game.pegs,
  )
  ignore(
    @geometry.match_intersections_to_targets(game.intersections, game.targets),
  )
}

///|
fn check_completion(game : @types.Game) -> Unit {
  let mut all_hit = true
  for i in 0..<game.targets.length() {
    if !game.targets[i].hit {
      all_hit = false
      break
    }
  }
  if all_hit {
    game.play_state = Complete
    // Calculate and save score
    let stars = @types.count_stars(
      game,
      game.current_level,
      game.strings.length(),
    )
    let score = game.scores[game.current_level]
    score.completed = true
    score.strings_used = game.strings.length()
    if stars > score.stars {
      score.stars = stars
    }
    @types.set_message(game, "All targets hit!", 2.0)
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @types.start_level(game, game.current_level)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Go to next level if available
    let next = game.current_level + 1
    if next < @types.total_levels {
      @types.start_level(game, next)
    } else {
      game.screen = LevelSelect
    }
  }
}
