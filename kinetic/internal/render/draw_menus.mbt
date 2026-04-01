///|
fn draw_title(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_title_bg)
  // Animated title gears
  draw_title_gears(game)
  // Title text
  let title = "KINETIC"
  let tw = @draw.measure_text(title, 64)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    160,
    64,
    @types.color_highlight,
  )
  let subtitle = "Mechanical Gear Choreography"
  let stw = @draw.measure_text(subtitle, 22)
  @draw.draw_text(
    subtitle,
    @types.screen_width / 2 - stw / 2,
    235,
    22,
    @types.color_text_dim,
  )
  // Start prompt
  let prompt_alpha_f = (@types.sinf(game.anim_timer * 3.0) + 1.0) * 0.5
  let prompt_color = @raylib.fade(@types.color_text, prompt_alpha_f)
  let prompt = "Press ENTER to start"
  let ptw = @draw.measure_text(prompt, 24)
  @draw.draw_text(
    prompt,
    @types.screen_width / 2 - ptw / 2,
    400,
    24,
    prompt_color,
  )
  // Credits
  @draw.draw_text(
    "A puzzle of gears, ratios and direction",
    @types.screen_width / 2 - 170,
    520,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_title_gears(game : @types.Game) -> Unit {
  let angle = game.title_gear_angle
  // Gear 1 (left small)
  draw_title_single_gear(200.0, 350.0, 40.0, 10, @types.color_gear_small, angle)
  // Gear 2 (middle medium, reversed)
  draw_title_single_gear(
    280.0,
    350.0,
    55.0,
    14,
    @types.color_gear_medium,
    -angle,
  )
  // Gear 3 (right small)
  draw_title_single_gear(
    1000.0, 350.0, 40.0, 10, @types.color_gear_small, angle,
  )
}

///|
fn draw_title_single_gear(
  cx : Float,
  cy : Float,
  r : Float,
  teeth : Int,
  color : @raylib.Color,
  a : Float,
) -> Unit {
  @raylib.draw_circle(cx.to_int(), cy.to_int(), r, color)
  @raylib.draw_circle(cx.to_int(), cy.to_int(), 6.0, @types.color_title_bg)
  for t in 0..<teeth {
    let ta = a + Float::from_int(t) * 2.0 * @types.pi / Float::from_int(teeth)
    let ix = cx + @types.cosf(ta) * r
    let iy = cy + @types.sinf(ta) * r
    let ox = cx + @types.cosf(ta) * (r + 6.0)
    let oy = cy + @types.sinf(ta) * (r + 6.0)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(ix, iy),
      @raylib.Vector2::new(ox, oy),
      2.0,
      @types.color_tooth,
    )
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  @draw.draw_text("SELECT TIER", 100, 40, 36, @types.color_highlight)
  @draw.draw_text(
    "Choose a difficulty tier", 100, 85, 18, @types.color_text_dim,
  )
  let tiers : Array[@types.Tier] = [Gears, Trains, Workshop]
  for i in 0..<tiers.length() {
    let tier = tiers[i]
    let y = 160 + i * 160
    let is_selected = game.selected_tier == tier
    let box_color = if is_selected {
      @types.color_highlight
    } else {
      @types.color_panel
    }
    @raylib.draw_rectangle(80, y, 500, 130, box_color)
    let text_color = if is_selected { @raylib.black } else { @types.color_text }
    @draw.draw_text(@types.tier_name(tier), 110, y + 15, 30, text_color)
    let desc = tier_description(tier)
    @draw.draw_text(desc, 110, y + 55, 16, text_color)
    // Show progress
    let offset = @types.tier_level_offset(tier)
    let count = @types.tier_level_count(tier)
    let mut completed = 0
    let mut total_stars = 0
    for j in 0..<count {
      if game.scores[offset + j].completed {
        completed += 1
      }
      total_stars += game.scores[offset + j].stars
    }
    let prog = completed.to_string() +
      "/" +
      count.to_string() +
      " levels, " +
      total_stars.to_string() +
      " stars"
    @draw.draw_text(prog, 110, y + 85, 14, text_color)
  }
  // Navigation hints
  @draw.draw_text(
    "Up/Down: Select   Enter: Choose   Esc: Back", 100, 660, 16, @types.color_text_dim,
  )
  // Decorative gears on right side
  draw_decorative_gears(game.anim_timer)
}

///|
fn draw_decorative_gears(anim_timer : Float) -> Unit {
  let cx : Float = 900.0
  let cy : Float = 360.0
  let r1 : Float = 60.0
  let r2 : Float = 40.0
  let a1 : Float = anim_timer * 0.5
  let a2 : Float = -anim_timer * 0.75
  // Gear 1
  draw_title_single_gear(cx, cy, r1, 16, @types.color_gear_large, a1)
  // Gear 2
  let cx2 : Float = cx + r1 + r2
  draw_title_single_gear(cx2, cy, r2, 10, @types.color_gear_small, a2)
}

///|
fn tier_description(tier : @types.Tier) -> String {
  match tier {
    Gears => "8 levels: Learn meshing and speed ratios with 2 gear sizes"
    Trains => "9 levels: Gear trains, belts, and 2 outputs with 3 sizes"
    Workshop => "8 levels: All parts including ratchets, up to 3 outputs"
  }
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.selected_tier
  let tier_offset = @types.tier_level_offset(tier)
  let tier_count = @types.tier_level_count(tier)
  @draw.draw_text(
    @types.tier_name(tier) + " - Select Level",
    100,
    40,
    30,
    @types.color_highlight,
  )
  // Level grid
  let cols = 5
  for i in 0..<tier_count {
    let col = i % cols
    let row = i / cols
    let x = 100 + col * 200
    let y = 120 + row * 200
    let idx = tier_offset + i
    let is_selected = game.selected_level == idx
    let score = game.scores[idx]
    // Box
    let box_color = if is_selected {
      @types.color_highlight
    } else {
      @types.color_panel
    }
    @raylib.draw_rectangle(x, y, 170, 160, box_color)
    let tc = if is_selected { @raylib.black } else { @types.color_text }
    // Level number
    @draw.draw_text("Level " + (i + 1).to_string(), x + 10, y + 10, 22, tc)
    // Stars
    let star_y = y + 50
    for s in 0..<3 {
      let star_color = if s < score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      let sx = x + 20 + s * 50
      draw_star(Float::from_int(sx), Float::from_int(star_y), 12.0, star_color)
    }
    // Completion status
    if score.completed {
      @draw.draw_text("Completed", x + 10, y + 90, 14, tc)
      @draw.draw_text(
        "Gears: " + score.gears_used.to_string(),
        x + 10,
        y + 110,
        14,
        tc,
      )
    } else {
      @draw.draw_text("Not cleared", x + 10, y + 90, 14, tc)
    }
  }
  @draw.draw_text(
    "Arrow keys: Select   Enter: Play   Esc: Back", 100, 660, 16, @types.color_text_dim,
  )
}

///|
fn draw_star(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  // Simple 5-point star
  let points = 5
  for i in 0..<points {
    let a1 = Float::from_int(i) * 2.0 * @types.pi / Float::from_int(points) -
      @types.pi / 2.0
    let a2 = Float::from_int(i + 1) * 2.0 * @types.pi / Float::from_int(points) -
      @types.pi / 2.0
    let amid = (a1 + a2) / 2.0
    let ox = cx + @types.cosf(a1) * size
    let oy = cy + @types.sinf(a1) * size
    let ix = cx + @types.cosf(amid) * size * 0.4
    let iy = cy + @types.sinf(amid) * size * 0.4
    let ox2 = cx + @types.cosf(a2) * size
    let oy2 = cy + @types.sinf(a2) * size
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(ox, oy),
      @raylib.Vector2::new(ix, iy),
      color,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(ix, iy),
      @raylib.Vector2::new(ox2, oy2),
      color,
    )
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  @raylib.draw_rectangle(200, 100, 880, 520, @types.color_panel)
  @draw.draw_text("LEVEL COMPLETE!", 340, 130, 42, @types.color_highlight)
  @draw.draw_text(level.name, 340, 185, 24, @types.color_text)
  let score = game.scores[game.selected_level]
  // Stars display
  let star_y = 240
  for i in 0..<3 {
    let star_color = if i < score.stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    let sx = 480 + i * 80
    draw_star(Float::from_int(sx), Float::from_int(star_y), 24.0, star_color)
  }
  // Star descriptions
  @draw.draw_text(
    "1 Star: All outputs satisfied",
    340,
    300,
    18,
    if score.stars >= 1 {
      @types.color_output_ok
    } else {
      @types.color_text_dim
    },
  )
  @draw.draw_text(
    "2 Stars: Within par (" + level.par_gears.to_string() + " gears)",
    340,
    330,
    18,
    if score.stars >= 2 {
      @types.color_output_ok
    } else {
      @types.color_text_dim
    },
  )
  @draw.draw_text(
    "3 Stars: Par + minimum energy loss",
    340,
    360,
    18,
    if score.stars >= 3 {
      @types.color_output_ok
    } else {
      @types.color_text_dim
    },
  )
  // Stats
  @draw.draw_text(
    "Gears used: " + score.gears_used.to_string(),
    340,
    410,
    20,
    @types.color_text,
  )
  @draw.draw_text(
    "Par: " + level.par_gears.to_string(),
    340,
    440,
    20,
    @types.color_text_dim,
  )
  // Navigation
  @draw.draw_text(
    "Enter: Next Level   Esc: Level Select   R: Retry", 340, 530, 18, @types.color_text_dim,
  )
}
