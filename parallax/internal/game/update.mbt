///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  game.anim_timer += 1.0 / 60.0
  if game.message_timer > 0.0 {
    game.message_timer -= 1.0 / 60.0
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
  if @raylib.is_mouse_button_pressed(0) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let bx = (@types.screen_width - 200) / 2
    let by = 440
    if mx >= bx && mx < bx + 200 && my >= by && my < by + 50 {
      game.screen = TierSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
  if @raylib.is_mouse_button_pressed(0) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let card_w = 300
    let card_h = 350
    let gap = 40
    let total_w = card_w * 3 + gap * 2
    let start_x = (@types.screen_width - total_w) / 2
    let cy = 140
    for tier in 0..<3 {
      let cx = start_x + tier * (card_w + gap)
      if mx >= cx && mx < cx + card_w && my >= cy && my < cy + card_h {
        game.current_tier = tier
        game.screen = LevelSelect
        break
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
  if @raylib.is_mouse_button_pressed(0) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let btn_w = 200
    let btn_h = 100
    let gap_x = 20
    let gap_y = 20
    let cols = 5
    let total_w = cols * btn_w + (cols - 1) * gap_x
    let start_x = (@types.screen_width - total_w) / 2
    let start_y = 120
    for i in 0..<@types.levels_per_tier {
      let col = i % cols
      let row = i / cols
      let bx = start_x + col * (btn_w + gap_x)
      let by = start_y + row * (btn_h + gap_y)
      if mx >= bx && mx < bx + btn_w && my >= by && my < by + btn_h {
        let idx = @types.level_index(game.current_tier, i)
        start_level(game, idx)
        break
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_index : Int) -> Unit {
  let level = @levels.get_level(level_index)
  game.current_level = level_index
  game.grid = @types.new_voxel_grid(level.size)
  game.moves = 0
  game.undo_stack = []
  game.hover = @types.new_hover()
  game.play_state = Editing
  game.screen = Playing
  game.message = ""
  game.message_timer = 0.0
}

///|
fn update_playing(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  // ESC to go back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // R to reset
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  // U to undo
  if @raylib.is_key_pressed(@raylib.KeyU) {
    undo_move(game)
    return
  }
  // If complete, press Enter for results
  if game.play_state == Complete {
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      calculate_stars(game)
      game.screen = Results
    }
    return
  }
  // Handle hover and click in view panels
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover.active = false
  // Check each view panel
  check_view_interaction(game, Top, @types.view_top_x, @types.view_top_y, level, mx, my)
  check_view_interaction(
    game,
    Front,
    @types.view_front_x,
    @types.view_front_y,
    level,
    mx,
    my,
  )
  check_view_interaction(
    game,
    Side,
    @types.view_side_x,
    @types.view_side_y,
    level,
    mx,
    my,
  )
}

///|
fn check_view_interaction(
  game : @types.Game,
  view : @types.ViewKind,
  panel_x : Int,
  panel_y : Int,
  level : @types.Level,
  mx : Int,
  my : Int
) -> Unit {
  let size = level.size
  let cs = @types.cell_size_for_grid(size)
  let grid_w = size * cs
  let grid_h = size * cs
  // Check if mouse is in this panel
  if mx >= panel_x && mx < panel_x + grid_w && my >= panel_y && my < panel_y + grid_h {
    let col = (mx - panel_x) / cs
    let row = (my - panel_y) / cs
    if col >= 0 && col < size && row >= 0 && row < size {
      // Update hover preview
      let preview = @voxel.ray_preview(game.grid, view, col, row)
      match preview {
        Some(pos) => {
          game.hover.active = true
          game.hover.vx = pos.x
          game.hover.vy = pos.y
          game.hover.vz = pos.z
          game.hover.view = view
        }
        None => ()
      }
      // Handle click
      if @raylib.is_mouse_button_pressed(0) {
        do_toggle(game, view, col, row, level)
      }
    }
  }
}

///|
fn do_toggle(
  game : @types.Game,
  view : @types.ViewKind,
  col : Int,
  row : Int,
  level : @types.Level
) -> Unit {
  // Check voxel budget before adding
  let preview = @voxel.ray_preview(game.grid, view, col, row)
  match preview {
    Some(pos) => {
      let was_filled = @voxel.get_voxel(game.grid, pos.x, pos.y, pos.z)
      // If adding and budget exceeded, deny
      if !was_filled && level.voxel_budget > 0 {
        let filled = @voxel.count_filled(game.grid)
        if filled >= level.voxel_budget {
          game.message = "Voxel budget exceeded!"
          game.message_timer = 1.5
          return
        }
      }
      // Perform the toggle
      let result = @voxel.ray_toggle(game.grid, view, col, row)
      match result {
        Some(toggled) => {
          // Push undo entry
          game.undo_stack.push(
            { x: toggled.x, y: toggled.y, z: toggled.z, was_filled },
          )
          game.moves += 1
          // Check connectivity constraint
          if level.requires_connected {
            let filled = @voxel.count_filled(game.grid)
            if filled > 1 && !@voxel.check_connected(game.grid) {
              game.message = "Must stay connected!"
              game.message_timer = 1.0
            }
          }
          // Check completion
          if @voxel.check_completion(game.grid, level.targets) {
            // Also check constraints
            let mut valid = true
            if level.voxel_budget > 0 {
              let count = @voxel.count_filled(game.grid)
              if count > level.voxel_budget {
                valid = false
              }
            }
            if level.requires_connected && !@voxel.check_connected(game.grid) {
              valid = false
            }
            if valid {
              game.play_state = Complete
              game.message = ""
              game.message_timer = 0.0
            }
          }
        }
        None => ()
      }
    }
    None => ()
  }
}

///|
fn undo_move(game : @types.Game) -> Unit {
  if game.undo_stack.length() == 0 {
    return
  }
  let entry = game.undo_stack.unsafe_pop()
  // Restore the voxel to its previous state
  @voxel.set_voxel(game.grid, entry.x, entry.y, entry.z, entry.was_filled)
  game.moves = @types.maxi(0, game.moves - 1)
  game.play_state = Editing
}

///|
fn calculate_stars(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  let filled = @voxel.count_filled(game.grid)
  let mut stars = 1 // Completed = 1 star
  if game.moves <= level.par_moves {
    stars = 2
  }
  if game.moves <= level.par_moves && filled <= level.par_voxels {
    stars = 3
  }
  game.result_stars = stars
  // Update score
  let score = game.scores[game.current_level]
  score.completed = true
  if stars > score.stars {
    score.stars = stars
  }
  if game.moves < score.best_moves {
    score.best_moves = game.moves
  }
  if filled < score.best_voxels {
    score.best_voxels = filled
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_mouse_button_pressed(0) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let card_w = 500
    let card_h = 450
    let card_x = (@types.screen_width - card_w) / 2
    let card_y = (@types.screen_height - card_h) / 2
    // Next Level button
    let next_x = card_x + 30
    let next_y = card_y + card_h - 60
    if mx >= next_x && mx < next_x + 180 && my >= next_y && my < next_y + 40 {
      let next = game.current_level + 1
      if next < @types.total_levels {
        start_level(game, next)
        game.current_tier = next / @types.levels_per_tier
      } else {
        game.screen = TierSelect
      }
      return
    }
    // Level Select button
    let sel_x = card_x + card_w - 210
    let sel_y = card_y + card_h - 60
    if mx >= sel_x && mx < sel_x + 180 && my >= sel_y && my < sel_y + 40 {
      game.screen = LevelSelect
      return
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let next = game.current_level + 1
    if next < @types.total_levels {
      start_level(game, next)
      game.current_tier = next / @types.levels_per_tier
    } else {
      game.screen = TierSelect
    }
  }
}
