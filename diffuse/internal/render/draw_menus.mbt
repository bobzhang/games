///|
pub fn draw_title(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  // Animated ink drops
  let frame = game.frame_count
  draw_title_drops(frame)
  // Title
  let title = "DIFFUSE"
  let tw = @draw.measure_text(title, 64)
  @draw.draw_text(title, cx - tw / 2, 180, 64, @types.color_title_text)
  // Subtitle
  let sub = "A Subtractive Color Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, cx - sw / 2, 260, 24, @types.color_subtitle)
  // Start button
  let btn_text = "Play"
  let btn_w = 200
  let btn_h = 50
  let btn_x = cx - btn_w / 2
  let btn_y = 380
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hovering = mx >= btn_x &&
    mx <= btn_x + btn_w &&
    my >= btn_y &&
    my <= btn_y + btn_h
  let btn_color = if hovering {
    @types.color_button_hover
  } else {
    @types.color_button
  }
  @raylib.draw_rectangle(btn_x, btn_y, btn_w, btn_h, btn_color)
  let btw = @draw.measure_text(btn_text, 28)
  @draw.draw_text(
    btn_text,
    btn_x + btn_w / 2 - btw / 2,
    btn_y + 10,
    28,
    @types.color_button_text,
  )
  // Color legend
  draw_color_legend(cx, 480)
  // Footer
  let footer = "Moon + Raylib"
  let fw = @draw.measure_text(footer, 16)
  @draw.draw_text(
    footer,
    cx - fw / 2,
    @types.screen_height - 40,
    16,
    @types.color_subtitle,
  )
}

///|
fn draw_title_drops(frame : Int) -> Unit {
  let t : Float = Float::from_int(frame) * 0.02
  // Animated colored circles
  let colors = [
    @types.color_cyan, @types.color_magenta, @types.color_yellow, @types.color_blue,
    @types.color_green, @types.color_red,
  ]
  for i in 0..<colors.length() {
    let fi : Float = Float::from_int(i)
    let angle : Float = t + fi * 1.047
    let sin_val : Float = Float::from_double(@math.sin(angle.to_double()))
    let cos_val : Float = Float::from_double(@math.cos(angle.to_double()))
    let x : Float = 640.0 + cos_val * 250.0
    let y : Float = 120.0 + sin_val * 40.0
    let r : Float = 15.0 + sin_val * 5.0
    let c = colors[i]
    let fade = @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), 120)
    @raylib.draw_circle(x.to_int(), y.to_int(), r, fade)
  }
}

///|
fn draw_color_legend(cx : Int, y : Int) -> Unit {
  let label = "Color Mixing Guide"
  let lw = @draw.measure_text(label, 18)
  @draw.draw_text(label, cx - lw / 2, y, 18, @types.color_title_text)
  // Primary
  let py = y + 30
  let items = [
    ("C", @types.color_cyan),
    ("M", @types.color_magenta),
    ("Y", @types.color_yellow),
  ]
  let start_x = cx - 120
  for i in 0..<items.length() {
    let (name, color) = items[i]
    let ix = start_x + i * 80
    @raylib.draw_rectangle(ix, py, 24, 24, color)
    @draw.draw_text(name, ix + 30, py + 3, 16, @types.color_subtitle)
  }
  // Mixed
  let my = py + 34
  let mixed = [
    ("C+M=", @types.color_blue, "Blue"),
    ("C+Y=", @types.color_green, "Green"),
    ("M+Y=", @types.color_red, "Red"),
  ]
  for i in 0..<mixed.length() {
    let (formula, color, _name) = mixed[i]
    let ix = start_x + i * 80
    @draw.draw_text(formula, ix, my, 12, @types.color_subtitle)
    @raylib.draw_rectangle(ix + 30, my, 16, 16, color)
  }
  // Black
  let by = my + 24
  let btext = "C+M+Y = Black"
  let bw = @draw.measure_text(btext, 14)
  @draw.draw_text(btext, cx - bw / 2 - 12, by, 14, @types.color_subtitle)
  @raylib.draw_rectangle(cx + bw / 2 - 4, by, 16, 16, @types.color_black)
}

///|
pub fn draw_tier_select(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, cx - tw / 2, 60, 40, @types.color_title_text)
  let tiers : Array[(@types.Tier, String, String)] = [
    (Watercolor, "Watercolor", "Single colors, learn the basics"),
    (Pigment, "Pigment", "Two-color mixing, tighter puzzles"),
    (Palette, "Palette", "Full spectrum, complex challenges"),
  ]
  for i in 0..<tiers.length() {
    let (tier, name, desc) = tiers[i]
    let by = 160 + i * 140
    let bx = cx - 250
    let bw = 500
    let bh = 110
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovering = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
    // Count completed levels in this tier
    let start = @types.tier_start_index(tier)
    let count = @types.tier_level_count(tier)
    let mut completed = 0
    for j = start; j < start + count; j = j + 1 {
      if game.scores[j].completed {
        completed = completed + 1
      }
    }
    let bg = if hovering {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @draw.draw_text(name, bx + 20, by + 15, 28, @types.color_button_text)
    @draw.draw_text(
      desc,
      bx + 20,
      by + 50,
      16,
      @raylib.Color::new(220, 230, 255, 255),
    )
    let prog = completed.to_string() + "/" + count.to_string() + " completed"
    @draw.draw_text(
      prog,
      bx + 20,
      by + 75,
      16,
      @raylib.Color::new(200, 220, 180, 255),
    )
    // Stars earned
    let mut total_stars = 0
    for j = start; j < start + count; j = j + 1 {
      total_stars = total_stars + @types.star_count(game.scores[j].stars)
    }
    let star_text = total_stars.to_string() +
      "/" +
      (count * 3).to_string() +
      " stars"
    @draw.draw_text(
      star_text,
      bx + bw - 120,
      by + 15,
      16,
      @types.color_star_filled,
    )
  }
  // Back button
  draw_back_button()
}

///|
pub fn draw_level_select(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  let tier = game.selected_tier
  let tier_name = @types.tier_name(tier)
  let title = tier_name + " - Select Level"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(title, cx - tw / 2, 40, 32, @types.color_title_text)
  let start = @types.tier_start_index(tier)
  let count = @types.tier_level_count(tier)
  // Grid of level buttons
  let cols = 5
  let btn_size = 100
  let gap = 20
  let total_w = cols * btn_size + (cols - 1) * gap
  let sx = cx - total_w / 2
  let sy = 120
  for i = 0; i < count; i = i + 1 {
    let level_idx = start + i
    let col = i % cols
    let row = i / cols
    let bx = sx + col * (btn_size + gap)
    let by = sy + row * (btn_size + gap)
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovering = mx >= bx &&
      mx <= bx + btn_size &&
      my >= by &&
      my <= by + btn_size
    let score = game.scores[level_idx]
    let bg = if hovering {
      @types.color_button_hover
    } else if score.completed {
      @raylib.Color::new(60, 140, 90, 255)
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, btn_size, btn_size, bg)
    // Level number
    let num = (i + 1).to_string()
    let nw = @draw.measure_text(num, 32)
    @draw.draw_text(
      num,
      bx + btn_size / 2 - nw / 2,
      by + 15,
      32,
      @types.color_button_text,
    )
    // Stars
    let star_y = by + btn_size - 30
    let star_count = @types.star_count(score.stars)
    for s = 0; s < 3; s = s + 1 {
      let star_x = bx + 15 + s * 25
      let star_col = if s < star_count {
        @types.color_star_filled
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", star_x, star_y, 22, star_col)
    }
  }
  // Level info on hover
  let info_y = sy + (count + cols - 1) / cols * (btn_size + gap) + 20
  let mx2 = @raylib.get_mouse_x()
  let my2 = @raylib.get_mouse_y()
  for i = 0; i < count; i = i + 1 {
    let col = i % cols
    let row = i / cols
    let bx = sx + col * (btn_size + gap)
    let by = sy + row * (btn_size + gap)
    if mx2 >= bx && mx2 <= bx + btn_size && my2 >= by && my2 <= by + btn_size {
      let level = @levels.get_level(start + i)
      @draw.draw_text(level.name, cx - 100, info_y, 22, @types.color_title_text)
      let par = "Par: " + level.par_drops.to_string() + " drops"
      @draw.draw_text(par, cx - 100, info_y + 28, 16, @types.color_subtitle)
      let budget_str = "Budget: C=" +
        level.budget.cyan.to_string() +
        " M=" +
        level.budget.magenta.to_string() +
        " Y=" +
        level.budget.yellow.to_string()
      @draw.draw_text(
        budget_str,
        cx - 100,
        info_y + 50,
        16,
        @types.color_subtitle,
      )
      break
    }
  }
  draw_back_button()
}

///|
pub fn draw_results_overlay(game : @types.Game) -> Unit {
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 140),
  )
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  let panel_w = 400
  let panel_h = 280
  let px = cx - panel_w / 2
  let py = cy - panel_h / 2
  let bg = if game.play_state == Won {
    @types.color_won_bg
  } else {
    @types.color_failed_bg
  }
  @raylib.draw_rectangle(px, py, panel_w, panel_h, bg)
  @raylib.draw_rectangle_lines(
    px, py, panel_w, panel_h, @types.color_button_text,
  )
  if game.play_state == Won {
    let title = "Level Complete!"
    let tw = @draw.measure_text(title, 32)
    @draw.draw_text(title, cx - tw / 2, py + 20, 32, @types.color_button_text)
    // Stars
    let stars = @ink.compute_stars(game.grid, game.drops_used, game.par_drops)
    let star_c = @types.star_count(stars)
    let star_y = py + 70
    for s = 0; s < 3; s = s + 1 {
      let star_x = cx - 50 + s * 35
      let star_col = if s < star_c {
        @types.color_star_filled
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", star_x, star_y, 36, star_col)
    }
    // Stats
    let drops_text = "Drops used: " +
      game.drops_used.to_string() +
      " (par: " +
      game.par_drops.to_string() +
      ")"
    let dw = @draw.measure_text(drops_text, 18)
    @draw.draw_text(
      drops_text,
      cx - dw / 2,
      py + 120,
      18,
      @types.color_button_text,
    )
    let waste = @ink.count_waste(game.grid)
    let waste_text = "Wasted tiles: " + waste.to_string()
    let ww = @draw.measure_text(waste_text, 18)
    @draw.draw_text(
      waste_text,
      cx - ww / 2,
      py + 145,
      18,
      @types.color_button_text,
    )
  } else {
    let title = "Puzzle Failed"
    let tw = @draw.measure_text(title, 32)
    @draw.draw_text(title, cx - tw / 2, py + 20, 32, @types.color_button_text)
    let hint = "A target has wrong ink channels."
    let hw = @draw.measure_text(hint, 16)
    @draw.draw_text(hint, cx - hw / 2, py + 70, 16, @types.color_button_text)
    let hint2 = "Ink mixing is additive - can't undo!"
    let hw2 = @draw.measure_text(hint2, 16)
    @draw.draw_text(hint2, cx - hw2 / 2, py + 95, 16, @types.color_button_text)
  }
  // Buttons
  let btn_y = py + panel_h - 70
  // Retry
  let retry_x = cx - 180
  let retry_w = 150
  let retry_h = 40
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let rh = mx >= retry_x &&
    mx <= retry_x + retry_w &&
    my >= btn_y &&
    my <= btn_y + retry_h
  @raylib.draw_rectangle(
    retry_x,
    btn_y,
    retry_w,
    retry_h,
    if rh {
      @types.color_button_hover
    } else {
      @types.color_button
    },
  )
  let rt = "Retry"
  let rtw = @draw.measure_text(rt, 20)
  @draw.draw_text(
    rt,
    retry_x + retry_w / 2 - rtw / 2,
    btn_y + 8,
    20,
    @types.color_button_text,
  )
  // Next / Menu
  let next_x = cx + 30
  let next_w = 150
  let next_h = 40
  let nh = mx >= next_x &&
    mx <= next_x + next_w &&
    my >= btn_y &&
    my <= btn_y + next_h
  @raylib.draw_rectangle(
    next_x,
    btn_y,
    next_w,
    next_h,
    if nh {
      @types.color_button_hover
    } else {
      @types.color_button
    },
  )
  let nt = if game.play_state == Won { "Next" } else { "Menu" }
  let ntw = @draw.measure_text(nt, 20)
  @draw.draw_text(
    nt,
    next_x + next_w / 2 - ntw / 2,
    btn_y + 8,
    20,
    @types.color_button_text,
  )
}

///|
pub fn draw_results_screen(game : @types.Game) -> Unit {
  // Redirect to level select for now
  draw_level_select(game)
}

///|
fn draw_back_button() -> Unit {
  let bx = 20
  let by = @types.screen_height - 60
  let bw = 100
  let bh = 40
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hovering = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
  @raylib.draw_rectangle(
    bx,
    by,
    bw,
    bh,
    if hovering {
      @types.color_button_hover
    } else {
      @types.color_button
    },
  )
  let t = "Back"
  let tw = @draw.measure_text(t, 20)
  @draw.draw_text(t, bx + bw / 2 - tw / 2, by + 8, 20, @types.color_button_text)
}
