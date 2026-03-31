///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Background grid pattern
  for i in 0..<16 {
    for j in 0..<12 {
      let x = i * 80 + 10
      let y = j * 60 + 10
      let pulse = time + Float::from_int(i + j) * 0.3
      let alpha_f = 20.0 + Float::from_double(@math.sin(pulse.to_double())) * 15.0
      let alpha = alpha_f.to_int()
      @raylib.draw_rectangle_lines(
        x,
        y,
        70,
        50,
        @raylib.Color::new(60, 80, 120, alpha),
      )
    }
  }
  // Title
  let title = "TOPOLOGY"
  let title_w = @draw.measure_text(title, 72)
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @types.color_accent,
  )
  // Subtitle
  let sub = "Shape Transformation Puzzle"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 65, 22, @types.color_text_dim)
  // Instructions
  let inst = "Transform shapes to match targets. Minimize cost."
  let inst_w = @draw.measure_text(inst, 16)
  @draw.draw_text(inst, (w - inst_w) / 2, h / 2 + 20, 16, @types.color_text_dim)
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 28)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 80 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    28,
    @raylib.Color::new(60, 200, 255, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Title
  let title = "SELECT TIER"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    60,
    40,
    @types.color_text,
  )
  let tiers : Array[@types.Tier] = [Morph, Sculpt, Transform]
  let tier_descs = [
    "Shift + Rotate",
    "+ Flip + Grow",
    "+ Shrink (Full Kit)",
  ]
  let tier_counts = [
    @types.morph_levels, @types.sculpt_levels, @types.transform_levels,
  ]
  for i in 0..<tiers.length() {
    let box_x = w / 2 - 200
    let box_y = 160 + i * 160
    let box_w = 400
    let box_h = 130
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovered = mx >= box_x && mx < box_x + box_w && my >= box_y &&
      my < box_y + box_h
    // Check if tier is unlocked (previous tier must have at least 1 star on all levels)
    let unlocked = is_tier_unlocked(game, tiers[i])
    let bg_color = if !unlocked {
      @types.color_op_disabled
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_op_bg
    }
    @raylib.draw_rectangle(box_x, box_y, box_w, box_h, bg_color)
    @raylib.draw_rectangle_lines(
      box_x,
      box_y,
      box_w,
      box_h,
      @types.tier_color(tiers[i]),
    )
    // Tier name
    let tname = @types.tier_name(tiers[i])
    let tname_w = @draw.measure_text(tname, 32)
    @draw.draw_text(
      tname,
      box_x + (box_w - tname_w) / 2,
      box_y + 15,
      32,
      @types.tier_color(tiers[i]),
    )
    // Description
    let desc = tier_descs[i]
    let desc_w = @draw.measure_text(desc, 16)
    @draw.draw_text(
      desc,
      box_x + (box_w - desc_w) / 2,
      box_y + 55,
      16,
      @types.color_text_dim,
    )
    // Level count + stars earned
    let start = @types.tier_start_index(tiers[i])
    let count = tier_counts[i]
    let mut stars_earned = 0
    let mut completed_count = 0
    for j in 0..<count {
      if game.level_scores[start + j].completed {
        completed_count = completed_count + 1
      }
      stars_earned = stars_earned + @types.star_count(
          game.level_scores[start + j].stars,
        )
    }
    let info_str = completed_count.to_string() +
      "/" +
      count.to_string() +
      " levels  " +
      stars_earned.to_string() +
      "/" +
      (count * 3).to_string() +
      " stars"
    let info_w = @draw.measure_text(info_str, 14)
    @draw.draw_text(
      info_str,
      box_x + (box_w - info_w) / 2,
      box_y + 85,
      14,
      @types.color_text_dim,
    )
    if !unlocked {
      let lock = "LOCKED"
      let lock_w = @draw.measure_text(lock, 18)
      @draw.draw_text(
        lock,
        box_x + (box_w - lock_w) / 2,
        box_y + 105,
        18,
        @raylib.Color::new(255, 80, 80, 200),
      )
    }
  }
  // Back
  @draw.draw_text("ESC - Back", 20, h - 35, 14, @types.color_text_dim)
}

///|
fn is_tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Morph => true
    Sculpt => {
      // Need at least 4 Morph levels completed
      let start = @types.tier_start_index(Morph)
      let mut count = 0
      for i in 0..<@types.morph_levels {
        if game.level_scores[start + i].completed {
          count = count + 1
        }
      }
      count >= 4
    }
    Transform => {
      // Need at least 5 Sculpt levels completed
      let start = @types.tier_start_index(Sculpt)
      let mut count = 0
      for i in 0..<@types.sculpt_levels {
        if game.level_scores[start + i].completed {
          count = count + 1
        }
      }
      count >= 5
    }
  }
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier = game.current_tier
  let start = @types.tier_start_index(tier)
  let count = @types.tier_level_count(tier)
  // Title
  let title = @types.tier_name(tier) + " - Select Level"
  let title_w = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    40,
    36,
    @types.tier_color(tier),
  )
  // Level grid (4 columns)
  let cols = 4
  let box_size = 120
  let gap = 20
  let grid_w = cols * box_size + (cols - 1) * gap
  let base_x = (w - grid_w) / 2
  let base_y = 110
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let bx = base_x + col * (box_size + gap)
    let by = base_y + row * (box_size + gap + 20)
    let hovered = mx >= bx && mx < bx + box_size && my >= by &&
      my < by + box_size
    let score = game.level_scores[start + i]
    let bg = if hovered {
      @types.color_button_hover
    } else if score.completed {
      @raylib.Color::new(40, 60, 50, 230)
    } else {
      @types.color_op_bg
    }
    @raylib.draw_rectangle(bx, by, box_size, box_size, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      box_size,
      box_size,
      if score.completed {
        @types.color_target
      } else {
        @types.color_grid_line
      },
    )
    // Level number
    let num_str = (i + 1).to_string()
    let num_w = @draw.measure_text(num_str, 28)
    @draw.draw_text(
      num_str,
      bx + (box_size - num_w) / 2,
      by + 10,
      28,
      @types.color_text,
    )
    // Stars
    let stars = @types.star_count(score.stars)
    for si in 0..<3 {
      let star_x = bx + 20 + si * 30
      let star_y = by + 50
      let star_color = if si < stars {
        @types.color_gold
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", star_x, star_y, 24, star_color)
    }
    // Best cost if completed
    if score.completed {
      let cost_str = "Cost: " + score.best_cost.to_string()
      let cost_w = @draw.measure_text(cost_str, 12)
      @draw.draw_text(
        cost_str,
        bx + (box_size - cost_w) / 2,
        by + 85,
        12,
        @types.color_text_dim,
      )
    }
  }
  @draw.draw_text(
    "ESC - Back",
    20,
    @types.screen_height - 35,
    14,
    @types.color_text_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 160))
  // Result box
  let box_w = 500
  let box_h = 400
  let box_x = (w - box_w) / 2
  let box_y = (h - box_h) / 2
  @raylib.draw_rectangle(
    box_x,
    box_y,
    box_w,
    box_h,
    @raylib.Color::new(30, 32, 48, 245),
  )
  @raylib.draw_rectangle_lines(box_x, box_y, box_w, box_h, @types.color_accent)
  // Title
  let result_title = "LEVEL COMPLETE!"
  let rt_w = @draw.measure_text(result_title, 36)
  @draw.draw_text(
    result_title,
    box_x + (box_w - rt_w) / 2,
    box_y + 30,
    36,
    @types.color_gold,
  )
  // Cost
  let cost_str = "Total Cost: " + game.total_cost.to_string()
  let cost_w = @draw.measure_text(cost_str, 24)
  @draw.draw_text(
    cost_str,
    box_x + (box_w - cost_w) / 2,
    box_y + 90,
    24,
    @types.color_text,
  )
  // Par info
  let level_idx = game.current_level_idx
  let score = game.level_scores[level_idx]
  let par_str = "Par: " +
    score.best_cost.to_string() +
    " (your best)"
  let par_w = @draw.measure_text(par_str, 18)
  @draw.draw_text(
    par_str,
    box_x + (box_w - par_w) / 2,
    box_y + 130,
    18,
    @types.color_text_dim,
  )
  // Stars
  let stars = @types.star_count(score.stars)
  let star_base_x = box_x + box_w / 2 - 60
  for i in 0..<3 {
    let sx = star_base_x + i * 45
    let sy = box_y + 180
    let star_color = if i < stars {
      @types.color_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, sy, 40, star_color)
  }
  // Star explanation
  let star_info = match score.stars {
    Zero => "Keep trying!"
    One => "Completed!"
    Two => "Within par!"
    Three => "Perfect!"
  }
  let si_w = @draw.measure_text(star_info, 20)
  @draw.draw_text(
    star_info,
    box_x + (box_w - si_w) / 2,
    box_y + 240,
    20,
    @types.color_accent,
  )
  // Options
  let next_text = "ENTER - Next Level"
  let next_w = @draw.measure_text(next_text, 18)
  @draw.draw_text(
    next_text,
    box_x + (box_w - next_w) / 2,
    box_y + 300,
    18,
    @types.color_text,
  )
  let retry_text = "R - Retry    ESC - Level Select"
  let retry_w = @draw.measure_text(retry_text, 16)
  @draw.draw_text(
    retry_text,
    box_x + (box_w - retry_w) / 2,
    box_y + 340,
    16,
    @types.color_text_dim,
  )
}
