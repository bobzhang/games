///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Background: dark museum wall
  @raylib.draw_rectangle(0, 0, w, h, @types.color_bg)
  // Decorative frame border
  let frame_x = w / 2 - 200
  let frame_y = h / 4 - 30
  let frame_w = 400
  let frame_h = 250
  // Outer frame
  @raylib.draw_rectangle(
    frame_x - 8,
    frame_y - 8,
    frame_w + 16,
    frame_h + 16,
    @types.color_frame_gold,
  )
  @raylib.draw_rectangle(
    frame_x - 4,
    frame_y - 4,
    frame_w + 8,
    frame_h + 8,
    @types.color_frame,
  )
  // Canvas area
  @raylib.draw_rectangle(frame_x, frame_y, frame_w, frame_h, @types.color_canvas)
  // Animated "restoration" effect - regions appearing clean
  let anim_phase = (time * 0.5).to_int() % 12
  let cell_w = frame_w / 6
  let cell_h = frame_h / 4
  for row in 0..<4 {
    for col in 0..<6 {
      let idx = row * 6 + col
      let cx = frame_x + col * cell_w
      let cy = frame_y + row * cell_h
      if idx < anim_phase {
        // Restored - nice color
        let hue = Float::from_int(idx) * 30.0 + time * 20.0
        let r = ((@types.sinf(hue * 0.01) * 40.0 + 160.0).to_int()).land(255)
        let g = ((@types.sinf(hue * 0.013 + 2.0) * 40.0 + 170.0).to_int()).land(
          255,
        )
        let b = ((@types.sinf(hue * 0.017 + 4.0) * 30.0 + 140.0).to_int()).land(
          255,
        )
        @raylib.draw_rectangle(
          cx + 1,
          cy + 1,
          cell_w - 2,
          cell_h - 2,
          @raylib.Color::new(r, g, b, 255),
        )
      } else {
        // Damaged - show cracks
        @raylib.draw_rectangle(
          cx + 1,
          cy + 1,
          cell_w - 2,
          cell_h - 2,
          @types.color_canvas_dark,
        )
        @raylib.draw_line(
          cx + 5,
          cy + 5,
          cx + cell_w - 5,
          cy + cell_h - 5,
          @types.color_crack,
        )
      }
    }
  }
  // Title text
  let title = "PATINA"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 2 + 60,
    72,
    @raylib.Color::new(235, 225, 205, alpha),
  )
  // Subtitle
  let sub = "ARTWORK  RESTORATION  PUZZLE"
  let sub_w = @draw.measure_text(sub, 18)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 2 + 140, 18, @types.color_text_dim)
  // Controls
  let start_text = "PRESS ENTER TO BEGIN"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h - 100,
    24,
    @raylib.Color::new(235, 225, 205, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Header
  let header = "SELECT TIER"
  let hw = @draw.measure_text(header, 40)
  @draw.draw_text(header, (w - hw) / 2, 40, 40, @types.color_text)
  // Tier cards
  let tiers : Array[@types.Tier] = [Sketches, Paintings, Masterworks]
  let card_w = 300
  let card_h = 350
  let total_w = card_w * 3 + 40 * 2
  let start_x = (w - total_w) / 2
  for i in 0..<3 {
    let tier = tiers[i]
    let cx = start_x + i * (card_w + 40)
    let cy = (h - card_h) / 2
    let selected = @types.tier_index(game.selected_tier) == i
    // Card background
    let bg_color = if selected {
      @raylib.Color::new(60, 55, 45, 255)
    } else {
      @raylib.Color::new(40, 35, 28, 255)
    }
    @raylib.draw_rectangle(cx, cy, card_w, card_h, bg_color)
    // Card border
    let border_color = if selected {
      @types.color_frame_gold
    } else {
      @types.color_frame
    }
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(card_w),
        Float::from_int(card_h),
      ),
      if selected { 3.0 } else { 1.0 },
      border_color,
    )
    // Tier name
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 28)
    @draw.draw_text(
      name,
      cx + (card_w - nw) / 2,
      cy + 20,
      28,
      if selected { @types.color_highlight } else { @types.color_text },
    )
    // Tier description
    let desc = match tier {
      Sketches => "Single damage types"
      Paintings => "Mixed damage, order matters"
      Masterworks => "Complex sequences"
    }
    let dw = @draw.measure_text(desc, 14)
    @draw.draw_text(
      desc,
      cx + (card_w - dw) / 2,
      cy + 60,
      14,
      @types.color_text_dim,
    )
    // Level range info
    let (lo, hi) = @types.tier_level_range(tier)
    let count_str = "Levels: " + (hi - lo).to_string()
    let cw = @draw.measure_text(count_str, 16)
    @draw.draw_text(
      count_str,
      cx + (card_w - cw) / 2,
      cy + 90,
      16,
      @types.color_text_dim,
    )
    // Stars earned for this tier
    let mut stars_earned = 0
    for li in lo..<hi {
      stars_earned = stars_earned + game.level_scores[li]
    }
    let max_stars = (hi - lo) * 3
    let star_str = "Stars: " +
      stars_earned.to_string() +
      " / " +
      max_stars.to_string()
    let sw = @draw.measure_text(star_str, 16)
    @draw.draw_text(
      star_str,
      cx + (card_w - sw) / 2,
      cy + 120,
      16,
      @types.color_star_gold,
    )
    // Tier number
    let num = (i + 1).to_string()
    let num_w = @draw.measure_text(num, 80)
    @draw.draw_text(
      num,
      cx + (card_w - num_w) / 2,
      cy + 180,
      80,
      @raylib.Color::new(80, 75, 60, 100),
    )
  }
  // Nav hints
  @draw.draw_text(
    "LEFT/RIGHT to select   ENTER to confirm   ESC to go back",
    w / 2 - 250,
    h - 60,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Header
  let tier_str = @types.tier_name(game.selected_tier)
  let header = tier_str + " - SELECT LEVEL"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(header, (w - hw) / 2, 30, 36, @types.color_text)
  let (lo, hi) = @types.tier_level_range(game.selected_tier)
  let count = hi - lo
  // Grid of level cards
  let cols = if count <= 4 { count } else { 4 }
  let rows = (count + cols - 1) / cols
  let card_w = 200
  let card_h = 120
  let gap = 20
  let total_w = cols * card_w + (cols - 1) * gap
  let total_h = rows * card_h + (rows - 1) * gap
  let base_x = (w - total_w) / 2
  let base_y = (h - total_h) / 2 + 20
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let cx = base_x + col * (card_w + gap)
    let cy = base_y + row * (card_h + gap)
    let level_idx = lo + i
    let selected = game.selected_level == level_idx
    // Card bg
    let bg = if selected {
      @raylib.Color::new(60, 55, 45, 255)
    } else {
      @raylib.Color::new(40, 35, 28, 255)
    }
    @raylib.draw_rectangle(cx, cy, card_w, card_h, bg)
    // Border
    let bc = if selected {
      @types.color_frame_gold
    } else {
      @types.color_frame
    }
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(card_w),
        Float::from_int(card_h),
      ),
      if selected { 2.0 } else { 1.0 },
      bc,
    )
    // Level number
    let num_str = "Level " + (level_idx + 1).to_string()
    @draw.draw_text(
      num_str,
      cx + 10,
      cy + 10,
      18,
      if selected { @types.color_highlight } else { @types.color_text },
    )
    // Stars
    let stars = game.level_scores[level_idx]
    for s in 0..<3 {
      let sx = cx + 10 + s * 22
      let sy = cy + card_h - 35
      let star_color = if s < stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      draw_star(sx, sy, 8, star_color)
    }
  }
  // Nav hints
  @draw.draw_text(
    "ARROWS to select   ENTER to play   ESC to go back",
    w / 2 - 220,
    h - 50,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(30, 25, 20, 230))
  match game.score {
    None => ()
    Some(score) => {
      // Title
      let title = "RESTORATION COMPLETE"
      let tw = @draw.measure_text(title, 40)
      @draw.draw_text(title, (w - tw) / 2, 80, 40, @types.color_text)
      // Stars
      let stars = score.stars
      let star_size = 30
      let star_gap = 80
      let stars_total_w = 3 * star_gap
      let star_base_x = (w - stars_total_w) / 2 + star_gap / 2
      for i in 0..<3 {
        let sx = star_base_x + i * star_gap
        let sy = 160
        let color = if i < stars {
          @types.color_star_gold
        } else {
          @types.color_star_empty
        }
        draw_star(sx, sy, star_size, color)
      }
      // Stats
      let cy = 260
      let stat_x = w / 2 - 120
      @draw.draw_text(
        "Restored: " + score.restored_count.to_string(),
        stat_x,
        cy,
        22,
        @types.color_restored,
      )
      @draw.draw_text(
        "Worsened: " + score.worsened_count.to_string(),
        stat_x,
        cy + 35,
        22,
        if score.worsened_count > 0 {
          @types.color_worsened
        } else {
          @types.color_text
        },
      )
      @draw.draw_text(
        "Sealed: " + score.sealed_count.to_string(),
        stat_x,
        cy + 70,
        22,
        @types.color_sealed,
      )
      @draw.draw_text(
        "Tools Used: " + score.total_tools_used.to_string(),
        stat_x,
        cy + 105,
        22,
        @types.color_text,
      )
      // Par info
      match game.current_level {
        Some(level) => {
          let par_str = "Par: " + level.par_tools.to_string()
          @draw.draw_text(par_str, stat_x, cy + 140, 22, @types.color_text_dim)
        }
        None => ()
      }
      // Rating description
      let rating = match stars {
        3 => "MASTERFUL RESTORATION!"
        2 => "EXCELLENT WORK!"
        1 => "RESTORATION COMPLETE"
        _ => "NEEDS MORE PRACTICE"
      }
      let rw = @draw.measure_text(rating, 24)
      @draw.draw_text(rating, (w - rw) / 2, cy + 200, 24, @types.color_highlight)
    }
  }
  // Navigation
  @draw.draw_text(
    "ENTER - Next Level   R - Retry   ESC - Level Select",
    w / 2 - 230,
    h - 60,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_star(x : Int, y : Int, size : Int, color : @raylib.Color) -> Unit {
  let s = Float::from_int(size)
  let fx = Float::from_int(x)
  let fy = Float::from_int(y)
  // Simple star shape using triangles
  let outer = s
  let inner = s * 0.4
  // Draw a 5-pointed star
  for i in 0..<5 {
    let fi = Float::from_int(i)
    let angle1 = fi * 1.2566 - 1.5708
    let angle2 = (fi + 0.5) * 1.2566 - 1.5708
    let angle3 = (fi + 1.0) * 1.2566 - 1.5708
    let x1 = fx + @types.cosf(angle1) * outer
    let y1 = fy + @types.sinf(angle1) * outer
    let x2 = fx + @types.cosf(angle2) * inner
    let y2 = fy + @types.sinf(angle2) * inner
    let x3 = fx + @types.cosf(angle3) * outer
    let y3 = fy + @types.sinf(angle3) * outer
    @raylib.draw_triangle(
      @raylib.Vector2::new(fx, fy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(fx, fy),
      @raylib.Vector2::new(x2, y2),
      @raylib.Vector2::new(x3, y3),
      color,
    )
  }
}
