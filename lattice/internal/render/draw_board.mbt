///|
fn draw_hex_grid(game : @types.Game) -> Unit {
  let size = @types.hex_size
  for r in 0..<@types.board_size {
    for c in 0..<@types.board_size {
      let coord : @types.HexCoord = { row: r, col: c }
      let (px, py) = @types.hex_to_pixel(coord, size)
      let ix = px.to_int()
      let iy = py.to_int()
      // Determine fill color
      let is_hover = match game.hover_hex {
        Some(h) => @types.hex_eq(h, coord)
        None => false
      }
      let fill = if is_hover {
        @types.color_hex_hover
      } else {
        @types.color_hex_fill
      }
      // Draw hex
      draw_hexagon_filled(ix, iy, size - 1.0, fill)
      draw_hexagon_outline(ix, iy, size - 1.0, @types.color_hex_border)
      // Draw stone if occupied
      match @types.get_cell(game.board, coord) {
        Occupied(Black) => draw_stone(ix, iy, size, true)
        Occupied(White) => draw_stone(ix, iy, size, false)
        Empty => ()
      }
    }
  }
  // Draw last move indicator
  match game.last_move {
    Some(lm) => {
      let (lx, ly) = @types.hex_to_pixel(lm, size)
      @raylib.draw_circle_lines(
        lx.to_int(),
        ly.to_int(),
        size * 0.85,
        @types.color_accent,
      )
    }
    None => ()
  }
  // Draw pattern highlights
  draw_pattern_highlights(game)
  // Draw capture animations
  draw_capture_anims(game)
}

///|
fn draw_hexagon_filled(cx : Int, cy : Int, radius : Float, color : @raylib.Color) -> Unit {
  @raylib.draw_poly(
    @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy)),
    6,
    radius,
    30.0,
    color,
  )
}

///|
fn draw_hexagon_outline(
  cx : Int,
  cy : Int,
  radius : Float,
  color : @raylib.Color
) -> Unit {
  @raylib.draw_poly_lines(
    @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy)),
    6,
    radius,
    30.0,
    color,
  )
}

///|
fn draw_stone(cx : Int, cy : Int, hex_size : Float, is_black : Bool) -> Unit {
  let stone_radius = hex_size * 0.55
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  if is_black {
    // Black stone with highlight
    @raylib.draw_circle(cx, cy, stone_radius + 1.0, @types.color_black_highlight)
    @raylib.draw_circle(cx, cy, stone_radius, @types.color_black_stone)
    // Shine effect
    @raylib.draw_circle(
      (fcx - stone_radius * 0.25).to_int(),
      (fcy - stone_radius * 0.25).to_int(),
      stone_radius * 0.2,
      @raylib.Color::new(80, 80, 90, 120),
    )
  } else {
    // White stone with shadow
    @raylib.draw_circle(
      cx + 1,
      cy + 1,
      stone_radius + 1.0,
      @raylib.Color::new(100, 100, 110, 100),
    )
    @raylib.draw_circle(cx, cy, stone_radius, @types.color_white_stone)
    // Shine effect
    @raylib.draw_circle(
      (fcx - stone_radius * 0.25).to_int(),
      (fcy - stone_radius * 0.25).to_int(),
      stone_radius * 0.2,
      @raylib.Color::new(255, 255, 255, 180),
    )
  }
}

///|
fn draw_pattern_highlights(game : @types.Game) -> Unit {
  let size = @types.hex_size
  for i in 0..<game.pattern_anims.length() {
    let anim = game.pattern_anims[i]
    let alpha_f = @types.minf(anim.timer / @types.pattern_anim_time, 1.0)
    let alpha = (alpha_f * 200.0).to_int()
    let base_color = pattern_color(anim.kind)
    let color = @raylib.Color::new(
      base_color.r.to_int(),
      base_color.g.to_int(),
      base_color.b.to_int(),
      alpha,
    )
    for j in 0..<anim.positions.length() {
      let pos = anim.positions[j]
      let (px, py) = @types.hex_to_pixel(pos, size)
      @raylib.draw_circle_lines(px.to_int(), py.to_int(), size * 0.9, color)
      @raylib.draw_circle_lines(px.to_int(), py.to_int(), size * 0.8, color)
    }
  }
}

///|
fn pattern_color(kind : @types.PatternKind) -> @raylib.Color {
  match kind {
    Bridge => @types.color_bridge
    Chain => @types.color_chain
    Triangle => @types.color_triangle
    Diamond => @types.color_diamond
    Fortress => @types.color_fortress
    Ring => @types.color_ring
    Star => @types.color_star
    Wall => @types.color_wall
  }
}

///|
fn draw_capture_anims(game : @types.Game) -> Unit {
  let size = @types.hex_size
  for i in 0..<game.capture_anims.length() {
    let anim = game.capture_anims[i]
    let t = anim.timer / @types.capture_anim_time
    let scale : Float = 1.0 - t
    let alpha = ((scale) * 255.0).to_int()
    let (px, py) = @types.hex_to_pixel(anim.pos, size)
    @raylib.draw_circle(
      px.to_int(),
      py.to_int(),
      size * 0.5 * scale,
      @raylib.Color::new(255, 80, 80, alpha),
    )
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  // Draw board area background
  @raylib.draw_rectangle(20, 20, 700, 680, @types.color_board_bg)
  // Draw the hex grid
  draw_hex_grid(game)
  // Draw UI panel
  draw_game_ui(game)
}

///|
fn draw_game_ui(game : @types.Game) -> Unit {
  let panel_x = 740
  let panel_w = 520
  // Panel background
  @raylib.draw_rectangle(panel_x, 20, panel_w, 680, @types.color_panel)
  // Turn indicator
  let turn_text = match game.play_state {
    GameOver => "GAME OVER"
    AIThinking => "AI thinking..."
    _ =>
      if game.current_player == Black {
        "Black's Turn"
      } else {
        "White's Turn"
      }
  }
  @draw.draw_text(turn_text, panel_x + 20, 40, 28, @types.color_accent)
  // Draw turn indicator stone
  if game.play_state != GameOver {
    let stone_x = panel_x + 280
    let stone_y = 52
    if game.current_player == Black {
      @raylib.draw_circle(stone_x, stone_y, 12.0, @types.color_black_stone)
    } else {
      @raylib.draw_circle(stone_x, stone_y, 12.0, @types.color_white_stone)
    }
  }
  // Scores
  let score_y = 90
  @draw.draw_text("SCORES", panel_x + 20, score_y, 22, @types.color_hud_text)
  // Black score
  @raylib.draw_circle(panel_x + 30, score_y + 40, 10.0, @types.color_black_stone)
  @draw.draw_text(
    "Black: " + game.black_score.to_string(),
    panel_x + 50,
    score_y + 30,
    20,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Captures: " + game.black_captures.to_string(),
    panel_x + 200,
    score_y + 30,
    16,
    @raylib.Color::new(160, 170, 190, 200),
  )
  // White score
  @raylib.draw_circle(
    panel_x + 30,
    score_y + 70,
    10.0,
    @types.color_white_stone,
  )
  @draw.draw_text(
    "White: " + game.white_score.to_string(),
    panel_x + 50,
    score_y + 60,
    20,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Captures: " + game.white_captures.to_string(),
    panel_x + 200,
    score_y + 60,
    16,
    @raylib.Color::new(160, 170, 190, 200),
  )
  // Pattern legend
  let legend_y = 210
  @draw.draw_text(
    "PATTERNS",
    panel_x + 20,
    legend_y,
    22,
    @types.color_hud_text,
  )
  let pattern_kinds : Array[@types.PatternKind] = [
    Bridge, Chain, Triangle, Diamond, Fortress, Ring, Star, Wall,
  ]
  for i in 0..<pattern_kinds.length() {
    let kind = pattern_kinds[i]
    let y = legend_y + 35 + i * 28
    let color = pattern_color(kind)
    @raylib.draw_rectangle(panel_x + 20, y, 16, 16, color)
    let name = @types.pattern_name(kind)
    let pts = @types.pattern_points(kind)
    @draw.draw_text(
      name + " (" + pts.to_string() + " pts)",
      panel_x + 44,
      y - 2,
      18,
      @types.color_hud_text,
    )
  }
  // Mode info
  let info_y = 500
  let mode_text = match game.mode {
    VsAI => {
      let diff = match game.difficulty {
        Easy => "Easy"
        Normal => "Normal"
        Hard => "Hard"
      }
      "vs AI (" + diff + ")"
    }
    Puzzle =>
      "Puzzle " +
      (game.current_puzzle + 1).to_string() +
      "/" +
      game.puzzle_levels.length().to_string()
    Local2P => "Local 2P"
  }
  @draw.draw_text(mode_text, panel_x + 20, info_y, 18, @types.color_hud_text)
  @draw.draw_text(
    "Move: " + game.move_count.to_string(),
    panel_x + 20,
    info_y + 25,
    18,
    @types.color_hud_text,
  )
  // Puzzle specific UI
  if game.mode == Puzzle {
    let pz_y = info_y + 60
    if game.current_puzzle < game.puzzle_levels.length() {
      let puzzle = game.puzzle_levels[game.current_puzzle]
      @draw.draw_text(
        "Target: " + puzzle.target_score.to_string() + "+ points",
        panel_x + 20,
        pz_y,
        20,
        @types.color_accent,
      )
      @draw.draw_text(
        puzzle.hint,
        panel_x + 20,
        pz_y + 28,
        16,
        @types.color_hud_text,
      )
      @draw.draw_text(
        "Score this move: " + game.puzzle_score.to_string(),
        panel_x + 20,
        pz_y + 56,
        18,
        if game.puzzle_solved {
          @raylib.Color::new(100, 255, 100, 255)
        } else {
          @types.color_hud_text
        },
      )
    }
  }
  // Controls
  let ctrl_y = 640
  @draw.draw_text(
    "[ESC] Back  [R] Restart  [P] Pass",
    panel_x + 20,
    ctrl_y,
    14,
    @raylib.Color::new(120, 130, 150, 200),
  )
  if game.mode == Puzzle {
    @draw.draw_text(
      "[N] Next Puzzle",
      panel_x + 20,
      ctrl_y + 20,
      14,
      @raylib.Color::new(120, 130, 150, 200),
    )
  }
}
