///|
fn draw_title(game : @types.Game) -> Unit {
  let _ = game
  // Decorative border
  @raylib.draw_rectangle_lines(
    20,
    20,
    @types.screen_width - 40,
    @types.screen_height - 40,
    @types.color_sand,
  )
  @raylib.draw_rectangle_lines(
    24,
    24,
    @types.screen_width - 48,
    @types.screen_height - 48,
    @types.color_sand,
  )
  // Title
  let title = "NOMAD"
  let tw = @draw.measure_text(title, 72)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    160,
    72,
    @types.color_title_text,
  )
  // Subtitle
  let sub = "Caravan Route Planning"
  let sw = @draw.measure_text(sub, 28)
  @draw.draw_text(
    sub,
    @types.screen_width / 2 - sw / 2,
    250,
    28,
    @types.color_sand_light,
  )
  // Decorative hex icons
  let icon_y : Float = 340.0
  let icon_cx : Float = fi(@types.screen_width / 2)
  draw_hex(icon_cx - 120.0, icon_y, 25.0, @types.color_oasis)
  draw_hex(icon_cx - 40.0, icon_y, 25.0, @types.color_trade)
  draw_hex(icon_cx + 40.0, icon_y, 25.0, @types.color_ruins)
  draw_hex(icon_cx + 120.0, icon_y, 25.0, @types.color_destination)
  // Description
  let d1 = "Plan routes across the desert"
  let d1w = @draw.measure_text(d1, 20)
  @draw.draw_text(
    d1,
    @types.screen_width / 2 - d1w / 2,
    410,
    20,
    @types.color_hud_text,
  )
  let d2 = "Manage water, collect gold, discover artifacts"
  let d2w = @draw.measure_text(d2, 20)
  @draw.draw_text(
    d2,
    @types.screen_width / 2 - d2w / 2,
    440,
    20,
    @types.color_hud_text,
  )
  // Start prompt
  let prompt = "Press ENTER to begin"
  let pw = @draw.measure_text(prompt, 28)
  @draw.draw_text(
    prompt,
    @types.screen_width / 2 - pw / 2,
    520,
    28,
    @types.color_sand_light,
  )
  // Credits
  let cr = "25 Levels across 3 Tiers"
  let cw = @draw.measure_text(cr, 18)
  @draw.draw_text(
    cr,
    @types.screen_width / 2 - cw / 2,
    580,
    18,
    @types.color_hud_text,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    60,
    40,
    @types.color_title_text,
  )
  let tiers : Array[(@types.Tier, String, String, Int, Int)] = [
    (OasisTrail, "Oasis Trail", "Levels 1-8: Gentle Introduction", 0, 8),
    (DuneSea, "Dune Sea", "Levels 9-17: Complex Routing", 8, 17),
    (LostCity, "Lost City", "Levels 18-25: Advanced Puzzles", 17, 25),
  ]
  for i in 0..<tiers.length() {
    let (tier, name, desc, start, end) = tiers[i]
    let bx = @types.screen_width / 2 - 200
    let by = 160 + i * 160
    let bw = 400
    let bh = 130
    // Count completed levels
    let mut completed = 0
    let mut total_stars = 0
    for j in start..<end {
      if game.scores[j].completed {
        completed += 1
      }
      total_stars += game.scores[j].stars
    }
    let is_selected = game.current_tier == tier
    let bg = if is_selected {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_hex_outline)
    @draw.draw_text(name, bx + 20, by + 15, 28, @types.color_title_text)
    @draw.draw_text(desc, bx + 20, by + 50, 16, @types.color_hud_text)
    @draw.draw_text(
      "\{completed}/\{end - start} completed",
      bx + 20,
      by + 75,
      16,
      @types.color_hud_text,
    )
    // Draw stars
    draw_stars_inline(bx + 20, by + 100, total_stars, (end - start) * 3)
  }
  @draw.draw_text(
    "Click tier or press 1/2/3  |  Esc: Back",
    @types.screen_width / 2 - 180,
    @types.screen_height - 40,
    18,
    @types.color_hud_text,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier_str = @types.tier_name(game.current_tier)
  let title = "Select Level - \{tier_str}"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    40,
    36,
    @types.color_title_text,
  )
  let levels = @levels.create_all_levels()
  let (start, end) = @types.tier_level_range(game.current_tier)
  let count = end - start
  let cols = if count <= 4 { count } else { 4 }
  let rows = (count + cols - 1) / cols
  let btn_w = 240
  let btn_h = 100
  let gap = 20
  let total_w = cols * btn_w + (cols - 1) * gap
  let total_h = rows * btn_h + (rows - 1) * gap
  let base_x = @types.screen_width / 2 - total_w / 2
  let base_y = @types.screen_height / 2 - total_h / 2
  for i in 0..<count {
    let level_idx = start + i
    let level = levels[level_idx]
    let score = game.scores[level_idx]
    let col = i % cols
    let row = i / cols
    let bx = base_x + col * (btn_w + gap)
    let by = base_y + row * (btn_h + gap)
    let is_current = game.current_level == level_idx
    let bg = if is_current {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg)
    @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, @types.color_hex_outline)
    @draw.draw_text(
      "\{level_idx + 1}. \{level.name}",
      bx + 10,
      by + 10,
      18,
      @types.color_title_text,
    )
    @draw.draw_text(
      "Water: \{level.starting_water}  Gold: \{level.gold_target}",
      bx + 10,
      by + 35,
      14,
      @types.color_hud_text,
    )
    if score.completed {
      @draw.draw_text("Completed", bx + 10, by + 55, 14, @types.color_success)
    }
    draw_stars_inline(bx + 10, by + 75, score.stars, 3)
  }
  @draw.draw_text(
    "Click level or press number  |  Esc: Back",
    @types.screen_width / 2 - 190,
    @types.screen_height - 40,
    18,
    @types.color_hud_text,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(lv) => lv
    None => return
  }
  let score = game.scores[game.current_level]
  // Title
  let title = if game.play_state == Failed {
    "Caravan Lost!"
  } else {
    "Route Complete!"
  }
  let tw = @draw.measure_text(title, 48)
  let title_color = if game.play_state == Failed {
    @types.color_warning
  } else {
    @types.color_gold_text
  }
  @draw.draw_text(title, @types.screen_width / 2 - tw / 2, 100, 48, title_color)
  // Level name
  let name_w = @draw.measure_text(level.name, 28)
  @draw.draw_text(
    level.name,
    @types.screen_width / 2 - name_w / 2,
    170,
    28,
    @types.color_hud_text,
  )
  // Stats
  let cx = @types.screen_width / 2 - 150
  let sy = 240
  @draw.draw_text(
    "Gold collected: \{game.result_gold}",
    cx,
    sy,
    22,
    @types.color_gold_text,
  )
  if level.gold_target > 0 {
    @draw.draw_text(
      "Gold target: \{level.gold_target}",
      cx,
      sy + 30,
      22,
      @types.color_hud_text,
    )
  }
  @draw.draw_text(
    "Artifacts: \{game.result_artifacts}",
    cx,
    sy + 60,
    22,
    @types.color_artifact_text,
  )
  if level.total_artifacts > 0 {
    @draw.draw_text(
      "Total available: \{level.total_artifacts}",
      cx,
      sy + 90,
      22,
      @types.color_hud_text,
    )
  }
  @draw.draw_text(
    "Route length: \{game.route.length()} steps",
    cx,
    sy + 120,
    22,
    @types.color_hud_text,
  )
  // Stars
  if game.play_state != Failed {
    let stars_text = match score.stars {
      1 => "Destination Reached"
      2 => "Gold Target Met"
      3 => "Perfect Expedition!"
      _ => ""
    }
    let st_w = @draw.measure_text(stars_text, 26)
    @draw.draw_text(
      stars_text,
      @types.screen_width / 2 - st_w / 2,
      sy + 170,
      26,
      @types.color_gold_text,
    )
    // Draw big stars
    for i in 0..<3 {
      let star_x = @types.screen_width / 2 - 75 + i * 60
      let star_y = sy + 210
      let color = if i < score.stars {
        @types.color_star_filled
      } else {
        @types.color_star_empty
      }
      @raylib.draw_poly(
        @raylib.Vector2::new(fi(star_x), fi(star_y)),
        5,
        20.0,
        0.0,
        color,
      )
    }
  }
  // Prompt
  @draw.draw_text(
    "Press Enter to continue  |  R to retry",
    @types.screen_width / 2 - 180,
    @types.screen_height - 80,
    20,
    @types.color_hud_text,
  )
}

///|
fn draw_stars_inline(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  let display_total = if total > 9 { 9 } else { total }
  for i in 0..<display_total {
    let sx = x + i * 18
    let color = if i < filled {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    @raylib.draw_poly(@raylib.Vector2::new(fi(sx), fi(y)), 5, 6.0, 0.0, color)
  }
}
