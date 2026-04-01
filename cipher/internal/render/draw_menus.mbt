///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Scrolling encrypted text background
  for row in 0..<18 {
    for col in 0..<52 {
      let seed = row * 52 + col
      let offset = (Float::from_int(seed) * 7.3 + time * 30.0).to_int()
      let ch_idx = (offset % 26 + 26) % 26
      let ch = @types.idx_to_char(ch_idx)
      let alpha = 20 +
        ((@types.sinf(Float::from_int(seed) * 0.5 + time) + 1.0) * 15.0).to_int()
      @draw.draw_text(
        ch.to_string(),
        col * 25,
        row * 42,
        16,
        @raylib.Color::new(0, 80, 40, alpha),
      )
    }
  }
  // Title
  let title = "C I P H E R"
  let tw = @draw.measure_text(title, 64)
  let pulse = (@types.sinf(time * 2.0) * 30.0).to_int()
  @draw.draw_text(
    title,
    (w - tw) / 2,
    h / 4 - 20,
    64,
    @raylib.Color::new(0, (200 + pulse).land(255), 100, 255),
  )
  // Subtitle
  let sub = "CODEBREAKING CASEFILE"
  let sw = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sw) / 2, h / 4 + 60, 22, @types.color_amber)
  // Tagline
  let tag = "Decode encrypted spy messages. Crack the code."
  let tagw = @draw.measure_text(tag, 16)
  @draw.draw_text(tag, (w - tagw) / 2, h / 4 + 95, 16, @types.color_dim)
  // Start prompt
  let start_text = "PRESS ENTER TO BEGIN"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 80 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(0, 220, 100, blink),
  )
  // Controls hint
  @draw.draw_text(
    "Click letters to map | Z=Undo | H=Hint | ESC=Back",
    w / 2 - 240,
    h * 3 / 4 + 50,
    14,
    @types.color_dim,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "SELECT TIER"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 40, 36, @types.color_green)
  let tiers : Array[@types.Tier] = [Recruit, Agent, Cryptographer]
  let descs : Array[String] = [
    "Caesar Cipher - 8 Missions", "Substitution Cipher - 9 Missions", "Vigenere Cipher - 8 Missions",
  ]
  let tier_icons : Array[String] = ["[I]", "[II]", "[III]"]
  for t in 0..<3 {
    let bx = w / 2 - 200
    let by = 140 + t * 160
    let bw = 400
    let bh = 130
    let is_selected = tiers[t] == game.selected_tier
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if is_selected {
      @types.color_highlight
    } else if hover {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      bw,
      bh,
      if is_selected {
        @types.color_green
      } else {
        @types.color_panel_border
      },
    )
    // Tier icon and name
    let tier_label = tier_icons[t] + " " + @types.tier_name(tiers[t])
    @draw.draw_text(tier_label, bx + 20, by + 15, 28, @types.color_white)
    @draw.draw_text(descs[t], bx + 20, by + 55, 16, @types.color_text)
    // Show star count for tier
    let (start, end_) = @types.tier_level_range(tiers[t])
    let mut total_stars = 0
    let mut completed = 0
    for i = start; i <= end_; i = i + 1 {
      total_stars += game.level_scores[i].stars
      if game.level_scores[i].completed {
        completed += 1
      }
    }
    let max_stars = (end_ - start + 1) * 3
    let progress = completed.to_string() +
      "/" +
      (end_ - start + 1).to_string() +
      " complete"
    @draw.draw_text(progress, bx + 20, by + 85, 14, @types.color_dim)
    let star_txt = total_stars.to_string() +
      "/" +
      max_stars.to_string() +
      " stars"
    @draw.draw_text(star_txt, bx + 250, by + 85, 14, @types.color_star_gold)
  }
  @draw.draw_text("ESC = Back", 20, h - 30, 14, @types.color_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let tier = game.selected_tier
  let title = @types.tier_name(tier) + " MISSIONS"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(title, (w - tw) / 2, 30, 32, @types.color_green)
  let (start, end_) = @types.tier_level_range(tier)
  let count = end_ - start + 1
  let cols = if count <= 4 { count } else { 5 }
  let cell_w = 180
  let cell_h = 120
  let gap = 15
  let grid_w = cols * cell_w + (cols - 1) * gap
  let base_x = (w - grid_w) / 2
  let base_y = 100
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i = 0; i < count; i = i + 1 {
    let level_id = start + i
    let col = i % cols
    let row = i / cols
    let bx = base_x + col * (cell_w + gap)
    let by = base_y + row * (cell_h + gap)
    let score = game.level_scores[level_id]
    let hover = mx >= bx && mx < bx + cell_w && my >= by && my < by + cell_h
    let selected = game.selected_level == level_id
    let bg = if selected {
      @types.color_highlight
    } else if hover {
      @types.color_button_hover
    } else {
      @types.color_panel
    }
    @raylib.draw_rectangle(bx, by, cell_w, cell_h, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      cell_w,
      cell_h,
      if selected {
        @types.color_green
      } else {
        @types.color_panel_border
      },
    )
    // Mission number
    let num_str = "CASE " + (level_id + 1).to_string()
    @draw.draw_text(num_str, bx + 10, by + 10, 20, @types.color_white)
    // Stars
    for s in 0..<3 {
      let star_x = bx + 10 + s * 22
      let star_y = by + 45
      let star_color = if s < score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", star_x, star_y, 24, star_color)
    }
    // Status
    let status = if score.completed { "DECODED" } else { "LOCKED" }
    let scolor = if score.completed {
      @types.color_green
    } else {
      @types.color_red
    }
    @draw.draw_text(status, bx + 10, by + 80, 14, scolor)
    if score.completed {
      let swaps_txt = "Swaps: " + score.best_swaps.to_string()
      @draw.draw_text(swaps_txt, bx + 90, by + 80, 12, @types.color_dim)
    }
  }
  @draw.draw_text(
    "Click a case to start | ESC = Back",
    20,
    h - 30,
    14,
    @types.color_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level = @levels.get_level(game.current_level)
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(5, 8, 12, 230))
  let title = if game.play_state == Solved {
    "CASE DECODED"
  } else {
    "CASE FAILED"
  }
  let tc = if game.play_state == Solved {
    @types.color_green
  } else {
    @types.color_red
  }
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(title, (w - tw) / 2, h / 4 - 30, 48, tc)
  // Plaintext reveal
  let ptw = @draw.measure_text(level.plaintext, 20)
  @draw.draw_text(
    level.plaintext,
    (w - ptw) / 2,
    h / 4 + 40,
    20,
    @types.color_amber,
  )
  // Stats
  if game.play_state == Solved {
    let stars = @types.calc_stars(
      game.swap_count,
      level.par_swaps,
      game.hints_used,
    )
    // Draw stars
    for s in 0..<3 {
      let sx = w / 2 - 60 + s * 50
      let sy = h / 2 - 20
      let sc = if s < stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", sx, sy, 48, sc)
    }
    let swap_txt = "Swaps: " +
      game.swap_count.to_string() +
      " (Par: " +
      level.par_swaps.to_string() +
      ")"
    let sww = @draw.measure_text(swap_txt, 18)
    @draw.draw_text(swap_txt, (w - sww) / 2, h / 2 + 50, 18, @types.color_text)
    let hint_txt = "Hints used: " + game.hints_used.to_string()
    let hiw = @draw.measure_text(hint_txt, 18)
    @draw.draw_text(hint_txt, (w - hiw) / 2, h / 2 + 80, 18, @types.color_text)
  }
  // Continue prompt
  let cont = "PRESS ENTER FOR NEXT CASE | ESC = BACK TO MISSIONS"
  let cw = @draw.measure_text(cont, 16)
  let blink = if game.frame_count % 50 < 35 { 255 } else { 100 }
  @draw.draw_text(
    cont,
    (w - cw) / 2,
    h * 3 / 4 + 40,
    16,
    @raylib.Color::new(0, 220, 100, blink),
  )
}
