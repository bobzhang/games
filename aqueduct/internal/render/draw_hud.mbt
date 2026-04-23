///|
/// Draw the HUD panel (right side).
pub fn draw_hud(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let panel_x = 700
  let panel_y = 80
  // Level name and tier
  @draw.draw_text(level.name, panel_x, panel_y, 28, @types.color_hud_text)
  @draw.draw_text(
    @types.tier_name(level.tier),
    panel_x,
    panel_y + 35,
    18,
    @types.tier_color(level.tier),
  )
  // Segments placed / par
  let segments = @types.count_segments(game)
  let seg_text = "Segments: \{segments} / \{level.par_segments}"
  let seg_color = if segments <= level.par_segments {
    @types.color_hud_text
  } else {
    @raylib.Color::new(255, 150, 50, 255)
  }
  @draw.draw_text(seg_text, panel_x, panel_y + 75, 20, seg_color)
  // Fountains status
  let fount_text = "Fountains: \{game.fountains_filled} / \{game.total_fountains}"
  @draw.draw_text(fount_text, panel_x, panel_y + 105, 20, @types.color_hud_text)
  // Tool selection
  draw_tool_panel(game, panel_x, panel_y + 155)
  // Controls help
  draw_controls(panel_x, panel_y + 340)
}

///|
fn draw_tool_panel(game : @types.Game, px : Int, py : Int) -> Unit {
  @draw.draw_text("Tools:", px, py, 20, @types.color_hud_text)
  let tools : Array[(@types.TileKind, String)] = [
    (Aqueduct, "Aqueduct"),
    (Reservoir, "Reservoir"),
    (Dam, "Dam"),
  ]
  for i, entry in tools {
    let kind = entry.0
    let label = entry.1
    let ty = py + 30 + i * 35
    let selected = game.selected_tool == kind
    let color = if selected {
      @types.color_selected
    } else {
      @types.color_hud_dim
    }
    if selected {
      @raylib.draw_rectangle(
        px - 4,
        ty - 2,
        220,
        32,
        @raylib.Color::new(60, 80, 120, 180),
      )
    }
    match tool_art(kind) {
      Some(texture) =>
        draw_art_fit(
          texture,
          Float::from_int(px + 16),
          Float::from_int(ty + 14),
          26.0,
          26.0,
          0.0,
          @raylib.white,
        )
      None => @raylib.draw_rectangle(px, ty + 4, 20, 20, @types.color_aqueduct)
    }
    @draw.draw_text("[\{i + 1}] \{label}", px + 36, ty + 2, 18, color)
  }
}

///|
fn draw_controls(px : Int, py : Int) -> Unit {
  let controls = [
    "Click: Place/Remove", "1/2/3: Select tool", "Space: Run water", "R: Reset water",
    "U: Undo", "C: Clear all", "Esc: Back",
  ]
  @draw.draw_text("Controls:", px, py, 18, @types.color_hud_text)
  for i, text in controls {
    @draw.draw_text(text, px, py + 24 + i * 22, 16, @types.color_hud_dim)
  }
}

///|
/// Draw star rating.
pub fn draw_stars(x : Int, y : Int, count : Int, max_count : Int) -> Unit {
  for i in 0..<max_count {
    let sx = x + i * 30
    let color = if i < count {
      @types.color_star_on
    } else {
      @types.color_star_off
    }
    @draw.draw_text("*", sx, y, 28, color)
  }
}

///|
/// Draw floating message.
pub fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let alpha = if game.message_timer < 0.5 {
      (game.message_timer * 510.0).to_int()
    } else {
      255
    }
    let a = if alpha > 255 { 255 } else if alpha < 0 { 0 } else { alpha }
    let color = @raylib.Color::new(255, 255, 200, a)
    let tw = @draw.measure_text(game.message, 24)
    let mx = (@types.screen_width - tw) / 2
    @draw.draw_text(game.message, mx, @types.screen_height - 60, 24, color)
  }
}

///|
/// Draw the play state indicator.
pub fn draw_play_state(game : @types.Game) -> Unit {
  let state_text = match game.play_state {
    Placing => "PLACING"
    Simulating => "SIMULATING..."
    Complete => "COMPLETE!"
    Failed => "NOT ALL FOUNTAINS REACHED"
  }
  let color = match game.play_state {
    Placing => @types.color_hud_dim
    Simulating => @types.color_water_flow
    Complete => @types.color_fountain_filled
    Failed => @raylib.Color::new(255, 100, 80, 255)
  }
  @draw.draw_text(state_text, 700, 50, 20, color)
}
