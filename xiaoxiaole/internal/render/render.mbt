///|
fn clamp_channel(v : Int) -> Int {
  if v < 0 {
    0
  } else if v > 255 {
    255
  } else {
    v
  }
}

///|
fn color_with_alpha(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), clamp_channel(alpha))
}

///|
fn lighten_color(c : @raylib.Color, amount : Int) -> @raylib.Color {
  @raylib.Color::new(
    clamp_channel(c.r.to_int() + amount),
    clamp_channel(c.g.to_int() + amount),
    clamp_channel(c.b.to_int() + amount),
    c.a.to_int(),
  )
}

///|
fn darken_color(c : @raylib.Color, amount : Int) -> @raylib.Color {
  @raylib.Color::new(
    clamp_channel(c.r.to_int() - amount),
    clamp_channel(c.g.to_int() - amount),
    clamp_channel(c.b.to_int() - amount),
    c.a.to_int(),
  )
}

///|
fn draw_centered_text(
  text : String,
  cx : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @draw.measure_text(text, size)
  @draw.draw_text(text, cx - tw / 2, y, size, color)
}

///|
fn board_bounds() -> (Int, Int, Int, Int) {
  let w = @types.grid_cols * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  let h = @types.grid_rows * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  (@types.board_left - 8, @types.board_top - 8, w, h)
}

///|
fn draw_scene_backdrop() -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @types.bg_color,
    @types.bg_color_bottom,
  )

  @raylib.draw_circle(
    96,
    92,
    172.0,
    color_with_alpha(@types.panel_accent_color, 22),
  )
  @raylib.draw_circle(
    @types.screen_w - 82,
    148,
    220.0,
    color_with_alpha(@types.success_color, 18),
  )
  @raylib.draw_circle(
    @types.screen_w / 2,
    @types.screen_h - 112,
    320.0,
    color_with_alpha(@types.panel_card_border, 14),
  )

  @raylib.draw_rectangle_gradient_v(
    0,
    @types.screen_h - 320,
    @types.screen_w,
    320,
    color_with_alpha(@types.board_bg_color, 0),
    color_with_alpha(@types.board_bg_color, 150),
  )

  for i in 0..<8 {
    let y = 124 + i * 78
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_w,
      2,
      color_with_alpha(@types.panel_card_border, 10 + i * 2),
    )
  }
}

///|
fn draw_jewel(
  x : Float,
  y : Float,
  size : Float,
  base : @raylib.Color,
  highlight : @raylib.Color,
) -> Unit {
  let shadow = color_with_alpha(darken_color(base, 98), 120)
  let shell = darken_color(base, 72)
  let top_glow = color_with_alpha(highlight, 176)
  let bevel = color_with_alpha(darken_color(base, 38), 188)
  let line = color_with_alpha(lighten_color(highlight, 20), 168)

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(x + 4.0, y + 6.0, size - 8.0, size - 8.0),
    0.34,
    8,
    shadow,
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(x, y, size, size),
    0.34,
    8,
    shell,
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(x + 2.0, y + 2.0, size - 4.0, size - 4.0),
    0.34,
    8,
    base,
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(x + 6.0, y + 6.0, size - 12.0, size * 0.38),
    0.52,
    8,
    top_glow,
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(x + 8.0, y + size * 0.56, size - 16.0, size * 0.16),
    0.42,
    8,
    bevel,
  )
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(x + 1.5, y + 1.5, size - 3.0, size - 3.0),
    0.34,
    8,
    2.0,
    line,
  )
  @raylib.draw_circle(
    (x + size * 0.30).to_int(),
    (y + size * 0.28).to_int(),
    size * 0.10,
    color_with_alpha(@raylib.white, 185),
  )
  @raylib.draw_circle(
    (x + size * 0.66).to_int(),
    (y + size * 0.64).to_int(),
    size * 0.08,
    color_with_alpha(highlight, 86),
  )
}

///|
fn draw_stat_tile(
  x : Int,
  y : Int,
  w : Int,
  label : String,
  value : String,
  accent : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y + 4),
      Float::from_int(w),
      54.0,
    ),
    0.26,
    8,
    color_with_alpha(darken_color(@types.panel_card_color, 58), 138),
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(w),
      54.0,
    ),
    0.26,
    8,
    darken_color(@types.panel_card_color, 6),
  )
  @raylib.draw_rectangle(x + 10, y + 8, w - 20, 4, accent)
  @draw.draw_text(label, x + 12, y + 16, 14, @types.panel_label_color)
  @draw.draw_text(value, x + 12, y + 28, 24, accent)
}

///|
fn draw_modal_card(
  title : String,
  score_text : String,
  sub : String,
  accent : @raylib.Color,
) -> Unit {
  let card_x = 92
  let card_y = 250
  let card_w = @types.screen_w - 184
  let card_h = 220
  let cx = @types.screen_w / 2

  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    color_with_alpha(@types.bg_color, 166),
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x),
      Float::from_int(card_y + 10),
      Float::from_int(card_w),
      Float::from_int(card_h),
    ),
    0.14,
    10,
    color_with_alpha(darken_color(@types.bg_color, 28), 210),
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x),
      Float::from_int(card_y),
      Float::from_int(card_w),
      Float::from_int(card_h),
    ),
    0.14,
    10,
    @types.panel_card_color,
  )
  @raylib.draw_rectangle(card_x, card_y, card_w, 8, accent)
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(card_x + 1),
      Float::from_int(card_y + 1),
      Float::from_int(card_w - 2),
      Float::from_int(card_h - 2),
    ),
    0.14,
    10,
    2.0,
    color_with_alpha(@types.panel_card_border, 190),
  )

  draw_centered_text(title, cx, card_y + 42, 44, accent)
  draw_centered_text(score_text, cx, card_y + 102, 24, @types.panel_text_color)
  draw_centered_text(sub, cx, card_y + 150, 18, @types.panel_label_color)
}

///|
/// Renders one full frame for the current Xiao Xiao Le state.
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_scene_backdrop()
  match game.state {
    Title => draw_title()
    _ => {
      game.draw_panel()
      game.draw_board()
      if game.state == Over {
        game.draw_overlay_over()
      }
      if game.state == Clear {
        game.draw_overlay_clear()
      }
    }
  }
}

///|
fn draw_title() -> Unit {
  let cx = @types.screen_w / 2
  let card_x = 56
  let card_y = 112
  let card_w = @types.screen_w - 112
  let card_h = 552

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x),
      Float::from_int(card_y + 12),
      Float::from_int(card_w),
      Float::from_int(card_h),
    ),
    0.10,
    10,
    color_with_alpha(darken_color(@types.bg_color, 22), 216),
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x),
      Float::from_int(card_y),
      Float::from_int(card_w),
      Float::from_int(card_h),
    ),
    0.10,
    10,
    @types.panel_card_color,
  )
  @raylib.draw_rectangle(card_x, card_y, card_w, 10, @types.panel_accent_color)
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(card_x + 1),
      Float::from_int(card_y + 1),
      Float::from_int(card_w - 2),
      Float::from_int(card_h - 2),
    ),
    0.10,
    10,
    2.0,
    color_with_alpha(@types.panel_card_border, 190),
  )

  draw_centered_text(
    "CASCADE PUZZLE",
    cx,
    146,
    18,
    color_with_alpha(@types.panel_label_color, 220),
  )
  draw_centered_text("XIAO XIAO LE", cx, 184, 58, @types.panel_text_color)
  draw_centered_text(
    "Match 3 or more gems to score and beat the level target.",
    cx,
    264,
    22,
    @types.panel_label_color,
  )

  for i in 0..<@types.num_colors {
    let kind = @types.GemKind::from_int(i)
    let jx = Float::from_int(card_x + 42 + i * 78)
    draw_jewel(
      jx,
      322.0,
      54.0,
      @types.gem_color(kind),
      @types.gem_highlight(kind),
    )
  }

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x + 42),
      420.0,
      Float::from_int(card_w - 84),
      54.0,
    ),
    0.20,
    8,
    darken_color(@types.panel_card_color, 8),
  )
  draw_centered_text(
    "Click adjacent gems to swap them and set up chain reactions.",
    cx,
    436,
    18,
    @types.panel_text_color,
  )

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x + 42),
      490.0,
      Float::from_int(card_w - 84),
      54.0,
    ),
    0.20,
    8,
    darken_color(@types.panel_card_color, 8),
  )
  draw_centered_text(
    "H shows a hint. R restarts the run. Beat the score goal before moves run out.",
    cx,
    506,
    18,
    @types.panel_label_color,
  )

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x + 110),
      576.0,
      Float::from_int(card_w - 220),
      62.0,
    ),
    0.35,
    10,
    color_with_alpha(darken_color(@types.success_color, 72), 190),
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x + 110),
      570.0,
      Float::from_int(card_w - 220),
      62.0,
    ),
    0.35,
    10,
    @types.success_color,
  )
  draw_centered_text(
    "Click Or Press Enter To Start",
    cx,
    589,
    22,
    lighten_color(@types.bg_color, 220),
  )
}

///|
fn @types.Game::draw_panel(game : @types.Game) -> Unit {
  let card_x = 20
  let card_y = 18
  let card_w = @types.screen_w - 40
  let card_h = 126
  let progress_x = 36
  let progress_y = 118
  let progress_w = @types.screen_w - 172
  let progress_h = 16

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x),
      Float::from_int(card_y + 8),
      Float::from_int(card_w),
      Float::from_int(card_h),
    ),
    0.12,
    10,
    color_with_alpha(darken_color(@types.bg_color, 24), 210),
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(card_x),
      Float::from_int(card_y),
      Float::from_int(card_w),
      Float::from_int(card_h),
    ),
    0.12,
    10,
    @types.panel_card_color,
  )
  @raylib.draw_rectangle(card_x, card_y, card_w, 8, @types.panel_accent_color)
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(card_x + 1),
      Float::from_int(card_y + 1),
      Float::from_int(card_w - 2),
      Float::from_int(card_h - 2),
    ),
    0.12,
    10,
    2.0,
    color_with_alpha(@types.panel_card_border, 180),
  )

  draw_stat_tile(
    36,
    32,
    82,
    "Level",
    game.level.to_string(),
    @types.panel_accent_color,
  )
  draw_stat_tile(
    128,
    32,
    132,
    "Score",
    game.score.to_string(),
    @types.panel_text_color,
  )
  draw_stat_tile(
    270,
    32,
    118,
    "Goal",
    game.target_score.to_string(),
    @types.panel_accent_color,
  )
  let moves_color = if game.moves_left <= 5 {
    @types.danger_color
  } else {
    @types.panel_text_color
  }
  draw_stat_tile(
    398,
    32,
    88,
    "Moves",
    game.moves_left.to_string(),
    moves_color,
  )
  draw_stat_tile(
    496,
    32,
    110,
    "Best",
    game.best_score.to_string(),
    @types.success_color,
  )

  if game.msg_t > 0.0 {
    let alpha = (@types.clampf(game.msg_t * 3.0, 0.0, 1.0) * 255.0).to_int()
    let banner = color_with_alpha(@types.panel_accent_color, alpha / 3)
    @raylib.draw_rectangle_rounded(
      @raylib.Rectangle::new(36.0, 92.0, 360.0, 22.0),
      0.55,
      8,
      banner,
    )
    @draw.draw_text(
      game.msg,
      46,
      94,
      18,
      color_with_alpha(@types.panel_text_color, alpha),
    )
  } else {
    @draw.draw_text(
      "Click gems to swap. H shows a hint.",
      42,
      94,
      18,
      @types.panel_label_color,
    )
  }

  @draw.draw_text("Target Progress", progress_x, 96, 16, @types.panel_label_color)
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(progress_x),
      Float::from_int(progress_y),
      Float::from_int(progress_w),
      Float::from_int(progress_h),
    ),
    0.70,
    8,
    @types.board_slot_color,
  )

  let fill_ratio = if game.target_score > 0 {
    @types.clampf(
      Float::from_int(game.score) / Float::from_int(game.target_score),
      0.0,
      1.0,
    )
  } else {
    0.0
  }
  let fill_w = (Float::from_int(progress_w) * fill_ratio).to_int()
  if fill_w > 0 {
    @raylib.draw_rectangle_gradient_v(
      progress_x,
      progress_y,
      fill_w,
      progress_h,
      lighten_color(@types.success_color, 18),
      darken_color(@types.success_color, 28),
    )
  }

  let score_summary = "\{game.score} / \{game.target_score}"
  @draw.draw_text(
    score_summary,
    progress_x + progress_w + 12,
    96,
    16,
    @types.panel_text_color,
  )
}

///|
fn @types.Game::draw_board(game : @types.Game) -> Unit {
  let (bx, by, bw, bh) = board_bounds()
  let cp = Float::from_int(@types.cell_px)

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(bx - 10),
      Float::from_int(by + 12),
      Float::from_int(bw + 20),
      Float::from_int(bh + 20),
    ),
    0.06,
    10,
    color_with_alpha(darken_color(@types.bg_color, 22), 200),
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(bx - 10),
      Float::from_int(by - 10),
      Float::from_int(bw + 20),
      Float::from_int(bh + 20),
    ),
    0.06,
    10,
    @types.panel_card_color,
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(bx),
      Float::from_int(by),
      Float::from_int(bw),
      Float::from_int(bh),
    ),
    0.05,
    10,
    @types.board_bg_color,
  )
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(bx - 9),
      Float::from_int(by - 9),
      Float::from_int(bw + 18),
      Float::from_int(bh + 18),
    ),
    0.06,
    10,
    2.0,
    color_with_alpha(@types.panel_card_border, 180),
  )

  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let sx = @types.cell_x(c)
      let sy = @types.cell_y(r)
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(sx + 1.0, sy + 4.0, cp - 2.0, cp - 2.0),
        0.30,
        8,
        color_with_alpha(darken_color(@types.board_slot_color, 14), 160),
      )
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(sx + 2.0, sy + 2.0, cp - 4.0, cp - 4.0),
        0.30,
        8,
        @types.board_slot_color,
      )
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(sx + 7.0, sy + 7.0, cp - 14.0, cp * 0.18),
        0.45,
        8,
        color_with_alpha(@types.panel_card_border, 24),
      )
    }
  }

  for i in 0..<@types.cell_count {
    let g = game.board[i]
    if g.kind.is_empty() {
      continue
    }
    let r = i / @types.grid_cols
    let c = i % @types.grid_cols
    let x = g.anim_x
    let y = g.anim_y
    let color = @types.gem_color(g.kind)
    let highlight = @types.gem_highlight(g.kind)

    draw_jewel(x, y, cp, color, highlight)

    if g.flash_t > 0.0 {
      let alpha = (g.flash_t / @types.flash_duration * 255.0).to_int()
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(x + 2.0, y + 2.0, cp - 4.0, cp - 4.0),
        0.34,
        8,
        color_with_alpha(@raylib.white, alpha),
      )
    }

    if game.sel_r == r && game.sel_c == c {
      let outer = color_with_alpha(@types.select_color, 110)
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(x - 3.0, y - 3.0, cp + 6.0, cp + 6.0),
        0.34,
        8,
        outer,
      )
      @raylib.draw_rectangle_rounded_lines_ex(
        @raylib.Rectangle::new(x - 1.0, y - 1.0, cp + 2.0, cp + 2.0),
        0.34,
        8,
        3.0,
        @types.select_color,
      )
      @raylib.draw_rectangle_rounded_lines_ex(
        @raylib.Rectangle::new(x + 4.0, y + 4.0, cp - 8.0, cp - 8.0),
        0.32,
        8,
        1.5,
        color_with_alpha(@raylib.white, 160),
      )
    }
  }

  if game.state == Play && game.hint_r1 >= 0 && game.hint_t > 2.0 {
    let pulse = Float::from_double(
        @math.sin((game.hint_t - 2.0).to_double() * 4.0),
      ) *
      0.5 +
      0.5
    let alpha = (pulse * 170.0).to_int()
    let hx1 = @types.cell_x(game.hint_c1)
    let hy1 = @types.cell_y(game.hint_r1)
    let hx2 = @types.cell_x(game.hint_c2)
    let hy2 = @types.cell_y(game.hint_r2)
    let center1_x = hx1 + cp * 0.5
    let center1_y = hy1 + cp * 0.5
    let center2_x = hx2 + cp * 0.5
    let center2_y = hy2 + cp * 0.5
    let hint_color = color_with_alpha(@types.hint_color, alpha + 40)

    @raylib.draw_line_ex(
      @raylib.Vector2::new(center1_x, center1_y),
      @raylib.Vector2::new(center2_x, center2_y),
      3.0,
      color_with_alpha(@types.hint_color, alpha / 2 + 30),
    )
    @raylib.draw_rectangle_rounded_lines_ex(
      @raylib.Rectangle::new(hx1, hy1, cp, cp),
      0.34,
      8,
      3.0,
      hint_color,
    )
    @raylib.draw_rectangle_rounded_lines_ex(
      @raylib.Rectangle::new(hx2, hy2, cp, cp),
      0.34,
      8,
      3.0,
      hint_color,
    )
  }
}

///|
fn @types.Game::draw_overlay_over(game : @types.Game) -> Unit {
  draw_modal_card(
    "Out Of Moves",
    "Final Score: \{game.score}",
    "Enter: Retry  |  R: Level 1  |  Esc: Title",
    @types.danger_color,
  )
}

///|
fn @types.Game::draw_overlay_clear(game : @types.Game) -> Unit {
  draw_modal_card(
    "Level Clear!",
    "Score: \{game.score}",
    "Enter: Next Level  |  R: Level 1",
    @types.success_color,
  )
}
