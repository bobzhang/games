///|
fn draw_title(game : @types.Game) -> Unit {
  // Animated background pattern - cascading dots
  let t = game.title_anim
  for row in 0..<15 {
    for col in 0..<20 {
      let fx = Float::from_int(col) * 64.0 + 32.0
      let fy = Float::from_int(row) * 48.0 + 24.0
      let offset = (Float::from_int(col) + Float::from_int(row)) * 0.3 + t *
        2.0
      let pulse_raw = offset - Float::from_int(offset.to_int())
      let pulse : Float = @types.absf(pulse_raw * 2.0 - 1.0)
      let alpha_f : Float = 20.0 + pulse * 40.0
      let alpha = alpha_f.to_int()
      let c = @raylib.Color::new(64, 96, 160, alpha)
      @raylib.draw_circle(fx.to_int(), fy.to_int(), 3.0 + pulse * 2.0, c)
    }
  }
  // Title text
  let title_y = 180
  @draw.draw_text("CASCADE", 420, title_y, 72, @types.color_ui_highlight)
  // Subtitle
  @draw.draw_text(
    "Domino Chain Reaction Puzzles",
    390,
    title_y + 85,
    24,
    @types.color_ui_text,
  )
  // Animated domino chain on title screen
  let chain_y = title_y + 160
  for i in 0..<8 {
    let cx = 340 + i * 80
    let delay = Float::from_int(i) * 0.5
    let anim_t = t - delay
    let tilt : Float = if anim_t > 0.0 {
      let raw_v = anim_t * 3.0
      let bounded = @types.clampf(raw_v, 0.0, 1.0)
      bounded * 80.0
    } else {
      0.0
    }
    let c = if i % 2 == 0 {
      @types.color_normal
    } else {
      @types.color_ui_highlight
    }
    let hw = @types.domino_width / 2.0
    let hh = @types.domino_height / 2.0
    let rec = @raylib.Rectangle::new(
      Float::from_int(cx) - hw,
      Float::from_int(chain_y) - hh,
      @types.domino_width,
      @types.domino_height,
    )
    @raylib.draw_rectangle_pro(
      rec,
      @raylib.Vector2::new(hw, hh),
      tilt,
      c,
    )
  }
  // Start prompt
  let blink_raw = t * 2.0 - Float::from_int((t * 2.0).to_int())
  let blink : Float = @types.absf(blink_raw * 2.0 - 1.0)
  let prompt_alpha_f : Float = 100.0 + blink * 155.0
  let prompt_alpha = prompt_alpha_f.to_int()
  let prompt_color = @raylib.Color::new(200, 210, 230, prompt_alpha)
  @draw.draw_text("Press ENTER to start", 455, 520, 24, prompt_color)
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  @draw.draw_text("SELECT TIER", 470, 60, 36, @types.color_ui_highlight)
  let tiers : Array[@types.Tier] = [Chains, Splits, Timing]
  let descriptions = [
    "Normal dominoes, Simple chains and turns",
    "Splitters and heavy, Parallel chains",
    "Delay dominoes, Precise timing",
  ]
  for i in 0..<3 {
    let tier = tiers[i]
    let bx = 200 + i * 320
    let by = 300
    let bw = 250
    let bh = 180
    let is_selected = game.selected_tier == tier
    let unlocked = @levels.tier_unlocked(game.scores, tier)
    // Background
    let bg_color = if is_selected {
      @raylib.Color::new(48, 64, 96, 224)
    } else {
      @types.color_ui_bg
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg_color)
    // Border
    let border_color = if unlocked {
      @types.tier_color(tier)
    } else {
      @types.color_grid_dot
    }
    @raylib.draw_rectangle_lines(bx, by, bw, bh, border_color)
    // Tier name
    let name_color = if unlocked {
      @types.tier_color(tier)
    } else {
      @types.color_grid_dot
    }
    @draw.draw_text(@types.tier_name(tier), bx + 20, by + 20, 28, name_color)
    // Description
    let desc_color = if unlocked {
      @types.color_ui_text
    } else {
      @types.color_grid_dot
    }
    @draw.draw_text(descriptions[i], bx + 20, by + 60, 14, desc_color)
    // Stars earned in this tier
    if unlocked {
      let base_idx = @types.tier_index(tier) * @types.levels_per_tier
      let mut total_stars = 0
      let mut completed = 0
      for j in 0..<@types.levels_per_tier {
        let idx = base_idx + j
        if idx < game.scores.length() {
          total_stars += game.scores[idx].stars
          if game.scores[idx].completed {
            completed += 1
          }
        }
      }
      let stat_text = completed.to_string() +
        "/8 done  " +
        total_stars.to_string() +
        " stars"
      @draw.draw_text(
        stat_text,
        bx + 20,
        by + bh - 40,
        16,
        @types.color_ui_text,
      )
    } else {
      @draw.draw_text("LOCKED", bx + 80, by + bh - 40, 20, @types.color_fail)
    }
    // Selection indicator
    if is_selected {
      @raylib.draw_rectangle_lines(
        bx - 3,
        by - 3,
        bw + 6,
        bh + 6,
        @types.color_ui_highlight,
      )
    }
  }
  // Controls
  @draw.draw_text(
    "Left/Right: Select   Enter: Choose   Esc: Back",
    350,
    @types.screen_height - 50,
    18,
    @types.color_grid_dot,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier_c = @types.tier_color(game.selected_tier)
  @draw.draw_text(
    @types.tier_name(game.selected_tier) + " - Select Level",
    400,
    60,
    32,
    tier_c,
  )
  let base_idx = @types.tier_index(game.selected_tier) * @types.levels_per_tier
  for i in 0..<@types.levels_per_tier {
    let col = i % 4
    let row = i / 4
    let bx = 240 + col * 210
    let by = 250 + row * 180
    let bw = 180
    let bh = 150
    let is_selected = i == game.selected_level
    let idx = base_idx + i
    let level = @levels.get_level(idx)
    // Background
    let bg = if is_selected {
      @raylib.Color::new(48, 64, 96, 224)
    } else {
      @types.color_ui_bg
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, tier_c)
    // Level number and name
    let num_text = (i + 1).to_string()
    @draw.draw_text(num_text, bx + 10, by + 10, 28, tier_c)
    @draw.draw_text(level.name, bx + 10, by + 45, 16, @types.color_ui_text)
    // Stars
    if idx < game.scores.length() {
      let score = game.scores[idx]
      if score.completed {
        draw_level_stars(score.stars, bx + 10, by + 75, 22)
      }
    }
    // Budget preview
    let budget = level.budget
    let mut budget_text = ""
    if budget.normal > 0 {
      budget_text += "N:" + budget.normal.to_string() + " "
    }
    if budget.heavy > 0 {
      budget_text += "H:" + budget.heavy.to_string() + " "
    }
    if budget.splitter > 0 {
      budget_text += "S:" + budget.splitter.to_string() + " "
    }
    if budget.delay > 0 {
      budget_text += "D:" + budget.delay.to_string()
    }
    @draw.draw_text(
      budget_text,
      bx + 10,
      by + bh - 30,
      14,
      @types.color_grid_dot,
    )
    // Selection indicator
    if is_selected {
      @raylib.draw_rectangle_lines(
        bx - 3,
        by - 3,
        bw + 6,
        bh + 6,
        @types.color_ui_highlight,
      )
    }
  }
  // Controls
  @draw.draw_text(
    "Arrows: Select   Enter: Play   Esc: Back",
    380,
    @types.screen_height - 50,
    18,
    @types.color_grid_dot,
  )
}

///|
fn draw_level_stars(count : Int, x : Int, y : Int, size : Int) -> Unit {
  for i in 0..<3 {
    let star_x = x + i * (size + 5)
    let c = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    let sz = Float::from_int(size) / 2.0
    @raylib.draw_circle(star_x + size / 2, y + size / 2, sz, c)
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let anim_t = @types.clampf(game.result_anim * 2.0, 0.0, 1.0)
  // Background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @types.color_bg,
  )
  // Results panel
  let panel_w = 600
  let panel_h = 400
  let px = (@types.screen_width - panel_w) / 2
  let py = (@types.screen_height - panel_h) / 2
  let slide_y = py + (Float::from_int(panel_h) * (1.0 - anim_t)).to_int()
  @raylib.draw_rectangle(px, slide_y, panel_w, panel_h, @types.color_ui_bg)
  @raylib.draw_rectangle_lines(
    px,
    slide_y,
    panel_w,
    panel_h,
    @types.color_success,
  )
  @draw.draw_text(
    "LEVEL COMPLETE",
    px + 160,
    slide_y + 20,
    32,
    @types.color_success,
  )
  match game.current_level {
    None => ()
    Some(level) => {
      @draw.draw_text(
        level.name,
        px + 20,
        slide_y + 70,
        24,
        @types.tier_color(level.tier),
      )
      let idx = level.id
      if idx < game.scores.length() {
        let score = game.scores[idx]
        // Stars
        draw_stars(score.stars, px + 210, slide_y + 110, 50)
        // Details
        @draw.draw_text(
          "Dominoes used: " + score.dominoes_used.to_string(),
          px + 50,
          slide_y + 190,
          22,
          @types.color_ui_text,
        )
        @draw.draw_text(
          "Chain ticks: " + score.ticks_taken.to_string(),
          px + 50,
          slide_y + 225,
          22,
          @types.color_ui_text,
        )
        @draw.draw_text(
          "Par: " +
            level.par_count.to_string() +
            " dominoes / " +
            level.par_ticks.to_string() +
            " ticks",
          px + 50,
          slide_y + 260,
          20,
          @types.color_grid_dot,
        )
        // Star explanations
        @draw.draw_text(
          "1 star: All targets hit",
          px + 50,
          slide_y + 300,
          16,
          if score.stars >= 1 {
            @types.color_star_gold
          } else {
            @types.color_grid_dot
          },
        )
        @draw.draw_text(
          "2 stars: Within par count",
          px + 50,
          slide_y + 322,
          16,
          if score.stars >= 2 {
            @types.color_star_gold
          } else {
            @types.color_grid_dot
          },
        )
        @draw.draw_text(
          "3 stars: Par count + fastest chain",
          px + 50,
          slide_y + 344,
          16,
          if score.stars >= 3 {
            @types.color_star_gold
          } else {
            @types.color_grid_dot
          },
        )
      }
    }
  }
  // Controls
  @draw.draw_text(
    "[Enter] Next Level   [R] Retry   [Esc] Level Select",
    330,
    @types.screen_height - 50,
    18,
    @types.color_grid_dot,
  )
}
