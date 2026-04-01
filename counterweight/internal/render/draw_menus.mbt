///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated gears in background
  for i in 0..<8 {
    let fi = Float::from_int(i)
    let gx = (fi * 173.0 + 50.0) % Float::from_int(w)
    let gy = (fi * 119.0 + 80.0) % Float::from_int(h)
    let radius : Float = 20.0 + fi * 5.0
    let angle = time * (if i % 2 == 0 { 1.0 } else { -1.0 })
    draw_gear(gx.to_int(), gy.to_int(), radius, angle, @types.color_gear)
  }
  // Title
  let title = "COUNTERWEIGHT"
  let tw = @draw.measure_text(title, 56)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  let title_color = @raylib.Color::new(255, 225, 150, alpha)
  @draw.draw_text(title, (w - tw) / 2, 180, 56, title_color)
  // Subtitle
  let sub = "A Clocktower Workshop Puzzle"
  let sw = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sw) / 2, 250, 22, @types.color_hud_text)
  // Click to start
  let start_text = "Click or Press ENTER to Start"
  let stw = @draw.measure_text(start_text, 20)
  let start_alpha = (@types.sinf(time * 3.0) * 100.0 + 155.0).to_int()
  let start_color = @raylib.Color::new(200, 180, 140, start_alpha)
  @draw.draw_text(start_text, (w - stw) / 2, 420, 20, start_color)
  // Stars count
  let stars = @types.total_stars(game.scores)
  let star_text = "Total Stars: " + stars.to_string() + " / 75"
  let starw = @draw.measure_text(star_text, 18)
  @draw.draw_text(star_text, (w - starw) / 2, 500, 18, @types.color_star_gold)
}

///|
fn draw_gear(
  cx : Int,
  cy : Int,
  radius : Float,
  angle : Float,
  color : @raylib.Color,
) -> Unit {
  let teeth = 8
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Draw gear body
  @raylib.draw_circle(cx, cy, radius * 0.7, color)
  @raylib.draw_circle(cx, cy, radius * 0.25, @types.color_bg)
  // Draw teeth
  for i in 0..<teeth {
    let a = angle + Float::from_int(i) * 6.28318 / Float::from_int(teeth)
    let tx = fcx + @types.cosf(a) * radius
    let ty = fcy + @types.sinf(a) * radius
    @raylib.draw_circle(tx.to_int(), ty.to_int(), radius * 0.2, color)
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, 80, 40, @types.color_title_text)
  let tier_names = ["Basics", "Chains", "Workshop"]
  let tier_descs = [
    "Simple pulleys & weights", "Chained pulleys & ratchets", "Breakable ropes & buckets",
  ]
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for t in 0..<3 {
    let bx = 240 + t * 300
    let by = 300
    let bw = 220
    let bh = 160
    let unlocked = @types.tier_unlocked(game.scores, t)
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if !unlocked {
      @raylib.Color::new(50, 40, 35, 255)
    } else if hover {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_pulley_brass)
    let name = tier_names[t]
    let nw = @draw.measure_text(name, 24)
    @draw.draw_text(
      name,
      bx + (bw - nw) / 2,
      by + 20,
      24,
      @types.color_button_text,
    )
    let desc = tier_descs[t]
    let dw = @draw.measure_text(desc, 14)
    @draw.draw_text(
      desc,
      bx + (bw - dw) / 2,
      by + 55,
      14,
      @types.color_hud_text,
    )
    // Show tier stars
    let tier_start = @types.level_index_for_tier(t, 0)
    let tier_count = @types.levels_in_tier(t)
    let mut tier_stars = 0
    for i in tier_start..<(tier_start + tier_count) {
      if i < game.scores.length() {
        tier_stars = tier_stars + game.scores[i].stars
      }
    }
    let max_stars = tier_count * 3
    let star_str = tier_stars.to_string() +
      "/" +
      max_stars.to_string() +
      " Stars"
    let ssw = @draw.measure_text(star_str, 16)
    @draw.draw_text(
      star_str,
      bx + (bw - ssw) / 2,
      by + 90,
      16,
      @types.color_star_gold,
    )
    if !unlocked {
      let lock = "LOCKED"
      let lw = @draw.measure_text(lock, 20)
      @draw.draw_text(
        lock,
        bx + (bw - lw) / 2,
        by + 120,
        20,
        @raylib.Color::new(200, 60, 60, 255),
      )
    }
  }
  // Back hint
  @draw.draw_text(
    "ESC: Back",
    20,
    @types.screen_height - 40,
    16,
    @types.color_hud_text,
  )
  // Message
  if game.message_timer > 0.0 {
    let msgw = @draw.measure_text(game.message, 20)
    @draw.draw_text(
      game.message,
      (w - msgw) / 2,
      550,
      20,
      @raylib.Color::new(255, 100, 80, 255),
    )
  }
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier_name = match game.selected_tier {
    0 => "Basics"
    1 => "Chains"
    _ => "Workshop"
  }
  let title = "Tier: " + tier_name
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 60, 36, @types.color_title_text)
  let count = @types.levels_in_tier(game.selected_tier)
  let cols = 5
  let bw = 120
  let bh = 80
  let gap = 20
  let start_x = (w - (cols * (bw + gap) - gap)) / 2
  let start_y = 200
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let bx = start_x + col * (bw + gap)
    let by = start_y + row * (bh + gap)
    let level_idx = @types.level_index_for_tier(game.selected_tier, i)
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_pulley_brass)
    // Level number
    let num = (i + 1).to_string()
    let nw = @draw.measure_text(num, 28)
    @draw.draw_text(
      num,
      bx + (bw - nw) / 2,
      by + 8,
      28,
      @types.color_button_text,
    )
    // Stars
    if level_idx < game.scores.length() {
      let score = game.scores[level_idx]
      let stars = score.stars
      for s in 0..<3 {
        let sx = bx + 25 + s * 28
        let sy = by + 50
        let sc = if s < stars {
          @types.color_star_gold
        } else {
          @types.color_star_empty
        }
        draw_star(sx, sy, 8.0, sc)
      }
    }
  }
  @draw.draw_text(
    "ESC: Back",
    20,
    @types.screen_height - 40,
    16,
    @types.color_hud_text,
  )
}

///|
fn draw_star(cx : Int, cy : Int, radius : Float, color : @raylib.Color) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Simple 5-point star approximation with triangles
  for i in 0..<5 {
    let angle1 = Float::from_int(i) * 1.2566 - 1.5708
    let angle2 = angle1 + 0.6283
    let ox = fcx + @types.cosf(angle1) * radius
    let oy = fcy + @types.sinf(angle1) * radius
    let ix = fcx + @types.cosf(angle2) * radius * 0.4
    let iy = fcy + @types.sinf(angle2) * radius * 0.4
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(ox, oy),
      @raylib.Vector2::new(ix, iy),
      color,
    )
    let angle3 = angle2
    let angle4 = angle1 + 1.2566
    let ix2 = fcx + @types.cosf(angle3) * radius * 0.4
    let iy2 = fcy + @types.sinf(angle3) * radius * 0.4
    let ox2 = fcx + @types.cosf(angle4) * radius
    let oy2 = fcy + @types.sinf(angle4) * radius
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(ix2, iy2),
      @raylib.Vector2::new(ox2, oy2),
      color,
    )
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let title = "Level Complete!"
  let tw = @draw.measure_text(title, 44)
  @draw.draw_text(title, (w - tw) / 2, 100, 44, @types.color_success)
  // Level name
  let name = @levels.get_level_name(game.current_level)
  let nw = @draw.measure_text(name, 24)
  @draw.draw_text(name, (w - nw) / 2, 160, 24, @types.color_title_text)
  // Stats
  let conn_text = "Connections: " +
    game.connections_used.to_string() +
    " (par: " +
    game.par_connections.to_string() +
    ")"
  let ctw = @draw.measure_text(conn_text, 20)
  @draw.draw_text(conn_text, (w - ctw) / 2, 220, 20, @types.color_hud_text)
  let rehook_text = "Rehooks: " +
    game.rehooks.to_string() +
    " (par: " +
    game.par_rehooks.to_string() +
    ")"
  let rtw = @draw.measure_text(rehook_text, 20)
  @draw.draw_text(rehook_text, (w - rtw) / 2, 250, 20, @types.color_hud_text)
  // Stars
  let stars = @physics.compute_stars(
    game.connections_used,
    game.rehooks,
    game.par_connections,
    game.par_rehooks,
  )
  let star_start_x = w / 2 - 75
  for s in 0..<3 {
    let sx = star_start_x + s * 55
    let sc = if s < stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star(sx, 340, 22.0, sc)
  }
  // Buttons
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Next level
  let nbx = 440
  let nby = 450
  let nbw = 180
  let nbh = 50
  let nhover = mx >= nbx && mx < nbx + nbw && my >= nby && my < nby + nbh
  let nbg = if nhover { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(nbx, nby, nbw, nbh, nbg)
  @raylib.draw_rectangle_lines(nbx, nby, nbw, nbh, @types.color_pulley_brass)
  let ntxt = if game.current_level + 1 < @types.total_levels {
    "Next Level"
  } else {
    "All Done!"
  }
  let nntw = @draw.measure_text(ntxt, 20)
  @draw.draw_text(
    ntxt,
    nbx + (nbw - nntw) / 2,
    nby + 15,
    20,
    @types.color_button_text,
  )
  // Replay button
  let rbx = 660
  let rhover = mx >= rbx && mx < rbx + nbw && my >= nby && my < nby + nbh
  let rbg = if rhover { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(rbx, nby, nbw, nbh, rbg)
  @raylib.draw_rectangle_lines(rbx, nby, nbw, nbh, @types.color_pulley_brass)
  let rtxt = "Replay"
  let rrtw = @draw.measure_text(rtxt, 20)
  @draw.draw_text(
    rtxt,
    rbx + (nbw - rrtw) / 2,
    nby + 15,
    20,
    @types.color_button_text,
  )
  // Back
  let backx = 540
  let backy = 520
  let bhover = mx >= backx &&
    mx < backx + nbw &&
    my >= backy &&
    my < backy + nbh
  let bbg = if bhover { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(backx, backy, nbw, nbh, bbg)
  @raylib.draw_rectangle_lines(
    backx, backy, nbw, nbh, @types.color_pulley_brass,
  )
  let btxt = "Level Select"
  let bbtw = @draw.measure_text(btxt, 20)
  @draw.draw_text(
    btxt,
    backx + (nbw - bbtw) / 2,
    backy + 15,
    20,
    @types.color_button_text,
  )
}
