///|
/// Draw the title screen
pub fn draw_title(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Animated background
  draw_echo_background(game)
  // Title
  let title = "ECHO MAZE"
  let title_size = 52
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    sh / 4 - 30,
    title_size,
    @raylib.Color::new(0, 220, 240, 255),
  )
  // Subtitle
  let sub = "TIME LOOP PUZZLE"
  let sub_size = 18
  let stw = @draw.measure_text(sub, sub_size)
  @draw.draw_text(
    sub,
    sw / 2 - stw / 2,
    sh / 4 + 35,
    sub_size,
    @raylib.Color::new(60, 220, 80, 220),
  )
  // Description
  let desc1 = "Record your path, then replay as a ghost"
  let desc2 = "Use ghosts to press buttons and hold doors"
  let d1w = @draw.measure_text(desc1, 14)
  let d2w = @draw.measure_text(desc2, 14)
  @draw.draw_text(
    desc1,
    sw / 2 - d1w / 2,
    sh / 2 - 10,
    14,
    @raylib.Color::new(160, 155, 180, 200),
  )
  @draw.draw_text(
    desc2,
    sw / 2 - d2w / 2,
    sh / 2 + 12,
    14,
    @raylib.Color::new(160, 155, 180, 200),
  )
  // Start prompt
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.06) * 0.5 + 0.5
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
    @raylib.Color::new(0, 220, 240, alpha),
  )
  // Version
  @draw.draw_text(
    "v1.0",
    10,
    sh - 25,
    14,
    @raylib.Color::new(80, 75, 100, 200),
  )
}

///|
/// Animated background with echo-themed effects
fn draw_echo_background(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Concentric echo rings from center
  let cx = Float::from_int(sw / 2)
  let cy = Float::from_int(sh / 2)
  let ring_count = 8
  for i in 0..<ring_count {
    let base_r : Float = Float::from_int(i * 80 + 50)
    let time_offset = Float::from_int(game.frame_count) * 0.02
    let radius = base_r + @types.sinf(time_offset + Float::from_int(i) * 0.5) * 20.0
    let alpha_f : Float = 15.0 - Float::from_int(i) * 1.5
    let alpha = @types.clampi(alpha_f.to_int(), 2, 30)
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(cx, cy),
      radius,
      @raylib.Color::new(0, 220, 240, alpha),
    )
  }
  // Horizontal scan lines
  for i in 0..<(sh / 6) {
    let y = i * 6
    let alpha = 6 + (
      @types.sinf(Float::from_int(y + game.frame_count * 2) * 0.015) * 4.0
    ).to_int()
    @raylib.draw_line(
      0,
      y,
      sw,
      y,
      @raylib.Color::new(60, 220, 80, @types.clampi(alpha, 0, 20)),
    )
  }
}

///|
/// Draw world select screen
pub fn draw_world_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  draw_echo_background(game)
  // Title
  let title = "SELECT WORLD"
  let title_size = 32
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    50,
    title_size,
    @raylib.Color::new(0, 220, 240, 255),
  )
  // World list
  let world_names = ["Foundations", "Timing", "Mastery"]
  let world_descs = [
    "Buttons, doors, and your first ghosts",
    "Timed doors and guard patrols",
    "All mechanics combined",
  ]
  let start_y = 140
  let item_h = 120
  for i in 0..<@types.num_worlds {
    let y = start_y + i * item_h
    let selected = i == game.selected_world
    let unlocked = @types.is_world_unlocked(game, i)
    // Selection box
    if selected {
      @raylib.draw_rectangle(
        sw / 4 - 10,
        y - 5,
        sw / 2 + 20,
        item_h - 10,
        @raylib.Color::new(0, 220, 240, 20),
      )
      @raylib.draw_rectangle_lines(
        sw / 4 - 10,
        y - 5,
        sw / 2 + 20,
        item_h - 10,
        @raylib.Color::new(0, 220, 240, 150),
      )
    }
    // World name
    let name = "World \{i + 1}: \{world_names[i]}"
    let name_color = if !unlocked {
      @raylib.Color::new(80, 75, 100, 200)
    } else if selected {
      @raylib.Color::new(255, 255, 255, 255)
    } else {
      @types.color_hud_text
    }
    @draw.draw_text(name, sw / 4, y + 5, 20, name_color)
    // Description
    @draw.draw_text(
      world_descs[i],
      sw / 4,
      y + 30,
      12,
      @raylib.Color::new(120, 115, 140, 200),
    )
    // Stars
    let stars = @types.world_stars(game, i)
    let max_stars = @types.levels_per_world * 3
    draw_star_display(sw / 4, y + 50, stars, max_stars)
    // Lock indicator
    if !unlocked {
      @draw.draw_text(
        "LOCKED - Need 6 stars from previous world",
        sw / 4,
        y + 72,
        11,
        @raylib.Color::new(240, 50, 50, 180),
      )
    }
  }
  // Navigation
  @draw.draw_text(
    "UP/DOWN Select  ENTER Open  ESC Back",
    sw / 4,
    sh - 40,
    14,
    @raylib.Color::new(120, 115, 140, 200),
  )
}

///|
/// Draw level select screen
pub fn draw_level_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  draw_echo_background(game)
  // Title
  let world_names = ["Foundations", "Timing", "Mastery"]
  let world_name = if game.current_world < world_names.length() {
    world_names[game.current_world]
  } else {
    "Unknown"
  }
  let title = "W\{game.current_world + 1}: \{world_name}"
  let title_size = 28
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    40,
    title_size,
    @raylib.Color::new(0, 220, 240, 255),
  )
  // Level list
  let start_y = 90
  let item_h = 68
  let levels = @maze.get_all_levels()
  for i in 0..<@types.levels_per_world {
    let y = start_y + i * item_h
    let selected = i == game.selected_level
    let unlocked = @types.is_level_unlocked(game, game.current_world, i)
    // Find level def
    let mut level_name = "???"
    let mut par = 1
    for l in levels {
      if l.world == game.current_world && l.level == i {
        level_name = l.name
        par = l.par_loops
      }
    }
    // Selection box
    if selected {
      @raylib.draw_rectangle(
        sw / 4 - 10,
        y - 3,
        sw / 2 + 20,
        item_h - 8,
        @raylib.Color::new(0, 220, 240, 15),
      )
      @raylib.draw_rectangle_lines(
        sw / 4 - 10,
        y - 3,
        sw / 2 + 20,
        item_h - 8,
        @raylib.Color::new(0, 220, 240, 100),
      )
    }
    // Level number and name
    let num_str = "\{game.current_world + 1}-\{i + 1}"
    let name_color = if !unlocked {
      @raylib.Color::new(80, 75, 100, 180)
    } else if selected {
      @raylib.Color::new(255, 255, 255, 255)
    } else {
      @types.color_hud_text
    }
    @draw.draw_text(
      "\{num_str}: \{level_name}",
      sw / 4,
      y + 2,
      16,
      name_color,
    )
    // Par loops
    @draw.draw_text(
      "Par: \{par} loops",
      sw / 4,
      y + 22,
      11,
      @raylib.Color::new(120, 115, 140, 180),
    )
    // Score display
    if game.current_world < game.level_scores.length() &&
      i < game.level_scores[game.current_world].length() {
      let score = game.level_scores[game.current_world][i]
      if score.completed {
        // Stars
        draw_star_display(sw * 3 / 4 - 80, y + 2, score.stars, 3)
        // Best loops
        @draw.draw_text(
          "Best: \{score.best_loops} loops",
          sw * 3 / 4 - 80,
          y + 22,
          11,
          @raylib.Color::new(120, 115, 140, 200),
        )
        // Collectibles
        if score.collectibles_total > 0 {
          @draw.draw_text(
            "Items: \{score.collectibles_got}/\{score.collectibles_total}",
            sw * 3 / 4 - 80,
            y + 36,
            11,
            @types.color_collectible,
          )
        }
      } else if !unlocked {
        @draw.draw_text(
          "LOCKED",
          sw * 3 / 4 - 60,
          y + 8,
          14,
          @raylib.Color::new(240, 50, 50, 150),
        )
      } else {
        @draw.draw_text(
          "---",
          sw * 3 / 4 - 40,
          y + 8,
          16,
          @raylib.Color::new(80, 75, 100, 150),
        )
      }
    }
  }
  // Total stars for this world
  let total_stars = @types.world_stars(game, game.current_world)
  let max_stars = @types.levels_per_world * 3
  @draw.draw_text(
    "World Stars: \{total_stars}/\{max_stars}",
    sw / 4,
    sh - 60,
    16,
    @types.color_star_gold,
  )
  // Navigation
  @draw.draw_text(
    "UP/DOWN Select  ENTER Play  ESC Back",
    sw / 4,
    sh - 35,
    14,
    @raylib.Color::new(120, 115, 140, 200),
  )
}

///|
fn draw_star_display(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * 18
    let color = if i < filled {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, y, 16, color)
  }
}

///|
/// Draw planning overlay
pub fn draw_planning_overlay(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Semi-transparent overlay
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 100))
  // Planning panel
  let panel_w = 500
  let panel_h = 300
  let px = sw / 2 - panel_w / 2
  let py = sh / 2 - panel_h / 2
  @raylib.draw_rectangle(
    px,
    py,
    panel_w,
    panel_h,
    @raylib.Color::new(20, 15, 40, 240),
  )
  @raylib.draw_rectangle_lines(
    px,
    py,
    panel_w,
    panel_h,
    @raylib.Color::new(0, 220, 240, 200),
  )
  // Title
  let title = "TIME LOOP PLANNING"
  let title_size = 24
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    py + 15,
    title_size,
    @raylib.Color::new(0, 220, 240, 255),
  )
  let nx = px + 25
  let mut y = py + 55
  // Status
  let ghosts_used = game.ghosts.length()
  let ghosts_left = @types.max_ghosts - ghosts_used
  @draw.draw_text(
    "Ghosts active: \{ghosts_used} / \{@types.max_ghosts}",
    nx,
    y,
    16,
    @types.color_hud_text,
  )
  y += 24
  @draw.draw_text(
    "Ghost slots remaining: \{ghosts_left}",
    nx,
    y,
    14,
    if ghosts_left > 0 {
      @raylib.Color::new(60, 220, 80, 220)
    } else {
      @raylib.Color::new(240, 50, 50, 220)
    },
  )
  y += 30
  // Timeline scrubber
  @draw.draw_text(
    "Timeline:",
    nx,
    y,
    12,
    @raylib.Color::new(120, 115, 140, 200),
  )
  y += 16
  let tl_w = panel_w - 50
  let tl_h = 20
  @raylib.draw_rectangle(
    nx,
    y,
    tl_w,
    tl_h,
    @types.color_timeline_bg,
  )
  if game.timeline.length() > 0 {
    let tick_w : Float = Float::from_int(tl_w) / Float::from_int(
      game.timeline.length(),
    )
    let cursor_x = nx + (Float::from_int(game.planning_tick) * tick_w).to_int()
    @raylib.draw_rectangle(
      cursor_x,
      y,
      @types.maxi(tick_w.to_int(), 3),
      tl_h,
      @raylib.Color::new(0, 220, 240, 200),
    )
  }
  @draw.draw_text(
    "Tick \{game.planning_tick}",
    nx + tl_w + 5,
    y + 2,
    12,
    @types.color_hud_text,
  )
  y += 35
  // Options
  @draw.draw_text(
    "SPACE/ENTER  Start New Loop",
    nx,
    y,
    15,
    @raylib.Color::new(0, 220, 240, 230),
  )
  y += 22
  @draw.draw_text(
    "U  Undo Last Ghost",
    nx,
    y,
    15,
    @raylib.Color::new(240, 220, 40, 230),
  )
  y += 22
  @draw.draw_text(
    "R  Reset Level",
    nx,
    y,
    15,
    @raylib.Color::new(240, 140, 40, 230),
  )
  y += 22
  @draw.draw_text(
    "Q  Quit to Level Select",
    nx,
    y,
    15,
    @raylib.Color::new(240, 50, 50, 200),
  )
  y += 22
  @draw.draw_text(
    "LEFT/RIGHT  Scrub Timeline",
    nx,
    y,
    13,
    @raylib.Color::new(120, 115, 140, 200),
  )
}

///|
/// Draw pause overlay
pub fn draw_pause(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  ignore(game)
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
    @raylib.Color::new(0, 220, 240, 255),
  )
  let options_x = sw / 2 - 80
  @draw.draw_text(
    "ESC  Resume",
    options_x,
    sh / 2,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "R  Restart Level",
    options_x,
    sh / 2 + 30,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Q  Quit to Menu",
    options_x,
    sh / 2 + 60,
    18,
    @types.color_hud_text,
  )
}

///|
/// Draw results screen
pub fn draw_results(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Background
  @raylib.draw_rectangle(0, 0, sw, sh, @types.color_bg)
  draw_echo_background(game)
  // Title
  let title = "LEVEL COMPLETE!"
  let title_size = 36
  let tw = @draw.measure_text(title, title_size)
  @draw.draw_text(
    title,
    sw / 2 - tw / 2,
    60,
    title_size,
    @raylib.Color::new(50, 255, 120, 255),
  )
  // Level name
  let level_name = match @maze.get_level(game.current_world, game.current_level) {
    Some(ld) => ld.name
    None => "Unknown"
  }
  let nw = @draw.measure_text(level_name, 20)
  @draw.draw_text(
    level_name,
    sw / 2 - nw / 2,
    105,
    20,
    @types.color_hud_text,
  )
  // Score breakdown
  let col_x = sw / 3
  let mut y = 160
  let line_h = 40
  // Loops used
  @draw.draw_text("Loops Used:", col_x, y, 18, @types.color_hud_text)
  let loops_str = game.result_loops.to_string()
  @draw.draw_text(
    loops_str,
    sw * 2 / 3 - @draw.measure_text(loops_str, 18),
    y,
    18,
    @raylib.Color::new(0, 220, 240, 255),
  )
  y += line_h
  // Par
  let par = match @maze.get_level(game.current_world, game.current_level) {
    Some(ld) => ld.par_loops
    None => 3
  }
  @draw.draw_text("Par:", col_x, y, 18, @types.color_hud_text)
  let par_str = par.to_string()
  let par_color = if game.result_loops <= par {
    @raylib.Color::new(50, 255, 120, 255)
  } else {
    @raylib.Color::new(240, 50, 50, 255)
  }
  @draw.draw_text(
    par_str,
    sw * 2 / 3 - @draw.measure_text(par_str, 18),
    y,
    18,
    par_color,
  )
  y += line_h
  // Collectibles
  if game.result_total_collectibles > 0 {
    @draw.draw_text("Collectibles:", col_x, y, 18, @types.color_hud_text)
    let coll_str = "\{game.result_collectibles}/\{game.result_total_collectibles}"
    let coll_color = if game.result_collectibles >= game.result_total_collectibles {
      @types.color_collectible
    } else {
      @types.color_hud_text
    }
    @draw.draw_text(
      coll_str,
      sw * 2 / 3 - @draw.measure_text(coll_str, 18),
      y,
      18,
      coll_color,
    )
    y += line_h
  }
  // Separator
  @raylib.draw_line(
    col_x,
    y,
    sw * 2 / 3,
    y,
    @raylib.Color::new(0, 220, 240, 150),
  )
  y += 20
  // Stars
  let star_size = 48
  let stars_w = game.result_stars * 50
  let stars_x = sw / 2 - stars_w / 2
  for i in 0..<3 {
    let color = if i < game.result_stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", stars_x + i * 50, y, star_size, color)
  }
  y += 70
  // Rating text
  let rating = match game.result_stars {
    3 => "PERFECT!"
    2 => "GREAT!"
    1 => "COMPLETE"
    _ => ""
  }
  let rating_color = match game.result_stars {
    3 => @types.color_star_gold
    2 => @raylib.Color::new(50, 255, 120, 255)
    _ => @types.color_hud_text
  }
  let rw = @draw.measure_text(rating, 28)
  @draw.draw_text(rating, sw / 2 - rw / 2, y, 28, rating_color)
  // Navigation
  @draw.draw_text(
    "ENTER  Continue    R  Replay",
    sw / 3,
    sh - 50,
    16,
    @types.color_hud_text,
  )
}
