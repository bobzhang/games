///|
pub fn update(game : @types.Game) -> Unit {
  let dt : Float = 1.0 / 60.0
  game.frame_count = game.frame_count + 1
  game.anim_timer = game.anim_timer + dt
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.screen = TierSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  // Three tier buttons
  for t in 0..<3 {
    let bx = 240 + t * 300
    let by = 300
    let bw = 220
    let bh = 160
    if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if @types.tier_unlocked(game.scores, t) {
          game.selected_tier = t
          game.screen = LevelSelect
        } else {
          @types.set_message(game, "Complete more levels to unlock!", 2.0)
        }
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let count = @types.levels_in_tier(game.selected_tier)
  let cols = 5
  let bw = 120
  let bh = 80
  let gap = 20
  let start_x = (@types.screen_width - (cols * (bw + gap) - gap)) / 2
  let start_y = 200
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let bx = start_x + col * (bw + gap)
    let by = start_y + row * (bh + gap)
    if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        let level_idx = @types.level_index_for_tier(game.selected_tier, i)
        load_level(game, level_idx)
        game.screen = Playing
      }
    }
  }
}

///|
fn load_level(game : @types.Game, level_idx : Int) -> Unit {
  let def = @levels.get_level(level_idx)
  game.current_level = level_idx
  game.current_tier = def.tier
  game.nodes = def.nodes
  game.ropes = def.ropes
  game.weights = def.weights
  game.crates = def.crates
  game.platforms = def.platforms
  game.buckets = def.buckets
  game.targets = def.targets
  game.par_connections = def.par_connections
  game.par_rehooks = def.par_rehooks
  game.has_waterfall = def.has_waterfall
  game.waterfall_x = def.waterfall_x
  game.connections_used = 0
  game.rehooks = 0
  game.play_state = Idle
  game.settle_timer = 0.0
  game.hover_node = -1
  game.message = ""
  game.message_timer = 0.0
  // Count pre-placed ropes
  for i in 0..<game.ropes.length() {
    if game.ropes[i].active {
      game.connections_used = game.connections_used + 1
    }
  }
  // Run initial equilibrium
  @physics.solve_equilibrium(game)
  // Snap positions immediately
  for i in 0..<game.weights.length() {
    if game.weights[i].active {
      game.weights[i].current_y = game.weights[i].target_y
    }
  }
  for i in 0..<game.crates.length() {
    if game.crates[i].active {
      game.crates[i].current_y = game.crates[i].target_y
    }
  }
  for i in 0..<game.buckets.length() {
    if game.buckets[i].active {
      game.buckets[i].current_y = game.buckets[i].target_y
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    load_level(game, game.current_level)
    return
  }
  match game.play_state {
    Won => {
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) ||
        @raylib.is_key_pressed(@raylib.KeyEnter) {
        game.screen = Results
      }
    }
    Failed => {
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        load_level(game, game.current_level)
      }
    }
    Settling => {
      game.settle_timer = game.settle_timer + dt
      let settled = @physics.animate_settling(game, dt)
      if settled || game.settle_timer > @types.settle_duration {
        // Check win condition
        let _ = @physics.check_targets(game)
        if @physics.check_all_crates_placed(game) {
          game.play_state = Won
          @types.set_message(game, "Level Complete!", 3.0)
        } else {
          game.play_state = Idle
        }
      }
    }
    Idle => update_idle_input(game)
    ConnectingRope(from_id) => update_connecting_input(game, from_id)
  }
  // Animate settling even in idle mode (for smooth visuals)
  let _ = @physics.animate_settling(game, dt)
  // Update buckets filling
  if game.has_waterfall {
    let mut any_filling = false
    for i in 0..<game.buckets.length() {
      if game.buckets[i].active && game.buckets[i].filling {
        any_filling = true
      }
    }
    if any_filling {
      @physics.solve_equilibrium(game)
    }
  }
}

///|
fn find_nearest_node(game : @types.Game, mx : Int, my : Int) -> Int {
  let mut best = -1
  let mut best_dist : Float = 999999.0
  for i in 0..<game.nodes.length() {
    let nx = @types.node_screen_x(game.nodes[i], game.grid_offset_x)
    let ny = @types.node_screen_y(game.nodes[i], game.grid_offset_y)
    let dx = Float::from_int(mx - nx)
    let dy = Float::from_int(my - ny)
    let dist = dx * dx + dy * dy
    if dist < best_dist && dist < 900.0 {
      best_dist = dist
      best = i
    }
  }
  best
}

///|
fn update_idle_input(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover_node = find_nearest_node(game, mx, my)
  // Left click to start connection
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if game.hover_node >= 0 {
      let node = game.nodes[game.hover_node]
      if node.kind == Pulley || node.kind == Ratchet || node.kind == Anchor {
        game.play_state = ConnectingRope(game.hover_node)
      } else if node.kind == WeightHook || node.kind == CrateHook {
        // Can also start from hook side
        game.play_state = ConnectingRope(game.hover_node)
      }
    }
  }
  // Right click to remove rope
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if game.hover_node >= 0 {
      remove_ropes_at_node(game, game.hover_node)
    }
  }
}

///|
fn update_connecting_input(game : @types.Game, from_id : Int) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover_node = find_nearest_node(game, mx, my)
  // Right click or escape to cancel
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) ||
    @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.play_state = Idle
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if game.hover_node >= 0 && game.hover_node != from_id {
      // Try to make connection
      if @physics.validate_connection(game, from_id, game.hover_node) {
        add_rope(game, from_id, game.hover_node)
        game.connections_used = game.connections_used + 1
        // Recalculate equilibrium
        @physics.solve_equilibrium(game)
        game.play_state = Settling
        game.settle_timer = 0.0
      } else {
        @types.set_message(game, "Invalid connection!", 1.0)
        game.play_state = Idle
      }
    } else {
      game.play_state = Idle
    }
  }
  ignore(mx)
  ignore(my)
}

///|
fn add_rope(game : @types.Game, from_id : Int, to_id : Int) -> Unit {
  let from_node = game.nodes[from_id]
  let to_node = game.nodes[to_id]
  // Determine sides
  let from_side : @types.RopeSide = if from_node.kind == Pulley ||
    from_node.kind == Ratchet {
    if to_node.pos.x < from_node.pos.x {
      LeftSide
    } else {
      RightSide
    }
  } else {
    LeftSide
  }
  let to_side : @types.RopeSide = if to_node.kind == Pulley ||
    to_node.kind == Ratchet {
    if from_node.pos.x < to_node.pos.x {
      LeftSide
    } else {
      RightSide
    }
  } else {
    RightSide
  }
  let rope : @types.Rope = {
    active: true,
    from_node: from_id,
    to_node: to_id,
    from_side,
    to_side,
    max_load: 999.0,
    broken: false,
    breakable: false,
  }
  game.ropes.push(rope)
}

///|
fn remove_ropes_at_node(game : @types.Game, node_id : Int) -> Unit {
  let mut removed = false
  for i in 0..<game.ropes.length() {
    if game.ropes[i].active {
      let r = game.ropes[i]
      if r.from_node == node_id || r.to_node == node_id {
        if !r.breakable {
          r.active = false
          removed = true
        }
      }
    }
  }
  if removed {
    game.rehooks = game.rehooks + 1
    @physics.solve_equilibrium(game)
    game.play_state = Settling
    game.settle_timer = 0.0
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Save score
  let stars = @physics.compute_stars(
    game.connections_used,
    game.rehooks,
    game.par_connections,
    game.par_rehooks,
  )
  let idx = game.current_level
  if idx >= 0 && idx < game.scores.length() {
    let score = game.scores[idx]
    score.completed = true
    if stars > score.stars {
      score.stars = stars
    }
    score.connections_used = game.connections_used
    score.rehooks = game.rehooks
  }
  // Next level button
  let bx = 440
  let by = 450
  let bw = 180
  let bh = 50
  if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      let next = game.current_level + 1
      if next < @types.total_levels {
        load_level(game, next)
        game.screen = Playing
      } else {
        game.screen = TierSelect
      }
    }
  }
  // Replay button
  let rx = 660
  if mx >= rx && mx < rx + bw && my >= by && my < by + bh {
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      load_level(game, game.current_level)
      game.screen = Playing
    }
  }
  // Back button
  let backx = 540
  let backy = 520
  if mx >= backx && mx < backx + bw && my >= backy && my < backy + bh {
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      game.screen = LevelSelect
    }
  }
}
