///|
fn draw_title(game : @types.Game) -> Unit {
  // Animated quilt pattern background
  let t = Float::from_int(game.frame_count) * 0.02
  for row in 0..<9 {
    for col in 0..<16 {
      let px = col * 80
      let py = row * 80
      let phase = @types.sinf(t + Float::from_int(row + col) * 0.5)
      let alpha_val = 30 + (phase * 20.0).to_int()
      let alpha_val = if alpha_val < 0 {
        0
      } else if alpha_val > 255 {
        255
      } else {
        alpha_val
      }
      let pat_idx = (row + col) % 6
      let base_c = @types.pattern_color(@types.pattern_at(pat_idx))
      let c = @raylib.Color::new(
        base_c.r.to_int(),
        base_c.g.to_int(),
        base_c.b.to_int(),
        alpha_val,
      )
      @raylib.draw_rectangle(px, py, 80, 80, c)
    }
  }
  // Title text with shadow
  let title = "QUILT"
  let tw = @draw.measure_text(title, 72)
  let tx = (@types.screen_width - tw) / 2
  @draw.draw_text(title, tx + 3, 153, 72, @raylib.Color::new(0, 0, 0, 80))
  @draw.draw_text(title, tx, 150, 72, @types.color_title)
  // Subtitle
  let sub = "Edge-Matching Puzzle"
  let sw = @draw.measure_text(sub, 28)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    235,
    28,
    @types.color_text,
  )
  // Menu options
  let menu_y = 340
  draw_menu_button("Play", @types.screen_width / 2, menu_y, 36)
  draw_menu_button("Daily Board", @types.screen_width / 2, menu_y + 60, 28)
  // Instructions
  @draw.draw_text(
    "Match edge patterns between neighboring patches",
    (
      @types.screen_width -
      @draw.measure_text("Match edge patterns between neighboring patches", 18)
    ) /
    2,
    560,
    18,
    @types.color_text_light,
  )
  @draw.draw_text(
    "Rotate and place to solve each quilt!",
    (
      @types.screen_width -
      @draw.measure_text("Rotate and place to solve each quilt!", 18)
    ) /
    2,
    585,
    18,
    @types.color_text_light,
  )
  // Controls
  @draw.draw_text(
    "[ENTER] Play    [D] Daily    [ESC] Quit",
    (
      @types.screen_width -
      @draw.measure_text("[ENTER] Play    [D] Daily    [ESC] Quit", 20)
    ) /
    2,
    650,
    20,
    @types.color_text,
  )
}

///|
fn draw_menu_button(text : String, cx : Int, y : Int, size : Int) -> Unit {
  let tw = @draw.measure_text(text, size)
  let bx = cx - tw / 2 - 20
  let by = y - 4
  let bw = tw + 40
  let bh = size + 12
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hover = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
  let bg = if hover { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(bx, by, bw, bh, bg)
  @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_grid_line)
  @draw.draw_text(text, cx - tw / 2, y, size, @raylib.white)
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  @draw.draw_text("Select Tier", 100, 40, 36, @types.color_title)
  let tiers : Array[@types.Tier] = [Scraps, Quilting, Masterwork]
  let tier_descs = [
    "3x3 grids, 3-4 patterns, learn the basics", "4x4 grids, all patterns, pinned patches",
    "4x4/5x5 grids, wildcards, master challenge",
  ]
  let tier_sizes = ["8 levels", "9 levels", "8 levels"]
  for i in 0..<3 {
    let ty = 120 + i * 170
    let bx = 100
    let bw = 1080
    let bh = 150
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= bx && mx <= bx + bw && my >= ty && my <= ty + bh
    let bg = if hover {
      @types.color_button_hover
    } else if i == game.tier_select_index {
      @types.color_button
    } else {
      @types.color_tray_bg
    }
    @raylib.draw_rectangle(bx, ty, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, ty, bw, bh, @types.color_grid_line)
    let text_c = if hover || i == game.tier_select_index {
      @raylib.white
    } else {
      @types.color_text
    }
    @draw.draw_text(
      "Tier " + (i + 1).to_string() + ": " + @types.tier_name(tiers[i]),
      bx + 20,
      ty + 15,
      30,
      text_c,
    )
    @draw.draw_text(tier_descs[i], bx + 20, ty + 55, 18, text_c)
    @draw.draw_text(tier_sizes[i], bx + 20, ty + 80, 16, text_c)
    // Show completion
    let (start, count) = @types.tier_levels(tiers[i])
    let mut completed = 0
    for j in 0..<count {
      if start + j < game.level_scores.length() &&
        game.level_scores[start + j].completed {
        completed += 1
      }
    }
    @draw.draw_text(
      completed.to_string() + "/" + count.to_string() + " complete",
      bx + bw - 200,
      ty + 60,
      20,
      text_c,
    )
  }
  @draw.draw_text(
    "[1/2/3] Select Tier    [ESC] Back", 100, 660, 20, @types.color_text_light,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.current_tier
  let (start, count) = @types.tier_levels(tier)
  @draw.draw_text(
    @types.tier_name(tier) + " - Select Level",
    100,
    40,
    32,
    @types.color_title,
  )
  let cols = 5
  let cell_w = 180
  let cell_h = 100
  let gap = 20
  let ox = 100
  let oy = 100
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let cx = ox + col * (cell_w + gap)
    let cy = oy + row * (cell_h + gap)
    let level_idx = start + i
    let score = game.level_scores[level_idx]
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= cx && mx <= cx + cell_w && my >= cy && my <= cy + cell_h
    let bg = if hover {
      @types.color_button_hover
    } else if score.completed {
      @raylib.Color::new(180, 220, 180, 255)
    } else {
      @types.color_tray_bg
    }
    @raylib.draw_rectangle(cx, cy, cell_w, cell_h, bg)
    @raylib.draw_rectangle_lines(cx, cy, cell_w, cell_h, @types.color_grid_line)
    let text_c = if hover { @raylib.white } else { @types.color_text }
    @draw.draw_text(
      "Level " + (i + 1).to_string(),
      cx + 10,
      cy + 10,
      22,
      text_c,
    )
    if score.completed {
      draw_stars(cx + 10, cy + 40, score.stars, 16)
      @draw.draw_text(
        "R:" +
        score.best_rotations.to_string() +
        " S:" +
        score.best_swaps.to_string(),
        cx + 10,
        cy + 70,
        14,
        text_c,
      )
    }
  }
  @draw.draw_text(
    "[1-9] or Click to select    [ESC] Back", 100, 660, 20, @types.color_text_light,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 100),
  )
  // Results card
  let card_w = 500
  let card_h = 400
  let card_x = (@types.screen_width - card_w) / 2
  let card_y = (@types.screen_height - card_h) / 2
  @raylib.draw_rectangle(card_x, card_y, card_w, card_h, @types.color_bg)
  @raylib.draw_rectangle_lines(
    card_x, card_y, card_w, card_h, @types.color_grid_line,
  )
  let title = if game.is_daily {
    "Daily Quilt Complete!"
  } else {
    "Level " + game.current_level.to_string() + " Complete!"
  }
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(
    title,
    card_x + (card_w - tw) / 2,
    card_y + 20,
    32,
    @types.color_title,
  )
  // Stars
  let level = @levels.get_level(game.current_level - 1)
  let stars = @matching.compute_stars(level, game.rotations, game.swaps)
  draw_stars(card_x + card_w / 2 - 36, card_y + 70, stars, 24)
  // Stats
  let sy = card_y + 120
  @draw.draw_text(
    "Rotations: " + game.rotations.to_string(),
    card_x + 50,
    sy,
    24,
    @types.color_text,
  )
  @draw.draw_text(
    "(par: " + level.par_rotations.to_string() + ")",
    card_x + 280,
    sy,
    24,
    if game.rotations <= level.par_rotations {
      @types.color_matched
    } else {
      @types.color_mismatched
    },
  )
  @draw.draw_text(
    "Swaps: " + game.swaps.to_string(),
    card_x + 50,
    sy + 40,
    24,
    @types.color_text,
  )
  @draw.draw_text(
    "(par: " + level.par_swaps.to_string() + ")",
    card_x + 280,
    sy + 40,
    24,
    if game.swaps <= level.par_swaps {
      @types.color_matched
    } else {
      @types.color_mismatched
    },
  )
  // Matched edges
  let total = @matching.count_edge_pairs(game.board)
  let matched = @matching.count_matched_pairs(game.board)
  @draw.draw_text(
    "Edges matched: " + matched.to_string() + "/" + total.to_string(),
    card_x + 50,
    sy + 80,
    24,
    @types.color_text,
  )
  // Buttons
  let btn_y = card_y + card_h - 80
  if !game.is_daily {
    draw_menu_button("Next Level", card_x + card_w / 4, btn_y, 22)
    draw_menu_button("Retry", card_x + card_w * 3 / 4, btn_y, 22)
  } else {
    draw_menu_button("Back to Menu", card_x + card_w / 2, btn_y, 22)
  }
  @draw.draw_text(
    "[ENTER] Next    [R] Retry    [ESC] Menu",
    card_x + 50,
    card_y + card_h - 30,
    16,
    @types.color_text_light,
  )
}
