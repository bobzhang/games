///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Animated background hexagons
  for i in 0..<30 {
    let fi = Float::from_int(i)
    let sx = ((fi * 97.3 + time * 15.0) % Float::from_int(w)).to_int()
    let sy = ((fi * 63.7 + time * 8.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)).to_int()
    let brightness = 35 + (fi * 11.0 % 30.0).to_int()
    let hex_r : Float = 8.0 + fi % 5.0 * 4.0
    @raylib.draw_poly(
      @raylib.Vector2::new(Float::from_int(sx), Float::from_int(sy)),
      6,
      hex_r,
      30.0,
      @raylib.Color::new(brightness, brightness, brightness + 15, 80),
    )
  }
  // Title
  let title = "LATTICE"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(
      @types.color_title.r.to_int(),
      @types.color_title.g.to_int(),
      @types.color_title.b.to_int(),
      alpha,
    ),
  )
  // Subtitle
  let sub = "HEX PATTERN STRATEGY"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 60, 20, @types.color_hud_text)
  // Decorative hex pattern
  let center_x = w / 2
  let center_y = h / 2 + 30
  for i in 0..<6 {
    let angle = Float::from_int(i) * @types.pi() / 3.0 + time * 0.5
    let dist : Float = 60.0
    let hx = Float::from_int(center_x) + @types.cosf(angle) * dist
    let hy = Float::from_int(center_y) + @types.sinf(angle) * dist
    @raylib.draw_poly(
      @raylib.Vector2::new(hx, hy),
      6,
      18.0,
      30.0,
      @raylib.Color::new(80, 160, 220, 100),
    )
  }
  @raylib.draw_poly(
    @raylib.Vector2::new(Float::from_int(center_x), Float::from_int(center_y)),
    6,
    18.0,
    30.0,
    @raylib.Color::new(100, 200, 255, 120),
  )
  // Start prompt
  let start = "Press ENTER or SPACE to start"
  let start_w = @draw.measure_text(start, 22)
  let blink = ((@types.sinf(time * 3.0) + 1.0) / 2.0 * 255.0).to_int()
  @draw.draw_text(
    start,
    (w - start_w) / 2,
    h - 120,
    22,
    @raylib.Color::new(200, 210, 230, blink),
  )
  // Version
  @draw.draw_text(
    "v1.0",
    w - 60,
    h - 30,
    14,
    @raylib.Color::new(100, 110, 130, 150),
  )
}

///|
fn draw_mode_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "SELECT MODE"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - title_w) / 2, 100, 40, @types.color_title)
  let modes = ["vs AI", "Puzzle Mode", "Local 2 Player"]
  let descs = [
    "Play against the computer", "Solve board puzzles for points", "Two players, same device",
  ]
  for i in 0..<modes.length() {
    let y = 220 + i * 120
    let is_selected = game.menu_selection == i
    let btn_color = if is_selected {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    let text_color = if is_selected {
      @types.color_accent
    } else {
      @types.color_hud_text
    }
    let bx = w / 2 - 200
    @raylib.draw_rectangle(bx, y, 400, 80, btn_color)
    if is_selected {
      @raylib.draw_rectangle_lines(bx, y, 400, 80, @types.color_accent)
    }
    let mode_w = @draw.measure_text(modes[i], 28)
    @draw.draw_text(modes[i], (w - mode_w) / 2, y + 12, 28, text_color)
    let desc_w = @draw.measure_text(descs[i], 16)
    @draw.draw_text(
      descs[i],
      (w - desc_w) / 2,
      y + 48,
      16,
      @raylib.Color::new(150, 160, 180, 200),
    )
  }
  @draw.draw_text(
    "[UP/DOWN] Select  [ENTER] Confirm  [ESC] Back",
    w / 2 - 200,
    h - 60,
    16,
    @raylib.Color::new(120, 130, 150, 200),
  )
}

///|
fn draw_difficulty_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "SELECT DIFFICULTY"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - title_w) / 2, 100, 40, @types.color_title)
  let diffs = ["Easy", "Normal", "Hard"]
  let descs = [
    "Random moves - learn the game", "Evaluates immediate score", "Looks ahead 2 turns (minimax)",
  ]
  for i in 0..<diffs.length() {
    let y = 220 + i * 120
    let is_selected = game.menu_selection == i
    let btn_color = if is_selected {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    let text_color = if is_selected {
      @types.color_accent
    } else {
      @types.color_hud_text
    }
    let bx = w / 2 - 200
    @raylib.draw_rectangle(bx, y, 400, 80, btn_color)
    if is_selected {
      @raylib.draw_rectangle_lines(bx, y, 400, 80, @types.color_accent)
    }
    let diff_w = @draw.measure_text(diffs[i], 28)
    @draw.draw_text(diffs[i], (w - diff_w) / 2, y + 12, 28, text_color)
    let desc_w = @draw.measure_text(descs[i], 16)
    @draw.draw_text(
      descs[i],
      (w - desc_w) / 2,
      y + 48,
      16,
      @raylib.Color::new(150, 160, 180, 200),
    )
  }
  @draw.draw_text(
    "[UP/DOWN] Select  [ENTER] Confirm  [ESC] Back",
    w / 2 - 200,
    h - 60,
    16,
    @raylib.Color::new(120, 130, 150, 200),
  )
}

///|
fn draw_puzzle_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "SELECT PUZZLE"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - title_w) / 2, 60, 40, @types.color_title)
  // Draw puzzle grid (4x5)
  let cols = 5
  let cell_w = 180
  let cell_h = 90
  let start_x = (w - cols * cell_w) / 2
  let start_y = 130
  let total = game.puzzle_levels.length()
  for i in 0..<total {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * cell_w
    let y = start_y + row * cell_h
    let is_selected = game.menu_selection == i
    let btn_color = if is_selected {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(x + 4, y + 4, cell_w - 8, cell_h - 8, btn_color)
    if is_selected {
      @raylib.draw_rectangle_lines(
        x + 4,
        y + 4,
        cell_w - 8,
        cell_h - 8,
        @types.color_accent,
      )
    }
    let num = (i + 1).to_string()
    let num_w = @draw.measure_text(num, 28)
    @draw.draw_text(
      num,
      x + (cell_w - num_w) / 2,
      y + 14,
      28,
      if is_selected {
        @types.color_accent
      } else {
        @types.color_hud_text
      },
    )
    if i < game.puzzle_levels.length() {
      let puzzle = game.puzzle_levels[i]
      let target = "Target: " + puzzle.target_score.to_string()
      let tw = @draw.measure_text(target, 14)
      @draw.draw_text(
        target,
        x + (cell_w - tw) / 2,
        y + 52,
        14,
        @raylib.Color::new(150, 160, 180, 200),
      )
    }
  }
  @draw.draw_text(
    "[Arrow Keys] Select  [ENTER] Play  [ESC] Back",
    w / 2 - 200,
    h - 50,
    16,
    @raylib.Color::new(120, 130, 150, 200),
  )
  ignore(h)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 160))
  // Results panel
  let panel_w = 500
  let panel_h = 400
  let px = (w - panel_w) / 2
  let py = (h - panel_h) / 2
  @raylib.draw_rectangle(px, py, panel_w, panel_h, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, panel_w, panel_h, @types.color_accent)
  // Title
  let title = "GAME OVER"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - title_w) / 2, py + 20, 40, @types.color_accent)
  // Winner
  let winner_text = game.result_message
  let ww = @draw.measure_text(winner_text, 28)
  @draw.draw_text(winner_text, (w - ww) / 2, py + 80, 28, @types.color_title)
  // Scores
  @draw.draw_text(
    "Black: " + game.black_score.to_string() + " points",
    px + 60,
    py + 140,
    22,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "  Captures: " + game.black_captures.to_string(),
    px + 60,
    py + 170,
    18,
    @raylib.Color::new(160, 170, 190, 200),
  )
  @draw.draw_text(
    "White: " + game.white_score.to_string() + " points",
    px + 60,
    py + 210,
    22,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "  Captures: " + game.white_captures.to_string(),
    px + 60,
    py + 240,
    18,
    @raylib.Color::new(160, 170, 190, 200),
  )
  // Controls
  @draw.draw_text(
    "[ENTER] Play Again  [ESC] Menu",
    px + 80,
    py + panel_h - 60,
    20,
    @types.color_hud_text,
  )
}
