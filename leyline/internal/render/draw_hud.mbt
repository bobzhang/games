///|
pub fn draw_toolbar(game : @types.Game) -> Unit {
  // Toolbar background
  @raylib.draw_rectangle(0, 0, @types.screen_width, 55, hud_bg_color)
  // Tool buttons
  let tools : Array[(@types.Tool, String, String)] = [
    (PlaceWaystone, "1:Place", "Place waystone"),
    (RemoveWaystone, "2:Remove", "Remove waystone"),
    (DrawLine, "3:Connect", "Draw ley line"),
    (EraseLine, "4:Erase", "Erase ley line"),
  ]
  for i in 0..<tools.length() {
    let (tool, label, _desc) = tools[i]
    let x = 20 + i * 140
    let is_active = game.tool == tool
    let color = if is_active { tool_active_color } else { tool_inactive_color }
    @raylib.draw_rectangle_lines(x, 8, 130, 36, color)
    if is_active {
      @raylib.draw_rectangle(x + 1, 9, 128, 34, @raylib.Color::new(80, 255, 180, 30))
    }
    @draw.draw_text(label, x + 8, 16, 18, color)
  }
  // Level name
  guard game.level_def is Some(def) else { return }
  let name = "Level \{game.current_level + 1}: \{def.name}"
  let tw = @draw.measure_text(name, 18)
  @draw.draw_text(name, @types.screen_width - tw - 20, 18, 18, text_color)
}

///|
pub fn draw_hud(game : @types.Game, state : @types.LevelState) -> Unit {
  let y = @types.hud_y
  @raylib.draw_rectangle(0, y, @types.screen_width, 60, hud_bg_color)
  // Waystones remaining
  let remaining = state.waystone_budget - state.waystones_placed
  let ws_text = "Waystones: \{remaining}/\{state.waystone_budget}"
  @draw.draw_text(ws_text, 20, y + 8, 18, text_color)
  // Energy delivered
  let energy_text = "Energy: \{state.total_energy_delivered.to_int()}"
  @draw.draw_text(energy_text, 250, y + 8, 18, energy_text_color)
  // Connections count
  let conn_text = "Lines: \{state.connections.length()}"
  @draw.draw_text(conn_text, 450, y + 8, 18, text_color)
  // Temple status
  let status = if state.all_temples_powered {
    "All Temples Powered!"
  } else {
    "Temples need energy"
  }
  let status_color = if state.all_temples_powered {
    temple_powered_color
  } else {
    text_dim_color
  }
  @draw.draw_text(status, 600, y + 8, 18, status_color)
  // Controls hint
  @draw.draw_text("[R]eset  [ESC]Back", 20, y + 35, 14, text_dim_color)
  // Message
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 18)
    @draw.draw_text(
      game.message,
      (@types.screen_width - mw) / 2,
      y + 35,
      18,
      @raylib.Color::new(255, 200, 100, 255),
    )
  }
}
