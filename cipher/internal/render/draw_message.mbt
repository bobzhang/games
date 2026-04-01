///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  // Header bar
  draw_header(game, level)
  // Message area
  draw_message_area(game, level)
  // Tool panel on right
  draw_tool_panel(game, level)
  // Bottom alphabet mapping strip
  draw_alphabet_strip(game, level)
  // Solved overlay flash
  if game.play_state == Solved && game.message_flash_timer > 0.0 {
    let alpha = (game.message_flash_timer * 255.0).to_int()
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(0, 255, 100, if alpha > 60 { 60 } else { alpha }),
    )
  }
}

///|
fn draw_header(game : @types.Game, level : @types.Level) -> Unit {
  let w = @types.screen_width
  @raylib.draw_rectangle(0, 0, w, 50, @types.color_panel)
  @raylib.draw_line(0, 50, w, 50, @types.color_panel_border)
  // Case number
  let case_txt = "CASE " + (game.current_level + 1).to_string()
  @draw.draw_text(case_txt, 15, 12, 22, @types.color_green)
  // Cipher type
  let cipher_name = match level.cipher_kind {
    Caesar => "CAESAR"
    Substitution => "SUBSTITUTION"
    Vigenere => "VIGENERE"
  }
  @draw.draw_text(cipher_name, 160, 16, 16, @types.color_amber)
  // Swap count
  let swap_txt = "Swaps: " +
    game.swap_count.to_string() +
    "/" +
    level.par_swaps.to_string()
  @draw.draw_text(swap_txt, 340, 16, 16, @types.color_text)
  // Hints
  let hint_txt = "Hints: " + game.hints_used.to_string()
  @draw.draw_text(hint_txt, 500, 16, 16, @types.color_text)
  // Correct count
  let correct = @types.count_correct(
    level.ciphertext,
    level.plaintext,
    game.mapping,
  )
  let total = @types.count_unique_letters(level.ciphertext)
  let prog_txt = "Correct: " + correct.to_string() + "/" + total.to_string()
  @draw.draw_text(prog_txt, 640, 16, 16, @types.color_cyan)
  // Status
  if game.play_state == Solved {
    @draw.draw_text("DECODED!", w - 120, 16, 18, @types.color_green)
  }
}

///|
fn draw_message_area(game : @types.Game, level : @types.Level) -> Unit {
  let base_x = @types.msg_area_x
  let base_y = @types.msg_area_y
  let cell_w = @types.char_cell_w
  let cell_h = @types.char_cell_h
  let max_cols = @types.msg_area_w / cell_w
  // Draw background panel
  @raylib.draw_rectangle(
    base_x - 10,
    base_y - 5,
    @types.msg_area_w + 20,
    560,
    @types.color_panel,
  )
  @raylib.draw_rectangle_lines(
    base_x - 10,
    base_y - 5,
    @types.msg_area_w + 20,
    560,
    @types.color_panel_border,
  )
  // Label
  @draw.draw_text("CIPHERTEXT:", base_x, base_y, 14, @types.color_dim)
  @draw.draw_text("DECODED:", base_x, base_y + cell_h + 5, 14, @types.color_dim)
  let ct = level.ciphertext
  let mut col = 0
  let mut row = 0
  let cipher_y_offset = base_y + 20
  let plain_y_offset = cipher_y_offset + cell_h + 20
  let row_height = cell_h * 2 + 50
  for i in 0..<ct.length() {
    let c = @types.str_char_at(ct, i)
    let x = base_x + col * cell_w
    let cipher_y = cipher_y_offset + row * row_height - game.scroll_offset
    let plain_y = plain_y_offset + row * row_height - game.scroll_offset
    // Only draw if visible
    if cipher_y >= base_y - 40 && cipher_y < base_y + 530 {
      if @types.is_upper(c) {
        let ci = @types.char_to_idx(c)
        let pi = game.mapping.cipher_to_plain[ci]
        let is_selected = ci == game.selected_cipher_letter
        let in_pattern = @types.is_position_in_pattern(game, i, ct)
        // Cipher letter cell background
        let cell_bg = if is_selected {
          @types.color_amber
        } else if in_pattern {
          // Highlighted pattern: pulsing teal/cyan background
          let pulse = @types.sinf(
              Float::from_int(game.frame_count) * 0.12,
            ) *
            0.3 +
            0.7
          let alpha = (pulse * 140.0).to_int()
          @raylib.Color::new(0, 120, 160, alpha)
        } else {
          @types.color_bg
        }
        @raylib.draw_rectangle(x, cipher_y, cell_w - 2, cell_h - 2, cell_bg)
        // Cipher letter
        let cipher_color = if is_selected {
          @types.color_bg
        } else {
          @types.color_cyan
        }
        @draw.draw_text(c.to_string(), x + 6, cipher_y + 6, 20, cipher_color)
        // Plain letter below
        if pi >= 0 {
          let plain_char = @types.idx_to_char(pi)
          let expected = @types.str_char_at(level.plaintext, i)
          let is_correct = plain_char == expected
          let plain_color = if is_correct {
            @types.color_green
          } else {
            @types.color_red
          }
          @raylib.draw_rectangle(
            x,
            plain_y,
            cell_w - 2,
            cell_h - 2,
            @raylib.Color::new(0, 0, 0, 200),
          )
          @draw.draw_text(
            plain_char.to_string(),
            x + 6,
            plain_y + 6,
            20,
            plain_color,
          )
        } else {
          @raylib.draw_rectangle(
            x,
            plain_y,
            cell_w - 2,
            cell_h - 2,
            @raylib.Color::new(30, 0, 0, 200),
          )
          @draw.draw_text("_", x + 6, plain_y + 6, 20, @types.color_red)
        }
      } else {
        // Space or punctuation
        @draw.draw_text(
          c.to_string(),
          x + 6,
          cipher_y + 6,
          20,
          @types.color_dim,
        )
        @draw.draw_text(c.to_string(), x + 6, plain_y + 6, 20, @types.color_dim)
      }
    }
    col += 1
    // Word wrap at spaces
    if c == ' ' || col >= max_cols {
      if c == ' ' || col > max_cols {
        col = 0
        row += 1
      }
    }
  }
}

///|
fn draw_alphabet_strip(game : @types.Game, level : @types.Level) -> Unit {
  let strip_y = @types.screen_height - 65
  let strip_x = 40
  let cell_w = 42
  @raylib.draw_rectangle(
    strip_x - 10,
    strip_y - 10,
    26 * cell_w + 20,
    60,
    @types.color_panel,
  )
  @raylib.draw_rectangle_lines(
    strip_x - 10,
    strip_y - 10,
    26 * cell_w + 20,
    60,
    @types.color_panel_border,
  )
  ignore(level)
  for i in 0..<26 {
    let x = strip_x + i * cell_w
    let letter = @types.idx_to_char(i)
    let is_selected = i == game.selected_cipher_letter
    let is_mapped = game.mapping.cipher_to_plain[i] >= 0
    // Background
    let bg = if is_selected {
      @types.color_amber
    } else if is_mapped {
      @types.color_dark_green
    } else {
      @types.color_bg
    }
    @raylib.draw_rectangle(x, strip_y, cell_w - 4, 44, bg)
    // Cipher letter on top
    let tc = if is_selected { @types.color_bg } else { @types.color_cyan }
    @draw.draw_text(letter.to_string(), x + 4, strip_y + 2, 14, tc)
    // Mapped plain letter below
    let pi = game.mapping.cipher_to_plain[i]
    if pi >= 0 {
      let plain_ch = @types.idx_to_char(pi)
      @draw.draw_text(
        plain_ch.to_string(),
        x + 4,
        strip_y + 22,
        16,
        @types.color_green,
      )
    } else {
      @draw.draw_text("?", x + 4, strip_y + 22, 16, @types.color_red)
    }
  }
}
