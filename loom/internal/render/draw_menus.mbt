///|
fn draw_title(game : @types.Game) -> Unit {
  let _ = game
  // Background decoration - loom frame
  @raylib.draw_rectangle(0, 0, @types.screen_width, 80, @types.color_loom_frame)
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 30,
    @types.screen_width,
    30,
    @types.color_loom_frame,
  )
  // Title
  let title = "LOOM"
  let tw = @draw.measure_text(title, 72)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    120,
    72,
    @types.color_title,
  )
  // Subtitle
  let sub = "A Weaving Pattern Puzzle"
  let sw = @draw.measure_text(sub, 28)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    200,
    28,
    @types.color_text,
  )
  // Decorative woven pattern preview
  draw_title_pattern(340, 260, 600, 180)
  // Instructions
  let instr = "Press ENTER or SPACE to begin"
  let iw = @draw.measure_text(instr, 24)
  @draw.draw_text(
    instr,
    (@types.screen_width - iw) / 2,
    480,
    24,
    @raylib.Color::new(
      @types.color_text.r.to_int(),
      @types.color_text.g.to_int(),
      @types.color_text.b.to_int(),
      180,
    ),
  )
  // Credits
  @draw.draw_text(
    "Thread your heddles, weave the pattern",
    (@types.screen_width - @draw.measure_text(
        "Thread your heddles, weave the pattern",
        18,
      )) /
    2,
    530,
    18,
    @types.color_text_light,
  )
}

///|
fn draw_title_pattern(x : Int, y : Int, w : Int, h : Int) -> Unit {
  // Draw a decorative plain weave preview
  let cs = 15
  let cols = w / cs
  let rows = h / cs
  @raylib.draw_rectangle(
    x - 2,
    y - 2,
    w + 4,
    h + 4,
    @types.color_loom_frame,
  )
  for row in 0..<rows {
    for col in 0..<cols {
      let is_warp = (row + col) % 2 == 0
      let ci = if is_warp { col % 4 } else { row % 4 }
      let color = @types.cell_color(ci)
      @raylib.draw_rectangle(x + col * cs, y + row * cs, cs - 1, cs - 1, color)
    }
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let _ = game
  @draw.draw_text("Select Tier", 100, 60, 40, @types.color_title)
  @draw.draw_text("Choose your weaving challenge", 100, 110, 20, @types.color_text_light)
  let tiers : Array[(@types.Tier, String, String)] = [
    (Apprentice, "Apprentice", "Plain weave - learn the basics (Levels 1-7)"),
    (Journeyman, "Journeyman", "Twill & satin - diagonal patterns (Levels 8-14)"),
    (Master, "Master", "Herringbone & diamond - complex patterns (Levels 15-20)"),
  ]
  for i in 0..<3 {
    let (_, name, desc) = tiers[i]
    let ty = 180 + i * 140
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= 340 && mx <= 940 && my >= ty && my <= ty + 110
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(340, ty, 600, 110, bg)
    @raylib.draw_rectangle_lines(340, ty, 600, 110, @types.color_loom_frame)
    // Tier number
    let num_str = (i + 1).to_string()
    @draw.draw_text(num_str, 360, ty + 10, 36, @raylib.white)
    // Tier name
    @draw.draw_text(name, 420, ty + 10, 32, @raylib.white)
    // Description
    @draw.draw_text(desc, 420, ty + 55, 18, @raylib.Color::new(255, 240, 220, 255))
    // Star count for completed levels
    let (start, count) = @types.tier_levels(tiers[i].0)
    let mut completed = 0
    let mut total_stars = 0
    for j in 0..<count {
      let idx = start + j
      if idx < game.level_scores.length() && game.level_scores[idx].completed {
        completed = completed + 1
        total_stars = total_stars + game.level_scores[idx].stars
      }
    }
    let progress = completed.to_string() +
      "/" +
      count.to_string() +
      " done  Stars: " +
      total_stars.to_string()
    @draw.draw_text(
      progress,
      420,
      ty + 80,
      16,
      @raylib.Color::new(255, 220, 180, 255),
    )
  }
  @draw.draw_text("Press 1/2/3 or click", 100, 620, 18, @types.color_text_light)
  @draw.draw_text("ESC: Back", 100, 650, 18, @types.color_text_light)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.current_tier
  let tn = @types.tier_name(tier)
  @draw.draw_text(tn + " - Select Level", 100, 40, 36, @types.color_title)
  let (start, count) = @types.tier_levels(tier)
  let cols = 4
  let cw = 200
  let ch = 80
  let gap = 20
  let ox = 200
  let oy = 140
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let cx = ox + col * (cw + gap)
    let cy = oy + row * (ch + gap)
    let level_idx = start + i
    let score = game.level_scores[level_idx]
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= cx && mx <= cx + cw && my >= cy && my <= cy + ch
    let bg = if score.completed {
      @raylib.Color::new(100, 180, 120, 255)
    } else if hover {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(cx, cy, cw, ch, bg)
    @raylib.draw_rectangle_lines(cx, cy, cw, ch, @types.color_loom_frame)
    // Level number
    let lnum = (level_idx + 1).to_string()
    @draw.draw_text("Level " + lnum, cx + 10, cy + 8, 24, @raylib.white)
    // Stars
    if score.completed {
      draw_stars_small(cx + 10, cy + 42, score.stars, 3)
    } else {
      @draw.draw_text(
        "Not started",
        cx + 10,
        cy + 48,
        14,
        @raylib.Color::new(255, 240, 220, 200),
      )
    }
  }
  // Navigation hints
  @draw.draw_text(
    "Press 1-" + count.to_string() + " or click  |  ESC: Back",
    100,
    620,
    18,
    @types.color_text_light,
  )
}

///|
fn draw_stars_small(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * 22
    let color = if i < filled {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star_shape(sx + 8, y + 8, 8, color)
  }
}

///|
fn draw_star_shape(cx : Int, cy : Int, radius : Int, color : @raylib.Color) -> Unit {
  // Simple star as a filled circle with rays
  let r = radius
  @raylib.draw_circle(cx, cy, Float::from_int(r), color)
  // Draw small triangular points
  let half = r / 2
  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy - r - half)),
    @raylib.Vector2::new(
      Float::from_int(cx - half),
      Float::from_int(cy - half),
    ),
    @raylib.Vector2::new(
      Float::from_int(cx + half),
      Float::from_int(cy - half),
    ),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy + r + half)),
    @raylib.Vector2::new(
      Float::from_int(cx + half),
      Float::from_int(cy + half),
    ),
    @raylib.Vector2::new(
      Float::from_int(cx - half),
      Float::from_int(cy + half),
    ),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(cx - r - half), Float::from_int(cy)),
    @raylib.Vector2::new(
      Float::from_int(cx - half),
      Float::from_int(cy + half),
    ),
    @raylib.Vector2::new(
      Float::from_int(cx - half),
      Float::from_int(cy - half),
    ),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(cx + r + half), Float::from_int(cy)),
    @raylib.Vector2::new(
      Float::from_int(cx + half),
      Float::from_int(cy - half),
    ),
    @raylib.Vector2::new(
      Float::from_int(cx + half),
      Float::from_int(cy + half),
    ),
    color,
  )
}
