///|
fn draw_playing(game : @types.Game) -> Unit {
  let level_idx = @types.tier_level_offset(game.current_tier) +
    game.current_level
  let level = @levels.get_level(level_idx)
  // Header
  draw_header(game, level)
  // Sequence display
  draw_sequence(game)
  // Codon grouping and trait readout
  draw_trait_readout(game)
  // Target comparison
  draw_target_comparison(game, level)
  // Operation palette
  draw_ops_panel(game, level)
  // Help overlay
  if game.show_help {
    draw_help_overlay()
  }
}

///|
fn draw_header(game : @types.Game, level : @types.Level) -> Unit {
  let w = @types.screen_width
  // Level name
  @draw.draw_text(level.name, 20, 15, 24, @types.color_highlight)
  // Edit counter
  let edits = "Edits: " +
    game.edit_count.to_string() +
    " / " +
    level.edit_budget.to_string()
  let edits_color = if game.edit_count >= level.edit_budget {
    @types.color_fail
  } else if game.edit_count > level.par_edits {
    @types.color_star
  } else {
    @types.color_success
  }
  @draw.draw_text(edits, w - 200, 15, 20, edits_color)
  // Par info
  let par = "Par: " +
    level.par_edits.to_string() +
    "  Min: " +
    level.min_edits.to_string()
  @draw.draw_text(par, w - 200, 40, 14, @types.color_text_dim)
  // Level description
  @draw.draw_text(level.description, 20, 50, 14, @types.color_text_dim)
  // Separator
  @raylib.draw_line(20, 75, w - 20, 75, @types.color_panel_border)
  // Controls hint
  @draw.draw_text(
    "Arrows:move  Shift+Arrow:select  Enter:apply  V:verify  Z:undo  R:restart  H:help  Tab:base  Esc:back",
    20, 80, 12, @types.color_text_dim,
  )
}

///|
fn draw_sequence(game : @types.Game) -> Unit {
  let seq = game.current_sequence
  let base_size = @types.seq_base_size
  let gap = @types.seq_base_gap
  let sy = @types.seq_y
  let total_width = seq.length() * (base_size + gap)
  // Scroll offset if sequence is too long
  let max_visible_width = @types.screen_width - 80
  let scroll_offset = if total_width > max_visible_width {
    let cursor_x = game.cursor * (base_size + gap)
    let center = max_visible_width / 2
    let offset = cursor_x - center
    if offset < 0 {
      0
    } else if offset > total_width - max_visible_width {
      total_width - max_visible_width
    } else {
      offset
    }
  } else {
    0
  }
  let sx_start = @types.seq_x_start - scroll_offset
  // Label
  @draw.draw_text("SEQUENCE:", 20, sy - 30, 16, @types.color_text_dim)
  @draw.draw_text(
    "(" + seq.length().to_string() + " bases)",
    130,
    sy - 30,
    14,
    @types.color_text_dim,
  )
  // Draw codon grouping brackets above
  draw_codon_brackets(game, sx_start, sy - 15)
  // Selection highlight
  if @types.has_selection(game) {
    let s = @types.selection_min(game)
    let e = @types.selection_max(game)
    let sel_x = sx_start + s * (base_size + gap) - 2
    let sel_w = (e - s) * (base_size + gap) + 4
    @raylib.draw_rectangle(
      sel_x,
      sy - 2,
      sel_w,
      base_size + 4,
      @types.color_selection,
    )
  }
  // Draw bases
  for i in 0..<seq.length() {
    let bx = sx_start + i * (base_size + gap)
    // Skip if off screen
    if bx + base_size < 0 || bx > @types.screen_width {
      continue
    }
    let base = seq[i]
    let color = @types.base_color(base)
    // Base background
    @raylib.draw_rectangle(
      bx,
      sy,
      base_size,
      base_size,
      @raylib.Color::new(
        color.r.to_int(),
        color.g.to_int(),
        color.b.to_int(),
        60,
      ),
    )
    @raylib.draw_rectangle_lines(bx, sy, base_size, base_size, color)
    // Base letter
    let letter = @types.base_char(base)
    let lw = @draw.measure_text(letter, 20)
    @draw.draw_text(
      letter,
      bx + (base_size - lw) / 2,
      sy + (base_size - 20) / 2,
      20,
      color,
    )
    // Position numbers (every 3rd)
    if i % 3 == 0 {
      @draw.draw_text(
        i.to_string(),
        bx,
        sy + base_size + 4,
        10,
        @types.color_text_dim,
      )
    }
  }
  // Cursor
  let cursor_x = sx_start + game.cursor * (base_size + gap) - 2
  let blink = game.frame_count % 40 < 25
  if blink {
    @raylib.draw_rectangle(
      cursor_x,
      sy - 4,
      3,
      base_size + 8,
      @types.color_cursor,
    )
  }
  // Current operation indicator at cursor
  let op_color = @types.op_color(game.selected_op)
  let op_label = @types.op_name(game.selected_op)
  @draw.draw_text(op_label, cursor_x - 10, sy + base_size + 20, 12, op_color)
  // If insert mode, show which base will be inserted
  if game.selected_op == Insert {
    let ins_label = "[" + @types.base_char(game.insert_base) + "]"
    @draw.draw_text(
      ins_label,
      cursor_x + 40,
      sy + base_size + 20,
      12,
      @types.base_color(game.insert_base),
    )
  }
}

///|
fn draw_codon_brackets(game : @types.Game, sx_start : Int, y : Int) -> Unit {
  let seq = game.current_sequence
  let base_size = @types.seq_base_size
  let gap = @types.seq_base_gap
  // Find start codon
  let start = @dna.find_start_codon(seq)
  if start < 0 {
    // No reading frame - draw a subtle warning indicator
    @draw.draw_text(
      "no ATG",
      sx_start,
      y - 8,
      10,
      @raylib.Color::new(200, 80, 80, 140),
    )
    return
  }
  let mut pos = start
  while pos + 2 < seq.length() {
    let bx1 = sx_start + pos * (base_size + gap)
    let bx2 = sx_start + (pos + 2) * (base_size + gap) + base_size
    // Color bracket with the trait's color for instant identification
    let tr = @types.codon_to_trait(seq[pos], seq[pos + 1], seq[pos + 2])
    let trait_col = @types.trait_color(tr)
    let bracket_color = @raylib.Color::new(
      trait_col.r.to_int(),
      trait_col.g.to_int(),
      trait_col.b.to_int(),
      160,
    )
    // Draw bracket: top bar with tick marks
    @raylib.draw_line(bx1, y, bx2, y, bracket_color)
    @raylib.draw_line(bx1, y, bx1, y + 6, bracket_color)
    @raylib.draw_line(bx2, y, bx2, y + 6, bracket_color)
    // Double the bracket lines for thickness
    @raylib.draw_line(bx1, y - 1, bx2, y - 1, bracket_color)
    // Draw trait abbreviation label above the bracket
    let label = @types.trait_name(tr)
    let label_w = @draw.measure_text(label, 9)
    let label_x = bx1 + (bx2 - bx1 - label_w) / 2
    @draw.draw_text(label, label_x, y - 12, 9, bracket_color)
    // Draw subtle codon background tint behind the 3 bases
    let tint_y = y + 8
    let tint_h = base_size + 12
    @raylib.draw_rectangle(
      bx1 - 1,
      tint_y,
      bx2 - bx1 + 2,
      tint_h,
      @raylib.Color::new(
        trait_col.r.to_int(),
        trait_col.g.to_int(),
        trait_col.b.to_int(),
        20,
      ),
    )
    if tr == Stop {
      break
    }
    pos += 3
  }
}

///|
fn draw_trait_readout(game : @types.Game) -> Unit {
  let ty = @types.trait_y
  let groups = @dna.get_codon_groups(game.current_sequence)
  @draw.draw_text("TRAITS:", 20, ty - 25, 16, @types.color_text_dim)
  if groups.length() == 0 {
    @draw.draw_text(
      "No valid reading frame (ATG start codon not found)",
      20,
      ty,
      16,
      @types.color_fail,
    )
    return
  }
  let count_str = "(" + groups.length().to_string() + " codons)"
  @draw.draw_text(count_str, 90, ty - 25, 14, @types.color_text_dim)
  let mut tx = 20
  for i in 0..<groups.length() {
    let group = groups[i]
    let color = @types.trait_color(group.trait_)
    let name = @types.trait_name(group.trait_)
    // Trait box with colored left accent bar
    let box_w = @draw.measure_text(name, 18) + 28
    // Left accent bar (trait color indicator)
    @raylib.draw_rectangle(tx, ty, 4, 30, color)
    // Box background
    @raylib.draw_rectangle(
      tx + 4,
      ty,
      box_w - 4,
      30,
      @raylib.Color::new(
        color.r.to_int(),
        color.g.to_int(),
        color.b.to_int(),
        35,
      ),
    )
    @raylib.draw_rectangle_lines(tx, ty, box_w, 30, color)
    // Trait name
    @draw.draw_text(name, tx + 12, ty + 6, 18, color)
    // Codon bases below in a grouped display
    let mut bx = tx + 4
    for j in 0..<group.bases.length() {
      let bc = @types.base_color(group.bases[j])
      @draw.draw_text(@types.base_char(group.bases[j]), bx, ty + 34, 12, bc)
      bx += 12
    }
    // Arrow between traits
    if i < groups.length() - 1 {
      tx += box_w + 4
      // Colored arrow using a triangle shape
      let arrow_y = ty + 15
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(tx + 10), Float::from_int(arrow_y)),
        @raylib.Vector2::new(Float::from_int(tx + 2), Float::from_int(arrow_y - 5)),
        @raylib.Vector2::new(Float::from_int(tx + 2), Float::from_int(arrow_y + 5)),
        @raylib.Color::new(100, 110, 130, 180),
      )
      tx += 14
    } else {
      tx += box_w
    }
  }
}

///|
fn draw_target_comparison(game : @types.Game, level : @types.Level) -> Unit {
  let ty = @types.target_y
  let target = level.target_traits
  let result = @types.read_sequence(game.current_sequence)
  let produced = result.traits
  let match_count = @dna.count_matching_traits(produced, target)
  let total = target.length()
  let all_matched = match_count == total && produced.length() == target.length()
  // Section label with progress
  @draw.draw_text("TARGET:", 20, ty - 25, 16, @types.color_text_dim)
  let progress_str = match_count.to_string() +
    "/" +
    total.to_string() +
    " matched"
  let progress_color = if all_matched {
    @types.color_success
  } else {
    @types.color_text_dim
  }
  @draw.draw_text(progress_str, 100, ty - 25, 14, progress_color)
  // Draw a subtle progress bar
  let bar_w = 120
  let bar_h = 3
  let bar_x = 210
  let bar_y = ty - 20
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(60, 60, 80, 120),
  )
  let fill_w = if total > 0 { bar_w * match_count / total } else { 0 }
  let fill_color = if all_matched {
    @types.color_success
  } else {
    @raylib.Color::new(80, 160, 220, 200)
  }
  @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, fill_color)
  let mut tx = 20
  for i in 0..<target.length() {
    let tr = target[i]
    let color = @types.trait_color(tr)
    let name = @types.trait_name(tr)
    let matched = i < produced.length() && produced[i] == tr
    let box_w = @draw.measure_text(name, 18) + 28
    // Left accent bar (match indicator)
    let accent_color = if matched {
      @types.color_success
    } else {
      @types.color_fail
    }
    @raylib.draw_rectangle(tx, ty, 4, 30, accent_color)
    // Background color indicates match/mismatch
    let bg_color = if matched {
      @raylib.Color::new(0, 200, 80, 30)
    } else {
      @raylib.Color::new(200, 40, 40, 25)
    }
    @raylib.draw_rectangle(tx + 4, ty, box_w - 4, 30, bg_color)
    let border_color = if matched {
      @types.color_success
    } else {
      @types.color_fail
    }
    @raylib.draw_rectangle_lines(tx, ty, box_w, 30, border_color)
    @draw.draw_text(name, tx + 12, ty + 6, 18, color)
    // Match status below: checkmark or X with what was produced
    if matched {
      @draw.draw_text(
        "OK",
        tx + box_w / 2 - 6,
        ty + 34,
        12,
        @types.color_success,
      )
    } else if i < produced.length() {
      // Show what was produced instead
      let got = @types.trait_name(produced[i])
      @draw.draw_text(
        "got:" + got,
        tx + 2,
        ty + 34,
        10,
        @types.color_fail,
      )
    } else {
      @draw.draw_text("---", tx + box_w / 2 - 8, ty + 34, 12, @types.color_fail)
    }
    // Arrow between target traits
    if i < target.length() - 1 {
      tx += box_w + 4
      let arrow_y = ty + 15
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(tx + 10), Float::from_int(arrow_y)),
        @raylib.Vector2::new(Float::from_int(tx + 2), Float::from_int(arrow_y - 5)),
        @raylib.Vector2::new(Float::from_int(tx + 2), Float::from_int(arrow_y + 5)),
        @raylib.Color::new(100, 110, 130, 180),
      )
      tx += 14
    } else {
      tx += box_w
    }
  }
}
