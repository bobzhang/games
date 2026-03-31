///|
fn draw_title(game : @types.Game) -> Unit {
  let _ = game
  // Dark background
  @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, @types.color_title_bg)
  // Decorative border
  @raylib.draw_rectangle_lines(
    20, 20, @types.screen_width - 40, @types.screen_height - 40, @types.color_desert,
  )
  @raylib.draw_rectangle_lines(
    24, 24, @types.screen_width - 48, @types.screen_height - 48, @types.color_desert,
  )
  // Title
  let title = "CARTOGRAPHER"
  let tw = @draw.measure_text(title, 60)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    180,
    60,
    @types.color_desert,
  )
  // Subtitle
  let sub = "A Map Drawing Deduction Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    @types.screen_width / 2 - sw / 2,
    260,
    24,
    @types.color_parchment,
  )
  // Decorative map elements
  draw_feature(
    @types.screen_width / 2 - 120, 380, Mountain, 40,
  )
  draw_feature(
    @types.screen_width / 2 - 40, 380, Forest, 40,
  )
  draw_feature(
    @types.screen_width / 2 + 40, 380, Town, 40,
  )
  draw_feature(
    @types.screen_width / 2 + 120, 380, Lake, 40,
  )
  // Start prompt
  let prompt = "Press ENTER to begin"
  let pw = @draw.measure_text(prompt, 28)
  @draw.draw_text(
    prompt,
    @types.screen_width / 2 - pw / 2,
    500,
    28,
    @types.color_parchment,
  )
  // Credits
  @draw.draw_text(
    "25 Levels across 3 Tiers",
    @types.screen_width / 2 - 120,
    560,
    18,
    @types.color_text_light,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, @types.color_title_bg)
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    60,
    40,
    @types.color_desert,
  )
  let tiers : Array[(@types.Tier, String, String, Int, Int)] = [
    (Surveyor, "Surveyor", "Levels 1-8: Distance & Direction", 0, 8),
    (Explorer, "Explorer", "Levels 9-17: All Clue Types", 8, 17),
    (Master, "Master", "Levels 18-25: Tight Constraints", 17, 25),
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
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_desert)
    @draw.draw_text(name, bx + 20, by + 15, 28, @types.color_white)
    @draw.draw_text(desc, bx + 20, by + 50, 16, @types.color_parchment)
    @draw.draw_text(
      "\{completed}/\{end - start} completed",
      bx + 20,
      by + 75,
      16,
      @types.color_parchment,
    )
    // Draw stars
    draw_stars_inline(bx + 20, by + 100, total_stars, (end - start) * 3)
  }
  @draw.draw_text(
    "Click tier or press 1/2/3  |  Esc: Back",
    @types.screen_width / 2 - 180,
    @types.screen_height - 40,
    18,
    @types.color_text_light,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, @types.color_title_bg)
  let tier_str = @types.tier_name(game.current_tier)
  let title = "Select Level - \{tier_str}"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    40,
    36,
    @types.color_desert,
  )
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
    let level = game.levels[level_idx]
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
    @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, @types.color_desert)
    @draw.draw_text(
      "\{level_idx + 1}. \{level.name}",
      bx + 10,
      by + 10,
      18,
      @types.color_white,
    )
    @draw.draw_text(
      "\{level.features_to_place.length()} features, \{level.clues.length()} clues",
      bx + 10,
      by + 35,
      14,
      @types.color_parchment,
    )
    if score.completed {
      @draw.draw_text("Completed", bx + 10, by + 55, 14, @types.color_clue_satisfied)
    }
    draw_stars_inline(bx + 10, by + 75, score.stars, 3)
  }
  @draw.draw_text(
    "Click level or press number  |  Esc: Back",
    @types.screen_width / 2 - 190,
    @types.screen_height - 40,
    18,
    @types.color_text_light,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, @types.color_title_bg)
  let level = game.levels[game.current_level]
  let score = game.scores[game.current_level]
  let title = "Level Complete!"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    100,
    48,
    @types.color_star_gold,
  )
  let name_w = @draw.measure_text(level.name, 28)
  @draw.draw_text(
    level.name,
    @types.screen_width / 2 - name_w / 2,
    170,
    28,
    @types.color_parchment,
  )
  // Stats
  let cx = @types.screen_width / 2 - 150
  let sy = 240
  @draw.draw_text(
    "Total Placements: \{game.total_placements}",
    cx,
    sy,
    22,
    @types.color_parchment,
  )
  @draw.draw_text(
    "Par: \{level.par_placements}",
    cx,
    sy + 35,
    22,
    @types.color_text_light,
  )
  @draw.draw_text(
    "Incorrect Placements: \{game.incorrect_count}",
    cx,
    sy + 70,
    22,
    if game.incorrect_count == 0 {
      @types.color_clue_satisfied
    } else {
      @types.color_clue_violated
    },
  )
  // Stars
  let stars_text = match score.stars {
    1 => "Completed"
    2 => "Within Par"
    3 => "Perfect Deduction!"
    _ => "Completed"
  }
  let st_w = @draw.measure_text(stars_text, 26)
  @draw.draw_text(
    stars_text,
    @types.screen_width / 2 - st_w / 2,
    sy + 120,
    26,
    @types.color_star_gold,
  )
  // Draw big stars
  for i in 0..<3 {
    let sx = @types.screen_width / 2 - 75 + i * 60
    let star_y = sy + 160
    let color = if i < score.stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star(sx, star_y, 20, color)
  }
  // Prompt
  @draw.draw_text(
    "Press Enter to continue  |  R to retry",
    @types.screen_width / 2 - 180,
    @types.screen_height - 80,
    20,
    @types.color_parchment,
  )
}

///|
fn draw_stars_inline(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  let display_total = if total > 9 { 9 } else { total }
  for i in 0..<display_total {
    let sx = x + i * 18
    let color = if i < filled {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star(sx, y, 6, color)
  }
}

///|
fn draw_star(cx : Int, cy : Int, size : Int, color : @raylib.Color) -> Unit {
  // Simple 5-point star using triangles
  @raylib.draw_poly(
    @raylib.Vector2::new(fi(cx), fi(cy)),
    5,
    fi(size),
    0.0,
    color,
  )
}
