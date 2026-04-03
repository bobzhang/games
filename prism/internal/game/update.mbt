///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
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
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    let idx = @types.tier_index(game.selected_tier)
    if idx > 0 {
      game.selected_tier = @types.index_to_tier(idx - 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let idx = @types.tier_index(game.selected_tier)
    if idx < 2 {
      game.selected_tier = @types.index_to_tier(idx + 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.selected_level = 0
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
  // Mouse clicks on tier boxes
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let box_w = 320
    let bx = (w - box_w) / 2
    for i in 0..<3 {
      let by = 160 + i * 170
      let box_h = 140
      if mx >= bx && mx < bx + box_w && my >= by && my < by + box_h {
        game.selected_tier = @types.index_to_tier(i)
        game.selected_level = 0
        game.screen = LevelSelect
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let tier_count = @levels.tier_level_count(game.selected_tier)
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.selected_level > 0 {
      game.selected_level -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.selected_level < tier_count - 1 {
      game.selected_level += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.selected_level >= 4 {
      game.selected_level -= 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if game.selected_level + 4 < tier_count {
      game.selected_level += 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    let (start, _) = @levels.tier_level_range(game.selected_tier)
    let level_idx = start + game.selected_level
    @levels.load_level(game, level_idx)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
  // Mouse clicks on level boxes
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let box_w = 240
    let box_h = 120
    let gap = 30
    let cols = 4
    let total_w = cols * box_w + (cols - 1) * gap
    let ox = (w - total_w) / 2
    for i in 0..<tier_count {
      let col = i % cols
      let row = i / cols
      let bx = ox + col * (box_w + gap)
      let by = 120 + row * (box_h + gap)
      if mx >= bx && mx < bx + box_w && my >= by && my < by + box_h {
        game.selected_level = i
        let (start, _) = @levels.tier_level_range(game.selected_tier)
        let level_idx = start + game.selected_level
        @levels.load_level(game, level_idx)
        game.screen = Playing
      }
    }
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Update hover position using hex grid
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let (hq, hr) = @types.pixel_to_hex(Float::from_int(mx), Float::from_int(my))
  if @types.grid_in_bounds(game.grid, hq, hr) {
    game.hover_q = hq
    game.hover_r = hr
    game.hover_valid = true
  } else {
    game.hover_valid = false
  }
  // Help toggle
  if @raylib.is_key_pressed(@raylib.KeyH) {
    game.show_help = !game.show_help
  }
  // Escape to go back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Number keys for palette selection
  if @raylib.is_key_pressed(@raylib.KeyOne) && game.palette.length() > 0 {
    game.selected_palette = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) && game.palette.length() > 1 {
    game.selected_palette = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) && game.palette.length() > 2 {
    game.selected_palette = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) && game.palette.length() > 3 {
    game.selected_palette = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) && game.palette.length() > 4 {
    game.selected_palette = 4
  }
  if @raylib.is_key_pressed(@raylib.KeySix) && game.palette.length() > 5 {
    game.selected_palette = 5
  }
  // Space to simulate
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    run_simulation(game)
  }
  // Click on grid to place/remove
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if game.hover_valid {
      handle_grid_click(game, game.hover_q, game.hover_r)
    }
  }
  // R to rotate placed component (cycle direction CW by 60)
  if @raylib.is_key_pressed(@raylib.KeyR) {
    if game.hover_valid {
      match @types.grid_get(game.grid, game.hover_q, game.hover_r) {
        Some(cell) =>
          if !cell.locked {
            match cell.component {
              Some(_) => {
                cell.direction = @types.hex_dir_cw(cell.direction)
                if game.play_state == Simulating {
                  run_simulation(game)
                }
              }
              None => ()
            }
          }
        None => ()
      }
    }
  }
}

///|
fn handle_grid_click(game : @types.Game, gq : Int, gr : Int) -> Unit {
  match @types.grid_get(game.grid, gq, gr) {
    Some(cell) => {
      if cell.locked {
        return
      }
      match cell.component {
        Some(kind) => {
          // Remove placed component - return to palette
          for i in 0..<game.palette.length() {
            let item = game.palette[i]
            if item.kind == kind &&
              item.filter_color == cell.filter_color &&
              item.crystal_face == cell.crystal_face {
              item.count += 1
              break
            }
          }
          cell.component = None
          cell.direction = E
          cell.filter_color = None
          cell.crystal_face = None
          if game.play_state == Simulating {
            run_simulation(game)
          }
        }
        None =>
          if game.selected_palette >= 0 &&
            game.selected_palette < game.palette.length() {
            let item = game.palette[game.selected_palette]
            if item.count > 0 {
              cell.component = Some(item.kind)
              cell.direction = E
              cell.filter_color = item.filter_color
              cell.crystal_face = item.crystal_face
              item.count -= 1
              if game.play_state == Simulating {
                run_simulation(game)
              }
            }
          }
      }
    }
    None => ()
  }
}

///|
fn run_simulation(game : @types.Game) -> Unit {
  game.beams = @optics.trace_all_beams(game.grid)
  let solved = @optics.check_all_targets(game.grid)
  if solved {
    game.play_state = Solved
    let idx = game.current_level_index
    let placed = @types.count_placed_components(game.grid)
    let score = game.scores[idx]
    score.solved = true
    score.components_used = placed
    let mut stars = 1
    if placed <= game.par_count {
      stars = 2
    }
    if placed <= game.par_count - 1 {
      stars = 3
    }
    if stars > score.stars {
      score.stars = stars
    }
    game.screen = Results
  } else {
    game.play_state = Simulating
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    let score = game.scores[game.current_level_index]
    if score.solved {
      let next_idx = game.current_level_index + 1
      let all_levels = @levels.get_all_levels()
      if next_idx < all_levels.length() {
        @levels.load_level(game, next_idx)
        game.screen = Playing
      } else {
        game.screen = TierSelect
      }
    } else {
      @levels.load_level(game, game.current_level_index)
      game.screen = Playing
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
