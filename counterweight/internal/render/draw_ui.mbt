///|
fn draw_playing_ui(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Top bar
  @raylib.draw_rectangle(0, 0, w, 50, @types.color_hud_bg)
  // Level name
  let name = @levels.get_level_name(game.current_level)
  let level_text = "Level " + (game.current_level + 1).to_string() + ": " + name
  @draw.draw_text(level_text, 20, 12, 22, @types.color_title_text)
  // Connection counter
  let conn_text = "Ropes: " +
    game.connections_used.to_string() +
    " (par: " +
    game.par_connections.to_string() +
    ")"
  let ctw = @draw.measure_text(conn_text, 18)
  @draw.draw_text(conn_text, w - ctw - 20, 6, 18, @types.color_hud_text)
  // Rehook counter
  let rehook_text = "Rehooks: " + game.rehooks.to_string()
  let rtw = @draw.measure_text(rehook_text, 16)
  @draw.draw_text(rehook_text, w - rtw - 20, 28, 16, @types.color_hud_text)
  // Target status
  draw_target_status(game)
  // State indicator
  match game.play_state {
    ConnectingRope(_) => {
      let hint = "Click target node to connect (Right-click to cancel)"
      let hw = @draw.measure_text(hint, 16)
      @draw.draw_text(
        hint,
        (w - hw) / 2,
        @types.screen_height - 30,
        16,
        @types.color_connect_line,
      )
    }
    Won => {
      let txt = "Level Complete! Click or ENTER for results"
      let tw = @draw.measure_text(txt, 24)
      @draw.draw_text(
        txt,
        (w - tw) / 2,
        @types.screen_height - 60,
        24,
        @types.color_success,
      )
    }
    Failed => {
      let txt = "Click to retry"
      let tw = @draw.measure_text(txt, 22)
      @draw.draw_text(
        txt,
        (w - tw) / 2,
        @types.screen_height - 50,
        22,
        @raylib.Color::new(255, 100, 80, 255),
      )
    }
    Settling => {
      let txt = "Settling..."
      let tw = @draw.measure_text(txt, 18)
      @draw.draw_text(
        txt,
        (w - tw) / 2,
        @types.screen_height - 30,
        18,
        @types.color_hud_text,
      )
    }
    Idle => {
      let hint = "Click a node to start connecting. Right-click to remove rope. R to reset. ESC for menu."
      let hw = @draw.measure_text(hint, 14)
      @draw.draw_text(
        hint,
        (w - hw) / 2,
        @types.screen_height - 25,
        14,
        @raylib.Color::new(160, 145, 120, 200),
      )
    }
  }
  // Message overlay
  if game.message_timer > 0.0 {
    let msgw = @draw.measure_text(game.message, 22)
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 255.0).to_int()
    @draw.draw_text(
      game.message,
      (w - msgw) / 2,
      80,
      22,
      @raylib.Color::new(255, 220, 100, a),
    )
  }
}

///|
fn draw_target_status(game : @types.Game) -> Unit {
  // Show target status on right side
  let x = @types.screen_width - 200
  let mut y = 55
  @draw.draw_text("Targets:", x, y, 16, @types.color_hud_text)
  y = y + 22
  for i in 0..<game.targets.length() {
    let t = game.targets[i]
    if t.crate_index >= 0 && t.crate_index < game.crates.length() {
      let c = game.crates[t.crate_index]
      let status = if c.at_target { "[OK]" } else { "[..] " }
      let color = if c.at_target {
        @types.color_success
      } else {
        @types.color_hud_text
      }
      let text = status + " Crate " + (i + 1).to_string()
      @draw.draw_text(text, x, y, 14, color)
      y = y + 18
    }
  }
}
