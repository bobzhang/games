///|
fn draw_title(game : @types.Game) -> Unit {
  // Seismograph wave animation
  let t = game.anim_timer
  let wave_y = 300
  let wave_color = @types.color_title_accent
  for x in 0..<@types.screen_width {
    let xf = Float::from_int(x)
    let amp : Float = 30.0 + @types.sinf(t * 0.5) * 15.0
    let freq : Float = 0.02 + @types.sinf(t * 0.3) * 0.005
    let y1 : Float = Float::from_int(wave_y) +
      @types.sinf(xf * freq + t * 2.0) * amp
    let y2 : Float = Float::from_int(wave_y) +
      @types.sinf(xf * freq + t * 2.0 + 0.1) * amp
    let alpha = @types.clampf(
      1.0 - @types.absf(xf - 640.0) / 640.0,
      0.1,
      1.0,
    )
    let a = (alpha * 255.0).to_int()
    @raylib.draw_line_ex(
      @raylib.Vector2::new(xf, y1),
      @raylib.Vector2::new(xf + 1.0, y2),
      2.0,
      @raylib.Color::new(
        wave_color.r.to_int(),
        wave_color.g.to_int(),
        wave_color.b.to_int(),
        a,
      ),
    )
  }
  // Title text
  let title = "TREMOR"
  let title_w = @draw.measure_text(title, 72)
  @draw.draw_text(
    title,
    640 - title_w / 2,
    160,
    72,
    @types.color_title_accent,
  )
  // Subtitle
  let sub = "Seismograph Triangulation Puzzle"
  let sub_w = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, 640 - sub_w / 2, 240, 24, @types.color_hud_text)
  // Prompt
  let prompt_alpha = (@types.sinf(t * 3.0) * 0.5 + 0.5) * 255.0
  let prompt = "Press ENTER to begin"
  let prompt_w = @draw.measure_text(prompt, 28)
  @draw.draw_text(
    prompt,
    640 - prompt_w / 2,
    450,
    28,
    @raylib.Color::new(255, 255, 255, prompt_alpha.to_int()),
  )
  // Version / credits
  @draw.draw_text(
    "Place sensors. Find the epicenter.",
    440,
    550,
    20,
    @types.color_grid_line,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  @draw.draw_text("SELECT TIER", 490, 60, 36, @types.color_hud_text)
  let tiers : Array[@types.Tier] = [Detection, Precision, Crisis]
  let tier_descs : Array[String] = [
    "Single quake, broad sensors, generous budget",
    "All sensors, tighter budgets, blocked zones",
    "Dual quakes, noisy zones, all sensor types",
  ]
  for i in 0..<tiers.length() {
    let tier = tiers[i]
    let bx = 340
    let by = 150 + i * 160
    let bw = 600
    let bh = 130
    let unlocked = @types.tier_unlocked(game, tier)
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh &&
      unlocked
    let bg = if hover {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_grid_line)
    let name = @types.tier_name(tier)
    let name_color = if unlocked {
      @types.color_hud_text
    } else {
      @types.color_grid_line
    }
    @draw.draw_text(
      "Tier " + (i + 1).to_string() + ": " + name,
      bx + 20,
      by + 15,
      28,
      name_color,
    )
    @draw.draw_text(tier_descs[i], bx + 20, by + 55, 18, @types.color_grid_line)
    // Level count info
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
    @draw.draw_text(
      completed.to_string() + "/" + count.to_string() + " complete  Stars: " +
      total_stars.to_string() +
      "/" +
      (count * 3).to_string(),
      bx + 20,
      by + 85,
      18,
      @types.color_star_filled,
    )
    if !unlocked {
      @draw.draw_text("LOCKED", bx + 480, by + 50, 24, @types.color_epicenter)
    }
  }
  @draw.draw_text(
    "Esc: back to title",
    40,
    670,
    18,
    @types.color_grid_line,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.current_tier
  let name = @types.tier_name(tier)
  @draw.draw_text(
    "Tier: " + name + " - Select Level",
    400,
    30,
    30,
    @types.color_hud_text,
  )
  let start = @types.tier_start_index(tier)
  let count = @types.tier_level_count(tier)
  let cols = 5
  let bw = 200
  let bh = 100
  let margin = 20
  let start_x = (1280 - (cols * bw + (cols - 1) * margin)) / 2
  let start_y = 100
  for i in 0..<count {
    let idx = start + i
    let col = i % cols
    let row = i / cols
    let bx = start_x + col * (bw + margin)
    let by = start_y + row * (bh + margin)
    let unlocked = @types.level_unlocked(game, idx)
    let score = game.level_scores[idx]
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh &&
      unlocked
    let bg = if hover {
      @types.color_button_hover
    } else if unlocked {
      @types.color_button
    } else {
      @raylib.Color::new(30, 30, 40, 200)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_grid_line)
    // Level number
    let label = (i + 1).to_string()
    let label_color = if unlocked {
      @types.color_hud_text
    } else {
      @types.color_grid_line
    }
    @draw.draw_text(label, bx + 15, by + 10, 28, label_color)
    if unlocked {
      // Stars
      draw_stars(bx + 15, by + 50, score.stars, 3)
      if score.completed {
        @draw.draw_text(
          "DONE",
          bx + 120,
          by + 15,
          18,
          @raylib.Color::new(50, 255, 50, 255),
        )
      }
    } else {
      @draw.draw_text("LOCKED", bx + 60, by + 35, 20, @types.color_epicenter)
    }
  }
  @draw.draw_text(
    "Esc: back to tiers",
    40,
    670,
    18,
    @types.color_grid_line,
  )
}

///|
fn draw_stars(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * 28
    let color = if i < filled {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    // Draw star as circle + lines
    @raylib.draw_circle(sx + 10, y + 10, 8.0, color)
    // Small rays
    let center = @raylib.Vector2::new(
      Float::from_int(sx + 10),
      Float::from_int(y + 10),
    )
    for r in 0..<5 {
      let angle = Float::from_int(r) * @types.two_pi / 5.0 - @types.pi / 2.0
      let tip_x = Float::from_int(sx + 10) + @types.cosf(angle) * 12.0
      let tip_y = Float::from_int(y + 10) + @types.sinf(angle) * 12.0
      @raylib.draw_line_ex(
        center,
        @raylib.Vector2::new(tip_x, tip_y),
        2.0,
        color,
      )
    }
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  match game.level {
    None => ()
    Some(level) => {
      let score = game.level_scores[level.level_index]
      // Dark overlay
      @raylib.draw_rectangle(0, 0, 1280, 720, @raylib.Color::new(
          0, 0, 0, 180,
        ))
      // Results panel
      let px = 340
      let py = 120
      let pw = 600
      let ph = 480
      @raylib.draw_rectangle(px, py, pw, ph, @types.color_hud_bg)
      @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_grid_line)
      let all_found = @sensors.all_epicenters_found(level.epicenters)
      if all_found {
        @draw.draw_text(
          "LEVEL COMPLETE!",
          px + 160,
          py + 20,
          32,
          @raylib.Color::new(50, 255, 50, 255),
        )
      } else {
        @draw.draw_text(
          "LEVEL FAILED",
          px + 180,
          py + 20,
          32,
          @types.color_epicenter,
        )
      }
      @draw.draw_text(level.name, px + 30, py + 70, 24, @types.color_hud_text)
      // Stats
      @draw.draw_text(
        "Budget used: " +
        game.budget_used.to_string() +
        " / " +
        level.sensor_budget.to_string(),
        px + 30,
        py + 120,
        22,
        @types.color_hud_text,
      )
      @draw.draw_text(
        "Par budget: " + level.par_budget.to_string(),
        px + 350,
        py + 120,
        20,
        @types.color_grid_line,
      )
      @draw.draw_text(
        "Guesses: " + game.guess_count.to_string(),
        px + 30,
        py + 155,
        22,
        @types.color_hud_text,
      )
      @draw.draw_text(
        "Par guesses: " + level.par_guesses.to_string(),
        px + 350,
        py + 155,
        20,
        @types.color_grid_line,
      )
      @draw.draw_text(
        "Sensors placed: " + game.sensor_place_count.to_string(),
        px + 30,
        py + 190,
        22,
        @types.color_hud_text,
      )
      // Stars
      if all_found {
        @draw.draw_text("Stars earned:", px + 30, py + 240, 24, @types.color_star_filled)
        draw_stars(px + 230, py + 240, score.stars, 3)
        // Star explanations
        @draw.draw_text(
          "Star 1: Located all epicenters",
          px + 30,
          py + 280,
          18,
          if score.stars >= 1 {
            @types.color_star_filled
          } else {
            @types.color_grid_line
          },
        )
        @draw.draw_text(
          "Star 2: Within par budget (" + level.par_budget.to_string() + ")",
          px + 30,
          py + 305,
          18,
          if score.stars >= 2 {
            @types.color_star_filled
          } else {
            @types.color_grid_line
          },
        )
        @draw.draw_text(
          "Star 3: Par budget + par guesses (" +
          level.par_guesses.to_string() +
          ")",
          px + 30,
          py + 330,
          18,
          if score.stars >= 3 {
            @types.color_star_filled
          } else {
            @types.color_grid_line
          },
        )
      }
      // Actions
      @draw.draw_text(
        "R: Retry    Enter: Next Level    Esc: Level Select",
        px + 40,
        py + 400,
        20,
        @types.color_hud_text,
      )
    }
  }
}
