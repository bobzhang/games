///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time : Float = Float::from_int(game.frame_count) * 0.03
  // Background hex pattern
  for row in 0..<6 {
    for col in 0..<10 {
      let offset : Float = if row % 2 == 1 { 70.0 } else { 0.0 }
      let hx : Float = 80.0 + Float::from_int(col) * 140.0 + offset
      let hy : Float = 60.0 + Float::from_int(row) * 120.0
      let sv : Float = @types.sinf(time + Float::from_int(row * col))
      let av : Float = 30.0 + sv * 20.0
      let alpha = av.to_int()
      draw_hex_outline(
        hx, hy, 40.0, @raylib.Color::new(60, 80, 120, alpha),
      )
    }
  }
  // Title
  let title = "STRATAGEM"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title, (w - title_w) / 2, h / 5, 72, @raylib.Color::new(220, 200, 140, alpha),
  )
  // Subtitle
  let sub = "A HEX WARGAME"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub, (w - sub_w) / 2, h / 5 + 80, 20, @types.color_hud_text,
  )
  // Menu items
  let items = ["[C] Campaign", "[S] Skirmish", "[Q] Quit"]
  for i in 0..<items.length() {
    let item = items[i]
    let iw = @draw.measure_text(item, 28)
    let iy = h / 2 + 40 + i * 55
    @draw.draw_text(
      item, (w - iw) / 2, iy, 28, @raylib.Color::new(180, 190, 210, 255),
    )
  }
  // Version
  @draw.draw_text("v1.0", 10, h - 30, 16, @raylib.Color::new(100, 100, 120, 200))
}

///|
fn draw_campaign(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let camp = game.campaign
  // Title
  let title = "CAMPAIGN"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(title, (w - tw) / 2, 30, 48, @types.color_gold)
  // Score
  let score_text = "Total Score: " + camp.total_score.to_string()
  let stw = @draw.measure_text(score_text, 20)
  @draw.draw_text(
    score_text, (w - stw) / 2, 85, 20, @types.color_hud_text,
  )
  // Level grid (3 columns x 4 rows)
  let cols = 3
  let box_w = 350
  let box_h = 100
  let gap = 20
  let start_x = (w - (cols * box_w + (cols - 1) * gap)) / 2
  let start_y = 130
  for i in 0..<@types.total_campaign_levels {
    let col = i % cols
    let row = i / cols
    let bx = start_x + col * (box_w + gap)
    let by = start_y + row * (box_h + gap)
    let unlocked = i < camp.levels_unlocked
    let bg = if unlocked {
      @raylib.Color::new(40, 45, 60, 220)
    } else {
      @raylib.Color::new(25, 25, 35, 220)
    }
    @raylib.draw_rectangle(bx, by, box_w, box_h, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      box_w,
      box_h,
      if unlocked {
        @raylib.Color::new(100, 120, 160, 200)
      } else {
        @raylib.Color::new(50, 50, 60, 200)
      },
    )
    let num = (i + 1).to_string()
    let level_def = @levels.get_campaign_level(i)
    let label = if unlocked { num + ". " + level_def.name } else { "LOCKED" }
    let text_color = if unlocked {
      @raylib.Color::new(200, 210, 230, 255)
    } else {
      @raylib.Color::new(80, 80, 90, 200)
    }
    @draw.draw_text(label, bx + 10, by + 10, 22, text_color)
    if unlocked {
      // Show description
      @draw.draw_text(
        level_def.description,
        bx + 10,
        by + 38,
        13,
        @raylib.Color::new(140, 145, 160, 180),
      )
      // Victory condition indicator
      let vc_text = match level_def.victory {
        EliminateAll => "Eliminate All"
        CaptureFlag(_, _) => "Capture Flag"
      }
      @draw.draw_text(
        vc_text,
        bx + 10,
        by + 56,
        12,
        @raylib.Color::new(180, 150, 80, 180),
      )
    }
    if camp.level_scores[i] > 0 {
      let sc = "Score: " + camp.level_scores[i].to_string()
      @draw.draw_text(
        sc, bx + 10, by + 78, 16, @raylib.Color::new(200, 180, 80, 200),
      )
    }
  }
  // Navigation
  let nav = "[1-9,0,-,=] Select Level  [ESC] Back"
  let nw = @draw.measure_text(nav, 18)
  @draw.draw_text(nav, (w - nw) / 2, h - 40, 18, @types.color_hud_text)
}

///|
fn draw_skirmish(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let setup = game.skirmish
  // Title
  let title = "SKIRMISH"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(title, (w - tw) / 2, 40, 48, @types.color_gold)
  // Options
  let cy = h / 3
  // Map selection
  let map_name = @levels.skirmish_map_name(setup.map_index)
  @draw.draw_text("Map:", w / 4, cy, 24, @types.color_hud_text)
  @draw.draw_text(
    "< " + map_name + " >", w / 4 + 120, cy, 24, @types.color_gold,
  )
  // Army size
  @draw.draw_text("Army Size:", w / 4, cy + 60, 24, @types.color_hud_text)
  @draw.draw_text(
    "< " + setup.army_size.to_string() + " >",
    w / 4 + 220,
    cy + 60,
    24,
    @types.color_gold,
  )
  // Difficulty
  let diff_name = match setup.difficulty {
    Easy => "Easy"
    Normal => "Normal"
    Hard => "Hard"
  }
  @draw.draw_text("Difficulty:", w / 4, cy + 120, 24, @types.color_hud_text)
  @draw.draw_text(
    "< " + diff_name + " >", w / 4 + 220, cy + 120, 24, @types.color_gold,
  )
  // Controls
  let controls = [
    "[LEFT/RIGHT] Change Selection",
    "[UP/DOWN] Switch Option",
    "[ENTER] Start Battle",
    "[ESC] Back",
  ]
  for i in 0..<controls.length() {
    @draw.draw_text(
      controls[i],
      w / 4,
      cy + 220 + i * 30,
      18,
      @raylib.Color::new(150, 160, 180, 200),
    )
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time : Float = Float::from_int(game.frame_count) * 0.02
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(10, 10, 20, 240))
  // Animated background particles for victory
  if game.last_was_victory {
    for i in 0..<20 {
      let fi : Float = Float::from_int(i)
      let px = @types.sinf(time * 0.7 + fi * 1.3) * 400.0 + Float::from_int(
          w / 2,
        )
      let py = @types.cosf(time * 0.5 + fi * 0.9) * 250.0 + Float::from_int(
          h / 2,
        )
      let alpha_f : Float = @types.sinf(time + fi) * 40.0 + 50.0
      let alpha = @types.mini(@types.maxi(alpha_f.to_int(), 10), 90)
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        3.0,
        @raylib.Color::new(255, 215, 0, alpha),
      )
    }
  }
  let title = if game.last_was_victory { "VICTORY!" } else { "DEFEAT" }
  let title_color = if game.last_was_victory {
    // Pulsing gold for victory
    let pulse : Float = @types.sinf(time * 3.0) * 30.0 + 225.0
    @raylib.Color::new(
      @types.mini(pulse.to_int(), 255),
      @types.mini((pulse * 0.84).to_int(), 255),
      0,
      255,
    )
  } else {
    // Pulsing red for defeat
    let pulse : Float = @types.sinf(time * 2.0) * 30.0 + 200.0
    @raylib.Color::new(@types.mini(pulse.to_int(), 255), 40, 40, 255)
  }
  let tw = @draw.measure_text(title, 64)
  // Title shadow
  @draw.draw_text(
    title,
    (w - tw) / 2 + 2,
    h / 4 + 2,
    64,
    @raylib.Color::new(0, 0, 0, 180),
  )
  @draw.draw_text(title, (w - tw) / 2, h / 4, 64, title_color)
  // Decorative line under title
  let line_w = 300
  let line_x = (w - line_w) / 2
  let line_y = h / 4 + 75
  @raylib.draw_rectangle(
    line_x,
    line_y,
    line_w,
    2,
    @raylib.Color::new(120, 120, 140, 150),
  )
  // Stats with staggered reveal
  let cy = h / 2 - 30
  let stats = [
    ("Turns", game.last_turns.to_string()),
    ("Units Remaining", game.last_units_remaining.to_string()),
    ("Score", game.last_score.to_string()),
  ]
  for i in 0..<stats.length() {
    let (label, value) = stats[i]
    let text = label + ": " + value
    let sw = @draw.measure_text(text, 24)
    // Label
    @draw.draw_text(
      label + ":",
      (w - sw) / 2,
      cy + i * 45,
      24,
      @raylib.Color::new(160, 170, 190, 200),
    )
    // Value highlighted
    let label_w = @draw.measure_text(label + ": ", 24)
    let value_color = if i == 2 {
      @types.color_gold
    } else {
      @types.color_hud_text
    }
    @draw.draw_text(
      value,
      (w - sw) / 2 + label_w,
      cy + i * 45,
      24,
      value_color,
    )
  }
  // Navigation
  let nav = "[ENTER] Continue  [ESC] Main Menu"
  let nw = @draw.measure_text(nav, 20)
  let nav_alpha_f : Float = @types.sinf(time * 2.0) * 40.0 + 180.0
  let nav_alpha = @types.mini(nav_alpha_f.to_int(), 220)
  @draw.draw_text(
    nav,
    (w - nw) / 2,
    h - 80,
    20,
    @raylib.Color::new(160, 170, 190, nav_alpha),
  )
}
