///|
pub fn draw_title_screen(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @types.color_bg,
  )
  let title = "TIDE POOL"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    120,
    48,
    @types.color_title,
  )
  let sub = "A Tidal Ecology Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    @types.screen_width / 2 - sw / 2,
    185,
    24,
    @types.color_subtitle,
  )
  draw_wave_decoration(game, 260)
  let desc1 = "Manage a tide pool ecosystem across tidal cycles."
  let dw1 = @draw.measure_text(desc1, 16)
  @draw.draw_text(
    desc1,
    @types.screen_width / 2 - dw1 / 2,
    340,
    16,
    @types.color_hud_dim,
  )
  let desc2 = "Place organisms that thrive at different tide levels."
  let dw2 = @draw.measure_text(desc2, 16)
  @draw.draw_text(
    desc2,
    @types.screen_width / 2 - dw2 / 2,
    365,
    16,
    @types.color_hud_dim,
  )
  let desc3 = "Balance the ecosystem across 3 full tide cycles."
  let dw3 = @draw.measure_text(desc3, 16)
  @draw.draw_text(
    desc3,
    @types.screen_width / 2 - dw3 / 2,
    390,
    16,
    @types.color_hud_dim,
  )
  draw_button(
    "START",
    @types.screen_width / 2 - 80,
    460,
    160,
    45,
    game,
  )
  let stars = @types.total_stars(game.scores)
  let completed = @types.levels_completed(game.scores)
  if completed > 0 {
    let stat = "Completed: \{completed}/\{@types.total_levels}  Stars: \{stars}"
    let stw = @draw.measure_text(stat, 14)
    @draw.draw_text(
      stat,
      @types.screen_width / 2 - stw / 2,
      530,
      14,
      @types.color_hud_dim,
    )
  }
}

///|
fn draw_wave_decoration(game : @types.Game, y : Int) -> Unit {
  let frame = game.frame_count
  let wave_count = @types.screen_width / 4
  for i in 0..<wave_count {
    let x = i * 4
    let wave_offset = (frame + i * 3) % 60
    let wave_y = if wave_offset < 30 { wave_offset / 3 } else { (60 - wave_offset) / 3 }
    @raylib.draw_rectangle(
      x,
      y + wave_y,
      3,
      2,
      @types.color_water_surface,
    )
  }
}

///|
pub fn draw_level_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @types.color_bg,
  )
  let title = "SELECT LEVEL"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    30,
    32,
    @types.color_title,
  )
  let cols = 5
  let btn_w = 200
  let btn_h = 70
  let gap = 12
  let start_x = (@types.screen_width - cols * (btn_w + gap)) / 2
  let start_y = 80
  for i in 0..< @types.total_levels {
    let row = i / cols
    let col = i % cols
    let x = start_x + col * (btn_w + gap)
    let y = start_y + row * (btn_h + gap)
    let level = @levels.get_level(i)
    let unlocked = @types.is_level_unlocked(game.scores, i)
    let bg = if unlocked {
      @types.tier_color(level.tier)
    } else {
      @types.color_locked
    }
    let r = bg.r.to_int()
    let g = bg.g.to_int()
    let b = bg.b.to_int()
    let dimmed = @raylib.Color::new(r / 3, g / 3, b / 3, 255)
    @raylib.draw_rectangle(x, y, btn_w, btn_h, dimmed)
    @raylib.draw_rectangle_lines(x, y, btn_w, btn_h, bg)
    @draw.draw_text(
      "\{i + 1}. \{level.name}",
      x + 8,
      y + 6,
      13,
      if unlocked { @types.color_hud_text } else { @types.color_locked },
    )
    if unlocked {
      let tier_text = @types.tier_name(level.tier)
      @draw.draw_text(tier_text, x + 8, y + 24, 11, bg)
      let score = game.scores[i]
      if score.completed {
        for s in 0..<3 {
          let star_x = x + 8 + s * 18
          let star_y = y + 42
          let star_color = if s < score.stars {
            @types.color_star
          } else {
            @types.color_star_off
          }
          @draw.draw_text("*", star_x, star_y, 18, star_color)
        }
      }
    } else {
      @draw.draw_text("LOCKED", x + 8, y + 28, 12, @types.color_locked)
    }
  }
  draw_button(
    "BACK",
    @types.screen_width / 2 - 60,
    @types.screen_height - 50,
    120,
    36,
    game,
  )
}

///|
pub fn draw_results_screen(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @types.color_bg,
  )
  let result_text = match game.play_result {
    Victory => "ECOSYSTEM THRIVES!"
    Failure(msg) => "ECOSYSTEM COLLAPSED: \{msg}"
    None => "SIMULATION ENDED"
  }
  let is_victory = game.play_result == Victory
  let color = if is_victory { @types.color_ok } else { @types.color_warn }
  let tw = @draw.measure_text(result_text, 28)
  let max_w = @types.screen_width - 40
  let font_size = if tw > max_w { 20 } else { 28 }
  let tw2 = @draw.measure_text(result_text, font_size)
  @draw.draw_text(
    result_text,
    @types.screen_width / 2 - tw2 / 2,
    100,
    font_size,
    color,
  )
  match game.current_level {
    None => ()
    Some(level) => {
      @draw.draw_text(
        "Level: \{level.name}",
        @types.screen_width / 2 - 100,
        160,
        20,
        @types.color_hud_text,
      )
      @draw.draw_text(
        "Cycles survived: \{game.current_cycle}/\{@types.total_cycles}",
        @types.screen_width / 2 - 100,
        190,
        18,
        @types.color_hud_dim,
      )
      @draw.draw_text(
        "Turns completed: \{game.current_turn}/\{@types.max_turns}",
        @types.screen_width / 2 - 100,
        215,
        18,
        @types.color_hud_dim,
      )
      if is_victory {
        let total_placed = game.organisms.length()
        let stars = @types.compute_stars(game.current_cycle, total_placed)
        @draw.draw_text("Stars earned:", @types.screen_width / 2 - 100, 250, 18, @types.color_hud_dim)
        for s in 0..<3 {
          let sx = @types.screen_width / 2 - 100 + 130 + s * 30
          let sc = if s < stars {
            @types.color_star
          } else {
            @types.color_star_off
          }
          @draw.draw_text("*", sx, 248, 28, sc)
        }
      }
    }
  }
  let log_y = 290
  @draw.draw_text("Turn Log:", 40, log_y, 16, @types.color_hud_text)
  let max_visible = 8
  let start = if game.sim_log.length() > max_visible {
    game.sim_log.length() - max_visible
  } else {
    0
  }
  for i = start; i < game.sim_log.length(); i = i + 1 {
    let log = game.sim_log[i]
    let ly = log_y + 22 + (i - start) * 44
    let phase_str = match log.phase {
      Low => "Low"
      Mid => "Mid"
      High => "High"
    }
    @draw.draw_text(
      "T\{log.turn + 1} [\{phase_str} lv\{log.tide_level}] Alive: \{log.organisms_alive}",
      50,
      ly,
      13,
      @types.color_hud_dim,
    )
    let mut evt_text = ""
    let max_events = if log.events.length() > 3 { 3 } else { log.events.length() }
    for j in 0..<max_events {
      if j > 0 {
        evt_text = evt_text + " | "
      }
      evt_text = evt_text + log.events[j]
    }
    if log.events.length() > 3 {
      evt_text = evt_text + " ..."
    }
    let max_len = 120
    let display_text = if evt_text.length() > max_len {
      let mut truncated = ""
      let mut chars = 0
      for c in evt_text {
        if chars >= max_len {
          break
        }
        truncated = truncated + c.to_string()
        chars += 1
      }
      truncated + "..."
    } else {
      evt_text
    }
    @draw.draw_text(display_text, 60, ly + 16, 11, @types.color_hud_dim)
  }
  let btn_y = @types.screen_height - 60
  draw_button("RETRY", @types.screen_width / 2 - 180, btn_y, 140, 40, game)
  draw_button(
    "LEVELS",
    @types.screen_width / 2 + 40,
    btn_y,
    140,
    40,
    game,
  )
}

///|
pub fn draw_button(
  text : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  _game : @types.Game
) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hovered = mx >= x && mx < x + w && my >= y && my < y + h
  let bg = if hovered {
    @types.color_button_hover
  } else {
    @types.color_button
  }
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines(x, y, w, h, @types.color_hud_text)
  let tw = @draw.measure_text(text, 18)
  @draw.draw_text(
    text,
    x + w / 2 - tw / 2,
    y + h / 2 - 9,
    18,
    @types.color_hud_text,
  )
}
