///|
fn draw_title(_game : @types.Game) -> Unit {
  let title = "E R O D E"
  let tw = @draw.measure_text(title, 64)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    180,
    64,
    @types.color_text_highlight,
  )
  let sub = "Erosion Sculpting Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    260,
    24,
    @types.color_text,
  )
  let prompt = "Press ENTER to start"
  let pw = @draw.measure_text(prompt, 22)
  @draw.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    400,
    22,
    @types.color_text_dim,
  )
  // Draw a small decorative grid
  let demo_x = (@types.screen_width - 4 * 32) / 2
  let demo_y = 310
  for r in 0..<4 {
    for c in 0..<4 {
      let x = demo_x + c * 32
      let y = demo_y + r * 32
      let solid = r + c > 1 && r + c < 5
      if solid {
        @raylib.draw_rectangle(x, y, 30, 30, @types.color_solid)
      } else {
        @raylib.draw_rectangle(x, y, 30, 30, @types.color_empty)
      }
    }
  }
  // Instructions at bottom
  let inst = "Sculpt blocks to match targets using erosion forces"
  let iw = @draw.measure_text(inst, 18)
  @draw.draw_text(
    inst,
    (@types.screen_width - iw) / 2,
    500,
    18,
    @types.color_text_dim,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let title = "SELECT TIER"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    60,
    40,
    @types.color_text,
  )
  let tiers : Array[@types.Tier] = [Clay, Stone, Crystal]
  let tier_descs : Array[String] = [
    "Water + Wind (7 levels)", "+ Frost (7 levels)", "All Forces (6 levels)",
  ]
  for i, tier in tiers {
    let bx = 200
    let by = 160 + i * 160
    let bw = 880
    let bh = 130
    // Check if tier is unlocked (previous tier has at least 1 star on all levels)
    let unlocked = is_tier_unlocked(game, tier)
    let bg = if unlocked {
      @types.color_button
    } else {
      @raylib.Color::new(30, 30, 35, 255)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    let border = @types.tier_color(tier)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, border)
    let name = @types.tier_name(tier)
    let name_color = if unlocked {
      @types.tier_color(tier)
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(name, bx + 30, by + 15, 36, name_color)
    let desc_color = if unlocked {
      @types.color_text
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(tier_descs[i], bx + 30, by + 60, 20, desc_color)
    // Star count for this tier
    let (start, end) = @types.tier_level_range(tier)
    let mut total_stars = 0
    let mut max_stars = 0
    for j = start; j <= end; j = j + 1 {
      total_stars += game.level_scores[j].stars
      max_stars += 3
    }
    let star_text = "Stars: \{total_stars}/\{max_stars}"
    @draw.draw_text(star_text, bx + 30, by + 88, 18, desc_color)
    if !unlocked {
      @draw.draw_text(
        "LOCKED",
        bx + bw - 120,
        by + 50,
        22,
        @types.color_text_dim,
      )
    }
    // Key hint
    @draw.draw_text(
      "\{i + 1}",
      bx + bw - 40,
      by + 10,
      20,
      @types.color_text_dim,
    )
  }
  @draw.draw_text(
    "[ESC] Back",
    20,
    @types.screen_height - 30,
    16,
    @types.color_text_dim,
  )
}

///|
fn is_tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Clay => true
    Stone => {
      // Need at least 1 star on all Clay levels
      let (start, end) = @types.tier_level_range(Clay)
      for i = start; i <= end; i = i + 1 {
        if game.level_scores[i].stars == 0 {
          return false
        }
      }
      true
    }
    Crystal => {
      // Need at least 1 star on all Stone levels
      let (start, end) = @types.tier_level_range(Stone)
      for i = start; i <= end; i = i + 1 {
        if game.level_scores[i].stars == 0 {
          return false
        }
      }
      true
    }
  }
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.current_tier
  let tier_text = @types.tier_name(tier)
  let title = "\{tier_text} - SELECT LEVEL"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    40,
    36,
    @types.tier_color(tier),
  )
  let (start, end) = @types.tier_level_range(tier)
  let levels = @levels.get_all_levels()
  let cols = 4
  let card_w = 260
  let card_h = 120
  let gap_x = 30
  let gap_y = 20
  let total_w = cols * card_w + (cols - 1) * gap_x
  let base_x = (@types.screen_width - total_w) / 2
  let base_y = 100
  for idx = start; idx <= end; idx = idx + 1 {
    let i = idx - start
    let col = i % cols
    let row = i / cols
    let x = base_x + col * (card_w + gap_x)
    let y = base_y + row * (card_h + gap_y)
    let level = levels[idx]
    let score = game.level_scores[idx]
    @raylib.draw_rectangle(x, y, card_w, card_h, @types.color_button)
    @raylib.draw_rectangle_lines(x, y, card_w, card_h, @types.tier_color(tier))
    // Level number and name
    let num_text = "\{idx + 1}. \{level.name}"
    @draw.draw_text(num_text, x + 10, y + 10, 20, @types.color_text)
    // Budget summary
    let budget = level.budget
    let budget_text = "W:\{budget.water} Wn:\{budget.wind} F:\{budget.frost} H:\{budget.heat}"
    @draw.draw_text(budget_text, x + 10, y + 38, 14, @types.color_text_dim)
    // Par
    let par_text = "Par: \{level.par_forces}"
    @draw.draw_text(par_text, x + 10, y + 58, 14, @types.color_text_dim)
    // Stars
    draw_stars(x + 10, y + 80, score.stars, 3)
    if score.completed {
      @draw.draw_text(
        "DONE",
        x + card_w - 55,
        y + 85,
        16,
        @types.color_target_match,
      )
    }
  }
  @draw.draw_text(
    "[ESC] Back",
    20,
    @types.screen_height - 30,
    16,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Press level number to play",
    (@types.screen_width - @draw.measure_text("Press level number to play", 18)) /
    2,
    @types.screen_height - 50,
    18,
    @types.color_text_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let levels = @levels.get_all_levels()
  let level = levels[game.current_level]
  // Title
  let title = "RESULTS"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    80,
    48,
    @types.color_text,
  )
  // Level name
  let name = "Level \{game.current_level + 1}: \{level.name}"
  let nw = @draw.measure_text(name, 28)
  @draw.draw_text(
    name,
    (@types.screen_width - nw) / 2,
    150,
    28,
    @types.color_text_highlight,
  )
  // Match result
  let result = @erosion.compare_grids(game.grid, game.target)
  let pct = result.matching *
    100 /
    (result.matching + result.over_eroded + result.under_eroded)
  let pct_text = "Match: \{pct}%"
  let pw = @draw.measure_text(pct_text, 32)
  let pct_color = if pct == 100 {
    @types.color_target_match
  } else {
    @types.color_text
  }
  @draw.draw_text(pct_text, (@types.screen_width - pw) / 2, 220, 32, pct_color)
  // Forces used
  let forces_text = "Forces Used: \{game.forces_used} (Par: \{game.par_forces})"
  let fw = @draw.measure_text(forces_text, 24)
  @draw.draw_text(
    forces_text,
    (@types.screen_width - fw) / 2,
    270,
    24,
    @types.color_text,
  )
  // Over/under erosion
  if result.over_eroded > 0 {
    let over_text = "Over-eroded: \{result.over_eroded} cells"
    let ow = @draw.measure_text(over_text, 20)
    @draw.draw_text(
      over_text,
      (@types.screen_width - ow) / 2,
      310,
      20,
      @types.color_over_eroded,
    )
  }
  if result.under_eroded > 0 {
    let under_text = "Under-eroded: \{result.under_eroded} cells"
    let uw = @draw.measure_text(under_text, 20)
    @draw.draw_text(
      under_text,
      (@types.screen_width - uw) / 2,
      340,
      20,
      @types.color_under_eroded,
    )
  }
  // Stars
  let stars = game.level_scores[game.current_level].stars
  let star_x = (@types.screen_width - 3 * 50) / 2
  for i in 0..<3 {
    let sx = star_x + i * 50
    let color = if i < stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, 390, 48, color)
  }
  // Star descriptions
  let descs = ["Match target", "Within par forces", "No over-erosion"]
  for i in 0..<3 {
    let check = if i < stars { "[X]" } else { "[ ]" }
    let desc = "\{check} \{descs[i]}"
    let dw = @draw.measure_text(desc, 18)
    let dc = if i < stars {
      @types.color_target_match
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(desc, (@types.screen_width - dw) / 2, 460 + i * 28, 18, dc)
  }
  // Grids side by side (smaller)
  // Draw prompts
  @draw.draw_text(
    "[ENTER] Continue  [R] Retry",
    (
      @types.screen_width -
      @draw.measure_text("[ENTER] Continue  [R] Retry", 22)
    ) /
    2,
    600,
    22,
    @types.color_text_dim,
  )
}
