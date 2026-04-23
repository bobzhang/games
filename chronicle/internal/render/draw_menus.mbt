///|
fn draw_title(game : @types.Game) -> Unit {
  // Background
  if !draw_title_backdrop_art() {
    @raylib.draw_rectangle(
      0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
    )
    // Decorative lines
    for i in 0..<5 {
      let y = 100 + i * 120
      @raylib.draw_line(
        100,
        y,
        @types.screen_width - 100,
        y,
        @raylib.Color::new(60, 55, 70, 80),
      )
    }
  }
  // Title
  let pulse = Float::from_double(@math.sin(game.title_pulse.to_double() * 2.0))
  let alpha = 200 + Float::to_int(pulse * 55.0)
  let title_color = @raylib.Color::new(220, 200, 160, alpha)
  let title = "CHRONICLE"
  let tw = @draw.measure_text(title, 64)
  @draw.draw_text(title, (@types.screen_width - tw) / 2, 180, 64, title_color)
  // Subtitle
  let sub = "Causality Reconstruction Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    260,
    24,
    @types.color_subtitle,
  )
  // Case file decorations
  @raylib.draw_rectangle(
    440,
    320,
    400,
    200,
    @raylib.Color::new(50, 45, 60, 200),
  )
  @raylib.draw_rectangle_lines(440, 320, 400, 200, @types.color_subtitle)
  @draw.draw_text("CASE FILES", 540, 340, 28, @types.color_title)
  @draw.draw_text("20 Cases  |  3 Tiers", 520, 380, 18, @types.color_subtitle)
  @draw.draw_text("Deduce the timeline.", 510, 410, 18, @types.color_subtitle)
  @draw.draw_text("Connect the causes.", 514, 435, 18, @types.color_subtitle)
  @draw.draw_text("Solve the mystery.", 518, 460, 18, @types.color_subtitle)
  // Prompt
  let prompt = "Press ENTER to begin"
  let pw = @draw.measure_text(prompt, 22)
  let prompt_alpha : Int = 140 +
    Float::to_int(
      Float::from_double(@math.sin(game.title_pulse.to_double() * 3.0)) * 115.0,
    )
  @draw.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    580,
    22,
    @raylib.Color::new(200, 190, 170, prompt_alpha),
  )
  // Footer
  @draw.draw_text(
    "Arrow keys to navigate | Enter to select | Esc to go back",
    300,
    670,
    16,
    @raylib.Color::new(120, 110, 100, 200),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  @draw.draw_text("SELECT TIER", 520, 40, 36, @types.color_title)
  let tiers : Array[@types.Tier] = [Reports, Investigations, ColdCases]
  let tier_colors = [
    @types.color_tier_reports, @types.color_tier_investigations, @types.color_tier_cold,
  ]
  let tier_descs = [
    "6-card cases, simple ordering", "7-card cases, misleading clues", "8-card cases, complex chains",
  ]
  for i in 0..<3 {
    let y = 150 + i * 170
    let selected = @types.tier_index(game.current_tier) == i
    let box_color = if selected { tier_colors[i] } else { @types.color_button }
    @raylib.draw_rectangle(340, y, 600, 140, box_color)
    if selected {
      @raylib.draw_rectangle_lines(340, y, 600, 140, @types.color_white)
    }
    let name = @types.tier_name(tiers[i])
    let text_color = if selected {
      @raylib.Color::new(30, 25, 20, 255)
    } else {
      @types.color_hud
    }
    @draw.draw_text(name, 380, y + 20, 32, text_color)
    let count_str = @types.tier_case_count(tiers[i]).to_string() + " Cases"
    @draw.draw_text(count_str, 380, y + 60, 20, text_color)
    @draw.draw_text(tier_descs[i], 380, y + 90, 18, text_color)
    // Stars earned
    let ti = i
    let mut total_stars = 0
    for j in 0..<game.case_scores[ti].length() {
      total_stars += game.case_scores[ti][j].stars
    }
    let max_stars = game.case_scores[ti].length() * 3
    let star_text = total_stars.to_string() +
      "/" +
      max_stars.to_string() +
      " stars"
    @draw.draw_text(star_text, 780, y + 20, 20, @types.color_star)
  }
  @draw.draw_text(
    "Up/Down to select | Enter to choose | Esc to go back", 350, 680, 16, @types.color_subtitle,
  )
}

///|
fn draw_case_select(game : @types.Game) -> Unit {
  let tier = game.current_tier
  let tier_name = @types.tier_name(tier)
  @draw.draw_text(tier_name, 520, 30, 32, @types.color_title)
  let count = @types.tier_case_count(tier)
  let ti = @types.tier_index(tier)
  for i in 0..<count {
    let case_ = @levels.get_case(tier, i)
    let row = i / 4
    let col = i % 4
    let x = 80 + col * 290
    let y = 100 + row * 250
    let selected = game.current_case_index == i
    let box_color = if selected {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(x, y, 260, 220, box_color)
    if selected {
      @raylib.draw_rectangle_lines(x, y, 260, 220, @types.color_clue)
    }
    // Case number
    let num_str = "Case " + (i + 1).to_string()
    @draw.draw_text(num_str, x + 10, y + 10, 18, @types.color_subtitle)
    // Title
    @draw.draw_text(case_.title, x + 10, y + 35, 20, @types.color_title)
    // Theme
    @draw.draw_text(case_.theme, x + 10, y + 65, 16, @types.color_subtitle)
    // Card/link count
    let info = case_.cards.length().to_string() +
      " cards, " +
      case_.solution_links.length().to_string() +
      " links"
    @draw.draw_text(info, x + 10, y + 95, 16, @types.color_hud)
    // Stars
    let score = game.case_scores[ti][i]
    for s in 0..<3 {
      let sx = x + 10 + s * 30
      let sy = y + 130
      let star_col = if s < score.stars {
        @types.color_star
      } else {
        @types.color_star_empty
      }
      draw_star(sx, sy, 12.0, star_col)
    }
    // Clue count
    let clue_str = case_.clues.length().to_string() + " clues"
    @draw.draw_text(clue_str, x + 10, y + 170, 16, @types.color_clue)
  }
  @draw.draw_text(
    "Arrows to select | Enter to play | Esc to go back", 360, 680, 16, @types.color_subtitle,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let score = game.result_score
  @raylib.draw_rectangle(290, 100, 700, 520, @types.color_clue_panel_bg)
  @raylib.draw_rectangle_lines(290, 100, 700, 520, @types.color_subtitle)
  @draw.draw_text("CASE RESULTS", 510, 120, 36, @types.color_title)
  // Stars
  for s in 0..<3 {
    let sx = 540 + s * 60
    let star_col = if s < score.stars {
      @types.color_star
    } else {
      @types.color_star_empty
    }
    draw_star(sx, 185, 24.0, star_col)
  }
  // Order result
  let order_text = if score.order_correct {
    "Timeline Order: CORRECT"
  } else {
    "Timeline Order: INCORRECT (" + score.order_count.to_string() + " in place)"
  }
  let order_col = if score.order_correct {
    @types.color_correct
  } else {
    @types.color_wrong
  }
  @draw.draw_text(order_text, 380, 260, 24, order_col)
  // Links result
  let link_text = if score.links_correct {
    "Cause Links: ALL CORRECT"
  } else {
    "Cause Links: " + score.link_count.to_string() + " correct"
  }
  let link_col = if score.links_correct {
    @types.color_correct
  } else {
    @types.color_wrong
  }
  @draw.draw_text(link_text, 380, 310, 24, link_col)
  // Rewinds
  let rewind_text = "Rewinds used: " + game.rewinds.to_string()
  let rewind_col = if score.no_rewinds {
    @types.color_correct
  } else {
    @types.color_clue
  }
  @draw.draw_text(rewind_text, 380, 360, 24, rewind_col)
  // Star explanation
  @draw.draw_text("1 star: Correct order", 420, 420, 18, @types.color_subtitle)
  @draw.draw_text(
    "2 stars: Order + all links", 420, 448, 18, @types.color_subtitle,
  )
  @draw.draw_text(
    "3 stars: Order + links + no rewinds", 420, 476, 18, @types.color_subtitle,
  )
  @draw.draw_text("Enter: Continue | R: Retry", 500, 560, 20, @types.color_hud)
}

///|
fn clamp_color(v : Int) -> Int {
  if v < 0 {
    0
  } else if v > 255 {
    255
  } else {
    v
  }
}

///|
fn draw_star(x : Int, y : Int, size : Float, color : @raylib.Color) -> Unit {
  // Simple star: draw filled circle + small accent
  let cx = Float::from_int(x) + size
  let cy = Float::from_int(y) + size
  @raylib.draw_circle(Float::to_int(cx), Float::to_int(cy), size, color)
  // Inner highlight
  let inner = @raylib.Color::new(
    clamp_color(color.r.to_int() + 30),
    clamp_color(color.g.to_int() + 30),
    clamp_color(color.b.to_int() + 30),
    color.a.to_int(),
  )
  @raylib.draw_circle(
    Float::to_int(cx - size * 0.15),
    Float::to_int(cy - size * 0.15),
    size * 0.5,
    inner,
  )
}
