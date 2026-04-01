///|
fn draw_playing(game : @types.Game) -> Unit {
  // Draw the hex map
  draw_map(game)
  // Draw the planned route
  draw_route(game)
  // Draw the caravan
  draw_caravan(game)
  // Draw HUD
  draw_hud(game)
  // Draw tile tooltip on hover
  draw_tooltip(game)
  // Draw message
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 24)
    let msg_x = @types.screen_width / 2 - msg_w / 2
    let msg_y = @types.screen_height / 2
    @raylib.draw_rectangle(
      msg_x - 10,
      msg_y - 5,
      msg_w + 20,
      34,
      @types.color_hud_bg,
    )
    @draw.draw_text(game.message, msg_x, msg_y, 24, @types.color_warning)
  }
  // Controls help
  @draw.draw_text(
    "Click: Add/Remove hex  |  Space: Execute  |  R: Reset  |  Esc: Back",
    10,
    @types.screen_height - 28,
    16,
    @types.color_hud_text,
  )
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(lv) => lv
    None => return
  }
  // Right-side HUD panel
  let panel_x = 860
  let panel_y = 60
  let panel_w = 400
  let panel_h = 600
  @raylib.draw_rectangle(
    panel_x, panel_y, panel_w, panel_h, @types.color_hud_bg,
  )
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, panel_w, panel_h, @types.color_hex_outline,
  )
  // Level name
  @draw.draw_text(
    level.name,
    panel_x + 15,
    panel_y + 10,
    26,
    @types.color_title_text,
  )
  // Tier
  @draw.draw_text(
    @types.tier_name(level.tier),
    panel_x + 15,
    panel_y + 42,
    16,
    @types.color_hud_text,
  )
  // Water bar
  let bar_x = panel_x + 15
  let bar_y = panel_y + 75
  let bar_w = panel_w - 30
  let bar_h = 24
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.color_water_bg)
  let water_frac = if game.caravan.max_water > 0 {
    fi(game.caravan.water) / fi(game.caravan.max_water)
  } else {
    0.0
  }
  let fill_w = (fi(bar_w) * @types.clampf(water_frac, 0.0, 1.0)).to_int()
  @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, @types.color_water_bar)
  @raylib.draw_rectangle_lines(
    bar_x, bar_y, bar_w, bar_h, @types.color_hex_outline,
  )
  @draw.draw_text(
    "Water: \{game.caravan.water}/\{game.caravan.max_water}",
    bar_x + 8,
    bar_y + 3,
    18,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Water preview during planning
  if game.play_state == Planning && game.route.length() > 0 {
    let cost = @world.calculate_route_water_cost(level.map, game.route)
    let remaining = game.caravan.water - cost
    let cost_text = "Route cost: \{cost} water"
    let remain_color = if remaining < 0 {
      @types.color_warning
    } else {
      @types.color_success
    }
    @draw.draw_text(cost_text, bar_x, bar_y + 30, 16, @types.color_hud_text)
    @draw.draw_text(
      "Remaining: \{remaining}",
      bar_x + 200,
      bar_y + 30,
      16,
      remain_color,
    )
  }
  // Gold
  let gold_y = bar_y + 58
  @draw.draw_text(
    "Gold: \{game.caravan.gold}",
    bar_x,
    gold_y,
    20,
    @types.color_gold_text,
  )
  if level.gold_target > 0 {
    @draw.draw_text(
      "Target: \{level.gold_target}",
      bar_x + 150,
      gold_y,
      20,
      @types.color_hud_text,
    )
  }
  // Artifacts
  let art_y = gold_y + 28
  @draw.draw_text(
    "Artifacts: \{game.caravan.artifacts}",
    bar_x,
    art_y,
    20,
    @types.color_artifact_text,
  )
  if level.total_artifacts > 0 {
    @draw.draw_text(
      "Total: \{level.total_artifacts}",
      bar_x + 150,
      art_y,
      20,
      @types.color_hud_text,
    )
  }
  // Route info
  let route_y = art_y + 40
  @draw.draw_text(
    "Route: \{game.route.length()} steps",
    bar_x,
    route_y,
    18,
    @types.color_hud_text,
  )
  // Play state
  let state_y = route_y + 28
  let state_text = match game.play_state {
    Planning => "PLANNING - Click hexes to build route"
    Executing => "EXECUTING - Caravan moving..."
    Complete => "COMPLETE - Press Enter for results"
    Failed => "FAILED - Caravan stranded! Press R to retry"
  }
  let state_color = match game.play_state {
    Planning => @types.color_hud_text
    Executing => @types.color_trade
    Complete => @types.color_success
    Failed => @types.color_warning
  }
  @draw.draw_text(state_text, bar_x, state_y, 16, state_color)
  // Tile legend
  let legend_y = state_y + 50
  @draw.draw_text(
    "-- Tile Legend --", bar_x, legend_y, 18, @types.color_title_text,
  )
  let legends : Array[(String, String, @raylib.Color)] = [
    ("Sand", "1 water", @types.color_sand),
    ("Dunes", "2 water", @types.color_dunes),
    ("Oasis", "0 water, refill", @types.color_oasis),
    ("Trade Post", "1 water, gold", @types.color_trade),
    ("Ruins", "0 water, artifact", @types.color_ruins),
    ("Sandstorm", "Impassable", @types.color_storm),
    ("Destination", "Goal!", @types.color_destination),
  ]
  for i in 0..<legends.length() {
    let (name, desc, color) = legends[i]
    let ly = legend_y + 26 + i * 22
    @raylib.draw_rectangle(bar_x, ly + 2, 14, 14, color)
    @draw.draw_text(name, bar_x + 20, ly, 16, @types.color_hud_text)
    @draw.draw_text(desc, bar_x + 160, ly, 16, @types.color_hud_text)
  }
  // Star targets
  let star_y = legend_y + 26 + 7 * 22 + 10
  @draw.draw_text(
    "-- Star Targets --", bar_x, star_y, 18, @types.color_title_text,
  )
  @draw.draw_text(
    "1 star: Reach destination",
    bar_x,
    star_y + 24,
    14,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "2 stars: + Meet gold target",
    bar_x,
    star_y + 42,
    14,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "3 stars: + Collect all artifacts",
    bar_x,
    star_y + 60,
    14,
    @types.color_hud_text,
  )
}

///|
fn draw_tooltip(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(lv) => lv
    None => return
  }
  match game.hover_hex {
    Some(hh) =>
      if @types.hex_in_bounds(hh, level.map.width, level.map.height) {
        let tile = level.map.tiles[hh.row][hh.col]
        let name = @types.tile_name(tile.kind)
        let cost = @types.water_cost(tile.kind)
        let text = "\{name} (water: \{cost})"
        let mouse = @raylib.get_mouse_position()
        let mx = mouse.x.to_int()
        let my = mouse.y.to_int()
        let tw = @draw.measure_text(text, 16)
        @raylib.draw_rectangle(
          mx + 15,
          my - 25,
          tw + 10,
          22,
          @types.color_hud_bg,
        )
        @draw.draw_text(text, mx + 20, my - 23, 16, @types.color_hud_text)
      }
    None => ()
  }
}
