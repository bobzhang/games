///|
fn draw_hud(state : @types.LevelState, level_num : Int, frame : Int) -> Unit {
  // Left panel background
  @raylib.draw_rectangle(0, 0, 310, @types.screen_height, panel_bg)
  @raylib.draw_rectangle(310, 0, 2, @types.screen_height, panel_border)
  // Title
  let level_str = "Level \{level_num + 1}"
  @draw.draw_text(level_str, 20, 15, @types.title_font_size, text_bright)
  let tier_str = "Tier \{state.data.tier}"
  @draw.draw_text(tier_str, 20, 55, @types.info_font_size, text_dim)
  // Compass
  draw_compass(state, frame)
  // HP display
  draw_hp(state, 20, 350)
  // Steps
  let steps_str = "Steps: \{state.ship.steps}"
  @draw.draw_text(steps_str, 20, 420, @types.hud_font_size, text_bright)
  let par_str = "Par: \{state.data.par_steps}"
  @draw.draw_text(par_str, 20, 445, @types.info_font_size, text_dim)
  // Landmarks
  let lm_str = "Landmarks: \{state.ship.landmarks_found}/\{state.data.landmark_count}"
  @draw.draw_text(lm_str, 20, 480, @types.hud_font_size, text_bright)
  // Controls
  draw_controls(20, 530)
  // Message
  if state.message_timer > 0.0 {
    let msg_alpha = if state.message_timer < 1.0 {
      (state.message_timer * 255.0).to_int()
    } else {
      255
    }
    let msg_color = @raylib.Color::new(255, 255, 200, msg_alpha)
    let msg_x = @types.grid_offset_x + 10
    let msg_y = @types.grid_offset_y + @types.grid_rows * @types.tile_size + 15
    @draw.draw_text(state.message, msg_x, msg_y, 18, msg_color)
  }
  ignore(frame)
}

///|
fn draw_hp(state : @types.LevelState, x : Int, y : Int) -> Unit {
  @draw.draw_text("Hull:", x, y, @types.hud_font_size, text_bright)
  for i in 0..<@types.max_hp {
    let hx = x + 65 + i * 30
    let color = if i < state.ship.hp {
      if state.ship.hp == 1 {
        hp_crit
      } else if state.ship.hp == 2 {
        hp_warn
      } else {
        hp_full
      }
    } else {
      @raylib.Color::new(50, 50, 50, 200)
    }
    @raylib.draw_rectangle(hx, y + 2, 22, 18, color)
    @raylib.draw_rectangle_lines(hx, y + 2, 22, 18, panel_border)
  }
}

///|
fn draw_controls(x : Int, y : Int) -> Unit {
  @draw.draw_text("Controls:", x, y, @types.info_font_size, text_dim)
  @draw.draw_text("W - North", x + 10, y + 20, @types.info_font_size, text_dim)
  @draw.draw_text("S - South", x + 10, y + 38, @types.info_font_size, text_dim)
  @draw.draw_text("A - West", x + 10, y + 56, @types.info_font_size, text_dim)
  @draw.draw_text("D - East", x + 10, y + 74, @types.info_font_size, text_dim)
  @draw.draw_text(
    "R - Restart",
    x + 10,
    y + 96,
    @types.info_font_size,
    text_dim,
  )
  @draw.draw_text(
    "ESC - Menu",
    x + 10,
    y + 114,
    @types.info_font_size,
    text_dim,
  )
}

///|
fn draw_level_complete(state : @types.LevelState, frame : Int) -> Unit {
  // Overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  // Panel
  @raylib.draw_rectangle(cx - 180, cy - 120, 360, 240, panel_bg)
  @raylib.draw_rectangle_lines(cx - 180, cy - 120, 360, 240, panel_border)
  let pulse = @math.sinf(Float::from_int(frame) * 0.1) * 0.5 + 0.5
  let fval : Float = 200.0 + pulse * 55.0
  let title_alpha = fval.to_int()
  let title_color = @raylib.Color::new(255, 255, 100, title_alpha)
  @draw.draw_text("Lighthouse Found!", cx - 110, cy - 100, 24, title_color)
  let steps_str = "Steps: \{state.ship.steps} / Par: \{state.data.par_steps}"
  @draw.draw_text(steps_str, cx - 100, cy - 55, 18, text_bright)
  let lm_str = "Landmarks: \{state.ship.landmarks_found}/\{state.data.landmark_count}"
  @draw.draw_text(lm_str, cx - 80, cy - 30, 18, text_bright)
  // Stars
  let rating = @navigation.compute_star_rating(state)
  draw_star_display(cx, cy + 20, rating)
  @draw.draw_text("ENTER - Next Level", cx - 80, cy + 70, 16, text_dim)
  @draw.draw_text("ESC - Level Select", cx - 80, cy + 92, 16, text_dim)
}

///|
fn draw_game_over(frame : Int) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  @raylib.draw_rectangle(cx - 160, cy - 80, 320, 160, panel_bg)
  @raylib.draw_rectangle_lines(cx - 160, cy - 80, 320, 160, panel_border)
  let blink = frame % 40 < 20
  if blink {
    @draw.draw_text("SHIP SUNK!", cx - 70, cy - 50, 28, hp_crit)
  }
  @draw.draw_text("R - Retry", cx - 45, cy, 18, text_bright)
  @draw.draw_text("ESC - Menu", cx - 50, cy + 30, 18, text_dim)
}

///|
fn draw_star_display(cx : Int, cy : Int, rating : @types.StarRating) -> Unit {
  let count = @types.star_rating_value(rating)
  for i in 0..<3 {
    let sx = cx - 45 + i * 35
    let color = if i < count { star_gold } else { star_empty }
    @draw.draw_text("*", sx, cy, 28, color)
  }
}
