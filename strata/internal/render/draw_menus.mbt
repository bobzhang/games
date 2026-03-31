///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Draw layered earth background
  let layer_colors = [
    @types.color_sandstone,
    @types.color_limestone,
    @types.color_shale,
    @types.color_granite,
    @types.color_basalt,
    @types.color_coal,
    @types.color_slate,
  ]
  for i in 0..<layer_colors.length() {
    let fi = Float::from_int(i)
    let ly = h / 2 + 40 + (fi * 30.0).to_int()
    let wave = (@types.sinf(time + fi * 0.5) * 4.0).to_int()
    @raylib.draw_rectangle(0, ly + wave, w, 30, layer_colors[i])
  }
  // Title text
  let title = "STRATA"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  let alpha_clamped = if alpha > 255 {
    255
  } else if alpha < 0 {
    0
  } else {
    alpha
  }
  let title_color = @raylib.Color::new(
    @types.color_title_earth.r.to_int(),
    @types.color_title_earth.g.to_int(),
    @types.color_title_earth.b.to_int(),
    alpha_clamped,
  )
  @draw.draw_text(title, (w - title_w) / 2, h / 4 - 30, 72, title_color)
  // Subtitle
  let sub = "A Geological Layering Puzzle"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 50, 22, @types.color_text_dim)
  // Instructions
  let instr = "Press ENTER to begin"
  let instr_w = @draw.measure_text(instr, 20)
  let blink = @types.sinf(time * 3.0)
  if blink > 0.0 {
    @draw.draw_text(
      instr,
      (w - instr_w) / 2,
      h / 2 - 20,
      20,
      @types.color_accent,
    )
  }
  // Bottom text
  let bot = "Arrange rock layers to match geological clues"
  let bot_w = @draw.measure_text(bot, 16)
  @draw.draw_text(
    bot,
    (w - bot_w) / 2,
    h - 40,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let _h = @types.screen_height
  // Title
  let title = "Select Tier"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - title_w) / 2, 40, 40, @types.color_text)
  // Draw 3 tiers
  let tiers : Array[@types.Tier] = [Surface, Bedrock, DeepCore]
  for i in 0..<tiers.length() {
    let tier = tiers[i]
    let bx = 140 + i * 340
    let by = 160
    let bw = 300
    let bh = 400
    let tc = @types.tier_color(tier)
    // Background
    @raylib.draw_rectangle(bx, by, bw, bh, @types.color_bg_light)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, tc)
    // Tier name
    let tname = @types.tier_name(tier)
    let tw = @draw.measure_text(tname, 28)
    @draw.draw_text(tname, bx + (bw - tw) / 2, by + 20, 28, tc)
    // Level range info
    let range = @types.tier_level_range(tier)
    let count = range.1 - range.0 + 1
    let info = count.to_string() + " levels"
    let iw = @draw.measure_text(info, 18)
    @draw.draw_text(info, bx + (bw - iw) / 2, by + 60, 18, @types.color_text_dim)
    // Completion stats
    let mut completed = 0
    let mut total_stars = 0
    for j = range.0; j <= range.1; j = j + 1 {
      if game.scores[j].completed {
        completed += 1
      }
      total_stars += game.scores[j].stars
    }
    let comp_text = completed.to_string() + "/" + count.to_string() + " complete"
    let cw = @draw.measure_text(comp_text, 16)
    @draw.draw_text(
      comp_text,
      bx + (bw - cw) / 2,
      by + 100,
      16,
      @types.color_text_dim,
    )
    // Stars
    let star_text = total_stars.to_string() +
      "/" +
      (count * 3).to_string() +
      " stars"
    let sw = @draw.measure_text(star_text, 16)
    @draw.draw_text(
      star_text,
      bx + (bw - sw) / 2,
      by + 125,
      16,
      @types.color_star_gold,
    )
    // Difficulty description
    let desc = match tier {
      Surface => "4-5 layers\nBasic clues"
      Bedrock => "6-7 layers\nFossil & gap clues"
      DeepCore => "7-8 layers\nIntrusions & faults"
    }
    let dw = @draw.measure_text(desc, 14)
    @draw.draw_text(
      desc,
      bx + (bw - dw) / 2,
      by + 180,
      14,
      @types.color_text_dim,
    )
    // Key
    let key = (i + 1).to_string()
    let kw = @draw.measure_text(key, 36)
    @draw.draw_text(key, bx + (bw - kw) / 2, by + bh - 80, 36, tc)
    let press = "Press " + key
    let pw = @draw.measure_text(press, 16)
    @draw.draw_text(
      press,
      bx + (bw - pw) / 2,
      by + bh - 40,
      16,
      @types.color_text_dim,
    )
  }
  // Back instruction
  @draw.draw_text("ESC - Back", 20, 680, 16, @types.color_text_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let _h = @types.screen_height
  let tier = game.current_tier
  let tc = @types.tier_color(tier)
  let range = @types.tier_level_range(tier)
  // Title
  let title = @types.tier_name(tier) + " - Select Level"
  let title_w = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - title_w) / 2, 30, 36, tc)
  // Draw level buttons in a grid
  let cols = 5
  let cell_w = 200
  let cell_h = 100
  let start_x = (w - cols * cell_w) / 2
  let start_y = 100
  let mut idx = 0
  for j = range.0; j <= range.1; j = j + 1 {
    let col = idx % cols
    let row = idx / cols
    let bx = start_x + col * cell_w + 10
    let by = start_y + row * (cell_h + 20) + 10
    let bw = cell_w - 20
    let bh = cell_h - 10
    // Background
    let bg = if game.scores[j].completed {
      @raylib.Color::new(50, 70, 50, 255)
    } else {
      @types.color_bg_light
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, tc)
    // Level number
    let num = (j + 1).to_string()
    let nw = @draw.measure_text(num, 28)
    @draw.draw_text(num, bx + (bw - nw) / 2, by + 8, 28, @types.color_text)
    // Level name (fetch from levels)
    let level = @levels.get_level(j)
    let lname = level.name
    let lnw = @draw.measure_text(lname, 14)
    @draw.draw_text(
      lname,
      bx + (bw - lnw) / 2,
      by + 40,
      14,
      @types.color_text_dim,
    )
    // Stars
    let stars = game.scores[j].stars
    for s in 0..<3 {
      let sx = bx + (bw - 60) / 2 + s * 22
      let sy = by + bh - 25
      let sc = if s < stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      draw_star(sx, sy, 8, sc)
    }
    idx += 1
  }
  // Controls
  @draw.draw_text("ESC - Back", 20, 680, 16, @types.color_text_dim)
  @draw.draw_text(
    "Click or press 1-9 to select level",
    400,
    680,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_star(cx : Int, cy : Int, radius : Int, color : @raylib.Color) -> Unit {
  let r = Float::from_int(radius)
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Simple star: draw a filled circle for now (star shape approximation)
  @raylib.draw_circle(cx, cy, r, color)
  // Draw small triangles on top/bottom/sides for star points
  let hr = r * 0.5
  // Top point
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx, fcy - r * 1.4),
    @raylib.Vector2::new(fcx - hr, fcy - hr),
    @raylib.Vector2::new(fcx + hr, fcy - hr),
    color,
  )
  // Bottom point
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx, fcy + r * 1.4),
    @raylib.Vector2::new(fcx + hr, fcy + hr),
    @raylib.Vector2::new(fcx - hr, fcy + hr),
    color,
  )
  // Left point
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx - r * 1.4, fcy),
    @raylib.Vector2::new(fcx - hr, fcy + hr),
    @raylib.Vector2::new(fcx - hr, fcy - hr),
    color,
  )
  // Right point
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx + r * 1.4, fcy),
    @raylib.Vector2::new(fcx + hr, fcy - hr),
    @raylib.Vector2::new(fcx + hr, fcy + hr),
    color,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level = @levels.get_level(game.current_level)
  let score = game.scores[game.current_level]
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 180))
  // Result card
  let card_w = 500
  let card_h = 400
  let cx = (w - card_w) / 2
  let cy = (h - card_h) / 2
  @raylib.draw_rectangle(cx, cy, card_w, card_h, @types.color_bg_light)
  @raylib.draw_rectangle_lines(cx, cy, card_w, card_h, @types.color_accent)
  // Title
  let result_text = if game.play_state == Solved {
    "Level Complete!"
  } else {
    "Not Quite Right..."
  }
  let rt_w = @draw.measure_text(result_text, 32)
  let rt_color = if game.play_state == Solved {
    @types.color_correct
  } else {
    @types.color_incorrect
  }
  @draw.draw_text(result_text, cx + (card_w - rt_w) / 2, cy + 30, 32, rt_color)
  // Level name
  let ln = level.name
  let lnw = @draw.measure_text(ln, 20)
  @draw.draw_text(
    ln,
    cx + (card_w - lnw) / 2,
    cy + 75,
    20,
    @types.color_text_dim,
  )
  // Moves
  let moves_text = "Moves: " +
    game.moves.to_string() +
    " (par: " +
    level.par_moves.to_string() +
    ")"
  let mt_w = @draw.measure_text(moves_text, 22)
  @draw.draw_text(
    moves_text,
    cx + (card_w - mt_w) / 2,
    cy + 120,
    22,
    @types.color_text,
  )
  // Stars
  if game.play_state == Solved {
    let stars = score.stars
    for s in 0..<3 {
      let sx = cx + (card_w - 120) / 2 + s * 50
      let sy = cy + 180
      let sc = if s < stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      draw_star(sx, sy, 18, sc)
    }
    // Star explanation
    let star_desc = match stars {
      1 => "Correct order!"
      2 => "Within par moves!"
      3 => "Perfect - no mistakes!"
      _ => "Keep trying!"
    }
    let sd_w = @draw.measure_text(star_desc, 18)
    @draw.draw_text(
      star_desc,
      cx + (card_w - sd_w) / 2,
      cy + 220,
      18,
      @types.color_star_gold,
    )
  }
  // Controls
  let next_text = if game.play_state == Solved {
    "ENTER - Next Level  |  ESC - Level Select"
  } else {
    "R - Retry  |  ESC - Level Select"
  }
  let nt_w = @draw.measure_text(next_text, 18)
  @draw.draw_text(
    next_text,
    cx + (card_w - nt_w) / 2,
    cy + card_h - 60,
    18,
    @types.color_text_dim,
  )
}
