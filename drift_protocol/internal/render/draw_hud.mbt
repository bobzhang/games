///|
/// Draw the HUD overlay during gameplay
pub fn draw_hud(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  // Right panel background
  let panel_x = @types.grid_offset_x + @types.grid_width * @types.tile_size + 10
  let panel_w = sw - panel_x - 10
  @raylib.draw_rectangle(panel_x, 30, panel_w, 660, @types.color_hud_bg)
  @raylib.draw_rectangle_lines(panel_x, 30, panel_w, 660, @types.color_cyan)
  // Level name
  let name_x = panel_x + 10
  @draw.draw_text(game.level.name, name_x, 40, 16, @types.color_cyan)
  // Tier indicator
  let tier_text = match game.level.tier {
    Corporate => "CORPORATE"
    Military => "MILITARY"
  }
  let tier_color = match game.level.tier {
    Corporate => @types.color_neon_green
    Military => @types.color_neon_pink
  }
  @draw.draw_text(tier_text, name_x, 60, 12, tier_color)
  // Time
  let minutes = (game.time_played / 60.0).to_int()
  let seconds = (game.time_played % 60.0).to_int()
  let time_str = "\{minutes}:\{pad_zero(seconds)}"
  @draw.draw_text("TIME", name_x, 90, 12, @types.color_dim_text)
  @draw.draw_text(time_str, name_x, 105, 18, @types.color_hud_text)
  // Par time
  let par_min = (game.level.par_time / 60.0).to_int()
  let par_sec = (game.level.par_time % 60.0).to_int()
  @draw.draw_text(
    "PAR: \{par_min}:\{pad_zero(par_sec)}",
    name_x,
    128,
    12,
    @types.color_dim_text,
  )
  // Alert status
  draw_alert_status(game, name_x, 155)
  // Detection meter
  draw_detection_bar(game, name_x, 210)
  // Stealth status
  draw_stealth_status(game, name_x, 250)
  // Terminals
  draw_terminal_count(game, name_x, 310)
  // Coins
  @draw.draw_text("COINS", name_x, 360, 12, @types.color_dim_text)
  @draw.draw_text(
    game.player.coins.to_string(),
    name_x,
    375,
    18,
    @types.color_coin,
  )
  // Controls hint
  draw_controls_hint(panel_x, panel_w)
  // Minimap
  draw_minimap(game, panel_x + 10, 480)
  // Message overlay
  draw_message(game)
}

///|
fn pad_zero(n : Int) -> String {
  if n < 10 {
    "0\{n}"
  } else {
    n.to_string()
  }
}

///|
fn draw_alert_status(game : @types.Game, x : Int, y : Int) -> Unit {
  @draw.draw_text("ALERT STATUS", x, y, 12, @types.color_dim_text)
  let mut any_alert = false
  let mut any_suspicious = false
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active {
      match g.alert_state {
        Alert => any_alert = true
        Suspicious => any_suspicious = true
        _ => ()
      }
    }
  }
  if any_alert {
    @draw.draw_text("ALERT!", x, y + 16, 20, @types.color_guard_alert)
  } else if any_suspicious {
    @draw.draw_text("SUSPICIOUS", x, y + 16, 18, @types.color_guard_suspicious)
  } else {
    @draw.draw_text("Clear", x, y + 16, 16, @types.color_guard_patrol)
  }
}

///|
fn draw_detection_bar(game : @types.Game, x : Int, y : Int) -> Unit {
  @draw.draw_text("DETECTION", x, y, 12, @types.color_dim_text)
  let bar_w = 150
  let bar_h = 10
  // Background
  @raylib.draw_rectangle(
    x,
    y + 16,
    bar_w,
    bar_h,
    @raylib.Color::new(30, 30, 50, 255),
  )
  // Find max detection
  let mut max_det : Float = 0.0
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active && g.detection_meter > max_det {
      max_det = g.detection_meter
    }
  }
  let fill_w = (Float::from_int(bar_w) * max_det).to_int()
  let fill_color = if max_det > 0.7 {
    @types.color_guard_alert
  } else if max_det > 0.3 {
    @types.color_guard_suspicious
  } else {
    @types.color_guard_patrol
  }
  @raylib.draw_rectangle(x, y + 16, fill_w, bar_h, fill_color)
  @raylib.draw_rectangle_lines(
    x,
    y + 16,
    bar_w,
    bar_h,
    @raylib.Color::new(80, 80, 120, 255),
  )
}

///|
fn draw_stealth_status(game : @types.Game, x : Int, y : Int) -> Unit {
  @draw.draw_text("STEALTH", x, y, 12, @types.color_dim_text)
  if game.player.in_shadow {
    @draw.draw_text("IN SHADOW", x, y + 16, 16, @types.color_neon_green)
  } else {
    @draw.draw_text("EXPOSED", x, y + 16, 16, @types.color_guard_suspicious)
  }
  // Ghost status
  if game.player.detected_count == 0 {
    @draw.draw_text("GHOST", x, y + 36, 14, @types.color_grade_s)
  } else {
    @draw.draw_text(
      "Detected: \{game.player.detected_count}x",
      x,
      y + 36,
      12,
      @types.color_dim_text,
    )
  }
}

///|
fn draw_terminal_count(game : @types.Game, x : Int, y : Int) -> Unit {
  @draw.draw_text("TERMINALS", x, y, 12, @types.color_dim_text)
  let total = game.level.terminals.length()
  let hacked = game.player.hacked_terminals
  let color = if hacked == total {
    @types.color_neon_green
  } else {
    @types.color_terminal
  }
  @draw.draw_text("\{hacked}/\{total}", x, y + 16, 18, color)
}

///|
fn draw_controls_hint(panel_x : Int, panel_w : Int) -> Unit {
  let x = panel_x + 10
  let y = 420
  @draw.draw_text("CONTROLS", x, y, 10, @types.color_dim_text)
  @draw.draw_text(
    "WASD Move",
    x,
    y + 14,
    10,
    @raylib.Color::new(100, 110, 130, 255),
  )
  @draw.draw_text(
    "SHIFT Run",
    x + panel_w / 2 - 10,
    y + 14,
    10,
    @raylib.Color::new(100, 110, 130, 255),
  )
  @draw.draw_text(
    "E Interact",
    x,
    y + 26,
    10,
    @raylib.Color::new(100, 110, 130, 255),
  )
  @draw.draw_text(
    "Q Coin",
    x + panel_w / 2 - 10,
    y + 26,
    10,
    @raylib.Color::new(100, 110, 130, 255),
  )
  @draw.draw_text(
    "ESC Pause",
    x,
    y + 38,
    10,
    @raylib.Color::new(100, 110, 130, 255),
  )
}

///|
fn draw_minimap(game : @types.Game, x : Int, y : Int) -> Unit {
  let scale = 4
  let w = @types.grid_width * scale
  let h = @types.grid_height * scale
  // Background
  @raylib.draw_rectangle(x - 2, y - 2, w + 4, h + 4, @types.color_minimap_bg)
  @raylib.draw_rectangle_lines(
    x - 2,
    y - 2,
    w + 4,
    h + 4,
    @raylib.Color::new(60, 80, 100, 255),
  )
  // Tiles
  for ty in 0..<@types.grid_height {
    for tx in 0..<@types.grid_width {
      let px = x + tx * scale
      let py = y + ty * scale
      let color = match game.level.tiles[ty][tx] {
        Wall => @raylib.Color::new(80, 80, 100, 255)
        Shadow => @raylib.Color::new(20, 20, 35, 255)
        Exit => @raylib.Color::new(0, 200, 255, 255)
        Terminal | HighTerminal => @raylib.Color::new(0, 200, 80, 255)
        Door => @raylib.Color::new(150, 80, 40, 255)
        LaserGrid => @raylib.Color::new(200, 30, 30, 255)
        PowerNode => @raylib.Color::new(200, 130, 0, 255)
        _ => @raylib.Color::new(25, 25, 40, 255)
      }
      @raylib.draw_rectangle(px, py, scale, scale, color)
    }
  }
  // Guards
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active {
      let px = x + g.gx * scale
      let py = y + g.gy * scale
      let color = @types.guard_color(g.alert_state)
      @raylib.draw_rectangle(px, py, scale, scale, color)
    }
  }
  // Player
  let ppx = x + game.player.gx * scale
  let ppy = y + game.player.gy * scale
  @raylib.draw_rectangle(ppx, ppy, scale, scale, @types.color_player)
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer <= 0.0 {
    return
  }
  let text = game.message
  let size = 24
  let tw = @draw.measure_text(text, size)
  let cx = @types.grid_offset_x +
    @types.grid_width * @types.tile_size / 2 -
    tw / 2
  let cy = @types.grid_offset_y +
    @types.grid_height * @types.tile_size / 2 -
    size / 2
  // Background
  @raylib.draw_rectangle(
    cx - 10,
    cy - 5,
    tw + 20,
    size + 10,
    @types.color_hud_bg,
  )
  @draw.draw_text(text, cx, cy, size, @types.color_cyan)
}
