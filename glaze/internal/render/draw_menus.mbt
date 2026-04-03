///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Background pottery display
  let frame_x = w / 2 - 220
  let frame_y = h / 4 - 40
  let frame_w = 440
  let frame_h = 260
  // Outer decorative border
  @raylib.draw_rectangle(
    frame_x - 6,
    frame_y - 6,
    frame_w + 12,
    frame_h + 12,
    @types.color_highlight,
  )
  @raylib.draw_rectangle(
    frame_x - 3,
    frame_y - 3,
    frame_w + 6,
    frame_h + 6,
    @types.color_panel,
  )
  @raylib.draw_rectangle(frame_x, frame_y, frame_w, frame_h, @types.color_bg)
  // Animated glaze tiles
  let cell_w = frame_w / 8
  let cell_h = frame_h / 5
  let anim_phase = (time * 0.8).to_int() % 40
  for row in 0..<5 {
    for col in 0..<8 {
      let idx = row * 8 + col
      let cx = frame_x + col * cell_w + 1
      let cy = frame_y + row * cell_h + 1
      let cw = cell_w - 2
      let ch = cell_h - 2
      if idx < anim_phase {
        // Glazed cell with shifting hue
        let hue = Float::from_int(idx) * 40.0 + time * 30.0
        let rv = (@types.sinf(hue * 0.01) * 60.0 + 150.0).to_int().land(255)
        let gv = (@types.sinf(hue * 0.013 + 2.0) * 50.0 + 130.0)
          .to_int()
          .land(255)
        let bv = (@types.sinf(hue * 0.017 + 4.0) * 40.0 + 160.0)
          .to_int()
          .land(255)
        @raylib.draw_rectangle(
          cx,
          cy,
          cw,
          ch,
          @raylib.Color::new(rv, gv, bv, 255),
        )
      } else {
        // Empty kiln cell
        @raylib.draw_rectangle(cx, cy, cw, ch, @types.color_panel_light)
      }
    }
  }
  // Title
  let title = "GLAZE"
  let title_w = @draw.measure_text(title, 80)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 2 + 60,
    80,
    @raylib.Color::new(255, 220, 80, alpha),
  )
  // Subtitle
  let sub = "POTTERY  GLAZING  PUZZLE"
  let sub_w = @draw.measure_text(sub, 18)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 2 + 148, 18, @types.color_text_dim)
  // Instructions
  let start_text = "PRESS ENTER TO BEGIN"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h - 100,
    24,
    @raylib.Color::new(230, 225, 215, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Header
  let header = "SELECT TIER"
  let hw = @draw.measure_text(header, 40)
  @draw.draw_text(header, (w - hw) / 2, 40, 40, @types.color_text)
  // Tier cards
  let tiers : Array[@types.Tier] = [Beginner, Intermediate, Advanced]
  let card_w = 300
  let card_h = 350
  let total_w = card_w * 3 + 40 * 2
  let start_x = (w - total_w) / 2
  for i in 0..<3 {
    let tier = tiers[i]
    let cx = start_x + i * (card_w + 40)
    let cy = 120
    let is_selected = game.selected_tier == tier
    // Card background
    let bg = if is_selected {
      @types.color_panel_light
    } else {
      @types.color_panel
    }
    @raylib.draw_rectangle(cx, cy, card_w, card_h, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(
        cx, cy, card_w, card_h, @types.color_highlight,
      )
    }
    // Tier name
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 32)
    @draw.draw_text(
      name,
      cx + (card_w - nw) / 2,
      cy + 20,
      32,
      @types.color_text,
    )
    // Level count info
    let (lo, hi) = @types.tier_level_range(tier)
    let count_str = "Levels \{lo + 1} - \{hi}"
    let cw = @draw.measure_text(count_str, 20)
    @draw.draw_text(
      count_str,
      cx + (card_w - cw) / 2,
      cy + 65,
      20,
      @types.color_text_dim,
    )
    // Stars earned
    let mut total_stars = 0
    for j in lo..<hi {
      total_stars = total_stars + game.level_scores[j]
    }
    let star_str = "Stars: \{total_stars} / \{(hi - lo) * 3}"
    let sw = @draw.measure_text(star_str, 20)
    @draw.draw_text(
      star_str,
      cx + (card_w - sw) / 2,
      cy + 100,
      20,
      @types.color_star_gold,
    )
    // Decorative pottery preview
    let preview_x = cx + 40
    let preview_y = cy + 140
    let pcell = 30
    for pr in 0..<5 {
      for pc in 0..<7 {
        let px = preview_x + pc * (pcell + 2)
        let py = preview_y + pr * (pcell + 2)
        let idx = pr * 7 + pc
        let ci = (idx + i * 5) % 6
        let glaze = @types.glaze_from_index(ci)
        let color = @types.glaze_to_raylib(glaze)
        @raylib.draw_rectangle(px, py, pcell, pcell, color)
      }
    }
  }
  // Navigation hint
  let hint = "LEFT/RIGHT to select, ENTER to confirm, ESC to go back"
  let hint_w = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    (w - hint_w) / 2,
    @types.screen_height - 50,
    18,
    @types.color_text_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Header
  let tier_str = @types.tier_name(game.selected_tier)
  let header = "\{tier_str} Levels"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(header, (w - hw) / 2, 30, 36, @types.color_text)
  // Level grid
  let (lo, hi) = @types.tier_level_range(game.selected_tier)
  let count = hi - lo
  let cols = if count <= 4 { count } else { 4 }
  let rows = (count + cols - 1) / cols
  let card_w = 250
  let card_h = 120
  let gap = 20
  let total_w = cols * card_w + (cols - 1) * gap
  let total_h = rows * card_h + (rows - 1) * gap
  let start_x = (w - total_w) / 2
  let start_y = (h - total_h) / 2
  let levels = @levels.get_all_levels()
  for i in 0..<count {
    let level = levels[lo + i]
    let row = i / cols
    let col = i % cols
    let cx = start_x + col * (card_w + gap)
    let cy = start_y + row * (card_h + gap)
    let is_selected = game.selected_level == lo + i
    let bg = if is_selected {
      @types.color_panel_light
    } else {
      @types.color_panel
    }
    @raylib.draw_rectangle(cx, cy, card_w, card_h, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(
        cx, cy, card_w, card_h, @types.color_highlight,
      )
    }
    // Level number and name
    let num = lo + i + 1
    let name_str = "\{num}. \{level.name}"
    @draw.draw_text(name_str, cx + 12, cy + 12, 22, @types.color_text)
    // Moves info
    let info = "Moves: \{level.max_moves} (par: \{level.par_moves})"
    @draw.draw_text(info, cx + 12, cy + 42, 16, @types.color_text_dim)
    // Stars display
    let stars = game.level_scores[lo + i]
    draw_stars(cx + 12, cy + 70, stars, 3, 20)
    // Allowed glazes preview
    let ag = level.allowed_glazes
    for j in 0..<ag.length() {
      let color = @types.glaze_to_raylib(ag[j])
      let gx = cx + card_w - 30 - j * 22
      @raylib.draw_rectangle(gx, cy + 80, 18, 18, color)
      @raylib.draw_rectangle_lines(
        gx,
        cy + 80,
        18,
        18,
        @types.color_grid_border,
      )
    }
  }
  // Navigation hint
  let hint = "ARROWS to select, ENTER to play, ESC to go back"
  let hint_w = @draw.measure_text(hint, 18)
  @draw.draw_text(hint, (w - hint_w) / 2, h - 45, 18, @types.color_text_dim)
}

///|
fn draw_stars(x : Int, y : Int, filled : Int, total : Int, size : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * (size + 4)
    let color = if i < filled {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    // Draw a simple star shape using triangle and inverted triangle
    let cx = Float::from_int(sx + size / 2)
    let cy = Float::from_int(y + size / 2)
    let r = Float::from_int(size) / 2.0
    @raylib.draw_poly(@raylib.Vector2::new(cx, cy), 5, r, 0.0, color)
  }
}
