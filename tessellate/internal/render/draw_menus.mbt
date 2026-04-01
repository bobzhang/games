///|
fn draw_title(_game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Title
  let title = "TESSELLATE"
  let title_w = @draw.measure_text(title, 64)
  @draw.draw_text(title, (w - title_w) / 2, h / 4 - 20, 64, @types.color_title)
  // Subtitle
  let sub = "A Polyomino Packing Puzzle"
  let sub_w = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 60, 24, @types.color_text)
  // Instructions
  let inst = "Press ENTER to Play"
  let inst_w = @draw.measure_text(inst, 28)
  @draw.draw_text(inst, (w - inst_w) / 2, h * 3 / 5, 28, @types.color_button)
  // Controls info
  let ctrl = "R: Rotate  |  F: Flip  |  Click: Place  |  Right-Click: Remove"
  let ctrl_w = @draw.measure_text(ctrl, 18)
  @draw.draw_text(
    ctrl,
    (w - ctrl_w) / 2,
    h * 3 / 4,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "Select Tier"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - title_w) / 2, 50, 40, @types.color_title)
  let tiers : Array[@types.Tier] = [Squares, Shapes, Art]
  let tier_descs : Array[String] = [
    "Rectangular regions, simple pieces", "L/T/cross regions, pentominoes", "Stars, hearts, diamonds - tight fits",
  ]
  for i in 0..<3 {
    let bx = w / 2 - 200
    let by = 160 + i * 160
    let bw = 400
    let bh = 120
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovered = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let col = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, col)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_text)
    let name = @types.tier_name(tiers[i])
    let name_w = @draw.measure_text(name, 32)
    @draw.draw_text(name, bx + (bw - name_w) / 2, by + 15, 32, @raylib.white)
    let desc = tier_descs[i]
    let desc_w = @draw.measure_text(desc, 18)
    @draw.draw_text(
      desc,
      bx + (bw - desc_w) / 2,
      by + 55,
      18,
      @raylib.Color::new(200, 200, 220, 255),
    )
    // Star count for this tier
    let base = @types.tier_index(tiers[i]) * @types.levels_per_tier
    let mut total_stars = 0
    for j in 0..<@types.levels_per_tier {
      total_stars += game.level_scores[base + j].stars
    }
    let star_text = total_stars.to_string() +
      " / " +
      (@types.levels_per_tier * 3).to_string() +
      " stars"
    let star_w = @draw.measure_text(star_text, 18)
    @draw.draw_text(
      star_text,
      bx + (bw - star_w) / 2,
      by + 85,
      18,
      @types.color_star,
    )
  }
  let back = "ESC: Back"
  @draw.draw_text(back, 20, h - 40, 18, @types.color_text)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let tier_name = @types.tier_name(game.current_tier)
  let title = tier_name + " - Select Level"
  let title_w = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - title_w) / 2, 40, 36, @types.color_title)
  let base = @types.tier_index(game.current_tier) * @types.levels_per_tier
  let cols = 5
  let cell_w = 160
  let cell_h = 100
  let gap = 20
  let start_x = (w - cols * (cell_w + gap) + gap) / 2
  let start_y = 120
  for i in 0..<@types.levels_per_tier {
    let row = i / cols
    let col = i % cols
    let bx = start_x + col * (cell_w + gap)
    let by = start_y + row * (cell_h + gap)
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovered = mx >= bx && mx < bx + cell_w && my >= by && my < by + cell_h
    let bg_col = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, cell_w, cell_h, bg_col)
    @raylib.draw_rectangle_lines(bx, by, cell_w, cell_h, @types.color_text)
    let num = "Level " + (i + 1).to_string()
    let num_w = @draw.measure_text(num, 22)
    @draw.draw_text(num, bx + (cell_w - num_w) / 2, by + 15, 22, @raylib.white)
    // Draw stars
    let score = game.level_scores[base + i]
    let star_y = by + 55
    let star_start_x = bx + (cell_w - 3 * 30) / 2
    for s in 0..<3 {
      let sx = star_start_x + s * 30 + 5
      let col2 = if s < score.stars {
        @types.color_star
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", sx, star_y, 28, col2)
    }
  }
  let back = "ESC: Back to Tiers"
  @draw.draw_text(back, 20, h - 40, 18, @types.color_text)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level_idx = @types.level_index(game.current_tier, game.current_level)
  let score = game.level_scores[level_idx]
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 150))
  let box_w = 500
  let box_h = 400
  let bx = (w - box_w) / 2
  let by = (h - box_h) / 2
  @raylib.draw_rectangle(
    bx,
    by,
    box_w,
    box_h,
    @raylib.Color::new(40, 40, 60, 240),
  )
  @raylib.draw_rectangle_lines(bx, by, box_w, box_h, @types.color_title)
  let complete = "Level Complete!"
  let c_w = @draw.measure_text(complete, 36)
  @draw.draw_text(
    complete,
    bx + (box_w - c_w) / 2,
    by + 30,
    36,
    @types.color_title,
  )
  // Stars
  let star_start = bx + (box_w - 3 * 60) / 2
  for s in 0..<3 {
    let sx = star_start + s * 60 + 10
    let col = if s < score.stars {
      @types.color_star
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, by + 90, 48, col)
  }
  // Time
  let time_s = score.best_time
  let time_text = "Time: " + time_s.to_string() + "s"
  let t_w = @draw.measure_text(time_text, 24)
  @draw.draw_text(
    time_text,
    bx + (box_w - t_w) / 2,
    by + 170,
    24,
    @types.color_text,
  )
  // Rotations
  let rot_text = "Rotations: " + score.best_rotations.to_string()
  let r_w = @draw.measure_text(rot_text, 24)
  @draw.draw_text(
    rot_text,
    bx + (box_w - r_w) / 2,
    by + 210,
    24,
    @types.color_text,
  )
  // Buttons
  let retry = "R: Retry"
  let retry_w = @draw.measure_text(retry, 22)
  @draw.draw_text(
    retry,
    bx + (box_w - retry_w) / 2 - 100,
    by + 290,
    22,
    @types.color_button,
  )
  let next = "ENTER: Next Level"
  let next_w = @draw.measure_text(next, 22)
  @draw.draw_text(
    next,
    bx + (box_w - next_w) / 2 + 80,
    by + 290,
    22,
    @types.color_button,
  )
  let back = "ESC: Level Select"
  let back_w = @draw.measure_text(back, 22)
  @draw.draw_text(
    back,
    bx + (box_w - back_w) / 2,
    by + 340,
    22,
    @types.color_text,
  )
}
