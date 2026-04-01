///|
fn draw_ui(game : @types.Game) -> Unit {
  // Side panel
  let px = 20
  let py = 60
  let pw = 290
  let ph = 600
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @raylib.Color::new(60, 100, 160, 200))
  // Level info
  let level_num = game.current_level + 1
  let tier = @types.tier_for_level(game.current_level)
  let tier_name = @types.tier_name(tier)
  @draw.draw_text(tier_name, px + 15, py + 15, 22, @types.color_title_accent)
  @draw.draw_text(
    "Level " + level_num.to_string(),
    px + 15,
    py + 45,
    28,
    @types.color_text,
  )
  // Bridge count
  let segs = @types.total_bridge_segments(game.bridges)
  @draw.draw_text(
    "Bridges: " + segs.to_string(),
    px + 15,
    py + 95,
    20,
    @types.color_text,
  )
  @draw.draw_text(
    "Par: " + game.par_bridges.to_string(),
    px + 15,
    py + 120,
    18,
    @types.color_text_dim,
  )
  // Island satisfaction
  let (satisfied, total) = @solver.satisfaction_counts(
    game.islands, game.bridges,
  )
  @draw.draw_text(
    "Islands: " + satisfied.to_string() + "/" + total.to_string(),
    px + 15,
    py + 160,
    20,
    @types.color_text,
  )
  // Progress bar for islands
  let bar_x = px + 15
  let bar_y = py + 190
  let bar_w = pw - 30
  let bar_h = 12
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @raylib.Color::new(20, 30, 50, 255))
  if total > 0 {
    let fill_w = bar_w * satisfied / total
    let bar_color = if satisfied == total {
      @types.color_island_satisfied
    } else {
      @raylib.Color::new(80, 150, 220, 255)
    }
    @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, bar_color)
  }
  @raylib.draw_rectangle_lines(bar_x, bar_y, bar_w, bar_h, @raylib.Color::new(60, 100, 160, 200))
  // Removals
  @draw.draw_text(
    "Removals: " + game.removal_count.to_string(),
    px + 15,
    py + 220,
    18,
    if game.removal_count == 0 {
      @types.color_text_dim
    } else {
      @raylib.Color::new(220, 160, 80, 255)
    },
  )
  // Connectivity
  let connected = @types.is_connected(game.islands, game.bridges)
  let conn_text = if game.bridges.length() == 0 {
    "Not connected"
  } else if connected {
    "All connected"
  } else {
    "Disconnected"
  }
  let conn_color = if connected && game.bridges.length() > 0 {
    @types.color_island_satisfied
  } else {
    @types.color_text_dim
  }
  @draw.draw_text(conn_text, px + 15, py + 250, 18, conn_color)
  // Controls
  @draw.draw_text("Controls:", px + 15, py + 310, 20, @types.color_text)
  let controls = [
    "LMB: Select/Connect", "RMB: Remove bridge", "H: Hint", "Z: Undo",
    "R: Restart", "ESC: Back",
  ]
  for i, ctrl in controls {
    @draw.draw_text(
      ctrl,
      px + 15,
      py + 340 + i * 25,
      16,
      @types.color_text_dim,
    )
  }
  // Message
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 22)
    let mx2 = (@types.screen_width - mw) / 2
    let my2 = @types.screen_height - 60
    @raylib.draw_rectangle(
      mx2 - 10,
      my2 - 5,
      mw + 20,
      32,
      @raylib.Color::new(0, 0, 0, 180),
    )
    @draw.draw_text(game.message, mx2, my2, 22, @types.color_title_accent)
  }
  // Right side panel - island status list
  draw_island_status(game)
}

///|
fn draw_island_status(game : @types.Game) -> Unit {
  let px = @types.screen_width - 270
  let py = 60
  let pw = 250
  let max_show = @types.min_int(game.islands.length(), 20)
  let ph = 40 + max_show * 28
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @raylib.Color::new(60, 100, 160, 200))
  @draw.draw_text("Island Status", px + 15, py + 10, 20, @types.color_text)
  for i in 0..<max_show {
    let isl = game.islands[i]
    let current = @types.count_bridges_for_island(game.bridges, i)
    let required = isl.required_count
    let satisfied = current == required
    let over = current > required
    let color = if over {
      @types.color_island_over
    } else if satisfied {
      @types.color_island_satisfied
    } else {
      @types.color_text_dim
    }
    let text = "#" + (i + 1).to_string() + ": " + current.to_string() + "/" + required.to_string()
    @draw.draw_text(text, px + 15, py + 38 + i * 28, 16, color)
    // Small indicator circle
    let ind_color = if satisfied {
      @types.color_island_satisfied
    } else if over {
      @types.color_island_over
    } else {
      @types.color_text_dim
    }
    @raylib.draw_circle(px + pw - 25, py + 48 + i * 28, 5.0, ind_color)
  }
}
