///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Background decoration - floating numbers
  for i in 0..<30 {
    let fi = Float::from_int(i)
    let sx = ((fi * 137.5 + time * 15.0) % Float::from_int(w)).to_int()
    let sy = ((fi * 91.3 + time * 8.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)).to_int()
    let num = i % 9 + 1
    let alpha = 30 + (fi * 13.0 % 40.0).to_int()
    @draw.draw_text(
      num.to_string(),
      sx,
      sy,
      24,
      @raylib.Color::new(100, 120, 180, alpha),
    )
  }
  // Title
  let title = "SIEVE"
  let title_w = @draw.measure_text(title, 72)
  @draw.draw_text(title, (w - title_w) / 2, h / 5, 72, @types.color_title)
  // Subtitle
  let sub = "Number Theory Constraint Puzzles"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 5 + 85, 22, @types.color_subtitle)
  // Play button
  draw_button(w / 2 - 120, h / 2 + 30, 240, 60, "PLAY", 28, game)
  // Instructions
  let inst = "Place numbers 1-9 on a grid following mathematical constraints"
  let inst_w = @draw.measure_text(inst, 16)
  @draw.draw_text(
    inst,
    (w - inst_w) / 2,
    h - 100,
    16,
    @raylib.Color::new(120, 125, 150, 255),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Header
  let header = "SELECT TIER"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(header, (w - hw) / 2, 40, 36, @types.color_title)
  // Tier cards
  let tiers : Array[@types.Tier] = [Primes, Factors, Theorem]
  let card_w = 300
  let card_h = 200
  let gap = 40
  let total_w = 3 * card_w + 2 * gap
  let start_x = (w - total_w) / 2
  let start_y = 140
  for i in 0..<3 {
    let tier = tiers[i]
    let x = start_x + i * (card_w + gap)
    let y = start_y
    let color = @types.tier_color(tier)
    // Card bg
    @raylib.draw_rectangle(
      x,
      y,
      card_w,
      card_h,
      @raylib.Color::new(35, 40, 58, 255),
    )
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(card_w),
        Float::from_int(card_h),
      ),
      2.0,
      color,
    )
    // Tier name
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 32)
    @draw.draw_text(name, x + (card_w - nw) / 2, y + 20, 32, color)
    // Description
    let desc = match tier {
      Primes => "Sum + Unique"
      Factors => "Products + Adjacent"
      Theorem => "All constraints"
    }
    let dw = @draw.measure_text(desc, 16)
    @draw.draw_text(
      desc,
      x + (card_w - dw) / 2,
      y + 65,
      16,
      @types.color_subtitle,
    )
    // Level count
    let count = @types.tier_level_count(tier)
    let start = @types.tier_start_index(tier)
    let mut completed = 0
    for j in 0..<count {
      if game.scores[start + j].completed {
        completed += 1
      }
    }
    let prog = completed.to_string() + "/" + count.to_string() + " completed"
    let pw = @draw.measure_text(prog, 18)
    @draw.draw_text(
      prog,
      x + (card_w - pw) / 2,
      y + 100,
      18,
      @types.color_button_text,
    )
    // Stars
    let mut total_stars = 0
    for j in 0..<count {
      total_stars += game.scores[start + j].stars
    }
    let star_text = total_stars.to_string() +
      "/" +
      (count * 3).to_string() +
      " stars"
    let sw = @draw.measure_text(star_text, 16)
    @draw.draw_text(
      star_text,
      x + (card_w - sw) / 2,
      y + 130,
      16,
      @types.color_star_filled,
    )
    // Click hint
    let hint = "Click to select"
    let hiw = @draw.measure_text(hint, 14)
    @draw.draw_text(
      hint,
      x + (card_w - hiw) / 2,
      y + 165,
      14,
      @raylib.Color::new(100, 105, 130, 255),
    )
  }
  // Back button
  draw_button(w / 2 - 80, 500, 160, 45, "BACK", 22, game)
  // Back instruction
  @draw.draw_text(
    "Esc: back",
    30,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(100, 105, 130, 255),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier = game.current_tier
  let color = @types.tier_color(tier)
  // Header
  let header = @types.tier_name(tier) + " - Select Level"
  let hw = @draw.measure_text(header, 32)
  @draw.draw_text(header, (w - hw) / 2, 30, 32, color)
  // Level grid
  let count = @types.tier_level_count(tier)
  let start = @types.tier_start_index(tier)
  let btn_w = 100
  let btn_h = 80
  let cols = 5
  let gap = 20
  let total_w = cols * btn_w + (cols - 1) * gap
  let start_x = (w - total_w) / 2
  let start_y = 100
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * (btn_w + gap)
    let y = start_y + row * (btn_h + gap)
    let score = game.scores[start + i]
    // Button bg
    let bg = if score.completed {
      @raylib.Color::new(40, 60, 50, 255)
    } else {
      @raylib.Color::new(35, 40, 58, 255)
    }
    @raylib.draw_rectangle(x, y, btn_w, btn_h, bg)
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(btn_w),
        Float::from_int(btn_h),
      ),
      1.0,
      color,
    )
    // Level number
    let num = (i + 1).to_string()
    let nw = @draw.measure_text(num, 28)
    @draw.draw_text(
      num,
      x + (btn_w - nw) / 2,
      y + 10,
      28,
      @types.color_button_text,
    )
    // Stars
    let star_y = y + 48
    for s in 0..<3 {
      let star_x = x + 20 + s * 22
      let sc = if s < score.stars {
        @types.color_star_filled
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", star_x, star_y, 20, sc)
    }
  }
  // Back button
  draw_button(w / 2 - 80, 550, 160, 45, "BACK", 22, game)
  @draw.draw_text(
    "Esc: back to tiers",
    30,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(100, 105, 130, 255),
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 180))
  // Results panel
  let pw = 500
  let ph = 400
  let px = (w - pw) / 2
  let py = (h - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(30, 34, 52, 255))
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(px),
      Float::from_int(py),
      Float::from_int(pw),
      Float::from_int(ph),
    ),
    2.0,
    @types.color_title,
  )
  // Title
  let title = "LEVEL COMPLETE!"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, py + 25, 36, @types.color_constraint_sat)
  // Time
  let minutes = (game.timer / 60.0).to_int()
  let seconds = (game.timer % 60.0).to_int()
  let sec_str = if seconds < 10 {
    "0" + seconds.to_string()
  } else {
    seconds.to_string()
  }
  let time_text = "Time: " + minutes.to_string() + ":" + sec_str
  let ttw = @draw.measure_text(time_text, 24)
  @draw.draw_text(time_text, (w - ttw) / 2, py + 85, 24, @types.color_timer)
  // Par comparison
  match game.current_level {
    Some(level) => {
      let par_min = (level.par_time / 60.0).to_int()
      let par_sec = (level.par_time % 60.0).to_int()
      let ps_str = if par_sec < 10 {
        "0" + par_sec.to_string()
      } else {
        par_sec.to_string()
      }
      let par_text = "Par: " + par_min.to_string() + ":" + ps_str
      let ptw = @draw.measure_text(par_text, 20)
      @draw.draw_text(
        par_text,
        (w - ptw) / 2,
        py + 120,
        20,
        @types.color_subtitle,
      )
    }
    None => ()
  }
  // Stars
  let score = game.scores[game.current_level_index]
  let star_y = py + 170
  let star_total_w = 3 * 50
  let star_start_x = (w - star_total_w) / 2
  for i in 0..<3 {
    let sx = star_start_x + i * 50
    let sc = if i < score.stars {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx + 10, star_y, 40, sc)
  }
  // Star explanations
  let explanations = [
    "1 star: Solved", "2 stars: Under par time", "3 stars: Par time + no mistakes",
  ]
  for i in 0..<3 {
    let ew = @draw.measure_text(explanations[i], 16)
    let ec = if i < score.stars {
      @types.color_constraint_sat
    } else {
      @types.color_subtitle
    }
    @draw.draw_text(explanations[i], (w - ew) / 2, star_y + 55 + i * 24, 16, ec)
  }
  // Buttons
  draw_button(
    (w - 200) / 2 - 120,
    py + ph - 70,
    200,
    50,
    "NEXT LEVEL",
    22,
    game,
  )
  draw_button(
    (w - 200) / 2 + 120,
    py + ph - 70,
    200,
    50,
    "LEVEL SELECT",
    22,
    game,
  )
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  font_size : Int,
  _game : @types.Game,
) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hover = mx >= x && mx <= x + w && my >= y && my <= y + h
  let bg = if hover { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(w),
      Float::from_int(h),
    ),
    1.0,
    @types.color_grid_line,
  )
  let tw = @draw.measure_text(text, font_size)
  @draw.draw_text(
    text,
    x + (w - tw) / 2,
    y + (h - font_size) / 2,
    font_size,
    @types.color_button_text,
  )
}
