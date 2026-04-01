///|
fn draw_title(game : @types.Game) -> Unit {
  // Animated water background
  let frame = game.frame_count
  for y in 0..<(@types.screen_height / 20) {
    for x in 0..<(@types.screen_width / 20) {
      let wave = Float::from_double(
        @math.sin(
          Float::from_int(x * 20 + frame * 2).to_double() * 0.02 +
          Float::from_int(y * 20).to_double() * 0.03,
        ),
      )
      let base_b = 120 + (wave * 40.0).to_int()
      let b_clamped = @types.mini(@types.maxi(base_b, 80), 200)
      let color = @raylib.Color::new(20, 40, b_clamped, 255)
      @raylib.draw_rectangle(x * 20, y * 20, 20, 20, color)
    }
  }
  // Title overlay
  @raylib.draw_rectangle(
    0,
    180,
    @types.screen_width,
    200,
    @raylib.Color::new(0, 0, 0, 150),
  )
  // Title text
  let title = "ISTHMUS"
  let tw = @draw.measure_text(title, 72)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    210,
    72,
    @types.color_settlement,
  )
  // Subtitle
  let subtitle = "Rising Sea Land Bridge Puzzle"
  let sw = @draw.measure_text(subtitle, 24)
  @draw.draw_text(
    subtitle,
    (@types.screen_width - sw) / 2,
    300,
    24,
    @types.color_ui_text,
  )
  // Prompt
  let prompt = "Press ENTER to begin"
  let pulse = Float::from_double(
    @math.sin(Float::from_int(frame).to_double() * 0.05),
  )
  let alpha = 150 + (pulse * 105.0).to_int()
  let pw = @draw.measure_text(prompt, 28)
  @draw.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    480,
    28,
    @raylib.Color::new(220, 230, 245, alpha),
  )
  // Draw some island shapes
  draw_title_island(200, 500, frame)
  draw_title_island(900, 520, frame + 100)
  ignore(game)
}

///|
fn draw_title_island(x : Int, y : Int, frame : Int) -> Unit {
  let wave = Float::from_double(
    @math.sin(Float::from_int(frame).to_double() * 0.03),
  )
  let dy = (wave * 3.0).to_int()
  @raylib.draw_circle(x, y + dy, 40.0, @types.color_land_mid)
  @raylib.draw_circle(x + 30, y + dy - 5, 30.0, @types.color_land_high)
  @raylib.draw_circle(x - 20, y + dy + 5, 25.0, @types.color_land_low)
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  // Header
  let header = "Select Tier"
  let hw = @draw.measure_text(header, 40)
  @draw.draw_text(
    header,
    (@types.screen_width - hw) / 2,
    40,
    40,
    @types.color_ui_text,
  )
  // Draw three tier boxes
  let tiers : Array[@types.Tier] = [Shores, Straits, Archipelago]
  let box_w = 320
  let box_h = 350
  let gap = 40
  let total_w = box_w * 3 + gap * 2
  let start_x = (@types.screen_width - total_w) / 2
  for i in 0..<3 {
    let tier = tiers[i]
    let bx = start_x + i * (box_w + gap)
    let by = 120
    // Check tier unlocked (first tier always, others need prev completed)
    let unlocked = is_tier_unlocked(game, tier)
    let tier_color = match tier {
      Shores => @types.color_tier_shores
      Straits => @types.color_tier_straits
      Archipelago => @types.color_tier_archipelago
    }
    // Box background
    let bg_alpha = if unlocked { 200 } else { 80 }
    @raylib.draw_rectangle(
      bx,
      by,
      box_w,
      box_h,
      @raylib.Color::new(30, 35, 55, bg_alpha),
    )
    @raylib.draw_rectangle_lines(bx, by, box_w, box_h, tier_color)
    // Tier name
    let tname = @types.tier_name(tier)
    let tnw = @draw.measure_text(tname, 32)
    @draw.draw_text(tname, bx + (box_w - tnw) / 2, by + 20, 32, tier_color)
    // Level count and description
    let count = @types.tier_level_count(tier)
    let desc = count.to_string() + " levels"
    let dw = @draw.measure_text(desc, 20)
    @draw.draw_text(
      desc,
      bx + (box_w - dw) / 2,
      by + 65,
      20,
      @types.color_ui_text,
    )
    // Tier description
    let flavor = match tier {
      Shores => "Gentle slopes\nGenerous sand"
      Straits => "Steep drops\nTighter budget"
      Archipelago => "Scattered islands\nMinimal sand"
    }
    @draw.draw_text(
      flavor,
      bx + 20,
      by + 110,
      18,
      @raylib.Color::new(180, 190, 210, 255),
    )
    // Stars earned
    let (earned, possible) = tier_stars(game, tier)
    let stars_str = "Stars: " +
      earned.to_string() +
      " / " +
      possible.to_string()
    @draw.draw_text(stars_str, bx + 20, by + 200, 18, @types.color_star_gold)
    // Draw star icons
    for s in 0..<3 {
      let sx = bx + 20 + s * 30
      let sy = by + 230
      let star_filled = earned > s * count / 3
      let sc = if star_filled {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @raylib.draw_circle(sx + 10, sy + 10, 10.0, sc)
    }
    if !unlocked {
      // Locked overlay
      @raylib.draw_rectangle(
        bx,
        by,
        box_w,
        box_h,
        @raylib.Color::new(0, 0, 0, 150),
      )
      let lock_str = "LOCKED"
      let lw = @draw.measure_text(lock_str, 28)
      @draw.draw_text(
        lock_str,
        bx + (box_w - lw) / 2,
        by + box_h / 2 - 14,
        28,
        @raylib.Color::new(200, 80, 80, 255),
      )
    }
    // Number key hint
    let key_str = "[" + (i + 1).to_string() + "]"
    let kw = @draw.measure_text(key_str, 20)
    @draw.draw_text(
      key_str,
      bx + (box_w - kw) / 2,
      by + box_h - 35,
      20,
      @raylib.Color::new(150, 160, 180, 255),
    )
  }
  // Back hint
  @draw.draw_text(
    "Press ESC to go back",
    20,
    @types.screen_height - 40,
    18,
    @raylib.Color::new(150, 160, 180, 255),
  )
}

///|
fn is_tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Shores => true
    Straits => {
      // Need at least 4 Shores levels completed
      let mut completed = 0
      let start = @types.tier_start_level(Shores)
      let count = @types.tier_level_count(Shores)
      for i in start..<(start + count) {
        if game.level_scores[i].completed {
          completed += 1
        }
      }
      completed >= 4
    }
    Archipelago => {
      // Need at least 4 Straits levels completed
      let mut completed = 0
      let start = @types.tier_start_level(Straits)
      let count = @types.tier_level_count(Straits)
      for i in start..<(start + count) {
        if game.level_scores[i].completed {
          completed += 1
        }
      }
      completed >= 4
    }
  }
}

///|
fn tier_stars(game : @types.Game, tier : @types.Tier) -> (Int, Int) {
  let start = @types.tier_start_level(tier)
  let count = @types.tier_level_count(tier)
  let mut earned = 0
  let possible = count * 3
  for i in start..<(start + count) {
    earned += game.level_scores[i].stars
  }
  (earned, possible)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.selected_tier
  let tier_color = match tier {
    Shores => @types.color_tier_shores
    Straits => @types.color_tier_straits
    Archipelago => @types.color_tier_archipelago
  }
  // Header
  let header = @types.tier_name(tier) + " - Select Level"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(header, (@types.screen_width - hw) / 2, 30, 36, tier_color)
  let start = @types.tier_start_level(tier)
  let count = @types.tier_level_count(tier)
  // Grid of level buttons
  let cols = 4
  let btn_w = 250
  let btn_h = 120
  let gap_x = 30
  let gap_y = 20
  let total_w = cols * btn_w + (cols - 1) * gap_x
  let base_x = (@types.screen_width - total_w) / 2
  let base_y = 100
  for i in 0..<count {
    let level_idx = start + i
    let col = i % cols
    let row = i / cols
    let bx = base_x + col * (btn_w + gap_x)
    let by = base_y + row * (btn_h + gap_y)
    let score = game.level_scores[level_idx]
    let level = @levels.get_level(level_idx)
    // Button background
    let bg_color = if score.completed {
      @raylib.Color::new(30, 50, 40, 220)
    } else {
      @raylib.Color::new(30, 35, 55, 220)
    }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg_color)
    @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, tier_color)
    // Level number and name
    let num_str = (level_idx + 1).to_string() + ". " + level.name
    @draw.draw_text(num_str, bx + 10, by + 10, 18, @types.color_ui_text)
    // Level info
    let info = "Sea: " +
      level.max_sea_level.to_string() +
      "  Sand: " +
      level.sand_budget.to_string()
    @draw.draw_text(
      info,
      bx + 10,
      by + 38,
      14,
      @raylib.Color::new(150, 160, 180, 255),
    )
    let settle_count = level.settlements.length()
    let settle_str = settle_count.to_string() + " settlements"
    @draw.draw_text(settle_str, bx + 10, by + 58, 14, @types.color_settlement)
    // Stars
    for s in 0..<3 {
      let sx = bx + 10 + s * 25
      let sy = by + btn_h - 30
      let sc = if s < score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @raylib.draw_circle(sx + 8, sy + 8, 8.0, sc)
    }
    // Key hint
    let key_char = if i < 9 { (i + 1).to_string() } else { "0" }
    @draw.draw_text(
      "[" + key_char + "]",
      bx + btn_w - 35,
      by + btn_h - 25,
      14,
      @raylib.Color::new(120, 130, 150, 255),
    )
  }
  // Back hint
  @draw.draw_text(
    "Press ESC to go back  |  Press number to select level",
    20,
    @types.screen_height - 40,
    18,
    @raylib.Color::new(150, 160, 180, 255),
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  // Background overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let level = @levels.get_level(game.selected_level)
  let won = game.play_state == Won
  // Result box
  let box_w = 500
  let box_h = 400
  let bx = (@types.screen_width - box_w) / 2
  let by = (@types.screen_height - box_h) / 2
  @raylib.draw_rectangle(
    bx,
    by,
    box_w,
    box_h,
    @raylib.Color::new(25, 30, 50, 240),
  )
  let border_color = if won {
    @types.color_star_gold
  } else {
    @raylib.Color::new(200, 60, 60, 255)
  }
  @raylib.draw_rectangle_lines(bx, by, box_w, box_h, border_color)
  // Title
  let result_title = if won { "VICTORY!" } else { "FLOODED!" }
  let title_color = if won {
    @types.color_star_gold
  } else {
    @raylib.Color::new(255, 80, 80, 255)
  }
  let rtw = @draw.measure_text(result_title, 48)
  @draw.draw_text(
    result_title,
    bx + (box_w - rtw) / 2,
    by + 20,
    48,
    title_color,
  )
  // Level name
  let name_str = "Level " +
    (game.selected_level + 1).to_string() +
    ": " +
    level.name
  let nw = @draw.measure_text(name_str, 22)
  @draw.draw_text(
    name_str,
    bx + (box_w - nw) / 2,
    by + 80,
    22,
    @types.color_ui_text,
  )
  if won {
    // Stars display
    let stars = compute_stars(game)
    let stars_y = by + 130
    for s in 0..<3 {
      let sx = bx + box_w / 2 - 60 + s * 50
      let sc = if s < stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @raylib.draw_circle(sx + 15, stars_y + 15, 18.0, sc)
    }
    // Star descriptions
    let desc_y = by + 180
    let star1_str = "Connected at end"
    let s1_color = if stars >= 1 {
      @types.color_connected
    } else {
      @types.color_star_empty
    }
    @draw.draw_text(star1_str, bx + 40, desc_y, 18, s1_color)
    let sand_left = game.sand_remaining
    let star2_str = "Sand remaining: " +
      sand_left.to_string() +
      " (par: " +
      level.par_sand.to_string() +
      ")"
    let s2_color = if stars >= 2 {
      @types.color_connected
    } else {
      @types.color_star_empty
    }
    @draw.draw_text(star2_str, bx + 40, desc_y + 28, 18, s2_color)
    let star3_str = if game.never_disconnected {
      "Never disconnected!"
    } else {
      "Was disconnected during play"
    }
    let s3_color = if stars >= 3 {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text(star3_str, bx + 40, desc_y + 56, 18, s3_color)
    // Loss info
  } else if @terrain.any_settlement_flooded(game.grid, game.sea_level) {
    let lost_str = "A settlement was flooded!"
    let lw = @draw.measure_text(lost_str, 22)
    @draw.draw_text(
      lost_str,
      bx + (box_w - lw) / 2,
      by + 140,
      22,
      @raylib.Color::new(255, 100, 100, 255),
    )
  } else {
    let lost_str = "Settlements disconnected at final turn"
    let lw = @draw.measure_text(lost_str, 20)
    @draw.draw_text(
      lost_str,
      bx + (box_w - lw) / 2,
      by + 140,
      20,
      @raylib.Color::new(255, 100, 100, 255),
    )
  }
  // Options
  @draw.draw_text(
    "[R] Retry Level",
    bx + 40,
    by + box_h - 80,
    20,
    @types.color_ui_text,
  )
  @draw.draw_text(
    "[ESC] Back to Level Select",
    bx + 40,
    by + box_h - 50,
    20,
    @types.color_ui_text,
  )
}

///|
pub fn compute_stars(game : @types.Game) -> Int {
  let level = @levels.get_level(game.selected_level)
  if game.play_state != Won {
    return 0
  }
  let mut stars = 1
  // Star 2: sand remaining >= par
  if game.sand_remaining >= level.par_sand {
    stars = 2
  }
  // Star 3: never disconnected
  if game.never_disconnected && game.sand_remaining >= level.par_sand {
    stars = 3
  }
  stars
}
