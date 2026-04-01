///|
fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = game.anim_timer
  // Draw DNA helix animation
  draw_helix_background(time, w, h)
  // Title
  let title = "SPLICE"
  let title_w = @draw.measure_text(title, 72)
  let pulse = sinf(time * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(0, 220, 180, alpha),
  )
  // Subtitle
  let sub = "DNA SEQUENCE EDITING PUZZLE"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 65, 20, @types.color_text_dim)
  // Instructions
  @draw.draw_text(
    "Edit gene sequences to produce target traits",
    w / 2 - 220,
    h / 2 + 20,
    18,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Arrow keys to navigate, Enter to apply, V to verify",
    w / 2 - 240,
    h / 2 + 50,
    18,
    @types.color_text_dim,
  )
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 80 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(0, 200, 160, blink),
  )
}

///|
fn draw_helix_background(time : Float, w : Int, h : Int) -> Unit {
  let cx = Float::from_int(w) / 2.0
  let cy = Float::from_int(h) / 2.0
  let bases = ["A", "T", "G", "C"]
  let colors = [
    @types.color_base_a, @types.color_base_t, @types.color_base_g, @types.color_base_c,
  ]
  for i in 0..<20 {
    let fi = Float::from_int(i)
    let angle = fi * 0.3 + time * 0.8
    let y_off = fi * 30.0 - 300.0 + time * 20.0 % 600.0 - 300.0
    let x1 = cx + sinf(angle) * 80.0
    let x2 = cx - sinf(angle) * 80.0
    let py = cy + y_off
    if py > 0.0 && py < Float::from_int(h) {
      let depth1 = cosf(angle) * 0.5 + 0.5
      let depth2 : Float = 1.0 - depth1
      let alpha1 = (depth1 * 120.0).to_int()
      let alpha2 = (depth2 * 120.0).to_int()
      let bi = i % 4
      let c1 = colors[bi]
      let c2 = colors[(bi + 2) % 4]
      // Draw connecting line
      @raylib.draw_line(
        x1.to_int(),
        py.to_int(),
        x2.to_int(),
        py.to_int(),
        @raylib.Color::new(40, 60, 80, 60),
      )
      // Draw base circles
      @raylib.draw_circle(
        x1.to_int(),
        py.to_int(),
        6.0 * depth1 + 2.0,
        @raylib.Color::new(c1.r.to_int(), c1.g.to_int(), c1.b.to_int(), alpha1),
      )
      @raylib.draw_circle(
        x2.to_int(),
        py.to_int(),
        6.0 * depth2 + 2.0,
        @raylib.Color::new(c2.r.to_int(), c2.g.to_int(), c2.b.to_int(), alpha2),
      )
      // Draw base letters
      if depth1 > 0.3 {
        @draw.draw_text(
          bases[bi],
          x1.to_int() - 4,
          py.to_int() - 6,
          12,
          @raylib.Color::new(255, 255, 255, alpha1),
        )
      }
      if depth2 > 0.3 {
        @draw.draw_text(
          bases[(bi + 2) % 4],
          x2.to_int() - 4,
          py.to_int() - 6,
          12,
          @raylib.Color::new(255, 255, 255, alpha2),
        )
      }
    }
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Title
  let title = "SELECT TIER"
  let title_w = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - title_w) / 2, 40, 36, @types.color_highlight)
  // Draw tiers
  let tier_names = ["LAB BASICS", "GENE EDITING", "MASTERY"]
  let tier_descs = [
    "Learn Cut and Insert (8 levels)", "Add Duplicate and Delete (9 levels)", "Master all 5 operations (8 levels)",
  ]
  for i in 0..<3 {
    let y = 140 + i * 170
    let bx = w / 2 - 280
    let bw = 560
    let bh = 140
    let selected = i == game.current_tier
    let unlocked = @levels.is_tier_unlocked(i, game.level_scores)
    // Background
    let bg_color = if selected {
      @raylib.Color::new(30, 50, 70, 255)
    } else {
      @types.color_panel
    }
    @raylib.draw_rectangle(bx, y, bw, bh, bg_color)
    let border_color = if selected {
      @types.color_highlight
    } else {
      @types.color_panel_border
    }
    @raylib.draw_rectangle_lines(bx, y, bw, bh, border_color)
    if !unlocked {
      // Draw lock overlay
      @raylib.draw_rectangle(bx, y, bw, bh, @raylib.Color::new(0, 0, 0, 150))
      @draw.draw_text(
        "LOCKED",
        bx + bw / 2 - 35,
        y + bh / 2 - 10,
        22,
        @raylib.Color::new(150, 150, 150, 200),
      )
    } else {
      // Tier number
      let tier_num = "TIER " + (i + 1).to_string()
      @draw.draw_text(tier_num, bx + 20, y + 15, 16, @types.color_text_dim)
      // Tier name
      @draw.draw_text(
        tier_names[i],
        bx + 20,
        y + 40,
        28,
        if selected {
          @types.color_highlight
        } else {
          @types.color_text
        },
      )
      // Description
      @draw.draw_text(tier_descs[i], bx + 20, y + 75, 16, @types.color_text_dim)
      // Stars and completion
      let completed = @levels.tier_completed(i, game.level_scores)
      let total = @types.tier_level_count(i)
      let stars = @levels.tier_stars(i, game.level_scores)
      let max_stars = total * 3
      let progress = completed.to_string() +
        "/" +
        total.to_string() +
        " complete"
      @draw.draw_text(progress, bx + 20, y + 105, 16, @types.color_text_dim)
      // Draw stars
      let star_text = stars.to_string() + "/" + max_stars.to_string() + " *"
      @draw.draw_text(star_text, bx + bw - 120, y + 105, 16, @types.color_star)
    }
  }
  // Navigation hint
  @draw.draw_text(
    "Up/Down to select, Enter to play, Esc to go back",
    w / 2 - 220,
    670,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier = game.current_tier
  let tier_name = @types.tier_name(@types.tier_from_index(tier))
  // Title
  let title = tier_name + " - SELECT LEVEL"
  let title_w = @draw.measure_text(title, 30)
  @draw.draw_text(title, (w - title_w) / 2, 30, 30, @types.color_highlight)
  let count = @types.tier_level_count(tier)
  let offset = @types.tier_level_offset(tier)
  let cols = 4
  let cell_w = 260
  let cell_h = 120
  let gap = 20
  let total_w = cols * cell_w + (cols - 1) * gap
  let start_x = (w - total_w) / 2
  let start_y = 90
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * (cell_w + gap)
    let y = start_y + row * (cell_h + gap)
    let selected = i == game.current_level
    let level = @levels.get_level(offset + i)
    let score = game.level_scores[offset + i]
    // Background
    let bg = if selected {
      @raylib.Color::new(30, 50, 70, 255)
    } else {
      @types.color_panel
    }
    @raylib.draw_rectangle(x, y, cell_w, cell_h, bg)
    let border = if selected {
      @types.color_highlight
    } else if score.completed {
      @types.color_success
    } else {
      @types.color_panel_border
    }
    @raylib.draw_rectangle_lines(x, y, cell_w, cell_h, border)
    // Level number
    let num = (i + 1).to_string()
    @draw.draw_text(num, x + 10, y + 8, 14, @types.color_text_dim)
    // Level name
    @draw.draw_text(
      level.name,
      x + 10,
      y + 28,
      18,
      if selected {
        @types.color_highlight
      } else {
        @types.color_text
      },
    )
    // Budget info
    let budget = "Budget: " + level.edit_budget.to_string() + " edits"
    @draw.draw_text(budget, x + 10, y + 55, 14, @types.color_text_dim)
    // Stars
    draw_stars(x + 10, y + 80, score.stars, 3, 16)
    // Best edits if completed
    if score.completed {
      let best = "Best: " + score.best_edits.to_string()
      @draw.draw_text(best, x + cell_w - 80, y + 80, 14, @types.color_success)
    }
  }
  // Selected level description
  let sel_level = @levels.get_level(offset + game.current_level)
  let desc_y = start_y + (count + cols - 1) / cols * (cell_h + gap) + 10
  @draw.draw_text(sel_level.description, start_x, desc_y, 18, @types.color_text)
  // Target traits
  let target_label = "Target: "
  @draw.draw_text(target_label, start_x, desc_y + 30, 16, @types.color_text_dim)
  let mut tx = start_x + @draw.measure_text(target_label, 16) + 5
  for i in 0..<sel_level.target_traits.length() {
    let tr = sel_level.target_traits[i]
    let name = @types.trait_name(tr)
    let color = @types.trait_color(tr)
    @draw.draw_text(name, tx, desc_y + 30, 16, color)
    tx += @draw.measure_text(name, 16) + 10
  }
  // Navigation hint
  @draw.draw_text(
    "Arrow keys to select, Enter to play, Esc to go back",
    w / 2 - 230,
    670,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_stars(x : Int, y : Int, filled : Int, total : Int, size : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * (size + 4)
    let color = if i < filled {
      @types.color_star
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, y, size, color)
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level_idx = @types.tier_level_offset(game.current_tier) +
    game.current_level
  let level = @levels.get_level(level_idx)
  let score = game.level_scores[level_idx]
  // Background panel
  let px = w / 2 - 250
  let py = h / 2 - 200
  let pw = 500
  let ph = 400
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_highlight)
  // Title
  let title = "LEVEL COMPLETE!"
  let title_w = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - title_w) / 2, py + 30, 36, @types.color_success)
  // Level name
  let name_w = @draw.measure_text(level.name, 24)
  @draw.draw_text(level.name, (w - name_w) / 2, py + 80, 24, @types.color_text)
  // Edits used
  let edits_text = "Edits used: " +
    game.edit_count.to_string() +
    " / " +
    level.edit_budget.to_string()
  let edits_w = @draw.measure_text(edits_text, 20)
  @draw.draw_text(
    edits_text,
    (w - edits_w) / 2,
    py + 130,
    20,
    @types.color_text,
  )
  // Par
  let par_text = "Par: " +
    level.par_edits.to_string() +
    "  Min: " +
    level.min_edits.to_string()
  let par_w = @draw.measure_text(par_text, 18)
  @draw.draw_text(
    par_text,
    (w - par_w) / 2,
    py + 160,
    18,
    @types.color_text_dim,
  )
  // Stars
  let star_x = w / 2 - 40
  let star_y = py + 200
  draw_stars(star_x, star_y, score.stars, 3, 28)
  // Rating
  let rating = if score.stars == 3 {
    "PERFECT!"
  } else if score.stars == 2 {
    "GREAT!"
  } else {
    "COMPLETE"
  }
  let rating_color = if score.stars == 3 {
    @types.color_star
  } else if score.stars == 2 {
    @types.color_success
  } else {
    @types.color_text
  }
  let rating_w = @draw.measure_text(rating, 24)
  @draw.draw_text(rating, (w - rating_w) / 2, star_y + 40, 24, rating_color)
  // Continue prompt
  let count = @types.tier_level_count(game.current_tier)
  let continue_text = if game.current_level + 1 < count {
    "ENTER for next level, ESC for level select"
  } else {
    "ENTER or ESC to return"
  }
  let continue_w = @draw.measure_text(continue_text, 16)
  @draw.draw_text(
    continue_text,
    (w - continue_w) / 2,
    py + ph - 50,
    16,
    @types.color_text_dim,
  )
}
