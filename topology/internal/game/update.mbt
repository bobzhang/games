///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @raylib.get_frame_time()
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  if game.anim_timer > 0.0 {
    game.anim_timer = game.anim_timer - dt
    if game.anim_timer <= 0.0 {
      game.anim_timer = 0.0
      game.anim_shape_before = None
      if game.play_state == AnimatingOp {
        game.play_state = Idle
      }
    }
  }
  // Ensure level data is loaded
  let levels = @levels.get_levels()
  @types.set_level_data(levels)
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
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let tiers : Array[@types.Tier] = [Morph, Sculpt, Transform]
    let w = @types.screen_width
    for i in 0..<tiers.length() {
      let box_x = w / 2 - 200
      let box_y = 160 + i * 160
      let box_w = 400
      let box_h = 130
      if mx >= box_x && mx < box_x + box_w && my >= box_y && my < box_y + box_h {
        if is_tier_unlocked(game, tiers[i]) {
          game.current_tier = tiers[i]
          game.screen = LevelSelect
          return
        }
      }
    }
  }
}

///|
fn is_tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Morph => true
    Sculpt => {
      let start = @types.tier_start_index(Morph)
      let mut count = 0
      for i in 0..<@types.morph_levels {
        if game.level_scores[start + i].completed {
          count = count + 1
        }
      }
      count >= 4
    }
    Transform => {
      let start = @types.tier_start_index(Sculpt)
      let mut count = 0
      for i in 0..<@types.sculpt_levels {
        if game.level_scores[start + i].completed {
          count = count + 1
        }
      }
      count >= 5
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
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let start = @types.tier_start_index(game.current_tier)
    let count = @types.tier_level_count(game.current_tier)
    let cols = 4
    let box_size = 120
    let gap = 20
    let w = @types.screen_width
    let grid_w = cols * box_size + (cols - 1) * gap
    let base_x = (w - grid_w) / 2
    let base_y = 110
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let bx = base_x + col * (box_size + gap)
      let by = base_y + row * (box_size + gap + 20)
      if mx >= bx && mx < bx + box_size && my >= by && my < by + box_size {
        start_level(game, start + i)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let levels = @levels.get_levels()
  if level_idx < 0 || level_idx >= levels.length() {
    return
  }
  let level = levels[level_idx]
  game.current_level_idx = level_idx
  game.current_shape = @types.shape_clone(level.initial_shape)
  game.target_shape = @types.shape_clone(level.target_shape)
  game.ops_history = []
  game.shape_history = [@types.shape_clone(level.initial_shape)]
  game.total_cost = 0
  game.play_state = Idle
  game.selected_op = None
  game.hover_cell = None
  game.message = ""
  game.message_timer = 0.0
  game.anim_timer = 0.0
  game.anim_shape_before = None
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.play_state = Idle
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo(game)
    return
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level_idx)
    return
  }
  if game.play_state == Won {
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      game.screen = Results
    }
    return
  }
  if game.play_state == AnimatingOp {
    return
  }
  // Update hover cell
  update_hover(game)
  // Handle operation selection via keyboard
  handle_op_keys(game)
  // Handle operation selection via mouse click on buttons
  handle_op_click(game)
  // Handle state-specific input
  match game.play_state {
    SelectingDirection => handle_direction_input(game)
    SelectingFlipAxis => handle_flip_input(game)
    SelectingGrowCell => handle_grow_input(game)
    SelectingShrinkCell => handle_shrink_input(game)
    _ => ()
  }
}

///|
fn update_hover(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gx = (mx - ox) / cs
  let gy = (my - oy) / cs
  if gx >= 0 &&
    gx < @types.grid_cols &&
    gy >= 0 &&
    gy < @types.grid_rows &&
    mx >= ox &&
    my >= oy {
    game.hover_cell = Some(@types.vec2i(gx, gy))
  } else {
    game.hover_cell = None
  }
}

///|
fn handle_op_keys(game : @types.Game) -> Unit {
  let ops : Array[@types.OpKind] = [Shift, Rotate, Flip, Grow, Shrink]
  let keys = [
    @raylib.KeyOne,
    @raylib.KeyTwo,
    @raylib.KeyThree,
    @raylib.KeyFour,
    @raylib.KeyFive,
  ]
  let available = @types.get_level_available_ops(game.current_level_idx)
  for i in 0..<ops.length() {
    if @raylib.is_key_pressed(keys[i]) {
      let op = ops[i]
      if op_is_available(op, available) {
        select_operation(game, op)
        return
      }
    }
  }
}

///|
fn handle_op_click(game : @types.Game) -> Unit {
  if !@raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    return
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ops : Array[@types.OpKind] = [Shift, Rotate, Flip, Grow, Shrink]
  let available = @types.get_level_available_ops(game.current_level_idx)
  let base_x = 600
  let base_y = 210
  for i in 0..<ops.length() {
    let bx = base_x + i * 120
    let by = base_y
    let bw = 110
    let bh = 60
    if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
      let op = ops[i]
      if op_is_available(op, available) {
        select_operation(game, op)
        return
      }
    }
  }
}

///|
fn op_is_available(
  op : @types.OpKind,
  available : Array[@types.OpKind],
) -> Bool {
  for i in 0..<available.length() {
    if available[i] == op {
      return true
    }
  }
  false
}

///|
fn select_operation(game : @types.Game, op : @types.OpKind) -> Unit {
  game.selected_op = Some(op)
  match op {
    Shift => game.play_state = SelectingDirection
    Rotate =>
      // Apply immediately
      apply_rotate(game)
    Flip => game.play_state = SelectingFlipAxis
    Grow => game.play_state = SelectingGrowCell
    Shrink => game.play_state = SelectingShrinkCell
  }
}

///|
fn handle_direction_input(game : @types.Game) -> Unit {
  let mut dir : @types.Direction? = None
  if @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) {
    dir = Some(N)
  } else if @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    dir = Some(E)
  } else if @raylib.is_key_pressed(@raylib.KeyS) ||
    @raylib.is_key_pressed(@raylib.KeyDown) {
    dir = Some(S)
  } else if @raylib.is_key_pressed(@raylib.KeyA) ||
    @raylib.is_key_pressed(@raylib.KeyLeft) {
    dir = Some(W)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.play_state = Idle
    game.selected_op = None
    return
  }
  match dir {
    Some(d) => apply_shift(game, d)
    None => ()
  }
}

///|
fn handle_flip_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.play_state = Idle
    game.selected_op = None
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyH) {
    apply_flip(game, Horizontal)
  } else if @raylib.is_key_pressed(@raylib.KeyV) {
    apply_flip(game, Vertical)
  }
}

///|
fn handle_grow_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.play_state = Idle
    game.selected_op = None
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_cell {
      Some(cell) => {
        let adjacent = @types.shape_adjacent_empty(game.current_shape)
        let mut valid = false
        for i in 0..<adjacent.length() {
          if adjacent[i].x == cell.x && adjacent[i].y == cell.y {
            valid = true
            break
          }
        }
        if valid {
          apply_grow(game, cell)
        }
      }
      None => ()
    }
  }
}

///|
fn handle_shrink_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.play_state = Idle
    game.selected_op = None
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_cell {
      Some(cell) => {
        let edges = @types.shape_edge_cells(game.current_shape)
        let mut valid = false
        for i in 0..<edges.length() {
          if edges[i].x == cell.x && edges[i].y == cell.y {
            valid = true
            break
          }
        }
        if valid {
          apply_shrink(game, cell)
        }
      }
      None => ()
    }
  }
}

///|
fn apply_shift(game : @types.Game, dir : @types.Direction) -> Unit {
  let before = @types.shape_clone(game.current_shape)
  let new_shape = @transform.shift(game.current_shape, dir)
  // Check if shift actually moved (not clipped)
  if @types.shape_exact_match(new_shape, game.current_shape) {
    game.message = "Cannot shift there!"
    game.message_timer = 1.0
    return
  }
  record_op(game, Shift, before)
  game.current_shape = new_shape
  check_win(game)
}

///|
fn apply_rotate(game : @types.Game) -> Unit {
  let before = @types.shape_clone(game.current_shape)
  let new_shape = @transform.rotate_cw(game.current_shape)
  record_op(game, Rotate, before)
  game.current_shape = new_shape
  check_win(game)
}

///|
fn apply_flip(game : @types.Game, axis : @types.FlipAxis) -> Unit {
  let before = @types.shape_clone(game.current_shape)
  let new_shape = match axis {
    Horizontal => @transform.flip_h(game.current_shape)
    Vertical => @transform.flip_v(game.current_shape)
  }
  record_op(game, Flip, before)
  game.current_shape = new_shape
  check_win(game)
}

///|
fn apply_grow(game : @types.Game, cell : @types.Vec2i) -> Unit {
  let before = @types.shape_clone(game.current_shape)
  let new_shape = @transform.grow(game.current_shape, cell)
  if new_shape.cells.length() == game.current_shape.cells.length() {
    game.message = "Invalid grow!"
    game.message_timer = 1.0
    return
  }
  record_op(game, Grow, before)
  game.current_shape = new_shape
  check_win(game)
}

///|
fn apply_shrink(game : @types.Game, cell : @types.Vec2i) -> Unit {
  let before = @types.shape_clone(game.current_shape)
  let new_shape = @transform.shrink(game.current_shape, cell)
  if new_shape.cells.length() == game.current_shape.cells.length() {
    game.message = "Cannot remove that cell!"
    game.message_timer = 1.0
    return
  }
  record_op(game, Shrink, before)
  game.current_shape = new_shape
  check_win(game)
}

///|
fn record_op(
  game : @types.Game,
  kind : @types.OpKind,
  before : @types.Shape,
) -> Unit {
  let cost = @types.op_cost(kind)
  game.ops_history.push({ kind, cost, })
  game.shape_history.push(before)
  game.total_cost = game.total_cost + cost
  game.anim_shape_before = Some(before)
  game.anim_timer = @types.anim_duration
  game.play_state = Idle
  game.selected_op = None
}

///|
fn check_win(game : @types.Game) -> Unit {
  if @transform.check_match(game.current_shape, game.target_shape) {
    game.play_state = Won
    game.message = "Target matched!"
    game.message_timer = 3.0
    // Update score
    let level = @levels.get_level(game.current_level_idx)
    let stars = @transform.calculate_stars(
      game.total_cost,
      level.par_cost,
      level.min_cost,
    )
    let score = game.level_scores[game.current_level_idx]
    score.completed = true
    if game.total_cost < score.best_cost {
      score.best_cost = game.total_cost
    }
    // Update stars (only improve, never downgrade)
    let new_star_count = @types.star_count(stars)
    let old_star_count = @types.star_count(score.stars)
    if new_star_count > old_star_count {
      score.stars = stars
    }
  }
}

///|
fn undo(game : @types.Game) -> Unit {
  if game.ops_history.length() == 0 {
    game.message = "Nothing to undo"
    game.message_timer = 1.0
    return
  }
  if game.play_state == Won {
    return
  }
  let op = game.ops_history.unsafe_pop()
  let prev_shape = game.shape_history.unsafe_pop()
  game.current_shape = prev_shape
  game.total_cost = game.total_cost - op.cost
  game.play_state = Idle
  game.selected_op = None
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Next level
    let next_idx = game.current_level_idx + 1
    let levels = @levels.get_levels()
    if next_idx < levels.length() {
      // Check if next level is in same tier
      let current_tier_start = @types.tier_start_index(game.current_tier)
      let current_tier_count = @types.tier_level_count(game.current_tier)
      if next_idx < current_tier_start + current_tier_count {
        start_level(game, next_idx)
      } else {
        // Go to tier select
        game.screen = TierSelect
      }
    } else {
      game.screen = TierSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level_idx)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
