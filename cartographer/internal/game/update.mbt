///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  game.anim_timer = game.anim_timer + dt
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
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
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Surveyor
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Explorer
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = Master
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
          0 => game.current_tier = Surveyor
          1 => game.current_tier = Explorer
          _ => game.current_tier = Master
        }
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
  let (start, end) = @types.tier_level_range(game.current_tier)
  let count = end - start
  // Number keys 1-9
  for i in 0..<@types.mini(count, 9) {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      game.current_level = start + i
      start_level(game)
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
        start_level(game)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game) -> Unit {
  @types.reset_level(game)
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Handle escape
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Handle restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @types.reset_level(game)
    return
  }
  // Handle hints
  if @raylib.is_key_pressed(@raylib.KeyH) {
    let level = game.levels[game.current_level]
    game.hint_cells = @solver.compute_hints(
      game.grid, @types.grid_size, level.features_to_place, level.clues,
    )
    game.show_hints = true
    return
  }
  // Handle enter on complete
  if game.play_state == Complete {
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      game.screen = Results
    }
    return
  }
  // Track mouse hover
  let mouse = @raylib.get_mouse_position()
  let mx = mouse.x.to_int()
  let my = mouse.y.to_int()
  // Check if mouse is over the grid
  let grid_x = mx - @types.grid_offset_x
  let grid_y = my - @types.grid_offset_y
  let grid_total = @types.grid_size * @types.cell_size
  if grid_x >= 0 && grid_x < grid_total && grid_y >= 0 && grid_y < grid_total {
    let col = grid_x / @types.cell_size
    let row = grid_y / @types.cell_size
    game.hover_cell = Some(@types.vec2i(col, row))
  } else {
    game.hover_cell = None
  }
  // Handle palette clicks
  if @raylib.is_mouse_button_pressed(0) {
    // Check palette area
    let level = game.levels[game.current_level]
    let feature_kinds = get_unique_features(level.features_to_place)
    for i in 0..<feature_kinds.length() {
      let cell_x = @types.palette_x + i * (@types.palette_cell + 10)
      let cell_y = @types.palette_y
      if mx >= cell_x &&
        mx < cell_x + @types.palette_cell &&
        my >= cell_y &&
        my < cell_y + @types.palette_cell {
        let feat = feature_kinds[i]
        // Toggle selection
        match game.selected_feature {
          Some(sf) =>
            if sf == feat {
              game.selected_feature = None
            } else {
              game.selected_feature = Some(feat)
            }
          None => game.selected_feature = Some(feat)
        }
        return
      }
    }
    // Check grid click
    match game.hover_cell {
      Some(hc) => handle_grid_click(game, hc)
      None => ()
    }
  }
  // Right click to remove
  if @raylib.is_mouse_button_pressed(1) {
    match game.hover_cell {
      Some(hc) => {
        let idx = @types.pos_to_index(hc, @types.grid_size)
        match game.grid[idx] {
          Some(_) => {
            game.grid[idx] = None
            // Revalidate
            let level = game.levels[game.current_level]
            @solver.validate_all_clues(
              level.clues, game.grid, @types.grid_size,
            )
            game.show_hints = false
          }
          None => ()
        }
      }
      None => ()
    }
  }
}

///|
fn handle_grid_click(game : @types.Game, pos : @types.Vec2i) -> Unit {
  let level = game.levels[game.current_level]
  let idx = @types.pos_to_index(pos, @types.grid_size)
  match game.selected_feature {
    None => {
      // If there's a feature here, remove it
      match game.grid[idx] {
        Some(_) => {
          game.grid[idx] = None
          @solver.validate_all_clues(
            level.clues, game.grid, @types.grid_size,
          )
          game.show_hints = false
        }
        None => ()
      }
    }
    Some(feat) => {
      // Check if same feature already placed here - remove it
      match game.grid[idx] {
        Some(existing) =>
          if existing == feat {
            game.grid[idx] = None
            @solver.validate_all_clues(
              level.clues, game.grid, @types.grid_size,
            )
            game.show_hints = false
            return
          }
        None => ()
      }
      // Check if we can place more of this type
      let placed_count = @solver.count_placed_features(game.grid, feat)
      let needed_count = @solver.get_feature_placement_count(
        level.features_to_place, feat,
      )
      if placed_count >= needed_count {
        game.message = "All \{@types.feature_name(feat)}s already placed"
        game.message_timer = 1.5
        return
      }
      // Place the feature
      game.grid[idx] = Some(feat)
      game.total_placements += 1
      game.show_hints = false
      // Validate all clues
      @solver.validate_all_clues(level.clues, game.grid, @types.grid_size)
      // Check if this placement violates any clue
      if @solver.any_clue_violated(level.clues) {
        game.incorrect_count += 1
      }
      // Check if all features placed and all clues satisfied
      if @solver.all_features_placed(game.grid, level.features_to_place) &&
        @solver.all_clues_satisfied(level.clues) {
        game.play_state = Complete
        // Calculate score
        let score = game.scores[game.current_level]
        score.completed = true
        if game.incorrect_count == 0 {
          score.stars = 3
        } else if game.total_placements <= level.par_placements {
          score.stars = @types.maxi(score.stars, 2)
        } else {
          score.stars = @types.maxi(score.stars, 1)
        }
        if game.total_placements < score.best_placements {
          score.best_placements = game.total_placements
        }
        game.message = "Map Complete!"
        game.message_timer = 2.0
      }
    }
  }
}

///|
fn get_unique_features(
  features : Array[@types.FeatureKind]
) -> Array[@types.FeatureKind] {
  let result : Array[@types.FeatureKind] = []
  for i in 0..<features.length() {
    let f = features[i]
    let mut found = false
    for j in 0..<result.length() {
      if result[j] == f {
        found = true
        break
      }
    }
    if !found {
      result.push(f)
    }
  }
  result
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game)
    return
  }
}
