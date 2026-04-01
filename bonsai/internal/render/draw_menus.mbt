///|
fn draw_title(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let time = game.anim_timer
  // Dark nature background
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(25, 22, 18, 255))
  // Animated decorative tree in center
  draw_title_tree(sw / 2, sh / 2 + 40, time)
  // Title text
  let title = "BONSAI"
  let title_size = 64
  let tw = @draw.measure_text(title, title_size)
  let pulse_val = @types.sinf(time * 1.5) * 0.1 + 0.9
  let alpha = (pulse_val * 255.0).to_int()
  let title_color = @raylib.Color::new(60, 200, 90, alpha)
  @draw.draw_text(title, (sw - tw) / 2, 80, title_size, title_color)
  // Subtitle
  let sub = "A Tree Pruning Puzzle"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(
    sub,
    (sw - sub_w) / 2,
    155,
    22,
    @raylib.Color::new(180, 170, 150, 200),
  )
  // Start prompt
  let pulse2 = @types.sinf(time * 3.0) * 0.3 + 0.7
  let alpha2 = (pulse2 * 255.0).to_int()
  let start = "Press SPACE or CLICK to start"
  let start_w = @draw.measure_text(start, 24)
  @draw.draw_text(
    start,
    (sw - start_w) / 2,
    sh - 100,
    24,
    @raylib.Color::new(200, 190, 170, alpha2),
  )
}

///|
fn draw_title_tree(cx : Int, cy : Int, time : Float) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Trunk
  @raylib.draw_rectangle(cx - 6, cy - 20, 12, 120, @types.color_trunk)
  // Animated branches
  let branch_count = 7
  for i in 0..<branch_count {
    let fi = Float::from_int(i)
    let angle : Float = fi * 0.9 - 3.0 + @types.sinf(time + fi) * 0.15
    let len : Float = 40.0 + fi * 12.0
    let branch_y : Float = fcy - 20.0 - fi * 18.0
    let ex : Float = fcx + @types.cosf(angle) * len
    let ey : Float = branch_y + @types.sinf(angle) * len * 0.5
    let side : Float = if i % 2 == 0 { 1.0 } else { -1.0 }
    let bx : Float = fcx + side * (10.0 + fi * 5.0)
    @raylib.draw_line(
      bx.to_int(),
      branch_y.to_int(),
      ex.to_int(),
      ey.to_int(),
      @types.color_branch_pine,
    )
    // Leaf at tip
    let leaf_pulse = @types.sinf(time * 2.0 + fi * 1.5) * 3.0 + 10.0
    @raylib.draw_circle(
      ex.to_int(),
      ey.to_int(),
      leaf_pulse,
      @raylib.Color::new(
        ((180.0 : Float) + fi * 10.0).to_int(),
        ((120.0 : Float) + fi * 15.0).to_int(),
        ((140.0 : Float) + fi * 8.0).to_int(),
        180,
      ),
    )
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let _ = @types.screen_height
  // Title
  let title = "Select a Grove"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (sw - tw) / 2, 80, 40, @types.color_title)
  // Tier buttons
  let tiers : Array[@types.Tier] = [Tier1, Tier2, Tier3]
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<3 {
    let tier = tiers[i]
    let by = 250 + i * 100
    let bx = 440
    let bw = 400
    let bh = 70
    let unlocked = is_tier_unlocked(game, tier)
    let hovered = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
    let bg_color = if !unlocked {
      @types.color_locked
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg_color)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      bw,
      bh,
      @raylib.Color::new(120, 110, 90, 200),
    )
    // Tier name
    let name = @types.tier_name(tier)
    let label = if unlocked { name } else { name + " (Locked)" }
    let lw = @draw.measure_text(label, 26)
    let text_color = if unlocked {
      @raylib.Color::new(240, 235, 220, 255)
    } else {
      @raylib.Color::new(140, 130, 120, 200)
    }
    @draw.draw_text(label, bx + (bw - lw) / 2, by + 12, 26, text_color)
    // Star count for this tier
    let offset = @types.tier_level_offset(tier)
    let count = @types.tier_level_count(tier)
    let mut total_stars = 0
    let max_stars = count * 3
    for j in 0..<count {
      total_stars = total_stars + game.scores[offset + j].stars
    }
    let star_str = total_stars.to_string() +
      " / " +
      max_stars.to_string() +
      " stars"
    let sw2 = @draw.measure_text(star_str, 18)
    @draw.draw_text(
      star_str,
      bx + (bw - sw2) / 2,
      by + 44,
      18,
      @types.color_star_on,
    )
  }
  // Back hint
  @draw.draw_text(
    "ESC to go back",
    20,
    @types.screen_height - 40,
    18,
    @raylib.Color::new(150, 140, 130, 180),
  )
}

///|
fn is_tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Tier1 => true
    Tier2 => {
      let mut stars = 0
      for i in 0..<8 {
        stars = stars + game.scores[i].stars
      }
      stars >= 4
    }
    Tier3 => {
      let mut stars = 0
      for i in 8..<17 {
        stars = stars + game.scores[i].stars
      }
      stars >= 4
    }
  }
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  // Title
  let title = @types.tier_name(game.current_tier)
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (sw - tw) / 2, 60, 36, @types.color_title)
  // Subtitle
  let species = @types.tier_species(game.current_tier)
  let sub = "Species: " + @types.species_name(species)
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (sw - sub_w) / 2, 105, 22, @types.color_hud_text)
  // Level buttons
  let offset = @types.tier_level_offset(game.current_tier)
  let count = @types.tier_level_count(game.current_tier)
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<count {
    let col = i % 4
    let row = i / 4
    let bx = 240 + col * 200
    let by = 220 + row * 120
    let bw = 160
    let bh = 90
    let level_idx = offset + i
    let unlocked = is_level_unlocked(game, level_idx)
    let hovered = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
    let bg_color = if !unlocked {
      @types.color_locked
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg_color)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      bw,
      bh,
      @raylib.Color::new(120, 110, 90, 200),
    )
    // Level number
    let num = (i + 1).to_string()
    let num_w = @draw.measure_text(num, 28)
    let text_color = if unlocked {
      @raylib.Color::new(240, 235, 220, 255)
    } else {
      @raylib.Color::new(140, 130, 120, 200)
    }
    @draw.draw_text(num, bx + (bw - num_w) / 2, by + 10, 28, text_color)
    // Stars
    let score = game.scores[level_idx]
    for s in 0..<3 {
      let star_x = bx + bw / 2 - 30 + s * 25
      let star_y = by + 55
      let color = if s < score.stars {
        @types.color_star_on
      } else {
        @types.color_star_off
      }
      draw_star(star_x, star_y, 8.0, color)
    }
  }
  // Back hint
  @draw.draw_text(
    "ESC to go back",
    20,
    @types.screen_height - 40,
    18,
    @raylib.Color::new(150, 140, 130, 180),
  )
}

///|
fn is_level_unlocked(game : @types.Game, index : Int) -> Bool {
  if index == 0 {
    return true
  }
  let offset = @types.tier_level_offset(game.current_tier)
  if index == offset {
    return is_tier_unlocked(game, game.current_tier)
  }
  game.scores[index - 1].completed
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  match game.current_level {
    None => ()
    Some(level) => {
      // Background
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(30, 26, 22, 255))
      // Title
      let won = game.play_state == Won
      let title = if won { "Level Complete!" } else { "Try Again" }
      let tw = @draw.measure_text(title, 44)
      let title_color = if won {
        @types.color_title
      } else {
        @raylib.Color::new(200, 60, 40, 255)
      }
      @draw.draw_text(title, (sw - tw) / 2, 80, 44, title_color)
      // Stars
      let stars = game.scores[game.selected_level].stars
      for i in 0..<3 {
        let star_x = sw / 2 - 70 + i * 60
        let star_y = 170
        let color = if i < stars {
          @types.color_star_on
        } else {
          @types.color_star_off
        }
        draw_star(star_x, star_y, 24.0, color)
      }
      // Stats
      let mut ty = 240
      @draw.draw_text(
        "Species: " + @types.species_name(level.species),
        sw / 2 - 120,
        ty,
        22,
        @types.color_hud_text,
      )
      ty = ty + 35
      @draw.draw_text(
        "Turns Used: " +
        game.turn.to_string() +
        " / " +
        level.max_turns.to_string(),
        sw / 2 - 120,
        ty,
        22,
        @types.color_hud_text,
      )
      ty = ty + 35
      let par_color = if game.total_prunes <= level.par_prunes {
        @raylib.Color::new(50, 200, 80, 255)
      } else {
        @raylib.Color::new(200, 150, 50, 255)
      }
      @draw.draw_text(
        "Total Prunes: " +
        game.total_prunes.to_string() +
        " (par: " +
        level.par_prunes.to_string() +
        ")",
        sw / 2 - 120,
        ty,
        22,
        par_color,
      )
      ty = ty + 35
      // Zone results
      let (req_ok, forb_ok, tip_ok) = @growth.check_zones(
        game.tree,
        level.zones,
      )
      let ok_color = @raylib.Color::new(50, 200, 80, 255)
      let fail_color = @raylib.Color::new(200, 50, 50, 255)
      @draw.draw_text(
        "Required Zones: " + (if req_ok { "Filled" } else { "Missing" }),
        sw / 2 - 120,
        ty,
        22,
        if req_ok {
          ok_color
        } else {
          fail_color
        },
      )
      ty = ty + 30
      @draw.draw_text(
        "Forbidden Zones: " + (if forb_ok { "Clear" } else { "Violated" }),
        sw / 2 - 120,
        ty,
        22,
        if forb_ok {
          ok_color
        } else {
          fail_color
        },
      )
      ty = ty + 30
      @draw.draw_text(
        "Tip Targets: " + (if tip_ok { "Hit" } else { "Missed" }),
        sw / 2 - 120,
        ty,
        22,
        if tip_ok {
          ok_color
        } else {
          fail_color
        },
      )
      ty = ty + 50
      // Actions
      @draw.draw_text(
        "R - Retry    SPACE - Continue",
        sw / 2 - 140,
        ty,
        22,
        @types.color_hud_text,
      )
    }
  }
}
