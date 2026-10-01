///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  if game.message_timer > 0.0 {
    game.message_timer -= @raylib.get_frame_time()
    if game.message_timer <= 0.0 {
      game.message = ""
    }
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
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    // Three tier boxes centered
    let box_w = 300
    let box_h = 120
    let gap = 40
    let total_w = box_w * 3 + gap * 2
    let start_x = (@types.screen_width - total_w) / 2
    let by = @types.screen_height / 2 - box_h / 2
    let tiers : Array[@types.Tier] = [Vertices, Edges, Sculpt]
    for i in 0..<3 {
      let bx = start_x + i * (box_w + gap)
      if mx >= bx && mx <= bx + box_w && my >= by && my <= by + box_h {
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
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let tier_start = @types.tier_start_index(game.selected_tier)
    let tier_count = @types.tier_level_count(game.selected_tier)
    let cols = 4
    let cell_w = 180
    let cell_h = 80
    let gap = 20
    let total_w = cols * cell_w + (cols - 1) * gap
    let start_x = (@types.screen_width - total_w) / 2
    let start_y = 200
    for i in 0..<tier_count {
      let col = i % cols
      let row = i / cols
      let cx = start_x + col * (cell_w + gap)
      let cy = start_y + row * (cell_h + gap)
      if mx >= cx && mx <= cx + cell_w && my >= cy && my <= cy + cell_h {
        start_level(game, tier_start + i)
        return
      }
    }
    // Back button
    if mx >= 40 && mx <= 160 && my >= 640 && my <= 680 {
      game.screen = TierSelect
    }
  }
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  let level = @levels.get_level(index)
  game.level_index = index
  game.screen = Playing
  game.play_state = Placing
  game.placed_points = @types.clone_points(level.pre_placed_points)
  game.target = level.target_polygon
  game.undo_stack = []
  game.hull_matches = false
  game.match_pct = 0.0
  game.snap_preview = None
  game.hover_remove = -1
  game.message = ""
  game.message_timer = 0.0
  recompute_hull(game)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.level_index)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if @types.pop_undo(game) {
      recompute_hull(game)
      @types.set_message(game, "Undo", 0.8)
    }
    return
  }
  if game.play_state == Completed {
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      game.screen = Results
    }
    return
  }
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  let mouse_pt : @types.Point = { x: mx, y: my, }
  // Update snap preview
  if @types.point_in_plane(mouse_pt) {
    let snapped = @types.snap_point(mouse_pt)
    game.snap_preview = Some(snapped)
  } else {
    game.snap_preview = None
  }
  // Update hover for removal
  game.hover_remove = -1
  if @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
    let mut best_dist : Float = @types.remove_radius
    for i in 0..<game.placed_points.length() {
      let d = @types.point_dist(mouse_pt, game.placed_points[i])
      if d < best_dist {
        best_dist = d
        game.hover_remove = i
      }
    }
  }
  // Right-click to remove
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    let mut best_idx = -1
    let mut best_dist : Float = @types.remove_radius
    for i in 0..<game.placed_points.length() {
      let d = @types.point_dist(mouse_pt, game.placed_points[i])
      if d < best_dist {
        best_dist = d
        best_idx = i
      }
    }
    if best_idx >= 0 {
      @types.push_undo(game)
      let new_pts : Array[@types.Point] = Array(
        capacity=game.placed_points.length() - 1,
      )
      for i in 0..<game.placed_points.length() {
        if i != best_idx {
          new_pts.push(game.placed_points[i])
        }
      }
      game.placed_points = new_pts
      recompute_hull(game)
      return
    }
  }
  // Left-click to place
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if @types.point_in_plane(mouse_pt) {
      let snapped = @types.snap_point(mouse_pt)
      // Don't place on top of existing point
      let mut too_close = false
      for i in 0..<game.placed_points.length() {
        if @types.point_dist(snapped, game.placed_points[i]) <
          @types.grid_snap * 0.5 {
          too_close = true
          break
        }
      }
      if !too_close {
        @types.push_undo(game)
        game.placed_points.push(snapped)
        recompute_hull(game)
      }
    }
  }
}

///|
fn recompute_hull(game : @types.Game) -> Unit {
  game.current_hull = @geometry.compute_hull(game.placed_points)
  game.match_pct = @geometry.match_hull_to_target(
    game.current_hull,
    game.target,
  )
  game.hull_matches = @geometry.hull_matches_target(
    game.current_hull,
    game.target,
  )
  if game.hull_matches && game.play_state != Completed {
    game.play_state = Completed
    let pts_used = game.placed_points.length()
    let level = @levels.get_level(game.level_index)
    let stars = if pts_used <= level.min_points {
      3
    } else if pts_used <= level.par_points {
      2
    } else {
      1
    }
    let score = game.scores[game.level_index]
    if !score.completed || stars > score.stars {
      score.completed = true
      score.stars = stars
      score.points_used = pts_used
    }
    @types.set_message(game, "Hull Matched!", 2.0)
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Advance to next level if available
    let next = game.level_index + 1
    if next < @types.total_levels {
      start_level(game, next)
    } else {
      game.screen = LevelSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.level_index)
  }
  // Mouse click handling for buttons
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let cx = @types.screen_width / 2
    // "Next Level" button
    let next = game.level_index + 1
    if next < @types.total_levels {
      if mx >= cx - 100 && mx <= cx + 100 && my >= 480 && my <= 530 {
        start_level(game, next)
        return
      }
    }
    // "Retry" button
    if mx >= cx - 100 && mx <= cx + 100 && my >= 540 && my <= 590 {
      start_level(game, game.level_index)
      return
    }
    // "Menu" button
    if mx >= cx - 100 && mx <= cx + 100 && my >= 600 && my <= 650 {
      game.screen = LevelSelect
    }
  }
}
