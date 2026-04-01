///|
fn draw_season_tabs(game : @types.Game) -> Unit {
  let tab_w = 140
  let tab_h = 35
  let start_x = @types.grid_offset_x
  let tab_y = @types.grid_offset_y - 45
  for i in 0..<4 {
    let x = start_x + i * (tab_w + 8)
    let season = @types.season_from_index(i)
    let is_active = i == game.planning_season
    let bg = if is_active {
      @types.season_color(season)
    } else {
      @types.color_season_tab
    }
    @raylib.draw_rectangle(x, tab_y, tab_w, tab_h, bg)
    @raylib.draw_rectangle_lines(x, tab_y, tab_w, tab_h, @types.color_grid_line)
    let text_col = if is_active {
      @types.color_dark_text
    } else {
      @types.color_hud_text
    }
    @draw.draw_text(@types.season_name(season), x + 10, tab_y + 8, 18, text_col)
    // Show plan count
    let plan = game.plans[i]
    let mut count = 0
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        if plan.crops[r][c] != Fallow {
          count += 1
        }
      }
    }
    if count > 0 {
      @draw.draw_text(
        count.to_string(),
        x + tab_w - 30,
        tab_y + 8,
        18,
        text_col,
      )
    }
  }
}

///|
fn draw_crop_palette(game : @types.Game) -> Unit {
  let pal_x = @types.grid_offset_x + @types.grid_cols * @types.cell_size + 30
  let pal_y = @types.grid_offset_y
  // Background
  @raylib.draw_rectangle(pal_x, pal_y, 280, 420, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(
    pal_x,
    pal_y,
    280,
    420,
    @types.color_grid_line,
  )
  @draw.draw_text("Crops", pal_x + 10, pal_y + 8, 22, @types.color_title_text)
  let crops = @types.all_crops()
  let season = @types.season_from_index(game.planning_season)
  for i in 0..<crops.length() {
    let cy = pal_y + 40 + i * 47
    let crop = crops[i]
    let info = @types.crop_info(crop)
    let can_plant = @types.can_plant_in_season(crop, season)
    let is_selected = crop == game.selected_crop
    // Background
    if is_selected {
      @raylib.draw_rectangle(
        pal_x + 5,
        cy,
        270,
        42,
        @types.color_crop_selected,
      )
    } else if can_plant {
      @raylib.draw_rectangle(
        pal_x + 5,
        cy,
        270,
        42,
        @raylib.Color::new(80, 70, 55, 150),
      )
    } else {
      @raylib.draw_rectangle(
        pal_x + 5,
        cy,
        270,
        42,
        @raylib.Color::new(60, 55, 45, 100),
      )
    }
    // Crop color swatch
    let cc = @types.crop_color(crop)
    @raylib.draw_rectangle(pal_x + 10, cy + 5, 30, 30, cc)
    @raylib.draw_rectangle_lines(
      pal_x + 10,
      cy + 5,
      30,
      30,
      @types.color_grid_line,
    )
    // Name and info
    let text_col = if can_plant {
      @types.color_hud_text
    } else {
      @raylib.Color::new(120, 110, 100, 200)
    }
    @draw.draw_text(info.name, pal_x + 48, cy + 3, 16, text_col)
    // Season and value info
    let season_str = match info.plant_season {
      Some(s) => @types.season_name(s)
      None => "Any"
    }
    let detail = season_str +
      " | $" +
      info.value.to_string() +
      " | G:" +
      info.growth_time.to_string()
    @draw.draw_text(detail, pal_x + 48, cy + 22, 11, text_col)
    // Keyboard shortcut
    let key_str = (i + 1).to_string()
    @draw.draw_text(key_str, pal_x + 250, cy + 10, 14, text_col)
  }
  // Nutrient legend
  let leg_y = pal_y + 420 + 15
  @raylib.draw_rectangle(pal_x, leg_y, 280, 65, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(
    pal_x,
    leg_y,
    280,
    65,
    @types.color_grid_line,
  )
  @draw.draw_text("Nutrients", pal_x + 10, leg_y + 5, 14, @types.color_hud_text)
  @raylib.draw_rectangle(pal_x + 10, leg_y + 25, 12, 12, @types.color_n_bar)
  @draw.draw_text("N", pal_x + 28, leg_y + 25, 12, @types.color_hud_text)
  @raylib.draw_rectangle(pal_x + 60, leg_y + 25, 12, 12, @types.color_p_bar)
  @draw.draw_text("P", pal_x + 78, leg_y + 25, 12, @types.color_hud_text)
  @raylib.draw_rectangle(pal_x + 110, leg_y + 25, 12, 12, @types.color_k_bar)
  @draw.draw_text("K", pal_x + 128, leg_y + 25, 12, @types.color_hud_text)
  @draw.draw_text(
    "Clover/Fallow restore soil",
    pal_x + 10,
    leg_y + 44,
    11,
    @types.color_hud_text,
  )
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Top bar
  @raylib.draw_rectangle(0, 0, @types.screen_width, 55, @types.color_hud_bg)
  // Level name
  @draw.draw_text(
    @levels.level_name(game.level_index),
    15,
    5,
    22,
    @types.color_title_text,
  )
  // Tier
  @draw.draw_text(
    @levels.level_tier(game.level_index),
    15,
    30,
    14,
    @types.color_hud_text,
  )
  // Level number
  @draw.draw_text(
    "Level " + (game.level_index + 1).to_string() + "/20",
    250,
    5,
    18,
    @types.color_hud_text,
  )
  // Target value
  let goal = @levels.load_level(game.level_index)
  @draw.draw_text(
    "Target: $" + goal.target_value.to_string(),
    250,
    28,
    16,
    @types.color_wheat,
  )
  // Thresholds
  @draw.draw_text(
    "B:" +
    goal.bronze_threshold.to_string() +
    " S:" +
    goal.silver_threshold.to_string() +
    " G:" +
    goal.gold_threshold.to_string(),
    450,
    5,
    14,
    @types.color_hud_text,
  )
  // Hint
  @draw.draw_text(goal.hint, 450, 28, 13, @types.color_hud_text)
  // Planning season display
  let season = @types.season_from_index(game.planning_season)
  @draw.draw_text(
    "Planning: " + @types.season_name(season),
    900,
    5,
    18,
    @types.season_color(season),
  )
  // Average soil quality
  let avg_q = @farm.average_soil_quality(game.grid)
  @draw.draw_text(
    "Soil: " + avg_q.to_string() + "%",
    900,
    28,
    16,
    @types.color_hud_text,
  )
  // Simulate button hint
  @draw.draw_text(
    "Space: Simulate Year",
    1100,
    15,
    16,
    @types.color_button_hover,
  )
}

///|
fn draw_sim_hud(game : @types.Game) -> Unit {
  // Top bar
  @raylib.draw_rectangle(0, 0, @types.screen_width, 55, @types.color_hud_bg)
  let season = @types.season_from_index(game.sim_season)
  @draw.draw_text(
    "Simulating: " + @types.season_name(season),
    15,
    5,
    24,
    @types.season_color(season),
  )
  @draw.draw_text(
    "Step: " + game.sim_step.to_string(),
    300,
    10,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Value: $" + game.total_value.to_string(),
    500,
    10,
    22,
    @types.color_wheat,
  )
  @draw.draw_text(
    "Season: $" + game.season_value.to_string(),
    700,
    10,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    @levels.level_name(game.level_index),
    15,
    33,
    14,
    @types.color_hud_text,
  )
}

///|
fn draw_hover_info(game : @types.Game) -> Unit {
  let col = game.hover_col
  let row = game.hover_row
  if !@types.in_bounds(col, row) {
    return
  }
  let goal = @levels.load_level(game.level_index)
  if is_locked(col, row, goal.locked_plots) {
    return
  }
  let plot = game.grid[row][col]
  // Info panel at bottom
  let info_y = @types.grid_offset_y + @types.grid_rows * @types.cell_size + 15
  @raylib.draw_rectangle(
    @types.grid_offset_x,
    info_y,
    @types.grid_cols * @types.cell_size,
    80,
    @types.color_panel_bg,
  )
  @raylib.draw_rectangle_lines(
    @types.grid_offset_x,
    info_y,
    @types.grid_cols * @types.cell_size,
    80,
    @types.color_grid_line,
  )
  // Plot info
  let pos_str = "Plot (" +
    col.to_string() +
    "," +
    row.to_string() +
    ")"
  @draw.draw_text(pos_str, @types.grid_offset_x + 10, info_y + 5, 14, @types.color_hud_text)
  // Soil
  let soil_str = "N:" +
    plot.soil.nitrogen.to_string() +
    " P:" +
    plot.soil.phosphorus.to_string() +
    " K:" +
    plot.soil.potassium.to_string() +
    " (Avg:" +
    @types.soil_quality(plot.soil).to_string() +
    "%)"
  @draw.draw_text(soil_str, @types.grid_offset_x + 10, info_y + 25, 14, @types.color_hud_text)
  // Selected crop cost
  let info = @types.crop_info(game.selected_crop)
  let cost_str = @types.crop_name(game.selected_crop) +
    " needs N:" +
    info.n_cost.to_string() +
    " P:" +
    info.p_cost.to_string() +
    " K:" +
    info.k_cost.to_string()
  @draw.draw_text(cost_str, @types.grid_offset_x + 10, info_y + 45, 13, @types.color_hud_text)
  // Can plant indicator
  let season = @types.season_from_index(game.planning_season)
  let can = @types.can_plant_in_season(game.selected_crop, season) &&
    @types.soil_has_nutrients(plot.soil, game.selected_crop)
  let can_str = if can { "Can plant here" } else { "Cannot plant here" }
  let can_col = if can {
    @types.color_clover
  } else {
    @raylib.Color::new(200, 80, 80, 255)
  }
  @draw.draw_text(
    can_str,
    @types.grid_offset_x + 10,
    info_y + 62,
    13,
    can_col,
  )
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 && game.message.length() > 0 {
    let msg_w = game.message.length() * 10 + 40
    let msg_x = (@types.screen_width - msg_w) / 2
    let msg_y = @types.screen_height - 60
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 230.0).to_int()
    @raylib.draw_rectangle(
      msg_x,
      msg_y,
      msg_w,
      40,
      @raylib.Color::new(50, 40, 30, a),
    )
    let text_a = (alpha * 255.0).to_int()
    @draw.draw_text(
      game.message,
      msg_x + 20,
      msg_y + 10,
      18,
      @raylib.Color::new(255, 240, 200, text_a),
    )
  }
}

///|
fn draw_controls(game : @types.Game) -> Unit {
  ignore(game)
  let y = @types.screen_height - 30
  @draw.draw_text(
    "1-8: Select Crop  Click: Place  Tab: Season  Space: Simulate  R: Reset  ESC: Back",
    80,
    y,
    14,
    @types.color_dark_text,
  )
}
