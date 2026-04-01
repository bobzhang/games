///|
/// Draw the title screen
pub fn draw_title(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Animated background lines
  draw_cyber_background(game)
  // Title
  let title = "DRIFT PROTOCOL"
  let title_size = 48
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    sh / 4 - 20,
    title_size,
    @types.color_cyan,
  )
  // Subtitle
  let sub = "STEALTH HACKING INFILTRATION"
  let sub_size = 16
  let stw = @draw.measure_text(sub, sub_size)
  @draw.draw_text(
    sub,
    sw / 2 - stw / 2,
    sh / 4 + 40,
    sub_size,
    @types.color_neon_pink,
  )
  // Prompt
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.06) * 0.5 +
    0.5
  let alpha_f : Float = 180.0 * pulse
  let alpha = alpha_f.to_int() + 75
  let prompt = "PRESS ENTER TO BEGIN"
  let prompt_size = 20
  let ptw = @draw.measure_text(prompt, prompt_size)
  @draw.draw_text(
    prompt,
    sw / 2 - ptw / 2,
    sh * 3 / 4,
    prompt_size,
    @raylib.Color::new(0, 255, 220, alpha),
  )
  // Version
  @draw.draw_text("v1.0", 10, sh - 25, 14, @types.color_dim_text)
}

///|
fn draw_cyber_background(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Horizontal scan lines
  for i in 0..<(sh / 4) {
    let y = i * 4
    let alpha = 10 + (
      @types.sinf(Float::from_int(y + game.frame_count * 2) * 0.02) * 8.0
    ).to_int()
    @raylib.draw_line(
      0,
      y,
      sw,
      y,
      @raylib.Color::new(0, 255, 220, @types.clampi(alpha, 0, 255)),
    )
  }
  // Vertical accent lines
  let line_count = 8
  for i in 0..<line_count {
    let x = sw * (i + 1) / (line_count + 1)
    let offset = @types.sinf(
      Float::from_int(i * 37 + game.frame_count) * 0.03,
    )
    let alpha = 15 + (offset * 10.0).to_int()
    @raylib.draw_line(
      x,
      0,
      x,
      sh,
      @raylib.Color::new(255, 0, 128, @types.clampi(alpha, 0, 255)),
    )
  }
}

///|
/// Draw the level select screen
pub fn draw_level_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Background
  draw_cyber_background(game)
  // Title
  let title = "SELECT MISSION"
  let title_size = 32
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    40,
    title_size,
    @types.color_cyan,
  )
  // Level list
  let start_y = 100
  let item_h = 60
  for i in 0..<@types.total_levels {
    let y = start_y + i * item_h
    let selected = i == game.menu_selection
    let tier = if i < 4 { "CORPORATE" } else { "MILITARY" }
    let tier_col = if i < 4 {
      @types.color_neon_green
    } else {
      @types.color_neon_pink
    }
    // Selection highlight
    if selected {
      @raylib.draw_rectangle(
        sw / 4 - 10,
        y - 5,
        sw / 2 + 20,
        item_h - 5,
        @raylib.Color::new(0, 255, 220, 20),
      )
      @raylib.draw_rectangle_lines(
        sw / 4 - 10,
        y - 5,
        sw / 2 + 20,
        item_h - 5,
        @types.color_cyan,
      )
    }
    // Level name
    let name_str = "\{i + 1}. \{level_name_for(i)}"
    let name_color = if selected { @types.color_white } else { @types.color_hud_text }
    @draw.draw_text(name_str, sw / 4, y, 18, name_color)
    // Tier badge
    @draw.draw_text(tier, sw / 4, y + 22, 10, tier_col)
    // Score if completed
    match game.level_scores[i] {
      Some(s) => {
        let grade_str = grade_to_string(s.grade)
        let grade_col = @types.grade_color(s.grade)
        @draw.draw_text(grade_str, sw * 3 / 4 - 40, y + 5, 24, grade_col)
        @draw.draw_text(
          s.total.to_string(),
          sw * 3 / 4 - 40,
          y + 30,
          12,
          @types.color_dim_text,
        )
      }
      None =>
        @draw.draw_text(
          "---",
          sw * 3 / 4 - 40,
          y + 10,
          18,
          @types.color_dim_text,
        )
    }
  }
  // Total score
  let mut total = 0
  for i in 0..<game.level_scores.length() {
    match game.level_scores[i] {
      Some(s) => total += s.total
      None => ()
    }
  }
  if total > 0 {
    @draw.draw_text(
      "TOTAL SCORE: \{total}",
      sw / 4,
      sh - 60,
      20,
      @types.color_grade_s,
    )
  }
  // Navigation hint
  @draw.draw_text(
    "UP/DOWN Select  ENTER Start  ESC Back",
    sw / 4,
    sh - 30,
    14,
    @types.color_dim_text,
  )
}

///|
fn level_name_for(index : Int) -> String {
  match index {
    0 => "Lobby Infiltration"
    1 => "Server Room"
    2 => "Executive Floor"
    3 => "Data Center"
    4 => "Perimeter Breach"
    5 => "Command Bunker"
    6 => "Weapons Lab"
    7 => "War Room"
    _ => "Unknown"
  }
}

///|
fn grade_to_string(grade : @types.ScoreGrade) -> String {
  match grade {
    S => "S"
    A => "A"
    B => "B"
    C => "C"
  }
}

///|
/// Draw pause overlay
pub fn draw_pause(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Dim overlay
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 150))
  // Pause text
  let title = "PAUSED"
  let title_size = 40
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    sh / 3,
    title_size,
    @types.color_cyan,
  )
  @draw.draw_text(
    "ESC Resume",
    sw / 2 - 60,
    sh / 2,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Q Quit to Menu",
    sw / 2 - 70,
    sh / 2 + 30,
    18,
    @types.color_hud_text,
  )
  ignore(game)
}

///|
/// Draw results screen
pub fn draw_results(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let s = game.score
  // Background
  @raylib.draw_rectangle(0, 0, sw, sh, @types.color_bg)
  draw_cyber_background(game)
  // Title
  let title = "MISSION COMPLETE"
  let title_size = 36
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    40,
    title_size,
    @types.color_cyan,
  )
  // Level name
  let name = game.level.name
  let nw = @draw.measure_text(name, 20)
  @draw.draw_text(
    name,
    sw / 2 - nw / 2,
    85,
    20,
    @types.color_hud_text,
  )
  // Score breakdown
  let col_x = sw / 3
  let mut y = 130
  let line_h = 35
  draw_score_line("Base Score", s.base_score, col_x, y, @types.color_hud_text)
  y += line_h
  if s.ghost {
    draw_score_line("Ghost Bonus", s.ghost_bonus, col_x, y, @types.color_grade_s)
  } else {
    draw_score_line("Ghost Bonus", 0, col_x, y, @types.color_dim_text)
  }
  y += line_h
  if s.no_alerts {
    draw_score_line(
      "No Alert Bonus",
      s.no_alert_bonus,
      col_x,
      y,
      @types.color_neon_green,
    )
  } else {
    draw_score_line("No Alert Bonus", 0, col_x, y, @types.color_dim_text)
  }
  y += line_h
  draw_score_line(
    "Speed Bonus",
    s.speed_bonus,
    col_x,
    y,
    if s.speed_bonus > 0 { @types.color_cyan } else { @types.color_dim_text },
  )
  y += line_h
  draw_score_line(
    "Data Bonus",
    s.data_bonus,
    col_x,
    y,
    if s.all_data { @types.color_terminal } else { @types.color_dim_text },
  )
  y += line_h + 10
  // Separator
  @raylib.draw_line(col_x, y, sw * 2 / 3, y, @types.color_cyan)
  y += 15
  // Total
  draw_score_line("TOTAL", s.total, col_x, y, @types.color_white)
  y += line_h + 10
  // Grade
  let grade_str = grade_to_string(s.grade)
  let grade_size = 64
  let gw = @draw.measure_text(grade_str, grade_size)
  @draw.draw_text(
    grade_str,
    sw / 2 - gw / 2,
    y,
    grade_size,
    @types.grade_color(s.grade),
  )
  y += 80
  // Time
  let minutes = (s.time_taken / 60.0).to_int()
  let seconds = (s.time_taken % 60.0).to_int()
  let time_str = "Time: \{minutes}:\{pad_zero(seconds)}"
  let ttw = @draw.measure_text(time_str, 16)
  @draw.draw_text(time_str, sw / 2 - ttw / 2, y, 16, @types.color_dim_text)
  // Navigation
  @draw.draw_text(
    "ENTER Continue  R Replay",
    sw / 3,
    sh - 40,
    16,
    @types.color_hud_text,
  )
}

///|
fn draw_score_line(
  label : String,
  value : Int,
  x : Int,
  y : Int,
  color : @raylib.Color
) -> Unit {
  @draw.draw_text(label, x, y, 18, color)
  let val_str = "+\{value}"
  @draw.draw_text(
    val_str,
    @types.screen_width * 2 / 3 - @draw.measure_text(val_str, 18),
    y,
    18,
    color,
  )
}

///|
/// Draw hack minigame overlay
pub fn draw_hack_overlay(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let hg = game.hack_game
  // Dim background
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 180))
  // Panel
  let panel_w = 400
  let panel_h = 250
  let px = sw / 2 - panel_w / 2
  let py = sh / 2 - panel_h / 2
  @raylib.draw_rectangle(px, py, panel_w, panel_h, @raylib.Color::new(10, 10, 30, 240))
  @raylib.draw_rectangle_lines(px, py, panel_w, panel_h, @types.color_cyan)
  // Title
  @draw.draw_text("HIGH SECURITY HACK", px + 80, py + 15, 20, @types.color_neon_pink)
  // Timer bar with animated segments
  let bar_w = panel_w - 40
  let bar_h = 12
  let timer_ratio = hg.timer / hg.max_time
  // Background
  @raylib.draw_rectangle(
    px + 20,
    py + 50,
    bar_w,
    bar_h,
    @raylib.Color::new(30, 30, 50, 255),
  )
  // Animated fill with segment glow
  let fill_w = (Float::from_int(bar_w) * timer_ratio).to_int()
  let bar_color = if timer_ratio > 0.6 {
    @types.color_cyan
  } else if timer_ratio > 0.3 {
    @types.color_guard_suspicious
  } else {
    @types.color_guard_alert
  }
  @raylib.draw_rectangle(px + 20, py + 50, fill_w, bar_h, bar_color)
  // Glowing edge on the fill bar
  if fill_w > 2 {
    let pulse = @types.sinf(
      Float::from_int(game.frame_count) * 0.2,
    ) * 0.4 + 0.6
    let glow_alpha_f : Float = 180.0 * pulse
    let glow_alpha = glow_alpha_f.to_int()
    @raylib.draw_rectangle(
      px + 20 + fill_w - 3,
      py + 50,
      3,
      bar_h,
      @raylib.Color::new(255, 255, 255, @types.clampi(glow_alpha, 0, 255)),
    )
  }
  // Tick marks for visual rhythm
  let segments = 10
  for seg in 1..<segments {
    let tick_x = px + 20 + bar_w * seg / segments
    @raylib.draw_line(
      tick_x,
      py + 50,
      tick_x,
      py + 50 + bar_h,
      @raylib.Color::new(60, 60, 80, 120),
    )
  }
  // Border
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 50,
    bar_w,
    bar_h,
    @raylib.Color::new(80, 80, 120, 255),
  )
  // Sequence display
  @draw.draw_text("MATCH THE SEQUENCE:", px + 100, py + 80, 14, @types.color_hud_text)
  // Target sequence
  let seq_y = py + 110
  let bit_w = 50
  let seq_start = px + panel_w / 2 - @types.hack_sequence_length * bit_w / 2
  for i in 0..<@types.hack_sequence_length {
    let bx = seq_start + i * bit_w
    let val = hg.sequence[i]
    let text = if val == 0 { "0" } else { "1" }
    @raylib.draw_rectangle(
      bx,
      seq_y,
      bit_w - 4,
      40,
      @raylib.Color::new(20, 20, 40, 255),
    )
    @raylib.draw_rectangle_lines(
      bx,
      seq_y,
      bit_w - 4,
      40,
      @types.color_cyan,
    )
    @draw.draw_text(text, bx + 18, seq_y + 8, 24, @types.color_neon_green)
  }
  // Input progress
  @draw.draw_text("YOUR INPUT:", px + 130, py + 165, 14, @types.color_hud_text)
  let input_y = py + 190
  for i in 0..<@types.hack_sequence_length {
    let bx = seq_start + i * bit_w
    if i < hg.current_pos {
      let val = hg.input[i]
      let text = if val == 0 { "0" } else { "1" }
      let color = if val == hg.sequence[i] {
        @types.color_neon_green
      } else {
        @types.color_guard_alert
      }
      @raylib.draw_rectangle(bx, input_y, bit_w - 4, 30, @raylib.Color::new(20, 20, 40, 255))
      @draw.draw_text(text, bx + 18, input_y + 4, 20, color)
    } else {
      @raylib.draw_rectangle(
        bx,
        input_y,
        bit_w - 4,
        30,
        @raylib.Color::new(20, 20, 40, 255),
      )
      if i == hg.current_pos {
        // Cursor blink
        let blink = game.frame_count % 30 < 15
        if blink {
          @raylib.draw_rectangle_lines(
            bx,
            input_y,
            bit_w - 4,
            30,
            @types.color_guard_suspicious,
          )
        }
      }
    }
  }
  // Hint
  @draw.draw_text(
    "LEFT=0  RIGHT=1  ESC Cancel",
    px + 80,
    py + panel_h - 25,
    12,
    @types.color_dim_text,
  )
}

///|
/// Draw victory screen
pub fn draw_victory(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @types.color_bg)
  draw_cyber_background(game)
  // Title
  let title = "ALL MISSIONS COMPLETE"
  let title_size = 40
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    sh / 4 - 20,
    title_size,
    @types.color_grade_s,
  )
  // Total score
  let mut total = 0
  for i in 0..<game.level_scores.length() {
    match game.level_scores[i] {
      Some(s) => total += s.total
      None => ()
    }
  }
  let score_str = "TOTAL SCORE: \{total}"
  let ssw = @draw.measure_text(score_str, 28)
  @draw.draw_text(
    score_str,
    sw / 2 - ssw / 2,
    sh / 2 - 30,
    28,
    @types.color_cyan,
  )
  // Mission summary
  let mut y = sh / 2 + 20
  for i in 0..<@types.total_levels {
    let name = level_name_for(i)
    match game.level_scores[i] {
      Some(s) => {
        let grade_str = grade_to_string(s.grade)
        let line = "\{name}: \{grade_str} (\{s.total})"
        @draw.draw_text(
          line,
          sw / 3,
          y,
          14,
          @types.grade_color(s.grade),
        )
      }
      None =>
        @draw.draw_text(
          "\{name}: ---",
          sw / 3,
          y,
          14,
          @types.color_dim_text,
        )
    }
    y += 22
  }
  // Prompt
  let prompt = "PRESS ENTER"
  let pw = @draw.measure_text(prompt, 20)
  @draw.draw_text(
    prompt,
    sw / 2 - pw / 2,
    sh - 60,
    20,
    @types.color_hud_text,
  )
}
