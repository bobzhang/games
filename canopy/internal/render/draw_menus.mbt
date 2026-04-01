///|
fn draw_title(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Sky background
  @raylib.draw_rectangle(0, 0, sw, sh, @types.color_sky)
  // Ground
  @raylib.draw_rectangle(0, sh - 120, sw, 120, @types.color_ground)
  // Animated growing tree in center
  let tree_x = sw / 2
  let tree_base = sh - 120
  let anim_height = (sinf(time * 0.5) * 40.0 + 160.0).to_int()
  // Trunk
  @raylib.draw_rectangle(
    tree_x - 8,
    tree_base - anim_height,
    16,
    anim_height,
    @types.color_trunk,
  )
  // Branches
  let branch_count = anim_height / 40
  for i in 0..<branch_count {
    let by = tree_base - 40 - i * 40
    let bw = 30 + i * 5
    let sway = sinf(time + Float::from_int(i) * 1.5) * 5.0
    // Left branch
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(tree_x), Float::from_int(by)),
      @raylib.Vector2::new(
        Float::from_int(tree_x - bw) + sway,
        Float::from_int(by - 10),
      ),
      3.0,
      @types.color_branch,
    )
    @raylib.draw_circle(
      (Float::from_int(tree_x - bw) + sway).to_int(),
      by - 10,
      18.0,
      @types.color_leaf,
    )
    // Right branch
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(tree_x), Float::from_int(by)),
      @raylib.Vector2::new(
        Float::from_int(tree_x + bw) - sway,
        Float::from_int(by - 10),
      ),
      3.0,
      @types.color_branch,
    )
    @raylib.draw_circle(
      (Float::from_int(tree_x + bw) - sway).to_int(),
      by - 10,
      18.0,
      @types.color_leaf,
    )
  }
  // Crown
  let crown_y = tree_base - anim_height - 20
  @raylib.draw_circle(tree_x, crown_y, 30.0, @types.color_leaf)
  @raylib.draw_circle(tree_x - 15, crown_y + 10, 22.0, @types.color_leaf_dark)
  @raylib.draw_circle(tree_x + 15, crown_y + 10, 22.0, @types.color_leaf_dark)
  // Sun
  let sun_pulse = sinf(time) * 5.0
  @raylib.draw_circle(
    sw - 150,
    100,
    Float::from_int((sun_pulse + 50.0).to_int()),
    @types.color_sun,
  )
  // Title text
  let title = "CANOPY"
  let tw = @draw.measure_text(title, 72)
  @draw.draw_text(title, (sw - tw) / 2, 60, 72, @types.color_title_green)
  // Subtitle
  let sub = "A Tree Growth Puzzle"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(
    sub,
    (sw - sub_w) / 2,
    140,
    22,
    @raylib.Color::new(60, 80, 60, 220),
  )
  // Start prompt
  let prompt = "Press ENTER to Start"
  let pw = @draw.measure_text(prompt, 24)
  let alpha = ((sinf(time * 2.0) * 0.3 + 0.7) * 255.0).to_int()
  @draw.draw_text(
    prompt,
    (sw - pw) / 2,
    sh - 60,
    24,
    @raylib.Color::new(220, 230, 220, alpha),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @types.color_bg)
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (sw - tw) / 2, 50, 36, @types.color_hud_text)
  let tiers = ["Seedling", "Grove", "Forest"]
  let tier_colors = [
    @types.color_tier_seedling, @types.color_tier_grove, @types.color_tier_forest,
  ]
  let descs = [
    "7 levels - Learn growth & water", "7 levels - Shadow competition", "6 levels - Dense forests & precision",
  ]
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<3 {
    let bx = sw / 2 - 160
    let by = 150 + i * 140
    let bw = 320
    let bh = 110
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, tier_colors[i])
    // Tier name
    let name_w = @draw.measure_text(tiers[i], 28)
    @draw.draw_text(
      tiers[i],
      bx + (bw - name_w) / 2,
      by + 15,
      28,
      tier_colors[i],
    )
    // Description
    let dw = @draw.measure_text(descs[i], 14)
    @draw.draw_text(
      descs[i],
      bx + (bw - dw) / 2,
      by + 50,
      14,
      @types.color_hud_text,
    )
    // Progress: count stars
    let tier_val : @types.Tier = match i {
      0 => Seedling
      1 => Grove
      _ => Forest
    }
    let tier_start = @levels.tier_start_level(tier_val)
    let tier_count = @levels.tier_level_count(tier_val)
    let mut total_stars = 0
    for j = tier_start; j < tier_start + tier_count; j = j + 1 {
      if j < game.level_scores.length() {
        total_stars += game.level_scores[j].stars
      }
    }
    let count = tier_count
    let prog = total_stars.to_string() +
      "/" +
      (count * 3).to_string() +
      " stars"
    let prog_w = @draw.measure_text(prog, 14)
    @draw.draw_text(
      prog,
      bx + (bw - prog_w) / 2,
      by + 75,
      14,
      @types.color_star_gold,
    )
  }
  // Back hint
  let hint = "ESC: Back to Title"
  @draw.draw_text(hint, 20, sh - 30, 14, @raylib.Color::new(150, 160, 170, 200))
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @types.color_bg)
  let tier : @types.Tier = match game.selected_tier {
    0 => Seedling
    1 => Grove
    _ => Forest
  }
  let tier_name = match tier {
    Seedling => "Seedling"
    Grove => "Grove"
    Forest => "Forest"
  }
  let title = tier_name + " Levels"
  let tw = @draw.measure_text(title, 30)
  @draw.draw_text(title, (sw - tw) / 2, 40, 30, @types.color_hud_text)
  let start = @levels.tier_start_level(tier)
  let count = @levels.tier_level_count(tier)
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let cols = 4
  let bw = 140
  let bh = 100
  let gap = 20
  let total_w = cols * bw + (cols - 1) * gap
  let base_x = (sw - total_w) / 2
  let base_y = 100
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let bx = base_x + col * (bw + gap)
    let by = base_y + row * (bh + gap)
    let level_idx = start + i
    let hover = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      bw,
      bh,
      @raylib.Color::new(120, 180, 120, 200),
    )
    // Level number
    let num = (i + 1).to_string()
    let nw = @draw.measure_text(num, 28)
    @draw.draw_text(num, bx + (bw - nw) / 2, by + 10, 28, @types.color_hud_text)
    // Stars
    if level_idx < game.level_scores.length() {
      let score = game.level_scores[level_idx]
      let star_y = by + 55
      for s in 0..<3 {
        let sx = bx + bw / 2 - 30 + s * 22
        let sc = if s < score.stars {
          @types.color_star_gold
        } else {
          @types.color_star_empty
        }
        @raylib.draw_circle(sx, star_y, 8.0, sc)
      }
      if score.completed {
        @draw.draw_text(
          "Done",
          bx + bw / 2 - 15,
          by + 75,
          12,
          @types.color_target_met,
        )
      }
    }
  }
  // Back hint
  let hint = "ESC: Back to Tiers"
  @draw.draw_text(hint, 20, sh - 30, 14, @raylib.Color::new(150, 160, 170, 200))
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @types.color_bg)
  let stars = if game.current_level < game.level_scores.length() {
    game.level_scores[game.current_level].stars
  } else {
    0
  }
  let title = if stars > 0 { "Level Complete!" } else { "Level Failed" }
  let tc = if stars > 0 {
    @types.color_target_met
  } else {
    @types.color_target_marker
  }
  let tw = @draw.measure_text(title, 42)
  @draw.draw_text(title, (sw - tw) / 2, 80, 42, tc)
  // Stars display
  draw_stars(stars, sw / 2, 180)
  // Stats
  let turn_str = "Turns used: " +
    game.turn.to_string() +
    " (par: " +
    game.par_turns.to_string() +
    ")"
  let turn_w = @draw.measure_text(turn_str, 20)
  @draw.draw_text(turn_str, (sw - turn_w) / 2, 240, 20, @types.color_hud_text)
  let prune_str = "Prunes used: " +
    game.prunes_used.to_string() +
    " (par: " +
    game.par_prunes.to_string() +
    ")"
  let prune_w = @draw.measure_text(prune_str, 20)
  @draw.draw_text(prune_str, (sw - prune_w) / 2, 275, 20, @types.color_hud_text)
  // Target summary
  @draw.draw_text("Targets:", sw / 2 - 80, 330, 18, @types.color_sun)
  for i in 0..<game.targets.length() {
    let target = game.targets[i]
    let met = @growth.target_met(game, i)
    let y = 360 + i * 28
    let tree_h = if target.tree_index >= 0 &&
      target.tree_index < game.trees.length() {
      game.trees[target.tree_index].height
    } else {
      0
    }
    let status = "Tree " +
      (target.tree_index + 1).to_string() +
      ": " +
      tree_h.to_string() +
      "/" +
      target.required_height.to_string()
    let sc = if met {
      @types.color_target_met
    } else {
      @types.color_target_marker
    }
    let status_w = @draw.measure_text(status, 16)
    @draw.draw_text(status, (sw - status_w) / 2, y, 16, sc)
  }
  // Navigation
  let next_y = sh - 100
  if stars > 0 && game.current_level < @types.total_levels - 1 {
    let next_str = "ENTER: Next Level"
    let nw = @draw.measure_text(next_str, 20)
    @draw.draw_text(
      next_str,
      (sw - nw) / 2,
      next_y,
      20,
      @types.color_target_met,
    )
  }
  let retry_str = "R: Retry | ESC: Level Select"
  let rw = @draw.measure_text(retry_str, 16)
  @draw.draw_text(
    retry_str,
    (sw - rw) / 2,
    next_y + 35,
    16,
    @types.color_hud_text,
  )
}
