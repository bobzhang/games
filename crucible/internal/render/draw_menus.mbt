///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated bubbling cauldron in background
  for i in 0..<20 {
    let fi : Float = Float::from_int(i)
    let bx : Float = Float::from_int(w) / 2.0 +
      @types.sinf(fi * 0.7 + time) * 80.0
    let by : Float = Float::from_int(h) / 2.0 +
      60.0 -
      fi * 8.0 +
      @types.sinf(time + fi) * 10.0
    let size : Float = 6.0 + @types.sinf(fi + time * 2.0) * 3.0
    let alpha_f : Float = 180.0 - fi * 8.0
    let alpha : Int = alpha_f.to_int()
    let a = if alpha > 0 { alpha } else { 0 }
    @raylib.draw_circle(
      bx.to_int(),
      by.to_int(),
      size,
      @raylib.Color::new(160, 100, 220, a),
    )
  }
  // Large cauldron silhouette
  @raylib.draw_circle(w / 2, h / 2 + 80, 100.0, @types.color_cauldron_rim)
  @raylib.draw_circle(w / 2, h / 2 + 80, 85.0, @types.color_cauldron_inner)
  // Glowing liquid
  let glow_f : Float = 180.0 + @types.sinf(time * 2.0) * 60.0
  let glow_alpha : Int = glow_f.to_int()
  @raylib.draw_circle(
    w / 2,
    h / 2 + 80,
    70.0,
    @raylib.Color::new(140, 80, 200, glow_alpha),
  )
  // Title text
  let title = "CRUCIBLE"
  let title_w = @draw.measure_text(title, 64)
  let pulse : Float = @types.sinf(time * 1.5) * 0.15 + 0.85
  let ta : Int = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 6,
    64,
    @raylib.Color::new(180, 120, 255, ta),
  )
  // Subtitle
  let sub = "An Alchemy Puzzle"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 6 + 75, 22, @types.color_text_dim)
  // Start prompt
  let start = "PRESS ENTER TO BEGIN"
  let start_w = @draw.measure_text(start, 26)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 80 }
  @draw.draw_text(
    start,
    (w - start_w) / 2,
    h - 100,
    26,
    @raylib.Color::new(200, 180, 255, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Header
  let header = "SELECT TIER"
  let hw = @draw.measure_text(header, 40)
  @draw.draw_text(header, (w - hw) / 2, 50, 40, @types.color_text_bright)
  // Three tier cards
  let tiers : Array[@types.Tier] = [Apprentice, Journeyman, Master]
  for i in 0..<3 {
    let tier = tiers[i]
    let card_w = 300
    let card_h = 200
    let card_x = (w - card_w * 3 - 60) / 2 + i * (card_w + 30)
    let card_y = h / 2 - card_h / 2
    let unlocked = @levels.is_tier_unlocked(tier, game.level_scores)
    // Card background
    let bg = if unlocked {
      @types.color_button
    } else {
      @raylib.Color::new(40, 35, 45, 255)
    }
    @raylib.draw_rectangle(card_x, card_y, card_w, card_h, bg)
    @raylib.draw_rectangle_lines(
      card_x, card_y, card_w, card_h, @types.color_panel_border,
    )
    // Tier name
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 28)
    let text_color = if unlocked {
      @types.color_text_bright
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(
      name,
      card_x + (card_w - nw) / 2,
      card_y + 30,
      28,
      text_color,
    )
    // Level count and completion
    let start = @types.tier_start_index(tier)
    let count = @types.tier_level_count(tier)
    let mut completed = 0
    let mut total_stars = 0
    for j in start..<(start + count) {
      if game.level_scores[j].completed {
        completed += 1
      }
      total_stars += game.level_scores[j].stars
    }
    let progress = completed.to_string() + "/" + count.to_string() + " Complete"
    let pw = @draw.measure_text(progress, 18)
    @draw.draw_text(
      progress,
      card_x + (card_w - pw) / 2,
      card_y + 80,
      18,
      text_color,
    )
    // Stars
    let star_text = "Stars: " +
      total_stars.to_string() +
      "/" +
      (count * 3).to_string()
    let sw = @draw.measure_text(star_text, 16)
    @draw.draw_text(
      star_text,
      card_x + (card_w - sw) / 2,
      card_y + 110,
      16,
      @types.color_star_gold,
    )
    if !unlocked {
      let lock = "LOCKED"
      let lw = @draw.measure_text(lock, 20)
      @draw.draw_text(
        lock,
        card_x + (card_w - lw) / 2,
        card_y + 150,
        20,
        @types.color_destroy,
      )
    } else {
      // Hover hint
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      if mx >= card_x &&
        mx <= card_x + card_w &&
        my >= card_y &&
        my <= card_y + card_h {
        @raylib.draw_rectangle_lines(
          card_x - 2,
          card_y - 2,
          card_w + 4,
          card_h + 4,
          @types.color_title_glow,
        )
        let click = "Click to select"
        let cw = @draw.measure_text(click, 14)
        @draw.draw_text(
          click,
          card_x + (card_w - cw) / 2,
          card_y + 160,
          14,
          @types.color_text,
        )
      }
    }
  }
  // Navigation hint
  let nav = "ESC - Back to Title"
  @draw.draw_text(nav, 20, h - 40, 16, @types.color_text_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Header
  let header = @types.tier_name(game.current_tier) + " - Select Level"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(header, (w - hw) / 2, 40, 36, @types.color_text_bright)
  let start = @types.tier_start_index(game.current_tier)
  let count = @types.tier_level_count(game.current_tier)
  // Grid of level buttons
  let cols = 5
  let btn_w = 160
  let btn_h = 100
  let gap = 20
  let grid_w = cols * btn_w + (cols - 1) * gap
  let base_x = (w - grid_w) / 2
  let base_y = 120
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let bx = base_x + col * (btn_w + gap)
    let by = base_y + row * (btn_h + gap)
    let level_idx = start + i
    let level = @levels.get_level(level_idx)
    let score = game.level_scores[level_idx]
    // Button background
    let bg = if score.completed {
      @raylib.Color::new(40, 70, 50, 255)
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg)
    @raylib.draw_rectangle_lines(
      bx, by, btn_w, btn_h, @types.color_panel_border,
    )
    // Level number
    let num = "Level " + (i + 1).to_string()
    let nw = @draw.measure_text(num, 18)
    @draw.draw_text(
      num,
      bx + (btn_w - nw) / 2,
      by + 10,
      18,
      @types.color_text_bright,
    )
    // Target element
    let target_name = @types.element_name(level.target)
    let target_color = @types.element_color(level.target)
    let tw = @draw.measure_text(target_name, 16)
    @draw.draw_text(
      target_name,
      bx + (btn_w - tw) / 2,
      by + 35,
      16,
      target_color,
    )
    // Stars
    for s in 0..<3 {
      let star_x = bx + btn_w / 2 - 30 + s * 22
      let star_y = by + 62
      let star_color = if s < score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", star_x, star_y, 22, star_color)
    }
    // Hover
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    if mx >= bx && mx <= bx + btn_w && my >= by && my <= by + btn_h {
      @raylib.draw_rectangle_lines(
        bx - 2,
        by - 2,
        btn_w + 4,
        btn_h + 4,
        @types.color_title_glow,
      )
    }
  }
  // Navigation
  let nav = "ESC - Back to Tiers"
  @draw.draw_text(nav, 20, h - 40, 16, @types.color_text_dim)
  // Discovery progress
  let disc = "Recipes: " +
    game.discovered_count.to_string() +
    "/" +
    @types.total_reactions.to_string()
  let dw = @draw.measure_text(disc, 16)
  @draw.draw_text(disc, w - dw - 20, h - 40, 16, @types.color_text_dim)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(10, 8, 20, 220))
  // Result panel
  let pw = 500
  let ph = 400
  let px = (w - pw) / 2
  let py = (h - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_panel_border)
  // Title
  let title = "Level Complete!"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, py + 30, 36, @types.color_success)
  // Target produced
  let level = @levels.get_level(game.current_level_index)
  let target_text = "Target: " + @types.element_name(level.target)
  let ttw = @draw.measure_text(target_text, 24)
  @draw.draw_text(
    target_text,
    (w - ttw) / 2,
    py + 90,
    24,
    @types.element_color(level.target),
  )
  // Steps
  let steps = "Steps: " +
    game.result_steps.to_string() +
    " (par: " +
    level.par_steps.to_string() +
    ")"
  let stw = @draw.measure_text(steps, 20)
  @draw.draw_text(steps, (w - stw) / 2, py + 140, 20, @types.color_text)
  // Stars
  for i in 0..<3 {
    let star_x = w / 2 - 60 + i * 50
    let star_y = py + 190
    let star_size : Float = 30.0 +
      @types.sinf(time * 3.0 + Float::from_int(i)) * 3.0
    let star_color = if i < game.result_stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @raylib.draw_circle(star_x, star_y, star_size / 2.0, star_color)
    @draw.draw_text("*", star_x - 7, star_y - 12, 28, @types.color_bg)
  }
  // Star explanations
  let s1 = "1 star: Produce target"
  let s2 = "2 stars: Within par steps"
  let s3 = "3 stars: Par + no failures"
  @draw.draw_text(
    s1,
    px + 100,
    py + 240,
    14,
    if game.result_stars >= 1 {
      @types.color_text
    } else {
      @types.color_text_dim
    },
  )
  @draw.draw_text(
    s2,
    px + 100,
    py + 260,
    14,
    if game.result_stars >= 2 {
      @types.color_text
    } else {
      @types.color_text_dim
    },
  )
  @draw.draw_text(
    s3,
    px + 100,
    py + 280,
    14,
    if game.result_stars >= 3 {
      @types.color_text
    } else {
      @types.color_text_dim
    },
  )
  // Continue prompt
  let cont = "ENTER - Next Level    ESC - Level Select"
  let cw = @draw.measure_text(cont, 18)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 120 }
  @draw.draw_text(
    cont,
    (w - cw) / 2,
    py + ph - 50,
    18,
    @raylib.Color::new(200, 180, 255, blink),
  )
}
