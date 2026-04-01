///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated mosaic background tiles
  for i in 0..<40 {
    let fi = Float::from_int(i)
    let tx = ((fi * 97.3 + time * 15.0) % Float::from_int(w)).to_int()
    let ty = ((fi * 63.7 + time * 8.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)).to_int()
    let ci = i % 6
    let color = @types.tile_color_to_raylib(@types.index_to_tile_color(ci))
    let r = color.r.to_int()
    let g = color.g.to_int()
    let b = color.b.to_int()
    let alpha = 40 + (sinf(fi * 0.5 + time) * 20.0).to_int()
    let c = @raylib.Color::new(r, g, b, alpha)
    let size = 20 + i % 15
    if i % 3 == 0 {
      @raylib.draw_rectangle(tx, ty, size, size, c)
    } else if i % 3 == 1 {
      @raylib.draw_circle(
        tx + size / 2,
        ty + size / 2,
        Float::from_int(size / 2),
        c,
      )
    } else {
      let cx = Float::from_int(tx + size / 2)
      let cy = Float::from_int(ty + size / 2)
      let half = Float::from_int(size / 2)
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy - half),
        @raylib.Vector2::new(cx - half, cy + half),
        @raylib.Vector2::new(cx + half, cy + half),
        c,
      )
    }
  }
  // Title text
  let title = "MOSAIC"
  let title_w = @draw.measure_text(title, 72)
  let pulse = sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(180, 120, 255, alpha),
  )
  // Subtitle
  let sub = "SYMMETRY PATTERN RESTORATION"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 60, 20, @types.color_hud_text)
  // Decorative mosaic tiles below title
  let mosaic_y = h / 2 - 30
  for i in 0..<8 {
    let fi = Float::from_int(i)
    let mx = w / 2 - 4 * 36 + i * 36
    let ci = (i + game.frame_count / 30) % 6
    let tc = @types.tile_color_to_raylib(@types.index_to_tile_color(ci))
    let bob = sinf(time * 3.0 + fi * 0.8) * 5.0
    @raylib.draw_rectangle(mx, mosaic_y + bob.to_int(), 32, 32, tc)
  }
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(180, 120, 255, blink),
  )
  // Footer
  @draw.draw_text(
    "25 Puzzles across 3 Tiers",
    w / 2 - 100,
    h - 40,
    14,
    @types.color_hud_dim,
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "SELECT TIER"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 40, 36, @types.color_hud_text)
  let tiers : Array[@types.Tier] = [Repair, Restore, Master]
  let tier_descs = [
    "Mirror symmetry - 8 levels", "Rotational symmetry - 9 levels", "All symmetries - 8 levels",
  ]
  let tier_level_counts = [8, 9, 8]
  let card_w = 320
  let card_h = 350
  let gap = 40
  let total_w = 3 * card_w + 2 * gap
  let start_x = (w - total_w) / 2
  for i in 0..<3 {
    let cx = start_x + i * (card_w + gap)
    let cy = 120
    let tier = tiers[i]
    let tc = @types.tier_color(tier)
    let hovered = is_mouse_in_rect(cx, cy, card_w, card_h)
    // Background
    let bg = if hovered {
      @raylib.Color::new(60, 55, 80, 255)
    } else {
      @raylib.Color::new(40, 36, 52, 255)
    }
    @raylib.draw_rectangle(cx, cy, card_w, card_h, bg)
    @raylib.draw_rectangle_lines(cx, cy, card_w, card_h, tc)
    // Tier name
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 28)
    @draw.draw_text(name, cx + (card_w - nw) / 2, cy + 20, 28, tc)
    // Description
    let dw = @draw.measure_text(tier_descs[i], 14)
    @draw.draw_text(
      tier_descs[i],
      cx + (card_w - dw) / 2,
      cy + 60,
      14,
      @types.color_hud_dim,
    )
    // Stars earned
    let level_indices = @types.levels_for_tier(game, tier)
    let mut total_stars = 0
    let mut completed = 0
    for j in 0..<level_indices.length() {
      let score = game.scores[level_indices[j]]
      total_stars = total_stars + score.stars
      if score.completed {
        completed = completed + 1
      }
    }
    let max_stars = tier_level_counts[i] * 3
    let star_str = total_stars.to_string() +
      "/" +
      max_stars.to_string() +
      " Stars"
    let sw = @draw.measure_text(star_str, 18)
    @draw.draw_text(
      star_str,
      cx + (card_w - sw) / 2,
      cy + 100,
      18,
      @types.color_star_on,
    )
    // Progress
    let prog_str = completed.to_string() +
      "/" +
      tier_level_counts[i].to_string() +
      " Complete"
    let pw = @draw.measure_text(prog_str, 16)
    @draw.draw_text(
      prog_str,
      cx + (card_w - pw) / 2,
      cy + 130,
      16,
      @types.color_hud_dim,
    )
    // Decorative tiles
    let dec_y = cy + 170
    for j in 0..<6 {
      let dx = cx + 25 + j * 45
      let ci = (i * 2 + j) % 6
      let dc = @types.tile_color_to_raylib(@types.index_to_tile_color(ci))
      let time = Float::from_int(game.frame_count) * 0.03
      let bob = sinf(time + Float::from_int(j) * 0.7 + Float::from_int(i) * 2.0)
      let alpha_f : Float = 180.0 + bob * 40.0
      let alpha = alpha_f.to_int()
      let r = dc.r.to_int()
      let g = dc.g.to_int()
      let b = dc.b.to_int()
      @raylib.draw_rectangle(
        dx,
        dec_y,
        36,
        36,
        @raylib.Color::new(r, g, b, alpha),
      )
    }
    // Number key hint
    let key_hint = "Press " + (i + 1).to_string()
    let kw = @draw.measure_text(key_hint, 16)
    @draw.draw_text(
      key_hint,
      cx + (card_w - kw) / 2,
      cy + card_h - 40,
      16,
      @types.color_hud_dim,
    )
  }
  // Back
  @draw.draw_text("ESC: Back", 20, h - 30, 14, @types.color_hud_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let tc = @types.tier_color(game.current_tier)
  let title = @types.tier_name(game.current_tier) + " - SELECT LEVEL"
  let tw = @draw.measure_text(title, 30)
  @draw.draw_text(title, (w - tw) / 2, 30, 30, tc)
  let level_indices = @types.levels_for_tier(game, game.current_tier)
  let card_w = 120
  let card_h = 100
  let gap = 16
  let cols = 5
  let total_cols = if level_indices.length() < cols {
    level_indices.length()
  } else {
    cols
  }
  let total_w = total_cols * card_w + (total_cols - 1) * gap
  let start_x = (w - total_w) / 2
  let start_y = 100
  for i in 0..<level_indices.length() {
    let li = level_indices[i]
    let level = game.levels[li]
    let score = game.scores[li]
    let col = i % cols
    let row = i / cols
    let cx = start_x + col * (card_w + gap)
    let cy = start_y + row * (card_h + gap)
    let hovered = is_mouse_in_rect(cx, cy, card_w, card_h)
    let bg = if hovered {
      @raylib.Color::new(65, 60, 85, 255)
    } else {
      @raylib.Color::new(40, 36, 52, 255)
    }
    @raylib.draw_rectangle(cx, cy, card_w, card_h, bg)
    if score.completed {
      @raylib.draw_rectangle_lines(
        cx, cy, card_w, card_h, @types.color_correct_glow,
      )
    } else {
      @raylib.draw_rectangle_lines(
        cx, cy, card_w, card_h, @types.color_grid_line,
      )
    }
    // Level number
    let num_str = (i + 1).to_string()
    let nw = @draw.measure_text(num_str, 24)
    @draw.draw_text(num_str, cx + (card_w - nw) / 2, cy + 8, 24, tc)
    // Level name
    let lnw = @draw.measure_text(level.name, 12)
    @draw.draw_text(
      level.name,
      cx + (card_w - lnw) / 2,
      cy + 38,
      12,
      @types.color_hud_dim,
    )
    // Stars
    let star_y = cy + 60
    for s in 0..<3 {
      let star_x = cx + card_w / 2 - 30 + s * 22
      let star_color = if s < score.stars {
        @types.color_star_on
      } else {
        @types.color_star_off
      }
      draw_star(star_x, star_y, 8, star_color)
    }
    // Symmetry hint
    let sym_short = match level.symmetry {
      MirrorH => "MH"
      MirrorV => "MV"
      MirrorD => "MD"
      Rotate2 => "R2"
      Rotate4 => "R4"
      Glide => "GL"
    }
    let shw = @draw.measure_text(sym_short, 11)
    @draw.draw_text(
      sym_short,
      cx + (card_w - shw) / 2,
      cy + card_h - 18,
      11,
      @types.color_hud_dim,
    )
  }
  // Back
  @draw.draw_text("ESC: Back", 20, h - 30, 14, @types.color_hud_dim)
}

///|
fn draw_star(x : Int, y : Int, size : Int, color : @raylib.Color) -> Unit {
  let cx = Float::from_int(x)
  let cy = Float::from_int(y)
  let s = Float::from_int(size)
  // Simple 5-pointed star using triangles
  for i in 0..<5 {
    let fi = Float::from_int(i)
    let angle1 = fi * 1.2566 - 1.5708
    let angle2 = angle1 + 1.2566
    let outer1_x = cx + cosf(angle1) * s
    let outer1_y = cy + sinf(angle1) * s
    let outer2_x = cx + cosf(angle2) * s
    let outer2_y = cy + sinf(angle2) * s
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(outer1_x, outer1_y),
      @raylib.Vector2::new(outer2_x, outer2_y),
      color,
    )
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level = game.levels[game.current_level]
  let score = game.scores[game.current_level]
  // Title
  let title = if score.completed { "LEVEL COMPLETE!" } else { "RESULTS" }
  let title_color = if score.completed {
    @types.color_correct_glow
  } else {
    @types.color_hud_text
  }
  let tw = @draw.measure_text(title, 42)
  @draw.draw_text(title, (w - tw) / 2, h / 6, 42, title_color)
  // Level name
  let lnw = @draw.measure_text(level.name, 24)
  @draw.draw_text(
    level.name,
    (w - lnw) / 2,
    h / 6 + 55,
    24,
    @types.color_title_accent,
  )
  // Stars
  let star_y = h / 3
  let star_size = 20
  for i in 0..<3 {
    let sx = w / 2 - 60 + i * 45
    let sc = if i < score.stars {
      @types.color_star_on
    } else {
      @types.color_star_off
    }
    draw_star(sx, star_y, star_size, sc)
  }
  // Star descriptions
  let desc_y = star_y + 40
  let star_descs = [
    "Complete the level", "No incorrect placements", "Identify symmetry type",
  ]
  for i in 0..<3 {
    let check = if i < score.stars { "[X] " } else { "[ ] " }
    let desc = check + star_descs[i]
    let dw = @draw.measure_text(desc, 16)
    let dc = if i < score.stars {
      @types.color_correct_glow
    } else {
      @types.color_hud_dim
    }
    @draw.draw_text(desc, (w - dw) / 2, desc_y + i * 28, 16, dc)
  }
  // Error count
  let err_str = "Errors: " + game.errors.to_string()
  let ew = @draw.measure_text(err_str, 18)
  @draw.draw_text(err_str, (w - ew) / 2, desc_y + 100, 18, @types.color_hud_dim)
  // Actions
  let action_y = h * 3 / 4
  let next_text = "ENTER: Next Level   R: Replay   ESC: Level Select"
  let nw = @draw.measure_text(next_text, 18)
  let blink = if game.frame_count % 60 < 45 { 255 } else { 150 }
  @draw.draw_text(
    next_text,
    (w - nw) / 2,
    action_y,
    18,
    @raylib.Color::new(180, 120, 255, blink),
  )
}
