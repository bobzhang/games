///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt_raw = @raylib.get_frame_time()
  let dt = @types.minf(dt_raw, 0.05)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  // Update hint timer
  if game.hint_timer > 0.0 {
    game.hint_timer = game.hint_timer - dt
    if game.hint_timer <= 0.0 {
      game.hint_island_a = -1
      game.hint_island_b = -1
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
    // Check tier buttons (3 tier boxes arranged vertically)
    let tiers : Array[@types.Tier] = [Shores, Straits, Ocean]
    for i, tier in tiers {
      let bx = 390
      let by = 200 + i * 140
      let bw = 500
      let bh = 110
      if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
        game.current_tier = tier
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
    let start = @types.tier_start_level(game.current_tier)
    let count = @types.tier_level_count(game.current_tier)
    // Level buttons in a grid
    let cols = if count <= 5 { count } else { 5 }
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let bx = 240 + col * 170
      let by = 280 + row * 140
      let bw = 140
      let bh = 100
      if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
        start_level(game, start + i)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.current_level = level_idx
  game.islands = level.islands
  game.bridges = []
  game.selected_island = -1
  game.removal_count = 0
  game.grid_size = level.grid_size
  game.par_bridges = level.par_bridges
  game.play_state = Active
  game.hint_island_a = -1
  game.hint_island_b = -1
  game.hint_timer = 0.0
  game.undo_stack = []
  game.message = ""
  game.message_timer = 0.0
  // Initialize satisfaction animation arrays
  let sat_timers : Array[Float] = []
  let prev_sat : Array[Bool] = []
  for _i in 0..<level.islands.length() {
    sat_timers.push(0.0)
    prev_sat.push(false)
  }
  game.satisfaction_timers = sat_timers
  game.prev_satisfied = prev_sat
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
  if @raylib.is_key_pressed(@raylib.KeyZ) && game.undo_stack.length() > 0 {
    game.bridges = game.undo_stack.unsafe_pop()
    game.selected_island = -1
    return
  }
  // Hint
  if @raylib.is_key_pressed(@raylib.KeyH) {
    let (a, b) = @solver.find_hint(game.islands, game.bridges)
    if a >= 0 {
      game.hint_island_a = a
      game.hint_island_b = b
      game.hint_timer = 2.0
    } else {
      @types.set_message(game, "No hint available")
    }
    return
  }
  // Update satisfaction pulse timers
  let dt_sat = @types.minf(@raylib.get_frame_time(), 0.05)
  for i in 0..<game.islands.length() {
    let currently_satisfied = @solver.is_island_satisfied(
      game.islands,
      game.bridges,
      i,
    )
    // Detect newly satisfied
    if i < game.prev_satisfied.length() && i < game.satisfaction_timers.length() {
      if currently_satisfied && !game.prev_satisfied[i] {
        game.satisfaction_timers[i] = 1.0 // Start 1-second pulse
      }
      game.prev_satisfied[i] = currently_satisfied
      // Decay timer
      if game.satisfaction_timers[i] > 0.0 {
        game.satisfaction_timers[i] = game.satisfaction_timers[i] - dt_sat
      }
    }
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Right-click: remove bridge
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    handle_right_click(game, mx, my)
    return
  }
  // Left-click: select or connect
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    handle_left_click(game, mx, my)
  }
}

///|
fn handle_left_click(game : @types.Game, mx : Int, my : Int) -> Unit {
  let clicked = @types.find_nearest_island(game.islands, game.grid_size, mx, my)
  if game.selected_island < 0 {
    // Nothing selected - select island
    if clicked >= 0 {
      game.selected_island = clicked
    }
    return
  }
  // Something already selected
  if clicked < 0 {
    // Clicked empty space - deselect
    game.selected_island = -1
    return
  }
  if clicked == game.selected_island {
    // Clicked same island - deselect
    game.selected_island = -1
    return
  }
  // Try to connect selected to clicked
  let target = @types.find_connectable_island_at(
    game.islands,
    game.bridges,
    game.selected_island,
    game.grid_size,
    mx,
    my,
  )
  if target < 0 {
    // Can't connect, select the clicked island instead
    game.selected_island = clicked
    return
  }
  // Save undo state
  game.undo_stack.push(@types.clone_bridges(game.bridges))
  // Check existing bridge
  let existing = @types.find_bridge(game.bridges, game.selected_island, target)
  if existing >= 0 {
    if game.bridges[existing].count < 2 {
      game.bridges[existing].count = 2
    } else {
      // Already 2 bridges, select new island
      game.selected_island = clicked
      let _ = game.undo_stack.unsafe_pop()
      return
    }
  } else {
    let dir = @types.bridge_direction(
      game.islands,
      game.selected_island,
      target,
    )
    game.bridges.push(@types.new_bridge(game.selected_island, target, dir))
  }
  game.selected_island = -1
  // Check if solved
  check_solution(game)
}

///|
fn handle_right_click(game : @types.Game, mx : Int, my : Int) -> Unit {
  // Find if clicking near a bridge
  let bridge_idx = find_bridge_at(game, mx, my)
  if bridge_idx >= 0 {
    game.undo_stack.push(@types.clone_bridges(game.bridges))
    if game.bridges[bridge_idx].count > 1 {
      game.bridges[bridge_idx].count = 1
    } else {
      // Remove the bridge
      let new_bridges : Array[@types.Bridge] = []
      for i, b in game.bridges {
        if i != bridge_idx {
          new_bridges.push(b)
        }
      }
      game.bridges = new_bridges
    }
    game.removal_count = game.removal_count + 1
  }
  game.selected_island = -1
}

///|
fn find_bridge_at(game : @types.Game, mx : Int, my : Int) -> Int {
  let click_dist : Float = 12.0
  for i, br in game.bridges {
    let ia = game.islands[br.island_a]
    let ib = game.islands[br.island_b]
    let ax = Float::from_int(@types.island_screen_x(ia, game.grid_size))
    let ay = Float::from_int(@types.island_screen_y(ia, game.grid_size))
    let bx = Float::from_int(@types.island_screen_x(ib, game.grid_size))
    let by = Float::from_int(@types.island_screen_y(ib, game.grid_size))
    let fmx = Float::from_int(mx)
    let fmy = Float::from_int(my)
    let dist = point_to_segment_dist(fmx, fmy, ax, ay, bx, by)
    if dist < click_dist {
      return i
    }
  }
  -1
}

///|
fn point_to_segment_dist(
  px : Float,
  py : Float,
  ax : Float,
  ay : Float,
  bx : Float,
  by : Float,
) -> Float {
  let dx = bx - ax
  let dy = by - ay
  let len_sq = dx * dx + dy * dy
  if len_sq < 0.001 {
    let ex = px - ax
    let ey = py - ay
    return @types.absf(ex) + @types.absf(ey)
  }
  let mut t = ((px - ax) * dx + (py - ay) * dy) / len_sq
  if t < 0.0 {
    t = 0.0
  } else if t > 1.0 {
    t = 1.0
  }
  let proj_x = ax + t * dx
  let proj_y = ay + t * dy
  let ex = px - proj_x
  let ey = py - proj_y
  Float::from_double(
    (ex.to_double() * ex.to_double() + ey.to_double() * ey.to_double()).sqrt(),
  )
}

///|
fn check_solution(game : @types.Game) -> Unit {
  if @solver.is_puzzle_solved(game.islands, game.bridges) {
    game.play_state = Solved
    // Compute stars
    let stars = @solver.compute_stars(
      game.bridges,
      game.par_bridges,
      game.removal_count,
    )
    let score = game.level_scores[game.current_level]
    score.completed = true
    if stars > score.stars {
      score.stars = stars
    }
    let segs = @types.total_bridge_segments(game.bridges)
    if score.best_bridges == 0 || segs < score.best_bridges {
      score.best_bridges = segs
    }
    if game.removal_count == 0 {
      score.best_no_removals = true
    }
    game.screen = Results
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
    return
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    // Next level button
    if mx >= 440 && mx <= 640 && my >= 520 && my <= 580 {
      let next = game.current_level + 1
      if next < @types.total_levels {
        start_level(game, next)
      } else {
        game.screen = LevelSelect
      }
      return
    }
    // Back to levels button
    if mx >= 660 && mx <= 860 && my >= 520 && my <= 580 {
      game.screen = LevelSelect
      return
    }
  }
}
