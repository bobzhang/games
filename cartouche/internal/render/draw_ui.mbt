///|
fn draw_ui(game : @types.Game, tablet : @types.Tablet) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  // Panel background
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
  // Section: Letter palette
  @draw.draw_text("Assign Letter:", px, py, 18, @types.color_gold)
  let btn_size = @types.palette_btn_size
  let cols = @types.palette_cols
  for i in 0..<@types.symbol_count {
    let row = i / cols
    let col = i % cols
    let bx = px + col * (btn_size + 6)
    let by = py + 28 + row * (btn_size + 6)
    let letter = @types.letter_from_index(i)
    let is_used = @types.is_letter_used(game.current_mapping, i)
    // Button background
    let bg = if is_used {
      @raylib.Color::new(60, 80, 60, 200)
    } else {
      @raylib.Color::new(70, 55, 40, 200)
    }
    @raylib.draw_rectangle(bx, by, btn_size, btn_size, bg)
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
  // Section: Mapping table
  let my = @types.mapping_table_y
  @draw.draw_text("Mappings:", px, my, 18, @types.color_gold)
  let unique_syms = @types.get_inscription_symbols_unique(tablet.inscription)
  let mut row_y = my + 26
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
      if is_given {
        @draw.draw_text("(given)", px + 72, row_y, 12, @types.color_text_dim)
      }
    } else {
      @draw.draw_text("?", px + 52, row_y, 16, @types.color_text_dim)
    }
    row_y = row_y + 22
  }
  // Section: Status
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
  match sym {
    Circle =>
      @raylib.draw_circle_lines_v(@raylib.Vector2::new(cx, cy), r, color)
    Triangle =>
      @raylib.draw_triangle_lines(
        @raylib.Vector2::new(cx, cy - r),
        @raylib.Vector2::new(cx - r, cy + r * 0.7),
        @raylib.Vector2::new(cx + r, cy + r * 0.7),
        color,
      )
    Square =>
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(cx - r * 0.7, cy - r * 0.7, r * 1.4, r * 1.4),
        2.0,
        color,
      )
    Diamond => {
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r),
        @raylib.Vector2::new(cx + r * 0.7, cy),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx + r * 0.7, cy),
        @raylib.Vector2::new(cx, cy + r),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy + r),
        @raylib.Vector2::new(cx - r * 0.7, cy),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx - r * 0.7, cy),
        @raylib.Vector2::new(cx, cy - r),
        color,
      )
    }
    Star =>
      // 5-pointed star
      for i in 0..<5 {
        let fi = Float::from_int(i)
        let a1 = fi * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
        let a2 = (fi + 2.0) * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
        @raylib.draw_line_v(
          @raylib.Vector2::new(
            cx + @types.cosf(a1) * r,
            cy + @types.sinf(a1) * r,
          ),
          @raylib.Vector2::new(
            cx + @types.cosf(a2) * r,
            cy + @types.sinf(a2) * r,
          ),
          color,
        )
      }
    Cross => {
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx - r * 0.6, cy),
        @raylib.Vector2::new(cx + r * 0.6, cy),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r * 0.8),
        @raylib.Vector2::new(cx, cy + r * 0.8),
        color,
      )
      // crossbar
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx - r * 0.4, cy - r * 0.3),
        @raylib.Vector2::new(cx + r * 0.4, cy - r * 0.3),
        color,
      )
    }
    Arrow => {
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy + r * 0.7),
        @raylib.Vector2::new(cx, cy - r * 0.7),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r * 0.7),
        @raylib.Vector2::new(cx - r * 0.5, cy - r * 0.1),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r * 0.7),
        @raylib.Vector2::new(cx + r * 0.5, cy - r * 0.1),
        color,
      )
    }
    Wave =>
      for i in 0..<8 {
        let fi = Float::from_int(i)
        let x1 = cx - r * 0.8 + fi * r * 0.2
        let x2 = cx - r * 0.8 + (fi + 1.0) * r * 0.2
        let y1 = cy + @types.sinf(fi * 1.5) * r * 0.3
        let y2 = cy + @types.sinf((fi + 1.0) * 1.5) * r * 0.3
        @raylib.draw_line_v(
          @raylib.Vector2::new(x1, y1),
          @raylib.Vector2::new(x2, y2),
          color,
        )
      }
    Spiral =>
      for i in 0..<20 {
        let fi = Float::from_int(i)
        let a1 = fi * 0.5
        let a2 = (fi + 1.0) * 0.5
        let r1 = r * 0.1 + fi * r * 0.04
        let r2 = r * 0.1 + (fi + 1.0) * r * 0.04
        @raylib.draw_line_v(
          @raylib.Vector2::new(
            cx + @types.cosf(a1) * r1,
            cy + @types.sinf(a1) * r1,
          ),
          @raylib.Vector2::new(
            cx + @types.cosf(a2) * r2,
            cy + @types.sinf(a2) * r2,
          ),
          color,
        )
      }
    Dot => {
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r * 0.35, color)
      @raylib.draw_circle_lines_v(@raylib.Vector2::new(cx, cy), r * 0.7, color)
    }
    Crescent => {
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(cx - r * 0.15, cy),
        r * 0.7,
        color,
      )
      // Cover right portion with bg to make crescent
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx + r * 0.2, cy),
        r * 0.55,
        @types.color_stone,
      )
    }
    Lightning => {
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx + r * 0.2, cy - r * 0.8),
        @raylib.Vector2::new(cx - r * 0.2, cy - r * 0.1),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx - r * 0.2, cy - r * 0.1),
        @raylib.Vector2::new(cx + r * 0.2, cy - r * 0.1),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx + r * 0.2, cy - r * 0.1),
        @raylib.Vector2::new(cx - r * 0.2, cy + r * 0.8),
        color,
      )
    }
    Eye => {
      // Almond shape
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx - r * 0.8, cy),
        @raylib.Vector2::new(cx, cy - r * 0.4),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r * 0.4),
        @raylib.Vector2::new(cx + r * 0.8, cy),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx + r * 0.8, cy),
        @raylib.Vector2::new(cx, cy + r * 0.4),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy + r * 0.4),
        @raylib.Vector2::new(cx - r * 0.8, cy),
        color,
      )
      // Pupil
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r * 0.2, color)
    }
    Hand => {
      // Palm
      @raylib.draw_rectangle(
        (cx - r * 0.3).to_int(),
        (cy - r * 0.1).to_int(),
        (r * 0.6).to_int(),
        (r * 0.7).to_int(),
        color,
      )
      // Fingers (3 lines up)
      for i in 0..<3 {
        let fi = Float::from_int(i)
        let fx = cx - r * 0.2 + fi * r * 0.2
        @raylib.draw_line_v(
          @raylib.Vector2::new(fx, cy - r * 0.1),
          @raylib.Vector2::new(fx, cy - r * 0.7),
          color,
        )
      }
    }
    Sun => {
      @raylib.draw_circle_lines_v(@raylib.Vector2::new(cx, cy), r * 0.4, color)
      // Rays
      for i in 0..<8 {
        let fi = Float::from_int(i)
        let angle = fi * @types.pi * 2.0 / 8.0
        @raylib.draw_line_v(
          @raylib.Vector2::new(
            cx + @types.cosf(angle) * r * 0.5,
            cy + @types.sinf(angle) * r * 0.5,
          ),
          @raylib.Vector2::new(
            cx + @types.cosf(angle) * r * 0.85,
            cy + @types.sinf(angle) * r * 0.85,
          ),
          color,
        )
      }
    }
    MoonSym => {
      // Crescent moon (thicker arc)
      @raylib.draw_circle_lines_v(@raylib.Vector2::new(cx, cy), r * 0.7, color)
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx + r * 0.35, cy - r * 0.1),
        r * 0.5,
        @types.color_stone,
      )
    }
    Mountain => {
      @raylib.draw_triangle_lines(
        @raylib.Vector2::new(cx, cy - r * 0.7),
        @raylib.Vector2::new(cx - r * 0.8, cy + r * 0.7),
        @raylib.Vector2::new(cx + r * 0.8, cy + r * 0.7),
        color,
      )
      // Smaller peak
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx + r * 0.3, cy - r * 0.2),
        @raylib.Vector2::new(cx + r * 0.8, cy + r * 0.7),
        color,
      )
    }
    River =>
      // Two parallel wavy lines
      for j in 0..<2 {
        let offset_y = Float::from_int(j) * r * 0.4 - r * 0.2
        for i in 0..<6 {
          let fi = Float::from_int(i)
          let x1 = cx - r * 0.7 + fi * r * 0.28
          let x2 = cx - r * 0.7 + (fi + 1.0) * r * 0.28
          let y1 = cy + offset_y + @types.sinf(fi * 2.0) * r * 0.15
          let y2 = cy + offset_y + @types.sinf((fi + 1.0) * 2.0) * r * 0.15
          @raylib.draw_line_v(
            @raylib.Vector2::new(x1, y1),
            @raylib.Vector2::new(x2, y2),
            color,
          )
        }
      }
    Tree => {
      // Trunk
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy + r * 0.7),
        @raylib.Vector2::new(cx, cy - r * 0.2),
        color,
      )
      // Crown (triangle)
      @raylib.draw_triangle_lines(
        @raylib.Vector2::new(cx, cy - r * 0.8),
        @raylib.Vector2::new(cx - r * 0.5, cy + r * 0.1),
        @raylib.Vector2::new(cx + r * 0.5, cy + r * 0.1),
        color,
      )
    }
    Flame => {
      // Flame outline - teardrop shape
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r * 0.8),
        @raylib.Vector2::new(cx + r * 0.4, cy + r * 0.2),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx + r * 0.4, cy + r * 0.2),
        @raylib.Vector2::new(cx + r * 0.2, cy + r * 0.7),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx + r * 0.2, cy + r * 0.7),
        @raylib.Vector2::new(cx - r * 0.2, cy + r * 0.7),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx - r * 0.2, cy + r * 0.7),
        @raylib.Vector2::new(cx - r * 0.4, cy + r * 0.2),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx - r * 0.4, cy + r * 0.2),
        @raylib.Vector2::new(cx, cy - r * 0.8),
        color,
      )
      // Inner flame
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r * 0.3),
        @raylib.Vector2::new(cx + r * 0.15, cy + r * 0.3),
        color,
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(cx, cy - r * 0.3),
        @raylib.Vector2::new(cx - r * 0.15, cy + r * 0.3),
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
