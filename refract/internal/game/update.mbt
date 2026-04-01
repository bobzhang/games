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
  // Also handle mouse clicks on tier boxes
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
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.selected_level > 0 {
      game.selected_level -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.selected_level < 7 {
      game.selected_level += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.selected_level >= 4 {
      game.selected_level -= 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if game.selected_level < 4 {
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
    let total_w = 4 * box_w + 3 * gap
    let ox = (w - total_w) / 2
    for i in 0..<8 {
      let col = i % 4
      let row = i / 4
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
  // Update hover position
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gx = (mx - ox) / cs
  let gy = (my - oy) / cs
  if gx >= 0 && gx < @types.grid_width && gy >= 0 && gy < @types.grid_height {
    game.hover_x = gx
    game.hover_y = gy
  } else {
    game.hover_x = -1
    game.hover_y = -1
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
  // Click on grid to place/remove component
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if game.hover_x >= 0 && game.hover_y >= 0 {
      handle_grid_click(game, game.hover_x, game.hover_y)
    }
  }
  // R to rotate placed component
  if @raylib.is_key_pressed(@raylib.KeyR) {
    if game.hover_x >= 0 && game.hover_y >= 0 {
      match @types.grid_get(game.grid, game.hover_x, game.hover_y) {
        Some(cell) =>
          if !cell.locked {
            match cell.component {
              Some(_) => {
                cell.direction = @types.direction_cw(cell.direction)
                // Re-simulate if already simulating
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
fn handle_grid_click(game : @types.Game, gx : Int, gy : Int) -> Unit {
  match @types.grid_get(game.grid, gx, gy) {
    Some(cell) => {
      if cell.locked {
        return
      }
      match cell.component {
        Some(kind) => {
          // Remove placed component - return to palette
          for i in 0..<game.palette.length() {
            let item = game.palette[i]
            if item.kind == kind && item.filter_color == cell.filter_color {
              item.count += 1
              break
            }
          }
          cell.component = None
          cell.direction = N
          cell.filter_color = None
          // Re-simulate if active
          if game.play_state == Simulating {
            run_simulation(game)
          }
        }
        None =>
          // Place component from palette
          if game.selected_palette >= 0 &&
            game.selected_palette < game.palette.length() {
            let item = game.palette[game.selected_palette]
            if item.count > 0 {
              cell.component = Some(item.kind)
              cell.direction = N
              cell.filter_color = item.filter_color
              item.count -= 1
              // Re-simulate if active
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
  game.beams = @beam.trace_all_beams(game.grid)
  let solved = @beam.check_all_receivers(game.grid)
  if solved {
    game.play_state = Solved
    // Calculate score
    let idx = game.current_level_index
    let placed = @types.count_placed_components(game.grid)
    let crossings = @beam.count_beam_crossings(game.beams)
    let score = game.scores[idx]
    score.solved = true
    score.components_used = placed
    score.beam_crossings = crossings
    // Calculate stars
    let mut stars = 1 // Base star for solving
    if placed <= game.par_count {
      stars = 2 // Within par
    }
    if placed <= game.par_count && crossings == 0 {
      stars = 3 // Par + no crossings
    }
    // Only update if better
    if stars > score.stars {
      score.stars = stars
    }
    // Show results after short delay - go immediately for now
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
      // Next level
      let next_idx = game.current_level_index + 1
      let all_levels = @levels.get_all_levels()
      if next_idx < all_levels.length() {
        @levels.load_level(game, next_idx)
        game.screen = Playing
      } else {
        game.screen = TierSelect
      }
    } else {
      // Retry
      @levels.load_level(game, game.current_level_index)
      game.screen = Playing
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
