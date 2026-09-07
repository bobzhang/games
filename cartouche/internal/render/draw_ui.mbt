///|
fn draw_ui(game : @types.Game, tablet : @types.Tablet) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  // Panel background
  if !draw_decoder_panel_art(
      px - 10,
      py - 10,
      @types.screen_width - px + 10 - 20,
      @types.screen_height - py - 10,
    ) {
    @raylib.draw_rectangle(
      px - 10,
      py - 10,
      @types.screen_width - px + 10 - 20,
      @types.screen_height - py - 10,
      @raylib.Color::new(40, 30, 25, 200),
    )
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(px - 10),
        Float::from_int(py - 10),
        Float::from_int(@types.screen_width - px + 10 - 20),
        Float::from_int(@types.screen_height - py - 10),
      ),
      1.0,
      @types.color_stone_dark,
    )
  }
  draw_letter_palette(game)
  draw_mapping_table(game, tablet)
  draw_status_and_controls(game, tablet)
}

///|
fn draw_letter_palette(game : @types.Game) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let btn_size = @types.palette_btn_size
  @draw.draw_text("Assign Letter:", px, py, 18, @types.color_gold)
  for i in 0..<@types.symbol_count {
    let (bx, by) = @types.palette_button_pos(
      i, px, py, btn_size, @types.palette_btn_gap, @types.palette_cols, @types.palette_label_offset_y,
    )
    let letter = @types.letter_from_index(i)
    let is_used = @types.is_letter_used(game.current_mapping, i)
    // Button background
    let bg = if is_used {
      @raylib.Color::new(60, 80, 60, 200)
    } else {
      @raylib.Color::new(70, 55, 40, 200)
    }
    if !draw_glyph_backplate_art(bx, by, btn_size, bg) {
      @raylib.draw_rectangle(bx, by, btn_size, btn_size, bg)
    }
    // Border
    let border = if is_used {
      @types.color_given
    } else {
      @types.color_stone_dark
    }
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(bx),
        Float::from_int(by),
        Float::from_int(btn_size),
        Float::from_int(btn_size),
      ),
      1.0,
      border,
    )
    // Letter
    let lw = @draw.measure_text(letter, 20)
    let text_color = if is_used {
      @types.color_text_dim
    } else {
      @types.color_text
    }
    @draw.draw_text(letter, bx + (btn_size - lw) / 2, by + 12, 20, text_color)
  }
}

///|
fn draw_mapping_table(game : @types.Game, tablet : @types.Tablet) -> Unit {
  let px = @types.palette_x
  let my = @types.mapping_table_y
  @draw.draw_text("Mappings:", px, my, 18, @types.color_gold)
  // Column headers
  @draw.draw_text("Sym", px, my + 18, 10, @types.color_text_dim)
  @draw.draw_text("Map", px + 48, my + 18, 10, @types.color_text_dim)
  @draw.draw_text("Freq", px + 80, my + 18, 10, @types.color_text_dim)
  let unique_syms = @types.get_inscription_symbols_unique(tablet.inscription)
  let mut row_y = my + 32
  for i in 0..<unique_syms.length() {
    let sym = unique_syms[i]
    let si = @types.symbol_index(sym)
    let is_given = @types.is_given_symbol(tablet, sym)
    let is_selected = match game.selected_symbol {
      Some(sel) => sel == sym
      None => false
    }
    // Highlight row if selected
    if is_selected {
      @raylib.draw_rectangle(
        px - 4,
        row_y - 2,
        260,
        22,
        @raylib.Color::new(255, 200, 60, 40),
      )
    }
    // Draw mini symbol
    draw_symbol_small(
      sym,
      Float::from_int(px),
      Float::from_int(row_y),
      16.0,
      if is_given {
        @types.color_given
      } else {
        @types.color_sym_primary
      },
    )
    // Arrow
    @draw.draw_text("->", px + 24, row_y, 16, @types.color_text_dim)
    // Mapped letter
    let mapped = game.current_mapping.values[si]
    if mapped >= 0 {
      let letter = @types.letter_from_index(mapped)
      let letter_color = if is_given {
        @types.color_given
      } else {
        @types.color_mapped
      }
      @draw.draw_text(letter, px + 52, row_y, 16, letter_color)
    } else {
      @draw.draw_text("?", px + 52, row_y, 16, @types.color_text_dim)
    }
    // Frequency count
    let freq = @types.count_symbol_frequency(tablet.inscription, sym)
    let freq_str = "x" + freq.to_string()
    let freq_color = if freq >= 4 {
      @types.color_gold
    } else if freq >= 2 {
      @types.color_text
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(freq_str, px + 80, row_y, 14, freq_color)
    // Frequency bar
    let max_bar_w = 80
    let bar_w = @types.mini(freq * 12, max_bar_w)
    @raylib.draw_rectangle(
      px + 110,
      row_y + 4,
      bar_w,
      8,
      if is_given {
        @raylib.Color::new(80, 180, 80, 80)
      } else if mapped >= 0 {
        @raylib.Color::new(100, 160, 220, 80)
      } else {
        @raylib.Color::new(160, 150, 130, 60)
      },
    )
    if is_given {
      @draw.draw_text("(given)", px + 200, row_y + 2, 10, @types.color_text_dim)
    }
    row_y = row_y + 22
  }
}

///|
fn draw_status_and_controls(game : @types.Game, tablet : @types.Tablet) -> Unit {
  let px = @types.palette_x
  let status_y = @types.screen_height - 160
  @raylib.draw_line(
    px,
    status_y,
    @types.screen_width - 30,
    status_y,
    @types.color_stone_dark,
  )
  @draw.draw_text(
    "Guesses: " + game.guesses.to_string(),
    px,
    status_y + 10,
    18,
    @types.color_text,
  )
  @draw.draw_text(
    "Wrong: " + game.wrong_count.to_string(),
    px + 140,
    status_y + 10,
    18,
    if game.wrong_count > 0 {
      @types.color_wrong
    } else {
      @types.color_text
    },
  )
  @draw.draw_text(
    "Par: " + tablet.par_guesses.to_string(),
    px,
    status_y + 35,
    16,
    @types.color_text_dim,
  )
  // Controls
  let ctrl_y = status_y + 60
  @draw.draw_text("Controls:", px, ctrl_y, 16, @types.color_gold_dim)
  @draw.draw_text(
    "Click symbol, then letter",
    px,
    ctrl_y + 22,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "H: Hint  Z: Undo  X: Clear",
    px,
    ctrl_y + 40,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text("ESC: Back", px, ctrl_y + 58, 14, @types.color_text_dim)
}

///|
pub fn draw_symbol(
  sym : @types.Symbol,
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  let r = size / 2.0
  let thick : Float = if size > 24.0 { 2.5 } else { 1.5 }
  match sym {
    Circle => {
      @raylib.draw_ring(
        @raylib.Vector2::new(cx, cy),
        r * 0.65,
        r * 0.85,
        0.0,
        360.0,
        36,
        color,
      )
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r * 0.15, color)
    }
    Triangle => {
      let top = @raylib.Vector2::new(cx, cy - r * 0.85)
      let bl = @raylib.Vector2::new(cx - r * 0.8, cy + r * 0.65)
      let br = @raylib.Vector2::new(cx + r * 0.8, cy + r * 0.65)
      @raylib.draw_line_ex(top, bl, thick, color)
      @raylib.draw_line_ex(bl, br, thick, color)
      @raylib.draw_line_ex(br, top, thick, color)
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx, cy + r * 0.15),
        r * 0.12,
        color,
      )
    }
    Square => {
      let half = r * 0.75
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(cx - half, cy - half, half * 2.0, half * 2.0),
        thick,
        color,
      )
      let inner = r * 0.3
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - inner, cy),
        @raylib.Vector2::new(cx + inner, cy),
        1.5,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - inner),
        @raylib.Vector2::new(cx, cy + inner),
        1.5,
        color,
      )
    }
    Diamond => {
      let top = @raylib.Vector2::new(cx, cy - r * 0.9)
      let right = @raylib.Vector2::new(cx + r * 0.65, cy)
      let bottom = @raylib.Vector2::new(cx, cy + r * 0.9)
      let left = @raylib.Vector2::new(cx - r * 0.65, cy)
      @raylib.draw_line_ex(top, right, thick, color)
      @raylib.draw_line_ex(right, bottom, thick, color)
      @raylib.draw_line_ex(bottom, left, thick, color)
      @raylib.draw_line_ex(left, top, thick, color)
      @raylib.draw_line_ex(left, right, 1.0, color)
    }
    Star => {
      for i in 0..<5 {
        let fi = Float::from_int(i)
        let a1 = fi * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
        let a2 = (fi + 2.0) * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
        @raylib.draw_line_ex(
          @raylib.Vector2::new(
            cx + @types.cosf(a1) * r * 0.85,
            cy + @types.sinf(a1) * r * 0.85,
          ),
          @raylib.Vector2::new(
            cx + @types.cosf(a2) * r * 0.85,
            cy + @types.sinf(a2) * r * 0.85,
          ),
          thick,
          color,
        )
      }
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r * 0.12, color)
    }
    Cross => {
      let arm = r * 0.7
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - arm, cy),
        @raylib.Vector2::new(cx + arm, cy),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.85),
        @raylib.Vector2::new(cx, cy + r * 0.85),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.45, cy - r * 0.35),
        @raylib.Vector2::new(cx + r * 0.45, cy - r * 0.35),
        thick,
        color,
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx, cy - r * 0.85),
        r * 0.1,
        color,
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx, cy + r * 0.85),
        r * 0.1,
        color,
      )
    }
    Arrow => {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + r * 0.75),
        @raylib.Vector2::new(cx, cy - r * 0.75),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.75),
        @raylib.Vector2::new(cx - r * 0.5, cy - r * 0.15),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.75),
        @raylib.Vector2::new(cx + r * 0.5, cy - r * 0.15),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.3, cy + r * 0.55),
        @raylib.Vector2::new(cx, cy + r * 0.35),
        1.5,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.3, cy + r * 0.55),
        @raylib.Vector2::new(cx, cy + r * 0.35),
        1.5,
        color,
      )
    }
    Wave =>
      for row in 0..<2 {
        let offset_y = Float::from_int(row) * r * 0.5 - r * 0.25
        for i in 0..<10 {
          let fi = Float::from_int(i)
          let x1 = cx - r * 0.85 + fi * r * 0.17
          let x2 = cx - r * 0.85 + (fi + 1.0) * r * 0.17
          let y1 = cy + offset_y + @types.sinf(fi * 1.5) * r * 0.25
          let y2 = cy + offset_y + @types.sinf((fi + 1.0) * 1.5) * r * 0.25
          @raylib.draw_line_ex(
            @raylib.Vector2::new(x1, y1),
            @raylib.Vector2::new(x2, y2),
            thick,
            color,
          )
        }
      }
    Spiral =>
      for i in 0..<24 {
        let fi = Float::from_int(i)
        let a1 = fi * 0.45
        let a2 = (fi + 1.0) * 0.45
        let r1 = r * 0.08 + fi * r * 0.033
        let r2 = r * 0.08 + (fi + 1.0) * r * 0.033
        @raylib.draw_line_ex(
          @raylib.Vector2::new(
            cx + @types.cosf(a1) * r1,
            cy + @types.sinf(a1) * r1,
          ),
          @raylib.Vector2::new(
            cx + @types.cosf(a2) * r2,
            cy + @types.sinf(a2) * r2,
          ),
          thick,
          color,
        )
      }
    Dot => {
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r * 0.4, color)
      @raylib.draw_ring(
        @raylib.Vector2::new(cx, cy),
        r * 0.6,
        r * 0.75,
        0.0,
        360.0,
        36,
        color,
      )
    }
    Crescent =>
      @raylib.draw_ring(
        @raylib.Vector2::new(cx - r * 0.1, cy),
        r * 0.5,
        r * 0.75,
        40.0,
        320.0,
        24,
        color,
      )
    Lightning => {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.25, cy - r * 0.85),
        @raylib.Vector2::new(cx - r * 0.15, cy - r * 0.1),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.15, cy - r * 0.1),
        @raylib.Vector2::new(cx + r * 0.25, cy - r * 0.1),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.25, cy - r * 0.1),
        @raylib.Vector2::new(cx - r * 0.25, cy + r * 0.85),
        thick,
        color,
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx + r * 0.25, cy - r * 0.85),
        r * 0.08,
        color,
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx - r * 0.25, cy + r * 0.85),
        r * 0.08,
        color,
      )
    }
    Eye => {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.85, cy),
        @raylib.Vector2::new(cx, cy - r * 0.45),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.45),
        @raylib.Vector2::new(cx + r * 0.85, cy),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.85, cy),
        @raylib.Vector2::new(cx, cy + r * 0.45),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + r * 0.45),
        @raylib.Vector2::new(cx - r * 0.85, cy),
        thick,
        color,
      )
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r * 0.22, color)
      @raylib.draw_ring(
        @raylib.Vector2::new(cx, cy),
        r * 0.25,
        r * 0.32,
        0.0,
        360.0,
        20,
        color,
      )
    }
    Hand => {
      @raylib.draw_rectangle(
        (cx - r * 0.35).to_int(),
        (cy - r * 0.05).to_int(),
        (r * 0.7).to_int(),
        (r * 0.7).to_int(),
        color,
      )
      for i in 0..<3 {
        let fi = Float::from_int(i)
        let fx = cx - r * 0.25 + fi * r * 0.25
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx, cy - r * 0.05),
          @raylib.Vector2::new(fx, cy - r * 0.7),
          thick,
          color,
        )
        @raylib.draw_circle_v(
          @raylib.Vector2::new(fx, cy - r * 0.7),
          r * 0.06,
          color,
        )
      }
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.35, cy + r * 0.2),
        @raylib.Vector2::new(cx - r * 0.65, cy - r * 0.1),
        thick,
        color,
      )
    }
    Sun => {
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r * 0.35, color)
      for i in 0..<8 {
        let fi = Float::from_int(i)
        let angle = fi * @types.pi * 2.0 / 8.0
        @raylib.draw_line_ex(
          @raylib.Vector2::new(
            cx + @types.cosf(angle) * r * 0.48,
            cy + @types.sinf(angle) * r * 0.48,
          ),
          @raylib.Vector2::new(
            cx + @types.cosf(angle) * r * 0.85,
            cy + @types.sinf(angle) * r * 0.85,
          ),
          thick,
          color,
        )
      }
    }
    MoonSym => {
      @raylib.draw_ring(
        @raylib.Vector2::new(cx, cy),
        r * 0.45,
        r * 0.75,
        -60.0,
        210.0,
        24,
        color,
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx + r * 0.55, cy - r * 0.55),
        r * 0.08,
        color,
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx + r * 0.7, cy - r * 0.2),
        r * 0.06,
        color,
      )
    }
    Mountain => {
      let base_y = cy + r * 0.7
      let peak = @raylib.Vector2::new(cx - r * 0.15, cy - r * 0.75)
      let bl = @raylib.Vector2::new(cx - r * 0.85, base_y)
      let br = @raylib.Vector2::new(cx + r * 0.85, base_y)
      @raylib.draw_line_ex(bl, peak, thick, color)
      @raylib.draw_line_ex(peak, br, thick, color)
      let peak2 = @raylib.Vector2::new(cx + r * 0.4, cy - r * 0.3)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.1, base_y),
        peak2,
        thick,
        color,
      )
      @raylib.draw_line_ex(peak2, br, thick, color)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.35, cy - r * 0.4),
        @raylib.Vector2::new(cx + r * 0.05, cy - r * 0.4),
        1.5,
        color,
      )
    }
    River =>
      for j in 0..<3 {
        let offset_y = Float::from_int(j) * r * 0.35 - r * 0.35
        for i in 0..<8 {
          let fi = Float::from_int(i)
          let x1 = cx - r * 0.8 + fi * r * 0.2
          let x2 = cx - r * 0.8 + (fi + 1.0) * r * 0.2
          let y1 = cy + offset_y + @types.sinf(fi * 2.0) * r * 0.12
          let y2 = cy + offset_y + @types.sinf((fi + 1.0) * 2.0) * r * 0.12
          @raylib.draw_line_ex(
            @raylib.Vector2::new(x1, y1),
            @raylib.Vector2::new(x2, y2),
            thick,
            color,
          )
        }
      }
    Tree => {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + r * 0.75),
        @raylib.Vector2::new(cx, cy - r * 0.15),
        thick + 1.0,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.85),
        @raylib.Vector2::new(cx - r * 0.55, cy + r * 0.1),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.55, cy + r * 0.1),
        @raylib.Vector2::new(cx + r * 0.55, cy + r * 0.1),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.55, cy + r * 0.1),
        @raylib.Vector2::new(cx, cy - r * 0.85),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + r * 0.75),
        @raylib.Vector2::new(cx - r * 0.3, cy + r * 0.85),
        1.5,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + r * 0.75),
        @raylib.Vector2::new(cx + r * 0.3, cy + r * 0.85),
        1.5,
        color,
      )
    }
    Flame => {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.85),
        @raylib.Vector2::new(cx + r * 0.45, cy + r * 0.15),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.45, cy + r * 0.15),
        @raylib.Vector2::new(cx + r * 0.25, cy + r * 0.7),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx + r * 0.25, cy + r * 0.7),
        @raylib.Vector2::new(cx - r * 0.25, cy + r * 0.7),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.25, cy + r * 0.7),
        @raylib.Vector2::new(cx - r * 0.45, cy + r * 0.15),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - r * 0.45, cy + r * 0.15),
        @raylib.Vector2::new(cx, cy - r * 0.85),
        thick,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.3),
        @raylib.Vector2::new(cx + r * 0.18, cy + r * 0.35),
        1.5,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - r * 0.3),
        @raylib.Vector2::new(cx - r * 0.18, cy + r * 0.35),
        1.5,
        color,
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx, cy + r * 0.15),
        r * 0.1,
        color,
      )
    }
  }
}

///|
pub fn draw_symbol_small(
  sym : @types.Symbol,
  x : Float,
  y : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  draw_symbol(sym, x + size / 2.0, y + size / 2.0, size, color)
}
