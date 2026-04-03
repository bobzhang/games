///|
fn draw_playing(game : @types.Game) -> Unit {
  let tablet = @levels.get_tablet(game.current_tablet_index)
  draw_tablet_background()
  draw_inscription(game, tablet)
  draw_ui(game, tablet)
  draw_message(game)
}

///|
fn draw_tablet_background() -> Unit {
  let tx = @types.tablet_x
  let ty = @types.tablet_y
  let tw = @types.tablet_width
  let th = @types.tablet_height
  // Outer stone border
  @raylib.draw_rectangle(
    tx - 4,
    ty - 4,
    tw + 8,
    th + 8,
    @types.color_stone_dark,
  )
  // Main stone surface
  @raylib.draw_rectangle(tx, ty, tw, th, @types.color_stone)
  // Inner border
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(tx + 8),
      Float::from_int(ty + 8),
      Float::from_int(tw - 16),
      Float::from_int(th - 16),
    ),
    2.0,
    @types.color_stone_dark,
  )
  // Stone texture - subtle cracks
  for i in 0..<15 {
    let fi = Float::from_int(i)
    let cx = tx + 20 + (fi * 53.7 % Float::from_int(tw - 40)).to_int()
    let cy = ty + 20 + (fi * 37.3 % Float::from_int(th - 40)).to_int()
    let len = 10 + (fi * 7.1 % 20.0).to_int()
    @raylib.draw_line(
      cx,
      cy,
      cx + len,
      cy + (fi * 3.0 % 6.0 - 3.0).to_int(),
      @raylib.Color::new(150, 135, 110, 60),
    )
  }
}

///|
fn draw_inscription(game : @types.Game, tablet : @types.Tablet) -> Unit {
  let base_x = @types.tablet_x + @types.inscription_margin_x
  let base_y = @types.tablet_y + @types.inscription_margin_y
  let max_width = @types.tablet_width - @types.inscription_max_margin
  let time = Float::from_int(game.frame_count) * 0.03
  let positions = @types.compute_symbol_positions(
    tablet.inscription,
    base_x,
    base_y,
    max_width,
    @types.inscription_line_height,
    @types.symbol_spacing,
    @types.word_gap,
  )
  for pos in positions {
    match pos.symbol {
      None => ()
      Some(sym) => {
        let sx = Float::from_int(pos.x)
        let sy = Float::from_int(pos.y)
        let si = @types.symbol_index(sym)
        let is_given = @types.is_given_symbol(tablet, sym)
        let is_selected = match game.selected_symbol {
          Some(sel) => sel == sym
          None => false
        }
        let is_hint = match game.hint_symbol {
          Some(hs) => hs == sym && game.hint_timer > 0.0
          None => false
        }
        // Symbol background highlight
        if is_selected {
          let glow = @types.sinf(time * 4.0) * 0.3 + 0.7
          let alpha = (glow * 180.0).to_int()
          @raylib.draw_rectangle(
            (sx - 4.0).to_int(),
            (sy - 4.0).to_int(),
            (@types.symbol_size + 8.0).to_int(),
            (@types.symbol_size + 8.0).to_int(),
            @raylib.Color::new(255, 200, 60, alpha),
          )
        } else if is_hint {
          let glow = @types.sinf(time * 6.0) * 0.4 + 0.6
          let alpha = (glow * 160.0).to_int()
          @raylib.draw_rectangle(
            (sx - 4.0).to_int(),
            (sy - 4.0).to_int(),
            (@types.symbol_size + 8.0).to_int(),
            (@types.symbol_size + 8.0).to_int(),
            @raylib.Color::new(180, 100, 255, alpha),
          )
        }
        // Draw the hieroglyph symbol
        let sym_color = if is_given {
          @types.color_given
        } else {
          @types.color_sym_primary
        }
        draw_symbol(
          sym,
          sx + @types.symbol_size / 2.0,
          sy + @types.symbol_size / 2.0,
          @types.symbol_size,
          sym_color,
        )
        // Draw decoded letter below symbol
        let mapped_letter = game.current_mapping.values[si]
        if mapped_letter >= 0 {
          let letter = @types.letter_from_index(mapped_letter)
          let lw = @draw.measure_text(letter, 18)
          let letter_color = if is_given {
            @types.color_given
          } else {
            @types.color_mapped
          }
          @draw.draw_text(
            letter,
            (sx + @types.symbol_size / 2.0).to_int() - lw / 2,
            (sy + @types.symbol_size + 4.0).to_int(),
            18,
            letter_color,
          )
        } else {
          // Underscore for unmapped
          @draw.draw_text(
            "_",
            (sx + @types.symbol_size / 2.0).to_int() - 4,
            (sy + @types.symbol_size + 4.0).to_int(),
            18,
            @types.color_text_dim,
          )
        }
      }
    }
  }
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let w = @types.screen_width
    let mw = @draw.measure_text(game.message, 22)
    let alpha = @types.minf(game.message_timer * 3.0, 1.0)
    let a = (alpha * 255.0).to_int()
    @raylib.draw_rectangle(
      w / 2 - mw / 2 - 15,
      @types.screen_height - 60,
      mw + 30,
      36,
      @raylib.Color::new(40, 30, 25, (alpha * 200.0).to_int()),
    )
    @draw.draw_text(
      game.message,
      (w - mw) / 2,
      @types.screen_height - 55,
      22,
      @raylib.Color::new(230, 220, 200, a),
    )
  }
}
