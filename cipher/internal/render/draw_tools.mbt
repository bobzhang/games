///|
fn draw_tool_panel(game : @types.Game, level : @types.Level) -> Unit {
  let px = @types.tool_panel_x
  let pw = @types.tool_panel_w
  let py = 55
  let ph = @types.screen_height - 125
  // Panel background
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_panel_border)
  // Tool tabs
  let tools : Array[@types.Tool] = [FrequencyChart, LetterSwap, PatternFinder]
  let tab_names : Array[String] = ["FREQ", "SWAP", "PATTERN"]
  let tab_w = pw / 3
  for t in 0..<3 {
    let tx = px + t * tab_w
    let is_active = tools[t] == game.active_tool
    let bg = if is_active {
      @types.color_highlight
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(tx, py, tab_w, 30, bg)
    @raylib.draw_rectangle_lines(tx, py, tab_w, 30, @types.color_panel_border)
    let tc = if is_active { @types.color_green } else { @types.color_dim }
    @draw.draw_text(tab_names[t], tx + 10, py + 7, 14, tc)
  }
  let content_y = py + 40
  match game.active_tool {
    FrequencyChart => draw_frequency_chart(game, level, px, content_y, pw)
    LetterSwap => draw_letter_swap(game, level, px, content_y, pw)
    PatternFinder => draw_pattern_finder(game, level, px, content_y, pw)
  }
  // Hint button at bottom
  let hint_y = py + ph - 70
  draw_button(px + 10, hint_y, pw - 20, 30, "HINT (H)", @types.color_amber)
  // Undo button
  let undo_y = hint_y + 35
  draw_button(px + 10, undo_y, pw - 20, 30, "UNDO (Z)", @types.color_cyan)
}

///|
fn draw_frequency_chart(
  game : @types.Game,
  level : @types.Level,
  px : Int,
  py : Int,
  pw : Int,
) -> Unit {
  @draw.draw_text(
    "FREQUENCY ANALYSIS",
    px + 10,
    py,
    14,
    @types.color_text,
  )
  let cipher_freq = @crypto.letter_frequency_pct(level.ciphertext)
  let chart_x = px + 10
  let chart_y = py + 22
  let chart_h = 280
  let half_bar = (pw - 30) / 26 / 2
  let pair_w = half_bar * 2
  // Find max for scaling
  let mut max_freq : Float = 1.0
  for i in 0..<26 {
    if cipher_freq[i] > max_freq {
      max_freq = cipher_freq[i]
    }
    if @types.english_freq[i] > max_freq {
      max_freq = @types.english_freq[i]
    }
  }
  let bar_area_h = chart_h - 40
  let baseline_y = chart_y + bar_area_h
  // Hover detection
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let mut hovered_letter = -1
  for i in 0..<26 {
    let bx = chart_x + i * pair_w
    if mx >= bx && mx < bx + pair_w && my >= chart_y && my < baseline_y + 15 {
      hovered_letter = i
    }
  }
  for i in 0..<26 {
    let bx = chart_x + i * pair_w
    let is_hovered = i == hovered_letter
    // English bar (left half, blue-tinted)
    let eng_h = (@types.english_freq[i] / max_freq * Float::from_int(
        bar_area_h,
      )).to_int()
    let eng_color = if is_hovered {
      @raylib.Color::new(80, 80, 150, 220)
    } else {
      @types.color_bar_english
    }
    @raylib.draw_rectangle(
      bx,
      baseline_y - eng_h,
      half_bar - 1,
      eng_h,
      eng_color,
    )
    // Cipher bar (right half, green-tinted)
    let cip_h = (cipher_freq[i] / max_freq * Float::from_int(bar_area_h)).to_int()
    let cip_color = if is_hovered {
      @raylib.Color::new(0, 220, 100, 240)
    } else {
      @types.color_bar_cipher
    }
    @raylib.draw_rectangle(
      bx + half_bar,
      baseline_y - cip_h,
      half_bar - 1,
      cip_h,
      cip_color,
    )
    // Overlay outline when bars differ significantly (visual comparison aid)
    let diff = @types.absf(cipher_freq[i] - @types.english_freq[i])
    if diff > 4.0 {
      let taller_h = if eng_h > cip_h { eng_h } else { cip_h }
      let pulse = @types.sinf(
          Float::from_int(game.frame_count) * 0.08 + Float::from_int(i) * 0.5,
        ) *
        0.3 +
        0.7
      let outline_alpha = (pulse * 80.0).to_int()
      @raylib.draw_rectangle_lines(
        bx,
        baseline_y - taller_h,
        pair_w - 1,
        taller_h,
        @raylib.Color::new(255, 200, 50, outline_alpha),
      )
    }
    // Letter label
    let letter = @types.idx_to_char(i)
    let label_color = if is_hovered {
      @types.color_white
    } else {
      @types.color_dim
    }
    @draw.draw_text(letter.to_string(), bx + 1, baseline_y + 2, 9, label_color)
  }
  // Hover tooltip with percentages
  if hovered_letter >= 0 {
    let tip_y = baseline_y + 16
    let letter = @types.idx_to_char(hovered_letter)
    let eng_pct = @types.english_freq[hovered_letter]
    let cip_pct = cipher_freq[hovered_letter]
    let eng_int = eng_pct.to_int()
    let cip_int = cip_pct.to_int()
    let tip = letter.to_string() +
      ": Eng " +
      eng_int.to_string() +
      "% / Cip " +
      cip_int.to_string() +
      "%"
    @draw.draw_text(tip, px + 10, tip_y, 12, @types.color_amber)
    // Show current mapping if any
    let pi = game.mapping.cipher_to_plain[hovered_letter]
    if pi >= 0 {
      let mapped = @types.idx_to_char(pi)
      let map_txt = "Mapped: " +
        letter.to_string() +
        " -> " +
        mapped.to_string()
      @draw.draw_text(map_txt, px + 10, tip_y + 16, 12, @types.color_green)
    }
  } else {
    let tip_y = baseline_y + 16
    @draw.draw_text(
      "Hover a bar for details",
      px + 10,
      tip_y,
      11,
      @types.color_dim,
    )
  }
  // Legend
  let legend_y = baseline_y + 50
  @raylib.draw_rectangle(chart_x, legend_y, 10, 10, @types.color_bar_english)
  @draw.draw_text("English", chart_x + 14, legend_y, 11, @types.color_dim)
  @raylib.draw_rectangle(chart_x + 80, legend_y, 10, 10, @types.color_bar_cipher)
  @draw.draw_text("Cipher", chart_x + 94, legend_y, 11, @types.color_dim)
  // Top English letters guide
  @draw.draw_text(
    "E(12.7) T(9.1) A(8.2) O(7.5)",
    px + 10,
    legend_y + 18,
    10,
    @types.color_dim,
  )
  @draw.draw_text(
    "I(7.0) N(6.7) S(6.3) H(6.1)",
    px + 10,
    legend_y + 32,
    10,
    @types.color_dim,
  )
}

///|
fn draw_letter_swap(
  game : @types.Game,
  level : @types.Level,
  px : Int,
  py : Int,
  _pw : Int,
) -> Unit {
  ignore(level)
  @draw.draw_text("LETTER MAPPING", px + 10, py, 14, @types.color_text)
  if game.selected_cipher_letter >= 0 {
    let sel_ch = @types.idx_to_char(game.selected_cipher_letter)
    let sel_txt = "Selected: " + sel_ch.to_string()
    @draw.draw_text(sel_txt, px + 10, py + 22, 16, @types.color_amber)
    @draw.draw_text(
      "Click a letter below to assign:",
      px + 10,
      py + 45,
      12,
      @types.color_dim,
    )
  } else {
    @draw.draw_text(
      "Click a cipher letter to select",
      px + 10,
      py + 22,
      14,
      @types.color_dim,
    )
  }
  // Plain letter grid for assignment
  let grid_y = py + 72
  let cell = 40
  for i in 0..<26 {
    let col = i % 7
    let row = i / 7
    let gx = px + 15 + col * (cell + 4)
    let gy = grid_y + row * (cell + 4)
    let letter = @types.idx_to_char(i)
    let used = game.mapping.plain_used[i]
    let bg = if used { @types.color_dark_green } else { @types.color_button }
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= gx && mx < gx + cell && my >= gy && my < gy + cell
    let draw_bg = if hover && game.selected_cipher_letter >= 0 {
      @types.color_button_hover
    } else {
      bg
    }
    @raylib.draw_rectangle(gx, gy, cell, cell, draw_bg)
    @raylib.draw_rectangle_lines(gx, gy, cell, cell, @types.color_panel_border)
    let tc = if used { @types.color_green } else { @types.color_text }
    @draw.draw_text(letter.to_string(), gx + 10, gy + 8, 20, tc)
  }
  // Current mappings list
  let list_y = grid_y + 4 * (cell + 4) + 20
  @draw.draw_text("CURRENT MAPPINGS:", px + 10, list_y, 12, @types.color_dim)
  let mut line = 0
  for i in 0..<26 {
    let pi = game.mapping.cipher_to_plain[i]
    if pi >= 0 {
      let from = @types.idx_to_char(i)
      let to = @types.idx_to_char(pi)
      let map_txt = from.to_string() + " -> " + to.to_string()
      let col_num = line % 4
      let row_num = line / 4
      @draw.draw_text(
        map_txt,
        px + 15 + col_num * 80,
        list_y + 18 + row_num * 18,
        12,
        @types.color_green,
      )
      line += 1
    }
  }
}

///|
fn draw_pattern_finder(
  game : @types.Game,
  level : @types.Level,
  px : Int,
  py : Int,
  _pw : Int,
) -> Unit {
  @draw.draw_text("PATTERN ANALYSIS", px + 10, py, 14, @types.color_text)
  // Show cipher kind info
  let kind_txt = match level.cipher_kind {
    Caesar => "Caesar: All letters shifted by same amount"
    Substitution => "Substitution: Each letter maps to one other"
    Vigenere => "Vigenere: Repeating key shifts letters"
  }
  @draw.draw_text(kind_txt, px + 10, py + 22, 11, @types.color_dim)
  // Find patterns
  let patterns = if game.patterns_dirty {
    let p = @crypto.find_repeated_patterns(level.ciphertext, 3, 6)
    game.cached_patterns = p
    game.patterns_dirty = false
    p
  } else {
    game.cached_patterns
  }
  let pat_y = py + 50
  @draw.draw_text("Repeated sequences:", px + 10, pat_y, 13, @types.color_amber)
  let max_show = @types.mini(patterns.length(), 12)
  for i in 0..<max_show {
    let p = patterns[i]
    let txt = p.pattern +
      " (x" +
      p.count.to_string() +
      ") at positions: " +
      positions_to_string(p.positions)
    @draw.draw_text(txt, px + 10, pat_y + 20 + i * 18, 11, @types.color_text)
  }
  if patterns.length() == 0 {
    @draw.draw_text(
      "No repeated patterns found",
      px + 10,
      pat_y + 20,
      12,
      @types.color_dim,
    )
  }
  // For Vigenere, show spacing analysis
  if level.cipher_kind == Vigenere && patterns.length() > 0 {
    let spacing_y = pat_y + 25 + max_show * 18
    @draw.draw_text(
      "SPACING ANALYSIS (key length clues):",
      px + 10,
      spacing_y,
      12,
      @types.color_amber,
    )
    let mut line = 0
    for i in 0..<@types.mini(patterns.length(), 5) {
      let p = patterns[i]
      if p.positions.length() >= 2 {
        let gap = p.positions[1] - p.positions[0]
        let gap_txt = p.pattern + ": spacing=" + gap.to_string()
        @draw.draw_text(
          gap_txt,
          px + 10,
          spacing_y + 18 + line * 16,
          11,
          @types.color_text,
        )
        line += 1
      }
    }
  }
}

///|
fn positions_to_string(positions : Array[Int]) -> String {
  let buf = StringBuilder::new()
  for i in 0..<positions.length() {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(positions[i].to_string())
  }
  buf.to_string()
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  color : @raylib.Color,
) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hover = mx >= x && mx < x + w && my >= y && my < y + h
  let bg = if hover { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines(x, y, w, h, color)
  let tw = @draw.measure_text(text, 14)
  @draw.draw_text(text, x + (w - tw) / 2, y + (h - 14) / 2, 14, color)
}
