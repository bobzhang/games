///|
pub fn draw_title_screen(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  let title = "TERRARIUM"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(title, cx - tw / 2, 120, 48, @types.color_title)
  let sub = "Closed Ecosystem Balance Puzzle"
  let sw = @draw.measure_text(sub, 20)
  @draw.draw_text(sub, cx - sw / 2, 180, 20, @types.color_subtitle)
  let desc1 = "Build a self-sustaining terrarium"
  let d1w = @draw.measure_text(desc1, 16)
  @draw.draw_text(desc1, cx - d1w / 2, 240, 16, @types.color_hud_dim)
  let desc2 = "Place organisms to balance resources"
  let d2w = @draw.measure_text(desc2, 16)
  @draw.draw_text(desc2, cx - d2w / 2, 262, 16, @types.color_hud_dim)
  let desc3 = "Survive 10 turns to win!"
  let d3w = @draw.measure_text(desc3, 16)
  @draw.draw_text(desc3, cx - d3w / 2, 284, 16, @types.color_hud_dim)
  draw_jar_preview(cx, 380, game.frame_count)
  let btn_text = "PLAY"
  let btn_w = 160
  let btn_h = 50
  let btn_x = cx - btn_w / 2
  let btn_y = 520
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hover = mx >= btn_x &&
    mx <= btn_x + btn_w &&
    my >= btn_y &&
    my <= btn_y + btn_h
  let btn_color = if hover {
    @types.color_button_hover
  } else {
    @types.color_button
  }
  @raylib.draw_rectangle_rounded(
    rect(btn_x, btn_y, btn_w, btn_h),
    0.3,
    6,
    btn_color,
  )
  let btw = @draw.measure_text(btn_text, 24)
  @draw.draw_text(
    btn_text,
    btn_x + btn_w / 2 - btw / 2,
    btn_y + 13,
    24,
    @types.color_hud_text,
  )
  let stars = @types.total_stars(game.scores)
  if stars > 0 {
    let star_text = "Stars: " +
      stars.to_string() +
      " / " +
      (@types.total_levels * 3).to_string()
    let stw = @draw.measure_text(star_text, 16)
    @draw.draw_text(star_text, cx - stw / 2, 590, 16, @types.color_star)
  }
  let ctrl = "[Click PLAY or press ENTER]"
  let cw = @draw.measure_text(ctrl, 14)
  @draw.draw_text(ctrl, cx - cw / 2, 630, 14, @types.color_hud_dim)
}

///|
fn draw_jar_preview(cx : Int, cy : Int, frame : Int) -> Unit {
  let jar_w = 100
  let jar_h = 80
  @raylib.draw_rectangle_rounded(
    rect(cx - jar_w / 2, cy - jar_h / 2, jar_w, jar_h),
    0.1,
    6,
    @types.color_jar,
  )
  @raylib.draw_rectangle_rounded_lines_ex(
    rect(cx - jar_w / 2, cy - jar_h / 2, jar_w, jar_h),
    0.1,
    6,
    1.5,
    @types.color_jar_border,
  )
  let bob = frame / 30 % 2
  @raylib.draw_circle(cx - 20, cy + 10, 8.0, @types.color_moss)
  @raylib.draw_circle(cx + 15, cy + 5, 6.0, @types.color_fern)
  @raylib.draw_circle(cx + 5, cy - 5 - bob, 5.0, @types.color_beetle)
  @raylib.draw_circle(cx - 10, cy + 20, 4.0, @types.color_fungus)
}

///|
fn truncate_string(s : String, max_len : Int) -> String {
  if s.length() > max_len {
    let mut result = ""
    let mut count = 0
    for ch in s {
      if count >= max_len {
        break
      }
      result = result + ch.to_string()
      count += 1
    }
    result
  } else {
    s
  }
}

///|
pub fn draw_level_select(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  @draw.draw_text("Select Level", cx - 80, 30, 28, @types.color_title)
  let tier_names = ["Beginner", "Intermediate", "Advanced"]
  let tier_colors = [@types.color_tier1, @types.color_tier2, @types.color_tier3]
  let tier_starts = [0, 7, 14]
  let tier_counts = [7, 7, 6]
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for t in 0..<3 {
    let ty = 80 + t * 210
    @draw.draw_text(tier_names[t], 40, ty, 22, tier_colors[t])
    for i in 0..<tier_counts[t] {
      let level_id = tier_starts[t] + i
      let level = @levels.get_level(level_id)
      let bx = 40 + i * 170
      let by = ty + 30
      let bw = 155
      let bh = 155
      let unlocked = @types.is_level_unlocked(game.scores, level_id)
      let hover = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
      let bg_color = if !unlocked {
        @types.color_locked
      } else if hover {
        @types.color_button_hover
      } else {
        @types.color_button
      }
      @raylib.draw_rectangle_rounded(rect(bx, by, bw, bh), 0.1, 4, bg_color)
      let num_str = (level_id + 1).to_string()
      @draw.draw_text(num_str, bx + 8, by + 6, 20, @types.color_hud_text)
      if unlocked {
        let nw = truncate_string(level.name, 14)
        @draw.draw_text(nw, bx + 8, by + 30, 13, @types.color_subtitle)
        let score = game.scores[level_id]
        if score.completed {
          @draw.draw_text("DONE", bx + 8, by + 50, 12, @types.color_ok)
          draw_stars_small(bx + 8, by + 66, score.stars)
        }
        let orgs = level.available_organisms.length().to_string() + " types"
        @draw.draw_text(orgs, bx + 8, by + 85, 11, @types.color_hud_dim)
        let desc_short = truncate_string(level.description, 20) + ".."
        @draw.draw_text(desc_short, bx + 8, by + 100, 10, @types.color_hud_dim)
      } else {
        @draw.draw_text("LOCKED", bx + 8, by + 50, 14, @types.color_hud_dim)
      }
    }
  }
  let back = "[ESC] Back"
  @draw.draw_text(back, 40, @types.screen_height - 35, 16, @types.color_hud_dim)
}

///|
fn draw_stars_small(x : Int, y : Int, count : Int) -> Unit {
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star
    } else {
      @types.color_star_off
    }
    @draw.draw_text("*", x + i * 14, y, 14, color)
  }
}

///|
pub fn draw_playing_screen(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      @draw.draw_text(
        "Level " + (level.id + 1).to_string() + ": " + level.name,
        @types.grid_offset_x,
        20,
        24,
        @types.color_title,
      )
      let tier_col = @types.tier_color(level.tier)
      @draw.draw_text(
        @types.tier_name(level.tier),
        @types.grid_offset_x,
        48,
        14,
        tier_col,
      )
      let desc_y = 68
      @draw.draw_text(
        level.description,
        @types.grid_offset_x,
        desc_y,
        14,
        @types.color_hud_dim,
      )
      @draw.draw_text(
        "Goal: Sustain all organisms for " +
        @types.max_turns.to_string() +
        " turns",
        @types.grid_offset_x,
        desc_y + 18,
        13,
        @types.color_subtitle,
      )
    }
  }
  draw_jar_background()
  draw_grid_cells(game)
  draw_hover_highlight(game)
  draw_palette(game)
  draw_resource_bars(game)
  draw_turn_info(game)
  draw_message(game)
  let controls_y = @types.screen_height - 50
  @draw.draw_text(
    "[Click] Place  [Right-Click] Remove  [SPACE] Simulate  [R] Reset  [ESC] Back",
    20, controls_y, 14, @types.color_hud_dim,
  )
}

///|
pub fn draw_simulating_screen(game : @types.Game) -> Unit {
  draw_playing_screen(game)
  let cx = @types.screen_width / 2
  let banner_y = @types.screen_height / 2 - 20
  @raylib.draw_rectangle(
    0,
    banner_y - 5,
    @types.screen_width,
    30,
    @types.color_bg,
  )
  let sim_text = "Simulating Turn " + game.current_turn.to_string() + "..."
  let stw = @draw.measure_text(sim_text, 22)
  @draw.draw_text(sim_text, cx - stw / 2, banner_y, 22, @types.color_title)
  draw_sim_log(game)
}

///|
pub fn draw_results_screen(game : @types.Game) -> Unit {
  draw_playing_screen(game)
  let cx = @types.screen_width / 2
  let overlay_y = 200
  let overlay_h = 320
  @raylib.draw_rectangle(cx - 220, overlay_y, 440, overlay_h, @types.color_bg)
  @raylib.draw_rectangle_lines(
    cx - 220,
    overlay_y,
    440,
    overlay_h,
    @types.color_jar_border,
  )
  let result_text = match game.play_result {
    Victory => "VICTORY!"
    Failure(msg) => msg
    None => ""
  }
  let result_color = match game.play_result {
    Victory => @types.color_ok
    _ => @types.color_warn
  }
  let rtw = @draw.measure_text(result_text, 28)
  @draw.draw_text(result_text, cx - rtw / 2, overlay_y + 20, 28, result_color)
  let turns_text = "Turns survived: " +
    game.current_turn.to_string() +
    " / " +
    @types.max_turns.to_string()
  let ttw = @draw.measure_text(turns_text, 18)
  @draw.draw_text(
    turns_text,
    cx - ttw / 2,
    overlay_y + 60,
    18,
    @types.color_hud_text,
  )
  match game.current_level {
    Some(level) => {
      let stars = game.scores[level.id].stars
      draw_stars_large(cx - 42, overlay_y + 100, stars)
    }
    _ => ()
  }
  let btn_w = 140
  let btn_h = 40
  let retry_x = cx - btn_w - 20
  let next_x = cx + 20
  let btn_y = overlay_y + overlay_h - 70
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let retry_hover = mx >= retry_x &&
    mx <= retry_x + btn_w &&
    my >= btn_y &&
    my <= btn_y + btn_h
  @raylib.draw_rectangle_rounded(
    rect(retry_x, btn_y, btn_w, btn_h),
    0.2,
    4,
    if retry_hover {
      @types.color_button_hover
    } else {
      @types.color_button
    },
  )
  let rw = @draw.measure_text("RETRY", 20)
  @draw.draw_text(
    "RETRY",
    retry_x + btn_w / 2 - rw / 2,
    btn_y + 10,
    20,
    @types.color_hud_text,
  )
  let is_victory = game.play_result == Victory
  if is_victory {
    let next_hover = mx >= next_x &&
      mx <= next_x + btn_w &&
      my >= btn_y &&
      my <= btn_y + btn_h
    @raylib.draw_rectangle_rounded(
      rect(next_x, btn_y, btn_w, btn_h),
      0.2,
      4,
      if next_hover {
        @types.color_button_hover
      } else {
        @types.color_button
      },
    )
    let nw = @draw.measure_text("NEXT", 20)
    @draw.draw_text(
      "NEXT",
      next_x + btn_w / 2 - nw / 2,
      btn_y + 10,
      20,
      @types.color_hud_text,
    )
  }
}

///|
fn draw_stars_large(x : Int, y : Int, count : Int) -> Unit {
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star
    } else {
      @types.color_star_off
    }
    @draw.draw_text("*", x + i * 30, y, 28, color)
  }
}
