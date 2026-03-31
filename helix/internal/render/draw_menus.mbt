///|
fn draw_title(game : @types.Game) -> Unit {
  let t = game.anim_timer
  // Draw rotating helix decoration
  let cx : Float = 640.0
  let cy : Float = 300.0
  for i in 0..<20 {
    let fi = Float::from_int(i)
    let angle1 : Float = t * 1.5 + fi * 0.3
    let angle2 : Float = t * 1.5 + fi * 0.3 + @types.pi
    let radius : Float = 40.0 + fi * 8.0
    let x1 : Float = cx + radius * @types.cosf(angle1)
    let y1 : Float = cy + radius * @types.sinf(angle1) * 0.4
    let x2 : Float = cx + radius * @types.cosf(angle2)
    let y2 : Float = cy + radius * @types.sinf(angle2) * 0.4
    let alpha = 255 - i * 10
    let a = if alpha < 60 { 60 } else { alpha }
    let c1 = @raylib.Color::new(
      @types.color_cw_token.r.to_int(),
      @types.color_cw_token.g.to_int(),
      @types.color_cw_token.b.to_int(),
      a,
    )
    let c2 = @raylib.Color::new(
      @types.color_ccw_token.r.to_int(),
      @types.color_ccw_token.g.to_int(),
      @types.color_ccw_token.b.to_int(),
      a,
    )
    let size : Float = 8.0 - fi * 0.2
    let sz : Float = if size < 3.0 { 3.0 } else { size }
    @raylib.draw_circle_v(@raylib.Vector2::new(x1, y1), sz, c1)
    @raylib.draw_circle_v(@raylib.Vector2::new(x2, y2), sz, c2)
  }
  // Title text
  let title = "HELIX"
  let tw = @draw.measure_text(title, 72)
  @draw.draw_text(title, 640 - tw / 2, 120, 72, @types.color_title)
  let sub = "A Dual Spiral Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, 640 - sw / 2, 200, 24, @types.color_text_dim)
  // Pulsing prompt
  let pulse : Float = @types.sinf(t * 3.0) * 0.3 + 0.7
  let pa : Float = 255.0 * pulse
  let pai = pa.to_int()
  let pac = if pai < 0 { 0 } else if pai > 255 { 255 } else { pai }
  let prompt_color = @raylib.Color::new(
    @types.color_text.r.to_int(),
    @types.color_text.g.to_int(),
    @types.color_text.b.to_int(),
    pac,
  )
  let prompt = "Press ENTER to Start"
  let pw = @draw.measure_text(prompt, 28)
  @draw.draw_text(prompt, 640 - pw / 2, 500, 28, prompt_color)
  let controls = "Controls: Space/Enter = Step | Z = Undo | R = Restart"
  let ctrw = @draw.measure_text(controls, 18)
  @draw.draw_text(controls, 640 - ctrw / 2, 600, 18, @types.color_text_dim)
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(title, 640 - tw / 2, 60, 48, @types.color_title)
  let tiers : Array[(String, String, @types.Tier)] = [
    ("Coil", "8 levels - Switches & Gates", Coil),
    ("Twist", "9 levels - Sync Points & One-Shot", Twist),
    ("Double Helix", "8 levels - All Mechanics", DoubleHelix),
  ]
  for i in 0..<tiers.length() {
    let (name, desc, tier) = tiers[i]
    let y = 180 + i * 150
    let selected = game.selected_tier == tier
    let box_color = if selected {
      @types.tier_color(tier)
    } else {
      @types.color_text_dim
    }
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        340.0,
        Float::from_int(y),
        600.0,
        120.0,
      ),
      if selected { 3.0 } else { 1.0 },
      box_color,
    )
    if selected {
      @raylib.draw_rectangle(
        342,
        y + 2,
        596,
        116,
        @raylib.Color::new(
          box_color.r.to_int(),
          box_color.g.to_int(),
          box_color.b.to_int(),
          30,
        ),
      )
    }
    // Tier name
    let nw = @draw.measure_text(name, 32)
    @draw.draw_text(name, 640 - nw / 2, y + 20, 32, @types.tier_color(tier))
    // Description
    let dw = @draw.measure_text(desc, 18)
    @draw.draw_text(desc, 640 - dw / 2, y + 65, 18, @types.color_text)
    // Count completed
    let start = @types.tier_start_index(tier)
    let count = @types.tier_level_count(tier)
    let mut completed = 0
    for j in start..<(start + count) {
      if game.level_scores[j].completed {
        completed += 1
      }
    }
    let progress = completed.to_string() + "/" + count.to_string() +
      " completed"
    let prw = @draw.measure_text(progress, 16)
    @draw.draw_text(
      progress,
      640 - prw / 2,
      y + 90,
      16,
      @types.color_text_dim,
    )
  }
  let nav = "Up/Down = Select | Enter = Confirm | Escape = Back"
  let nw = @draw.measure_text(nav, 16)
  @draw.draw_text(nav, 640 - nw / 2, 660, 16, @types.color_text_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.selected_tier
  let tier_name_str = @types.tier_name(tier)
  let title = tier_name_str + " - Select Level"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, 640 - tw / 2, 40, 36, @types.tier_color(tier))
  let start = @types.tier_start_index(tier)
  let count = @types.tier_level_count(tier)
  let cols = 4
  let cell_w = 250
  let cell_h = 100
  let gap = 20
  let total_w = cols * cell_w + (cols - 1) * gap
  let ox = (1280 - total_w) / 2
  let oy = 110
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let x = ox + col * (cell_w + gap)
    let y = oy + row * (cell_h + gap)
    let level_idx = start + i
    let selected = game.selected_level == i
    let score = game.level_scores[level_idx]
    let border = if selected {
      @types.tier_color(tier)
    } else {
      @types.color_text_dim
    }
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(cell_w),
        Float::from_int(cell_h),
      ),
      if selected { 3.0 } else { 1.0 },
      border,
    )
    if selected {
      @raylib.draw_rectangle(
        x + 2,
        y + 2,
        cell_w - 4,
        cell_h - 4,
        @raylib.Color::new(
          border.r.to_int(),
          border.g.to_int(),
          border.b.to_int(),
          20,
        ),
      )
    }
    // Level number
    let num = (i + 1).to_string()
    @draw.draw_text(num, x + 10, y + 8, 24, @types.color_text)
    // Level name
    let level = @levels.get_level(level_idx)
    @draw.draw_text(level.name, x + 10, y + 38, 16, @types.color_text_dim)
    // Stars
    if score.completed {
      for si in 0..<3 {
        let sx = x + cell_w - 80 + si * 24
        let sy2 = y + 8
        let star_col = if si < score.stars {
          @types.color_star_gold
        } else {
          @types.color_star_empty
        }
        @draw.draw_text("*", sx, sy2, 24, star_col)
      }
    }
    // Par info
    let par_txt = "Par: " + level.par_steps.to_string()
    @draw.draw_text(par_txt, x + 10, y + 70, 14, @types.color_text_dim)
    if score.completed {
      let step_txt = "Best: " + score.steps.to_string()
      @draw.draw_text(step_txt, x + 120, y + 70, 14, @types.color_text_dim)
    }
  }
  let nav = "Arrows = Select | Enter = Play | Escape = Back"
  let nw = @draw.measure_text(nav, 16)
  @draw.draw_text(nav, 640 - nw / 2, 660, 16, @types.color_text_dim)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let level = match game.current_level {
    None => return
    Some(l) => l
  }
  // Background overlay
  @raylib.draw_rectangle(0, 0, 1280, 720, @raylib.Color::new(0, 0, 0, 200))
  let title = "Level Complete!"
  let tw2 = @draw.measure_text(title, 48)
  @draw.draw_text(title, 640 - tw2 / 2, 100, 48, @types.color_star_gold)
  // Level name
  let nw = @draw.measure_text(level.name, 28)
  @draw.draw_text(level.name, 640 - nw / 2, 170, 28, @types.color_text)
  // Steps
  let step_text = "Steps: " + game.steps.to_string() + " (Par: " +
    level.par_steps.to_string() + ")"
  let stw = @draw.measure_text(step_text, 24)
  @draw.draw_text(step_text, 640 - stw / 2, 230, 24, @types.color_text)
  // Pickups
  if level.pickups_total > 0 {
    let pickup_text = "Pickups: " + game.pickups_count.to_string() + "/" +
      level.pickups_total.to_string()
    let ptw = @draw.measure_text(pickup_text, 24)
    @draw.draw_text(
      pickup_text,
      640 - ptw / 2,
      270,
      24,
      @types.color_pickup,
    )
  }
  // Stars
  let stars = @types.calculate_stars(
    game.steps,
    level.par_steps,
    game.pickups_count,
    level.pickups_total,
  )
  for i in 0..<3 {
    let sx = 540 + i * 70
    let col = if i < stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, 330, 60, col)
  }
  // Navigation
  let nav = "Enter = Next Level | R = Retry | Escape = Level Select"
  let navw = @draw.measure_text(nav, 18)
  @draw.draw_text(nav, 640 - navw / 2, 500, 18, @types.color_text_dim)
}
