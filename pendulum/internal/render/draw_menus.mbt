///|
fn draw_title(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Title text
  let title = "PENDULUM"
  let tw = @draw.measure_text(title, 64)
  @draw.draw_text(title, (sw - tw) / 2, 100, 64, @types.color_weight)
  // Subtitle
  let sub = "A Swing Physics Puzzle"
  let stw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (sw - stw) / 2, 180, 24, @types.color_text_dim)
  // Animated pendulum on title screen
  draw_title_pendulum(game, sw / 2, 360)
  // Start prompt
  let prompt = "Press ENTER to Start"
  let pw = @draw.measure_text(prompt, 28)
  let alpha = @types.absf(@types.sinf(Float::from_int(game.frame_count) * 0.05))
  let a_byte = (alpha * 255.0).to_int()
  let a_clamped = if a_byte < 0 {
    0
  } else if a_byte > 255 {
    255
  } else {
    a_byte
  }
  let col = @raylib.Color::new(
    @types.color_text.r.to_int(),
    @types.color_text.g.to_int(),
    @types.color_text.b.to_int(),
    a_clamped,
  )
  @draw.draw_text(prompt, (sw - pw) / 2, sh - 120, 28, col)
  // Credits
  let credits = "MoonBit + Raylib"
  let cw = @draw.measure_text(credits, 16)
  @draw.draw_text(credits, (sw - cw) / 2, sh - 40, 16, @types.color_text_dim)
}

///|
fn draw_title_pendulum(game : @types.Game, cx : Int, cy : Int) -> Unit {
  let angle = @types.sinf(game.title_angle) * 0.8
  let rope_len : Float = 120.0
  let wx = Float::from_int(cx) + @types.sinf(angle) * rope_len
  let wy = Float::from_int(cy) + @types.cosf(angle) * rope_len
  // Rope
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy)),
    @raylib.Vector2::new(wx, wy),
    2.0,
    @types.color_rope,
  )
  // Anchor
  @raylib.draw_circle(cx, cy, 8.0, @types.color_anchor)
  // Weight
  @raylib.draw_circle(wx.to_int(), wy.to_int(), 16.0, @types.color_weight)
  @raylib.draw_circle(
    wx.to_int(),
    wy.to_int(),
    8.0,
    @raylib.Color::new(255, 230, 120, 255),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  // Title
  let title = "SELECT TIER"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (sw - tw) / 2, 60, 40, @types.color_text)
  let tiers : Array[@types.Tier] = [Swing, Wrap, Launch]
  let tier_descs : Array[String] = [
    "Simple pendulum swings. Learn the basics.", "Pegs wrap the rope, changing arcs. New paths!",
    "Complex arrangements. Precise cut timing.",
  ]
  for i = 0; i < 3; i = i + 1 {
    let tier = tiers[i]
    let bx = sw / 2 - 200
    let by = 160 + i * 160
    let bw = 400
    let bh = 130
    // Check hover
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.tier_color(tier))
    // Tier name
    let name = @types.tier_name(tier)
    @draw.draw_text(name, bx + 20, by + 15, 32, @types.tier_color(tier))
    // Level count
    let count = @types.tier_level_count(tier)
    let count_str = count.to_string() + " levels"
    @draw.draw_text(count_str, bx + 20, by + 55, 18, @types.color_text_dim)
    // Description
    @draw.draw_text(tier_descs[i], bx + 20, by + 85, 16, @types.color_text_dim)
    // Stars earned
    let offset = @types.tier_level_offset(tier)
    let mut total_stars = 0
    for j = 0; j < count; j = j + 1 {
      if offset + j < game.scores.length() {
        total_stars = total_stars + game.scores[offset + j].stars
      }
    }
    let star_str = total_stars.to_string() +
      "/" +
      (count * 3).to_string() +
      " stars"
    @draw.draw_text(
      star_str,
      bx + bw - 120,
      by + 15,
      18,
      @types.color_star_gold,
    )
  }
  // Back
  @draw.draw_text("[Esc] Back", 16, 680, 18, @types.color_text_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let tier = game.selected_tier
  let tier_col = @types.tier_color(tier)
  // Title
  let title = @types.tier_name(tier) + " Levels"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (sw - tw) / 2, 40, 36, tier_col)
  let count = @types.tier_level_count(tier)
  let offset = @types.tier_level_offset(tier)
  let cols = 4
  let bw = 140
  let bh = 120
  let gap = 20
  let total_w = cols * bw + (cols - 1) * gap
  let start_x = (sw - total_w) / 2
  let start_y = 110
  for i = 0; i < count; i = i + 1 {
    let col = i % cols
    let row = i / cols
    let bx = start_x + col * (bw + gap)
    let by = start_y + row * (bh + gap)
    let level_id = offset + i
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, tier_col)
    // Level number
    let num_str = (i + 1).to_string()
    @draw.draw_text(num_str, bx + 10, by + 10, 28, @types.color_text)
    // Stars
    let score = game.scores[level_id]
    for s = 0; s < 3; s = s + 1 {
      let star_col = if s < score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", bx + 10 + s * 20, by + 50, 24, star_col)
    }
    // Best ticks
    if score.completed {
      let best = "Best: " + score.best_ticks.to_string()
      @draw.draw_text(best, bx + 10, by + 85, 14, @types.color_text_dim)
    }
  }
  // Back
  @draw.draw_text("[Esc] Back", 16, 680, 18, @types.color_text_dim)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  match game.current_level {
    Some(level) => {
      // Title
      let title = "Level Complete!"
      let tw = @draw.measure_text(title, 48)
      @draw.draw_text(title, (sw - tw) / 2, 80, 48, @types.color_goal)
      // Level name
      let name = level.name
      let nw = @draw.measure_text(name, 28)
      @draw.draw_text(name, (sw - nw) / 2, 150, 28, @types.color_text)
      // Ticks
      let tick_str = "Ticks: " + game.tick_count.to_string()
      let tsw = @draw.measure_text(tick_str, 32)
      @draw.draw_text(tick_str, (sw - tsw) / 2, 220, 32, @types.color_text)
      // Par
      let par_str = "Par: " + level.par_ticks.to_string()
      let pw = @draw.measure_text(par_str, 24)
      let par_col = if game.tick_count <= level.par_ticks {
        @types.color_goal
      } else {
        @types.color_text_dim
      }
      @draw.draw_text(par_str, (sw - pw) / 2, 265, 24, par_col)
      // Collectibles
      let mut got = 0
      for i = 0; i < game.collected.length(); i = i + 1 {
        if game.collected[i] {
          got = got + 1
        }
      }
      if level.collectibles.length() > 0 {
        let coll_str = "Collectibles: " +
          got.to_string() +
          "/" +
          level.collectibles.length().to_string()
        let cw = @draw.measure_text(coll_str, 24)
        @draw.draw_text(
          coll_str,
          (sw - cw) / 2,
          310,
          24,
          @types.color_collectible,
        )
      }
      // Stars
      let stars = @physics.compute_stars(
        game.tick_count,
        level.par_ticks,
        level.collectibles.length(),
        got,
      )
      let star_y = 370
      let star_start = sw / 2 - 60
      for s = 0; s < 3; s = s + 1 {
        let col = if s < stars {
          @types.color_star_gold
        } else {
          @types.color_star_empty
        }
        @draw.draw_text("*", star_start + s * 45, star_y, 48, col)
      }
      // Options
      let opt1 = "[Enter] Next Level  [R] Retry  [Esc] Back"
      let ow = @draw.measure_text(opt1, 22)
      @draw.draw_text(opt1, (sw - ow) / 2, 500, 22, @types.color_text_dim)
    }
    None => ()
  }
}
