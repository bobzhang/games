///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Background: sand-colored gradient effect with scattered symbols
  for i in 0..<40 {
    let fi = Float::from_int(i)
    let sx = ((fi * 137.5 + time * 8.0) % Float::from_int(w)).to_int()
    let sy = ((fi * 91.3 + time * 4.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)).to_int()
    let alpha = 30 + (fi * 7.0 % 40.0).to_int()
    @raylib.draw_circle(
      sx,
      sy,
      2.0 + fi % 3.0,
      @raylib.Color::new(180, 160, 120, alpha),
    )
  }
  // Decorative border lines
  let border_alpha = ((@types.sinf(time) * 0.3 + 0.7) * 255.0).to_int()
  let border_color = @raylib.Color::new(218, 165, 32, border_alpha)
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      20.0,
      20.0,
      Float::from_int(w - 40),
      Float::from_int(h - 40),
    ),
    3.0,
    border_color,
  )
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      30.0,
      30.0,
      Float::from_int(w - 60),
      Float::from_int(h - 60),
    ),
    1.0,
    border_color,
  )
  ignore(draw_title_cartouche_art(w / 2, 215, 680, 385))
  // Title
  let title = "CARTOUCHE"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha2 = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    140,
    72,
    @raylib.Color::new(218, 165, 32, alpha2),
  )
  // Subtitle
  let sub = "Hieroglyph Decoder"
  let sub_w = @draw.measure_text(sub, 28)
  @draw.draw_text(sub, (w - sub_w) / 2, 230, 28, @types.color_stone_light)
  // Decorative symbols row
  let symbols = @types.all_symbols()
  let sym_y : Float = 300.0
  let sym_start_x = Float::from_int((w - 20 * 28) / 2)
  for i in 0..<symbols.length() {
    let fi = Float::from_int(i)
    let x = sym_start_x + fi * 28.0
    let wave : Float = @types.sinf(time * 1.5 + fi * 0.5) * 8.0
    let y : Float = sym_y + wave
    draw_symbol_small(symbols[i], x, y, 20.0, @types.color_gold_dim)
  }
  // Instructions
  let inst = "Press ENTER to Begin"
  let inst_w = @draw.measure_text(inst, 24)
  let blink = if game.frame_count / 40 % 2 == 0 { 255 } else { 120 }
  @draw.draw_text(
    inst,
    (w - inst_w) / 2,
    420,
    24,
    @raylib.Color::new(230, 220, 200, blink),
  )
  // Stats if any
  let stars = @types.total_stars(game)
  if stars > 0 {
    let stat = "Total Stars: " + stars.to_string() + " / 60"
    let stat_w = @draw.measure_text(stat, 20)
    @draw.draw_text(stat, (w - stat_w) / 2, 480, 20, @types.color_text_dim)
  }
  // Credits
  @draw.draw_text(
    "A MoonBit + Raylib Game",
    (w - @draw.measure_text("A MoonBit + Raylib Game", 16)) / 2,
    h - 50,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let time = Float::from_int(game.frame_count) * 0.02
  // Header
  let hdr = "Select Tier"
  let hdr_w = @draw.measure_text(hdr, 40)
  @draw.draw_text(hdr, (w - hdr_w) / 2, 40, 40, @types.color_gold)
  // Decorative line
  @raylib.draw_line(w / 2 - 200, 90, w / 2 + 200, 90, @types.color_gold_dim)
  // Three tier boxes
  let tiers : Array[@types.Tier] = [Fragments, Scrolls, Monuments]
  for i in 0..<3 {
    let tier = tiers[i]
    let bx = 140 + i * 350
    let by = 140
    let bw = 300
    let bh = 440
    let tc = @types.tier_color(tier)
    // Background panel
    if !draw_tier_card_art(tier, bx, by, bw, bh) {
      @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(50, 40, 30, 200))
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(
          Float::from_int(bx),
          Float::from_int(by),
          Float::from_int(bw),
          Float::from_int(bh),
        ),
        2.0,
        tc,
      )
    }
    // Tier name
    let tn = @types.tier_name(tier)
    let tn_w = @draw.measure_text(tn, 32)
    @draw.draw_text(tn, bx + (bw - tn_w) / 2, by + 20, 32, tc)
    // Tier description
    let desc = match tier {
      Fragments => "3-4 Words"
      Scrolls => "5-6 Words"
      Monuments => "7-8 Words"
    }
    let desc_w = @draw.measure_text(desc, 18)
    @draw.draw_text(
      desc,
      bx + (bw - desc_w) / 2,
      by + 60,
      18,
      @types.color_text_dim,
    )
    let diff = match tier {
      Fragments => "40% Given"
      Scrolls => "25% Given"
      Monuments => "15% Given"
    }
    let diff_w = @draw.measure_text(diff, 16)
    @draw.draw_text(
      diff,
      bx + (bw - diff_w) / 2,
      by + 85,
      16,
      @types.color_text_dim,
    )
    // Tablets preview (stars)
    let offset = @types.tier_tablet_offset(tier)
    let count = @types.tier_tablet_count(tier)
    for j in 0..<count {
      let ty = by + 120 + j * 40
      let tablet = @levels.get_tablet(offset + j)
      let score = game.scores[offset + j]
      // Tablet name
      @draw.draw_text(
        tablet.theme_name,
        bx + 15,
        ty + 2,
        16,
        if score.solved {
          @types.color_correct
        } else {
          @types.color_text
        },
      )
      // Stars
      for s in 0..<3 {
        let star_x = Float::from_int(bx + bw - 60 + s * 18)
        let star_y = Float::from_int(ty + 4)
        let star_color = if s < score.stars {
          @types.color_star_filled
        } else {
          @types.color_star_empty
        }
        draw_star_shape(star_x, star_y, 6.0, star_color)
      }
    }
    // Total stars
    let total = @types.total_stars_for_tier(game, tier)
    let max_stars = count * 3
    let summary = total.to_string() + "/" + max_stars.to_string() + " Stars"
    let summary_w = @draw.measure_text(summary, 18)
    @draw.draw_text(summary, bx + (bw - summary_w) / 2, by + bh - 45, 18, tc)
    // Key hint
    let key = (i + 1).to_string()
    let key_text = "[" + key + "]"
    let key_w = @draw.measure_text(key_text, 20)
    let key_pulse = @types.sinf(time * 3.0 + Float::from_int(i)) * 0.2 + 0.8
    let key_alpha = (key_pulse * 255.0).to_int()
    @draw.draw_text(
      key_text,
      bx + (bw - key_w) / 2,
      by + bh - 20,
      20,
      @raylib.Color::new(tc.r.to_int(), tc.g.to_int(), tc.b.to_int(), key_alpha),
    )
  }
  // Back hint
  @draw.draw_text(
    "ESC: Back",
    20,
    @types.screen_height - 30,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_tablet_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tc = @types.tier_color(game.current_tier)
  // Header
  let hdr = @types.tier_name(game.current_tier) + " - Select Tablet"
  let hdr_w = @draw.measure_text(hdr, 36)
  @draw.draw_text(hdr, (w - hdr_w) / 2, 40, 36, tc)
  @raylib.draw_line(w / 2 - 250, 85, w / 2 + 250, 85, @types.color_gold_dim)
  let offset = @types.tier_tablet_offset(game.current_tier)
  let count = @types.tier_tablet_count(game.current_tier)
  for j in 0..<count {
    let tablet = @levels.get_tablet(offset + j)
    let score = game.scores[offset + j]
    let bx = 100
    let by = 110 + j * 76
    let bw = w - 200
    let bh = 66
    // Panel
    let bg = if score.solved {
      @raylib.Color::new(40, 60, 40, 200)
    } else {
      @raylib.Color::new(50, 40, 30, 200)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(bx),
        Float::from_int(by),
        Float::from_int(bw),
        Float::from_int(bh),
      ),
      1.0,
      if score.solved {
        @types.color_correct
      } else {
        @types.color_stone_dark
      },
    )
    // Key
    let key = (j + 1).to_string()
    @draw.draw_text("[" + key + "]", bx + 15, by + 22, 22, tc)
    // Name
    @draw.draw_text(tablet.theme_name, bx + 60, by + 12, 24, @types.color_text)
    // Par info
    let par = "Par: " + tablet.par_guesses.to_string() + " guesses"
    @draw.draw_text(par, bx + 60, by + 40, 14, @types.color_text_dim)
    // Stars
    for s in 0..<3 {
      let star_x = Float::from_int(bx + bw - 80 + s * 22)
      let star_y = Float::from_int(by + 24)
      let star_color = if s < score.stars {
        @types.color_star_filled
      } else {
        @types.color_star_empty
      }
      draw_star_shape(star_x, star_y, 8.0, star_color)
    }
    // Status
    if score.solved {
      @draw.draw_text("SOLVED", bx + bw - 160, by + 8, 14, @types.color_correct)
    }
  }
  @draw.draw_text(
    "ESC: Back",
    20,
    @types.screen_height - 30,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  let tablet = @levels.get_tablet(game.current_tablet_index)
  let score = game.scores[game.current_tablet_index]
  // Background panel
  @raylib.draw_rectangle(
    w / 2 - 300,
    80,
    600,
    520,
    @raylib.Color::new(40, 30, 25, 230),
  )
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(Float::from_int(w / 2 - 300), 80.0, 600.0, 520.0),
    2.0,
    @types.color_gold,
  )
  // Header
  let hdr = "TABLET DECODED"
  let hdr_w = @draw.measure_text(hdr, 40)
  @draw.draw_text(hdr, (w - hdr_w) / 2, 100, 40, @types.color_gold)
  // Tablet name
  let name_w = @draw.measure_text(tablet.theme_name, 28)
  @draw.draw_text(
    tablet.theme_name,
    (w - name_w) / 2,
    160,
    28,
    @types.color_text,
  )
  // Decoded message
  let decoded = @types.decode_inscription(
    tablet.inscription,
    tablet.solution_mapping,
  )
  let dec_w = @draw.measure_text(decoded, 22)
  @draw.draw_text(decoded, (w - dec_w) / 2, 210, 22, @types.color_stone_light)
  // Stats
  @draw.draw_text(
    "Guesses: " + score.guesses_used.to_string(),
    w / 2 - 120,
    270,
    22,
    @types.color_text,
  )
  @draw.draw_text(
    "Wrong: " + score.wrong_count.to_string(),
    w / 2 - 120,
    300,
    22,
    if score.wrong_count == 0 {
      @types.color_correct
    } else {
      @types.color_wrong
    },
  )
  @draw.draw_text(
    "Par: " + tablet.par_guesses.to_string(),
    w / 2 - 120,
    330,
    22,
    @types.color_text_dim,
  )
  // Stars display
  let star_y : Float = 390.0
  for i in 0..<3 {
    let star_x = Float::from_int(w / 2 - 60 + i * 60)
    let star_size : Float = 20.0
    let is_earned = i < score.stars
    let star_color = if is_earned {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    let anim_offset : Float = @types.sinf(time * 2.0 + Float::from_int(i)) * 3.0
    let animated_size : Float = if is_earned {
      star_size + anim_offset
    } else {
      star_size
    }
    draw_star_shape(star_x, star_y, animated_size, star_color)
  }
  // Star descriptions
  let desc1 = "Decoded"
  let desc2 = "Within Par"
  let desc3 = "Perfect"
  let d1c = if score.stars >= 1 {
    @types.color_correct
  } else {
    @types.color_text_dim
  }
  let d2c = if score.stars >= 2 {
    @types.color_correct
  } else {
    @types.color_text_dim
  }
  let d3c = if score.stars >= 3 {
    @types.color_correct
  } else {
    @types.color_text_dim
  }
  @draw.draw_text(desc1, w / 2 - 70, 420, 14, d1c)
  @draw.draw_text(desc2, w / 2 - 15, 420, 14, d2c)
  @draw.draw_text(desc3, w / 2 + 42, 420, 14, d3c)
  // Navigation
  let nav1 = "ENTER: Next Tablet"
  let nav2 = "ESC: Back to Select"
  let n1w = @draw.measure_text(nav1, 20)
  let n2w = @draw.measure_text(nav2, 20)
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 160 }
  @draw.draw_text(
    nav1,
    (w - n1w) / 2,
    480,
    20,
    @raylib.Color::new(230, 220, 200, blink),
  )
  @draw.draw_text(nav2, (w - n2w) / 2, 510, 20, @types.color_text_dim)
  ignore(h)
}

///|
fn draw_star_shape(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  if !draw_star_icon_art(cx, cy, size * 2.6, color) {
    // 5-pointed star
    let outer = size
    let inner = size * 0.4
    for i in 0..<5 {
      let fi = Float::from_int(i)
      let angle1 = fi * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
      let angle2 = (fi + 0.5) * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
      let angle3 = (fi + 1.0) * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
      let x1 = cx + @types.cosf(angle1) * outer
      let y1 = cy + @types.sinf(angle1) * outer
      let x2 = cx + @types.cosf(angle2) * inner
      let y2 = cy + @types.sinf(angle2) * inner
      let x3 = cx + @types.cosf(angle3) * outer
      let y3 = cy + @types.sinf(angle3) * outer
      @raylib.draw_triangle(
        @raylib.Vector2::new(x1, y1),
        @raylib.Vector2::new(cx, cy),
        @raylib.Vector2::new(x2, y2),
        color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(x2, y2),
        @raylib.Vector2::new(cx, cy),
        @raylib.Vector2::new(x3, y3),
        color,
      )
    }
  }
}
