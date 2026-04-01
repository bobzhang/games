///|
/// Draw the HUD (turn counter, yield, etc.)
fn draw_hud(game : @types.Game) -> Unit {
  let panel_x = 720
  let panel_y = 10
  let panel_w = 550
  let panel_h = 60
  // Background panel
  @raylib.draw_rectangle(
    panel_x, panel_y, panel_w, panel_h, @types.color_hud_bg,
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(120, 110, 90, 200),
  )
  // Level name
  @draw.draw_text(
    game.level.name,
    panel_x + 10,
    panel_y + 5,
    16,
    @types.color_hud_text,
  )
  // Turn counter
  let turn_text = "Turn: " +
    game.turn.to_string() +
    "/" +
    game.level.turn_budget.to_string()
  @draw.draw_text(
    turn_text,
    panel_x + 10,
    panel_y + 28,
    18,
    @types.color_hud_text,
  )
  // Yield display
  let yield_text = "Yield: " +
    game.yield_collected.to_string() +
    "/" +
    game.level.target_yield.to_string()
  @draw.draw_text(
    yield_text,
    panel_x + 200,
    panel_y + 28,
    18,
    @types.color_hud_text,
  )
  // Yield progress bar
  let bar_x = panel_x + 200
  let bar_y = panel_y + 50
  let bar_w = 160
  let bar_h = 8
  let progress = if game.level.target_yield > 0 {
    @types.clampf(
      Float::from_int(game.yield_collected) /
      Float::from_int(game.level.target_yield),
      0.0,
      1.0,
    )
  } else {
    0.0
  }
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(40, 40, 30, 200),
  )
  let fill_w = (Float::from_int(bar_w) * progress).to_int()
  let bar_color = if game.yield_collected >= game.level.target_yield {
    @types.color_star_gold
  } else {
    @raylib.Color::new(120, 180, 80, 255)
  }
  @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, bar_color)
  // Goals
  if game.level.goals.length() > 0 {
    let goals_text = "Goals: " +
      game.goals_collected.to_string() +
      "/" +
      game.level.goals.length().to_string()
    @draw.draw_text(
      goals_text,
      panel_x + 390,
      panel_y + 28,
      18,
      @types.color_goal,
    )
  }
  // World indicator
  let world_text = @types.world_name(game.world_index) +
    " " +
    (game.level_index % @types.levels_per_world + 1).to_string()
  @draw.draw_text(
    world_text,
    panel_x + 390,
    panel_y + 5,
    16,
    @raylib.Color::new(180, 170, 150, 255),
  )
}

///|
/// Draw crop palette for selection
fn draw_crop_palette(game : @types.Game) -> Unit {
  let palette_x = 720
  let palette_y = 80
  let item_w = 120
  let item_h = 55
  let crops : Array[@types.CropKind] = [Wheat, Corn, Berry, Flower]
  // Title
  @draw.draw_text(
    "Crops (1-4):", palette_x, palette_y, 16, @types.color_dark_text,
  )
  for i in 0..<crops.length() {
    let kind = crops[i]
    let x = palette_x + i * (item_w + 8)
    let y = palette_y + 22
    let is_selected = match game.place_mode {
      CropPlace(k) => k == kind
      ChannelPlace => false
    }
    // Background
    let bg = if is_selected {
      @raylib.Color::new(200, 190, 160, 240)
    } else {
      @raylib.Color::new(160, 150, 130, 180)
    }
    @raylib.draw_rectangle(x, y, item_w, item_h, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(x, y, item_w, item_h, @types.color_white)
    }
    // Crop name
    let name = @types.crop_name(kind)
    @draw.draw_text(name, x + 5, y + 3, 14, @types.crop_color(kind))
    // Key indicator
    let key_str = (i + 1).to_string()
    @draw.draw_text(
      key_str,
      x + item_w - 18,
      y + 3,
      12,
      @raylib.Color::new(100, 90, 70, 200),
    )
    // Info line
    let info = "Y:" +
      @types.crop_base_yield(kind).to_string() +
      " T:" +
      @types.crop_grow_time(kind).to_string()
    @draw.draw_text(info, x + 5, y + 20, 12, @types.color_dark_text)
    // Small color swatch
    @raylib.draw_circle(
      x + item_w - 15,
      y + item_h - 15,
      8.0,
      @types.crop_color(kind),
    )
  }
  // Channel option
  let ch_x = palette_x
  let ch_y = palette_y + 82
  let is_channel = game.place_mode == ChannelPlace
  let ch_bg = if is_channel {
    @raylib.Color::new(160, 190, 220, 240)
  } else {
    @raylib.Color::new(140, 150, 170, 180)
  }
  @raylib.draw_rectangle(ch_x, ch_y, 140, 28, ch_bg)
  if is_channel {
    @raylib.draw_rectangle_lines(ch_x, ch_y, 140, 28, @types.color_white)
  }
  @draw.draw_text("5: Channel", ch_x + 5, ch_y + 5, 16, @types.color_channel)
}

///|
/// Draw controls help at bottom
fn draw_controls_help(game : @types.Game) -> Unit {
  ignore(game)
  let y = @types.screen_height - 35
  @raylib.draw_rectangle(
    0,
    y - 5,
    @types.screen_width,
    40,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @draw.draw_text(
    "L-Click: Place | R-Click: Remove | 1-4: Crop | 5: Channel | Enter: End Turn | U: Undo | R: Restart",
    10,
    y,
    14,
    @raylib.Color::new(200, 190, 170, 200),
  )
}
