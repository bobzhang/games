///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  game.frame_count += 1
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  // Update animation timers
  update_animations(game, dt)
  match game.screen {
    Title => process_title_input(game)
    LevelSelect => process_level_select_input(game)
    Planning => update_planning(game)
    Simulate => update_simulate(game, dt)
    Results => process_results_input(game)
  }
}

///|
fn update_animations(game : @types.Game, dt : Float) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if game.harvest_flash[r][c] > 0.0 {
        game.harvest_flash[r][c] -= dt * 2.0
        if game.harvest_flash[r][c] < 0.0 {
          game.harvest_flash[r][c] = 0.0
        }
      }
      if game.growth_anim[r][c] > 0.0 {
        game.growth_anim[r][c] -= dt * 1.5
        if game.growth_anim[r][c] < 0.0 {
          game.growth_anim[r][c] = 0.0
        }
      }
    }
  }
  if game.fade_timer > 0.0 {
    game.fade_timer -= dt
  }
  if game.anim_timer > 0.0 {
    game.anim_timer -= dt
  }
}

///|
fn process_title_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.menu_selection = (game.menu_selection + 1) % 2
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.menu_selection = (game.menu_selection + 1) % 2
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    match game.menu_selection {
      0 => {
        game.screen = LevelSelect
        game.menu_selection = 0
      }
      _ => () // Quit handled by window close
    }
  }
  // Mouse click on buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i in 0..<2 {
      let y = 320 + i * 70
      if mx >= 490 && mx <= 790 && my >= y && my <= y + 55 {
        game.menu_selection = i
        if i == 0 {
          game.screen = LevelSelect
          game.menu_selection = 0
        }
      }
    }
  }
}

///|
fn process_level_select_input(game : @types.Game) -> Unit {
  let cols = 5
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.menu_selection = @types.mini(
      game.menu_selection + 1,
      @types.total_levels - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.menu_selection = @types.maxi(game.menu_selection - 1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_selection = @types.mini(
      game.menu_selection + cols,
      @types.total_levels - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_selection = @types.maxi(game.menu_selection - cols, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    game.menu_selection = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    try_start_level(game, game.menu_selection)
  }
  // Mouse click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let btn_w = 200
    let btn_h = 100
    let gap_x = 20
    let gap_y = 15
    let start_x = (@types.screen_width - cols * btn_w - (cols - 1) * gap_x) / 2
    let start_y = 100
    for i in 0..<@types.total_levels {
      let col = i % cols
      let row = i / cols
      let x = start_x + col * (btn_w + gap_x)
      let y = start_y + row * (btn_h + gap_y) - game.scroll_offset
      if mx >= x && mx <= x + btn_w && my >= y && my <= y + btn_h {
        game.menu_selection = i
        try_start_level(game, i)
        break
      }
    }
  }
}

///|
pub fn is_level_unlocked(game : @types.Game, index : Int) -> Bool {
  if index == 0 {
    return true
  }
  match game.level_scores[index - 1] {
    Some(_) => true
    None => false
  }
}

///|
fn try_start_level(game : @types.Game, index : Int) -> Unit {
  if is_level_unlocked(game, index) {
    start_level(game, index)
  } else {
    @types.set_message(
      game,
      "Level locked! Complete previous level first.",
      2.0,
    )
  }
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  game.level_index = index
  let goal = @levels.load_level(index)
  // Reset grid with level soil
  @farm.reset_grid(game.grid, goal.initial_soil)
  // Reset plans
  for s in 0..<4 {
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        game.plans[s].crops[r][c] = Fallow
      }
    }
  }
  game.planning_season = 0
  game.selected_crop = Wheat
  game.total_value = 0
  game.season_value = 0
  game.hover_col = -1
  game.hover_row = -1
  game.hover_valid = false
  game.screen = Planning
  game.sim_season = 0
  game.sim_step = 0
  game.sim_timer = 0.0
  // Reset animations
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      game.harvest_flash[r][c] = 0.0
      game.growth_anim[r][c] = 0.0
    }
  }
  @types.set_message(game, "Plan your crops for each season!", 2.5)
}

///|
fn update_planning(game : @types.Game) -> Unit {
  update_hover(game)
  process_planning_input(game)
}

///|
fn update_hover(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @types.in_grid_area(mx, my) {
    let (col, row) = @types.pixel_to_grid(mx, my)
    game.hover_col = col
    game.hover_row = row
    if @types.in_bounds(col, row) {
      let goal = @levels.load_level(game.level_index)
      let locked = is_plot_locked(col, row, goal.locked_plots)
      if locked {
        game.hover_valid = false
      } else {
        let season = @types.season_from_index(game.planning_season)
        game.hover_valid = @types.can_plant_in_season(
            game.selected_crop,
            season,
          ) &&
          @types.soil_has_nutrients(
            game.grid[row][col].soil,
            game.selected_crop,
          )
      }
    } else {
      game.hover_valid = false
    }
  } else {
    game.hover_col = -1
    game.hover_row = -1
    game.hover_valid = false
  }
}

///|
fn is_plot_locked(
  col : Int,
  row : Int,
  locked : Array[(Int, Int)]
) -> Bool {
  for i in 0..<locked.length() {
    let (lc, lr) = locked[i]
    if lc == col && lr == row {
      return true
    }
  }
  false
}

///|
fn process_planning_input(game : @types.Game) -> Unit {
  // Crop selection keys 1-8
  let crops = @types.all_crops()
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_crop = crops[0]
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_crop = crops[1]
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_crop = crops[2]
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.selected_crop = crops[3]
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.selected_crop = crops[4]
  }
  if @raylib.is_key_pressed(@raylib.KeySix) {
    game.selected_crop = crops[5]
  }
  if @raylib.is_key_pressed(@raylib.KeySeven) {
    game.selected_crop = crops[6]
  }
  if @raylib.is_key_pressed(@raylib.KeyEight) {
    game.selected_crop = crops[7]
  }
  // Season tab switching
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.planning_season = (game.planning_season + 1) % 4
    @types.set_message(
      game,
      "Planning: " +
      @types.season_name(@types.season_from_index(game.planning_season)),
      1.0,
    )
  }
  // Place crop on click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    place_crop_at_hover(game)
  }
  // Right click to clear
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    clear_crop_at_hover(game)
  }
  // Simulate
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    start_simulation(game)
  }
  // Reset
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.level_index)
    @types.set_message(game, "Level reset!", 1.5)
  }
  // Back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.menu_selection = game.level_index
  }
  // Click on crop palette
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let pal_x = @types.grid_offset_x + @types.grid_cols * @types.cell_size + 30
    let pal_y = @types.grid_offset_y
    if mx >= pal_x && mx <= pal_x + 280 {
      for i in 0..<crops.length() {
        let cy = pal_y + 40 + i * 47
        if my >= cy && my <= cy + 42 {
          game.selected_crop = crops[i]
          break
        }
      }
    }
    // Click on season tabs
    let tab_w = 140
    let tab_y = @types.grid_offset_y - 45
    if my >= tab_y && my <= tab_y + 35 {
      for i in 0..<4 {
        let tx = @types.grid_offset_x + i * (tab_w + 8)
        if mx >= tx && mx <= tx + tab_w {
          game.planning_season = i
          break
        }
      }
    }
  }
}

///|
fn place_crop_at_hover(game : @types.Game) -> Unit {
  let col = game.hover_col
  let row = game.hover_row
  if !@types.in_bounds(col, row) {
    return
  }
  let goal = @levels.load_level(game.level_index)
  if is_plot_locked(col, row, goal.locked_plots) {
    @types.set_message(game, "This plot is rocky!", 1.0)
    return
  }
  let season = @types.season_from_index(game.planning_season)
  let crop = game.selected_crop
  if !@types.can_plant_in_season(crop, season) {
    @types.set_message(
      game,
      @types.crop_name(crop) +
      " can't be planted in " +
      @types.season_name(season),
      1.5,
    )
    return
  }
  // Store in plan
  game.plans[game.planning_season].crops[row][col] = crop
  @types.set_message(
    game,
    "Planned " +
    @types.crop_name(crop) +
    " at (" +
    col.to_string() +
    "," +
    row.to_string() +
    ")",
    0.8,
  )
}

///|
fn clear_crop_at_hover(game : @types.Game) -> Unit {
  let col = game.hover_col
  let row = game.hover_row
  if @types.in_bounds(col, row) {
    game.plans[game.planning_season].crops[row][col] = Fallow
    @types.set_message(game, "Cleared plan", 0.6)
  }
}

///|
fn start_simulation(game : @types.Game) -> Unit {
  // Reset grid for simulation
  let goal = @levels.load_level(game.level_index)
  @farm.reset_grid(game.grid, goal.initial_soil)
  game.total_value = 0
  game.season_value = 0
  game.sim_season = 0
  game.sim_step = 0
  game.sim_timer = 0.8
  game.screen = Simulate
  // Reset flash
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      game.harvest_flash[r][c] = 0.0
      game.growth_anim[r][c] = 0.0
    }
  }
  @types.set_message(game, "Simulating year...", 1.5)
}

///|
fn update_simulate(game : @types.Game, dt : Float) -> Unit {
  game.sim_timer -= dt
  if game.sim_timer > 0.0 {
    return
  }
  // Process one step
  let season = @types.season_from_index(game.sim_season)
  match game.sim_step % 3 {
    0 => {
      // Step 0: clear + plant
      @farm.clear_harvested(game.grid)
      let goal = @levels.load_level(game.level_index)
      // Apply plan but skip locked plots
      let plan = game.plans[game.sim_season]
      for r in 0..<@types.grid_rows {
        for c in 0..<@types.grid_cols {
          if is_plot_locked(c, r, goal.locked_plots) {
            continue
          }
          let crop = plan.crops[r][c]
          if crop != Fallow {
            let ok = @farm.plant_crop(game.grid[r][c], crop, season)
            if ok {
              game.growth_anim[r][c] = 1.0
            }
          }
        }
      }
      @types.set_message(
        game,
        @types.season_name(season) + ": Planting...",
        0.7,
      )
      game.sim_timer = 0.6
    }
    1 => {
      // Step 1: grow
      @farm.advance_season(game.grid, season)
      for r in 0..<@types.grid_rows {
        for c in 0..<@types.grid_cols {
          if game.grid[r][c].state == Growing ||
            game.grid[r][c].state == Mature {
            game.growth_anim[r][c] = 0.8
          }
        }
      }
      @types.set_message(
        game,
        @types.season_name(season) + ": Growing...",
        0.7,
      )
      game.sim_timer = 0.6
    }
    _ => {
      // Step 2: harvest
      let value = @farm.harvest_mature(game.grid, game.harvest_flash)
      game.season_value = value
      game.total_value += value
      @types.set_message(
        game,
        @types.season_name(season) +
        ": Harvested $" +
        value.to_string(),
        0.7,
      )
      game.sim_season += 1
      if game.sim_season >= 4 {
        // Year complete
        game.sim_timer = 1.0
        finish_simulation(game)
        return
      }
      game.sim_timer = 0.7
    }
  }
  game.sim_step += 1
}

///|
fn finish_simulation(game : @types.Game) -> Unit {
  let goal = @levels.load_level(game.level_index)
  let tier = @types.tier_from_value(
    game.total_value,
    goal.bronze_threshold,
    goal.silver_threshold,
    goal.gold_threshold,
  )
  // Save score
  let score : @types.LevelScore = {
    value_earned: game.total_value,
    target_value: goal.target_value,
    tier,
  }
  // Only save if better
  match game.level_scores[game.level_index] {
    Some(prev) =>
      if game.total_value > prev.value_earned {
        game.level_scores[game.level_index] = Some(score)
      }
    None => game.level_scores[game.level_index] = Some(score)
  }
  game.screen = Results
}

///|
fn process_results_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    if game.level_index < @types.total_levels - 1 {
      start_level(game, game.level_index + 1)
    } else {
      game.screen = LevelSelect
      game.menu_selection = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.level_index)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.menu_selection = game.level_index
  }
}
