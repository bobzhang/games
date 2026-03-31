///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
  }
  // Update transition
  if game.transition_timer > 0.0 {
    game.transition_timer -= dt
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
    return
  }
  // Check PLAY button click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cx = @types.screen_width / 2
    if mx >= cx - 100 && mx < cx + 100 && my >= 480 && my < 530 {
      game.screen = TierSelect
    }
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let cx = @types.screen_width / 2
    let card_x = cx - 250
    let card_w = 500
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    if mx >= card_x && mx < card_x + card_w {
      let tiers : Array[@types.Tier] = [Plots, Districts, Zoning]
      for i in 0..<3 {
        let y = 160 + i * 160
        if my >= y && my < y + 130 {
          game.current_tier = tiers[i]
          game.screen = LevelSelect
          return
        }
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
    let cx = @types.screen_width / 2
    let cols = 4
    let btn_w = 200
    let btn_h = 120
    let gap = 30
    let total_w = cols * btn_w + (cols - 1) * gap
    let base_x = cx - total_w / 2
    let base_y = 100
    let start = @types.tier_start_idx(game.current_tier)
    let count = @types.tier_level_count(game.current_tier)
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let x = base_x + col * (btn_w + gap)
      let y = base_y + row * (btn_h + gap)
      if mx >= x && mx < x + btn_w && my >= y && my < y + btn_h {
        start_level(game, start + i)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, idx : Int) -> Unit {
  let level = @levels.get_level(idx)
  game.current_level_idx = idx
  game.current_level = Some(level)
  game.fences = []
  game.regions = []
  game.constraint_status = []
  game.undo_stack = []
  game.hover_fence = None
  game.play_state = Drawing
  game.screen = Playing
  game.message = ""
  game.message_timer = 0.0
  // Initial region computation
  recompute_regions(game)
}

///|
fn recompute_regions(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      game.regions = @solver.flood_fill_regions(level.grid, game.fences)
      game.constraint_status = @solver.validate_level(
        level,
        game.fences,
        game.regions,
      )
      // Check if all constraints satisfied
      if @solver.all_constraints_satisfied(game.constraint_status) {
        game.play_state = Complete
      } else {
        game.play_state = Drawing
      }
    }
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level_idx)
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if game.undo_stack.length() > 0 {
      let entry = game.undo_stack[game.undo_stack.length() - 1]
      let _ = game.undo_stack.pop()
      game.fences = entry.fences
      recompute_regions(game)
    }
    return
  }
  // Enter to go to results when complete
  if game.play_state == Complete {
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      go_to_results(game)
      return
    }
  }
  // Update hover fence
  update_hover(game)
  // Handle click to place/remove fence
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_fence {
      None => ()
      Some(f) => {
        if game.play_state != Complete {
          // Save undo state
          game.undo_stack.push({ fences: @types.copy_fences(game.fences) })
          // Toggle fence
          @types.toggle_fence(game.fences, f)
          // Recompute
          recompute_regions(game)
        }
      }
    }
  }
}

///|
fn update_hover(game : @types.Game) -> Unit {
  match game.current_level {
    None => {
      game.hover_fence = None
    }
    Some(level) => {
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y
      let cs = @types.cell_size
      let gw = level.grid.width
      let gh = level.grid.height
      // Check if mouse is near any grid edge
      let snap_dist = 12
      game.hover_fence = None
      // Check horizontal edges (between rows)
      for row in 1..<gh {
        for col in 0..<gw {
          let ex = ox + col * cs + cs / 2
          let ey = oy + row * cs
          let dx = mx - ex
          let dy = my - ey
          if dx > -(cs / 2) &&
            dx < cs / 2 &&
            dy > -snap_dist &&
            dy < snap_dist {
            game.hover_fence = Some(@types.make_fence(row, col, Horizontal))
            return
          }
        }
      }
      // Check vertical edges (between columns)
      for row in 0..<gh {
        for col in 1..<gw {
          let ex = ox + col * cs
          let ey = oy + row * cs + cs / 2
          let dx = mx - ex
          let dy = my - ey
          if dx > -snap_dist &&
            dx < snap_dist &&
            dy > -(cs / 2) &&
            dy < cs / 2 {
            game.hover_fence = Some(@types.make_fence(row, col, Vertical))
            return
          }
        }
      }
    }
  }
}

///|
fn go_to_results(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      let satisfied = @solver.all_constraints_satisfied(game.constraint_status)
      let fence_count = game.fences.length()
      let stars = @solver.compute_stars(level, fence_count, satisfied)
      game.result_stars = stars
      game.result_fence_count = fence_count
      // Update level score
      if game.current_level_idx < game.level_scores.length() {
        let score = game.level_scores[game.current_level_idx]
        if stars > score.stars {
          score.stars = stars
        }
        score.completed = satisfied
        if fence_count < score.fence_count || score.fence_count == 0 {
          score.fence_count = fence_count
        }
      }
      game.screen = Results
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let cx = @types.screen_width / 2
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let btn_y = 400
    // Retry button
    if mx >= cx - 220 && mx < cx - 20 && my >= btn_y && my < btn_y + 50 {
      start_level(game, game.current_level_idx)
      return
    }
    // Next button (only if completed)
    if game.result_stars > 0 {
      if mx >= cx + 20 && mx < cx + 220 && my >= btn_y && my < btn_y + 50 {
        let next = game.current_level_idx + 1
        if next < @types.total_levels {
          start_level(game, next)
        } else {
          game.screen = LevelSelect
        }
        return
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.result_stars > 0 {
      let next = game.current_level_idx + 1
      if next < @types.total_levels {
        start_level(game, next)
      } else {
        game.screen = LevelSelect
      }
    } else {
      start_level(game, game.current_level_idx)
    }
  }
}
