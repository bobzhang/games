///|
pub fn update(game : @types.Game, levels : Array[@types.Level]) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  game.anim_timer = game.anim_timer + dt
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game, levels)
    Playing => update_playing(game)
    Results => update_results(game, levels)
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
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = OasisTrail
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = DuneSea
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = LostCity
    game.screen = LevelSelect
    return
  }
  // Mouse click on tier buttons
  if @raylib.is_mouse_button_pressed(0) {
    let mouse = @raylib.get_mouse_position()
    let mx = mouse.x.to_int()
    let my = mouse.y.to_int()
    let bx = @types.screen_width / 2 - 200
    let bw = 400
    let bh = 130
    for i in 0..<3 {
      let by = 160 + i * 160
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        match i {
          0 => game.current_tier = OasisTrail
          1 => game.current_tier = DuneSea
          _ => game.current_tier = LostCity
        }
        game.screen = LevelSelect
        return
      }
    }
  }
}

///|
fn update_level_select(
  game : @types.Game,
  levels : Array[@types.Level],
) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let (start, end) = @types.tier_level_range(game.current_tier)
  let count = end - start
  // Number keys 1-9
  for i in 0..<@types.mini(count, 9) {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      game.current_level = start + i
      start_level(game, levels)
      return
    }
  }
  // Mouse click
  if @raylib.is_mouse_button_pressed(0) {
    let mouse = @raylib.get_mouse_position()
    let mx = mouse.x.to_int()
    let my = mouse.y.to_int()
    let cols = if count <= 4 { count } else { 4 }
    let rows = (count + cols - 1) / cols
    let btn_w = 240
    let btn_h = 100
    let gap = 20
    let total_w = cols * btn_w + (cols - 1) * gap
    let total_h = rows * btn_h + (rows - 1) * gap
    let base_x = @types.screen_width / 2 - total_w / 2
    let base_y = @types.screen_height / 2 - total_h / 2
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let bx = base_x + col * (btn_w + gap)
      let by = base_y + row * (btn_h + gap)
      if mx >= bx && mx < bx + btn_w && my >= by && my < by + btn_h {
        game.current_level = start + i
        start_level(game, levels)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, levels : Array[@types.Level]) -> Unit {
  let level = levels[game.current_level]
  game.level = Some(level)
  game.caravan = @types.new_caravan(level.start, level.starting_water)
  game.route = []
  game.hover_hex = None
  game.play_state = Planning
  game.execute_timer = 0.0
  game.message = ""
  game.message_timer = 0.0
  game.result_gold = 0
  game.result_artifacts = 0
  game.result_stars = 0
  game.water_preview = level.starting_water
  @types.seed_rng(game.current_level * 7 + 42)
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  // Handle escape
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  let level = match game.level {
    Some(lv) => lv
    None => return
  }
  // Handle restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.caravan = @types.new_caravan(level.start, level.starting_water)
    game.route = []
    game.hover_hex = None
    game.play_state = Planning
    game.execute_timer = 0.0
    game.message = ""
    game.message_timer = 0.0
    game.water_preview = level.starting_water
    @types.seed_rng(game.current_level * 7 + 42)
    return
  }
  // Track mouse hover for hex picking
  let mouse = @raylib.get_mouse_position()
  let mx = mouse.x
  let my = mouse.y
  let hovered = @types.pixel_to_hex(mx, my, @types.hex_size)
  if @types.hex_in_bounds(hovered, level.map.width, level.map.height) {
    game.hover_hex = Some(hovered)
  } else {
    game.hover_hex = None
  }
  match game.play_state {
    Planning => update_planning(game, level)
    Executing => update_executing(game, level, dt)
    Complete =>
      if @raylib.is_key_pressed(@raylib.KeyEnter) {
        game.screen = Results
      }
    Failed => ()
  }
}

///|
fn update_planning(game : @types.Game, level : @types.Level) -> Unit {
  // Space to execute route
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.route.length() == 0 {
      @types.set_message(game, "Plan a route first!", 2.0)
      return
    }
    // Check route reaches destination
    let last = game.route[game.route.length() - 1]
    if last.col != level.destination.col || last.row != level.destination.row {
      @types.set_message(game, "Route must reach the destination!", 2.0)
      return
    }
    // Start execution
    game.caravan.route = game.route
    game.caravan.route_index = 0
    game.play_state = Executing
    game.execute_timer = 0.0
    @types.seed_rng(game.current_level * 7 + 42)
    return
  }
  // Left click to add/toggle hex in route
  if @raylib.is_mouse_button_pressed(0) {
    match game.hover_hex {
      Some(hh) => handle_route_click(game, level, hh)
      None => ()
    }
  }
  // Right click to remove last route hex
  if @raylib.is_mouse_button_pressed(1) {
    if game.route.length() > 0 {
      let _ = game.route.pop()
    }
  }
}

///|
fn handle_route_click(
  game : @types.Game,
  level : @types.Level,
  hex : @types.HexCoord,
) -> Unit {
  let map = level.map
  // Check if clicking the last hex in route to remove it
  if game.route.length() > 0 {
    let last = game.route[game.route.length() - 1]
    if last.col == hex.col && last.row == hex.row {
      let _ = game.route.pop()
      return
    }
  }
  // Check if clicking start hex - ignore
  if hex.col == level.start.col && hex.row == level.start.row {
    return
  }
  // Check if hex is already in route (not last) - truncate route to that point
  for i in 0..<game.route.length() {
    if game.route[i].col == hex.col && game.route[i].row == hex.row {
      // Truncate route to this point
      let new_route : Array[@types.HexCoord] = []
      for j in 0..<=i {
        new_route.push(game.route[j])
      }
      game.route = new_route
      return
    }
  }
  // Must be adjacent to last position in route (or start)
  let last = if game.route.length() > 0 {
    game.route[game.route.length() - 1]
  } else {
    level.start
  }
  if !@types.hex_are_adjacent(last, hex) {
    @types.set_message(game, "Must be adjacent to last step!", 1.5)
    return
  }
  // Check bounds
  if !@types.hex_in_bounds(hex, map.width, map.height) {
    return
  }
  // Check not sandstorm
  let tile = map.tiles[hex.row][hex.col]
  if tile.kind == Sandstorm {
    @types.set_message(game, "Cannot cross sandstorm!", 1.5)
    return
  }
  // Add to route
  game.route.push(hex)
}

///|
fn update_executing(
  game : @types.Game,
  level : @types.Level,
  dt : Float,
) -> Unit {
  game.execute_timer = game.execute_timer + dt
  if game.execute_timer < @types.move_speed {
    return
  }
  game.execute_timer = 0.0
  // Execute one step
  let result = @world.execute_route_step(game.caravan, level.map)
  match result {
    Complete => {
      // Check if caravan is at destination
      let at_dest = game.caravan.pos.col == level.destination.col &&
        game.caravan.pos.row == level.destination.row
      if at_dest {
        game.play_state = Complete
        game.result_gold = game.caravan.gold
        game.result_artifacts = game.caravan.artifacts
        // Calculate stars
        let stars = @world.calculate_stars(
          true,
          game.caravan.gold,
          level.gold_target,
          game.caravan.artifacts,
          level.total_artifacts,
        )
        game.result_stars = stars
        // Update score
        let score = game.scores[game.current_level]
        score.completed = true
        score.stars = @types.maxi(score.stars, stars)
        score.best_gold = @types.maxi(score.best_gold, game.caravan.gold)
        score.best_artifacts = @types.maxi(
          score.best_artifacts,
          game.caravan.artifacts,
        )
        @types.set_message(game, "Route Complete!", 3.0)
      } else {
        // Route ended but did not reach destination
        game.play_state = Failed
        game.result_gold = game.caravan.gold
        game.result_artifacts = game.caravan.artifacts
        @types.set_message(game, "Did not reach destination!", 3.0)
      }
    }
    Failed => {
      game.play_state = Failed
      game.result_gold = game.caravan.gold
      game.result_artifacts = game.caravan.artifacts
      @types.set_message(game, "Caravan stranded - no water!", 3.0)
    }
    Executing => ()
    Planning => ()
  }
}

///|
fn update_results(game : @types.Game, levels : Array[@types.Level]) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, levels)
    return
  }
}
