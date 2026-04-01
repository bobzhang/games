///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated hex pattern at the top
  let colors = [
    @types.color_beam_red, @types.color_beam_green, @types.color_beam_blue,
    @types.color_beam_yellow, @types.color_beam_magenta, @types.color_beam_cyan,
  ]
  for i in 0..<6 {
    let fi = Float::from_int(i)
    let angle = fi * @types.pi / 3.0 + time * 0.5
    let radius : Float = 100.0 +
      Float::from_double(@math.sin((time + fi).to_double())) * 20.0
    let bx = Float::from_int(w) / 2.0 + @types.cosf(angle) * radius
    let by = Float::from_int(h) / 3.0 - 50.0 +
      @types.sinf(angle) * radius * 0.5
    @raylib.draw_circle(
      bx.to_int(),
      by.to_int(),
      4.0,
      fade_color(colors[i], 150),
    )
  }
  // Title
  let title = "PRISM"
  let title_w = @draw.measure_text(title, 80)
  let pulse_d = @math.sin(time.to_double() * 2.0)
  let pulse = Float::from_double(pulse_d) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 3,
    80,
    @raylib.Color::new(200, 180, 255, alpha),
  )
  // Subtitle
  let sub = "A LIGHT PATH ROUTING PUZZLE"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 3 + 90, 20, @types.color_text_dim)
  // Start prompt
  let start = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 80 }
  @draw.draw_text(
    start,
    (w - start_w) / 2,
    h * 2 / 3,
    24,
    @raylib.Color::new(140, 120, 255, blink),
  )
  // Controls hint
  let hint = "Hex grid - Click to place - R to rotate - 1-6 select"
  let hint_w = @draw.measure_text(hint, 14)
  @draw.draw_text(hint, (w - hint_w) / 2, h * 2 / 3 + 50, 14, @types.color_text_dim)
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "SELECT TIER"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - title_w) / 2, 60, 40, @types.color_text)
  let tiers : Array[(@types.Tier, String, @raylib.Color)] = [
    (Fundamentals, "Mirrors & Crystals", @types.color_beam_cyan),
    (Chromatics, "Color Filtering", @types.color_beam_yellow),
    (Mastery, "Complex Routing", @types.color_beam_magenta),
  ]
  for i in 0..<3 {
    let (tier, desc, color) = tiers[i]
    let box_w = 320
    let box_h = 140
    let bx = (w - box_w) / 2
    let by = 160 + i * 170
    let selected = @types.tier_index(game.selected_tier) == i
    let bg = if selected {
      @raylib.Color::new(35, 30, 60, 255)
    } else {
      @raylib.Color::new(20, 16, 36, 255)
    }
    @raylib.draw_rectangle(bx, by, box_w, box_h, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      box_w,
      box_h,
      if selected { color } else { @types.color_cell_border },
    )
    let name = @types.tier_name(tier)
    let name_w = @draw.measure_text(name, 28)
    @draw.draw_text(name, bx + (box_w - name_w) / 2, by + 20, 28, color)
    let desc_w = @draw.measure_text(desc, 16)
    @draw.draw_text(
      desc,
      bx + (box_w - desc_w) / 2,
      by + 60,
      16,
      @types.color_text_dim,
    )
    // Stars earned
    let (start_idx, end_idx) = @levels.tier_level_range(tier)
    let mut total_stars = 0
    for j = start_idx; j < end_idx; j = j + 1 {
      if j < game.scores.length() {
        total_stars += game.scores[j].stars
      }
    }
    let max_stars = (end_idx - start_idx) * 3
    let star_text = total_stars.to_string() + " / " + max_stars.to_string() + " Stars"
    let star_w = @draw.measure_text(star_text, 16)
    @draw.draw_text(
      star_text,
      bx + (box_w - star_w) / 2,
      by + 100,
      16,
      @types.color_star_filled,
    )
  }
  @draw.draw_text(
    "UP/DOWN to select   ENTER to play   ESC to go back",
    w / 2 - 220,
    h - 50,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let tier = game.selected_tier
  let tier_name = @types.tier_name(tier)
  let title = tier_name + " - Select Level"
  let title_w = @draw.measure_text(title, 32)
  @draw.draw_text(title, (w - title_w) / 2, 40, 32, @types.color_text)
  let (start_idx, end_idx) = @levels.tier_level_range(tier)
  let tier_count = end_idx - start_idx
  let levels = @levels.get_all_levels()
  let cols = 4
  for i in 0..<tier_count {
    let level_idx = start_idx + i
    let col = i % cols
    let row = i / cols
    let box_w = 240
    let box_h = 120
    let gap = 30
    let total_w = cols * box_w + (cols - 1) * gap
    let ox = (w - total_w) / 2
    let bx = ox + col * (box_w + gap)
    let by = 120 + row * (box_h + gap)
    let selected = game.selected_level == i
    let bg = if selected {
      @raylib.Color::new(35, 30, 60, 255)
    } else {
      @raylib.Color::new(20, 16, 36, 255)
    }
    @raylib.draw_rectangle(bx, by, box_w, box_h, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      box_w,
      box_h,
      if selected { @types.color_accent } else { @types.color_cell_border },
    )
    if level_idx < levels.length() {
      let name = levels[level_idx].name
      let name_w = @draw.measure_text(name, 18)
      @draw.draw_text(
        name,
        bx + (box_w - name_w) / 2,
        by + 15,
        18,
        @types.color_text,
      )
    }
    // Stars
    if level_idx < game.scores.length() {
      let score = game.scores[level_idx]
      for s in 0..<3 {
        let sx = bx + box_w / 2 - 30 + s * 22
        let sy = by + 50
        let color = if s < score.stars {
          @types.color_star_filled
        } else {
          @types.color_star_empty
        }
        draw_star_shape(sx, sy, 8, color)
      }
      if score.solved {
        @draw.draw_text(
          "SOLVED",
          bx + box_w / 2 - 24,
          by + 80,
          14,
          @types.color_success,
        )
      }
    }
  }
  @draw.draw_text(
    "ARROWS to select   ENTER to play   ESC to go back",
    w / 2 - 220,
    h - 50,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let idx = game.current_level_index
  let score = game.scores[idx]
  let title = if score.solved { "LEVEL COMPLETE!" } else { "NOT QUITE..." }
  let title_color = if score.solved {
    @types.color_success
  } else {
    @types.color_failure
  }
  let title_w = @draw.measure_text(title, 48)
  @draw.draw_text(title, (w - title_w) / 2, h / 4 - 40, 48, title_color)
  let name_w = @draw.measure_text(game.level_name, 24)
  @draw.draw_text(
    game.level_name,
    (w - name_w) / 2,
    h / 4 + 20,
    24,
    @types.color_text,
  )
  if score.solved {
    for s in 0..<3 {
      let sx = w / 2 - 50 + s * 40
      let sy = h / 2 - 40
      let color = if s < score.stars {
        @types.color_star_filled
      } else {
        @types.color_star_empty
      }
      draw_star_shape(sx, sy, 16, color)
    }
    let comp_text = "Components: " +
      score.components_used.to_string() +
      " / " +
      game.par_count.to_string() +
      " par"
    let comp_w = @draw.measure_text(comp_text, 20)
    @draw.draw_text(comp_text, (w - comp_w) / 2, h / 2 + 20, 20, @types.color_text)
  }
  let next_text = if score.solved {
    "ENTER: Next Level   ESC: Level Select"
  } else {
    "ENTER: Retry   ESC: Level Select"
  }
  let next_w = @draw.measure_text(next_text, 18)
  @draw.draw_text(
    next_text,
    (w - next_w) / 2,
    h * 3 / 4,
    18,
    @types.color_accent,
  )
}

///|
fn draw_star_shape(
  cx : Int,
  cy : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let s = Float::from_int(size)
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  @raylib.draw_circle(cx, cy, s, color)
  let point_len = s * 0.6
  for i in 0..<5 {
    let angle = Float::from_int(i) * 1.2566 - 1.5708
    let px = fcx +
      Float::from_double(@math.cos(angle.to_double())) * (s + point_len)
    let py = fcy +
      Float::from_double(@math.sin(angle.to_double())) * (s + point_len)
    @raylib.draw_line(cx, cy, px.to_int(), py.to_int(), color)
  }
}
