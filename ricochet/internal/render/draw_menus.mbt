///|
/// Draw title screen with neon text.
pub fn draw_title(game : @types.Game) -> Unit {
  // Pulsing title
  let pulse : Float = 0.8 + 0.2 * @types.sinf(game.title_pulse * 2.0)
  let title_size_f : Float = 48.0 * pulse
  let title_size = title_size_f.to_int()
  let title = "RICOCHET"
  let tw = @draw.measure_text(title, title_size)
  let tx = (@types.screen_width - tw) / 2
  // Glow behind
  @draw.draw_text(
    title,
    tx - 1,
    180 - 1,
    title_size,
    @raylib.Color::new(0, 255, 255, 40),
  )
  @draw.draw_text(title, tx, 180, title_size, @types.color_title)
  // Subtitle
  let sub = "A Neon Geometry Puzzle"
  let sw = @draw.measure_text(sub, 22)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    240,
    22,
    @types.color_hud_text,
  )
  // Menu
  let start = "Press SPACE to Start"
  let stw = @draw.measure_text(start, 24)
  let flash : Float = @types.sinf(game.title_pulse * 4.0)
  let alpha_f : Float = 180.0 + 75.0 * flash
  let alpha : Int = alpha_f.to_int()
  @draw.draw_text(
    start,
    (@types.screen_width - stw) / 2,
    380,
    24,
    @raylib.Color::new(255, 255, 255, alpha),
  )
  // Decorative lines
  let cx = @types.screen_width / 2
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(cx - 200), 320.0),
    @raylib.Vector2::new(Float::from_int(cx + 200), 320.0),
    1.0,
    @raylib.Color::new(0, 255, 255, 60),
  )
  // Controls hint
  let hint = "Arrow Keys to Aim | Space to Launch | R to Restart"
  let hw = @draw.measure_text(hint, 16)
  @draw.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    500,
    16,
    @raylib.Color::new(120, 120, 160, 200),
  )
}

///|
/// Draw world selection screen.
pub fn draw_world_select(game : @types.Game) -> Unit {
  let title = "SELECT WORLD"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    60,
    36,
    @types.color_title,
  )
  let world_names = ["1: LINES", "2: SPLITS", "3: GATES"]
  for i in 0..<3 {
    let bx = 200 + i * 300
    let by = 250
    let bw = 240
    let bh = 200
    let is_selected = game.world == i
    let border_col = if is_selected {
      @types.color_menu_highlight
    } else {
      @types.color_wall
    }
    // Box
    @raylib.draw_rectangle_lines(bx, by, bw, bh, border_col)
    if is_selected {
      @raylib.draw_rectangle(
        bx + 1,
        by + 1,
        bw - 2,
        bh - 2,
        @raylib.Color::new(255, 255, 0, 20),
      )
    }
    // World name
    let name = world_names[i]
    let nw = @draw.measure_text(name, 22)
    @draw.draw_text(name, bx + (bw - nw) / 2, by + 30, 22, border_col)
    // Stars earned for this world
    let mut total_stars = 0
    let start_idx = i * @types.levels_per_world
    for j in 0..<@types.levels_per_world {
      total_stars += game.scores[start_idx + j].stars
    }
    let star_text = "Stars: \{total_stars}/\{@types.levels_per_world * 3}"
    let stw = @draw.measure_text(star_text, 16)
    @draw.draw_text(
      star_text,
      bx + (bw - stw) / 2,
      by + 80,
      16,
      @types.color_star_filled,
    )
    // Levels completed
    let mut completed = 0
    for j in 0..<@types.levels_per_world {
      if game.scores[start_idx + j].completed {
        completed += 1
      }
    }
    let comp_text = "Completed: \{completed}/\{@types.levels_per_world}"
    let cw = @draw.measure_text(comp_text, 16)
    @draw.draw_text(
      comp_text,
      bx + (bw - cw) / 2,
      by + 110,
      16,
      @types.color_hud_text,
    )
  }
  // Controls
  @draw.draw_text(
    "LEFT/RIGHT: Select  |  SPACE: Enter  |  ESC: Back",
    320,
    520,
    18,
    @raylib.Color::new(150, 150, 180, 200),
  )
}

///|
/// Draw level selection grid.
pub fn draw_level_select(game : @types.Game) -> Unit {
  let world_label = match game.world {
    0 => "LINES"
    1 => "SPLITS"
    2 => "GATES"
    _ => "???"
  }
  let title = "WORLD \{game.world + 1}: \{world_label}"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    50,
    32,
    @types.color_title,
  )
  // 2 rows x 5 columns grid
  let cols = 5
  let cell_w = 180
  let cell_h = 120
  let grid_w = cols * cell_w
  let start_x = (@types.screen_width - grid_w) / 2
  let start_y = 130
  let world_offset = game.world * @types.levels_per_world
  for i in 0..<@types.levels_per_world {
    let col = i % cols
    let row = i / cols
    let cx = start_x + col * cell_w
    let cy = start_y + row * (cell_h + 20)
    let is_selected = game.level_index == i
    let score = game.scores[world_offset + i]
    let border_col = if is_selected {
      @types.color_menu_highlight
    } else if score.completed {
      @types.color_gate
    } else {
      @types.color_wall
    }
    // Cell box
    @raylib.draw_rectangle_lines(cx, cy, cell_w - 10, cell_h, border_col)
    if is_selected {
      @raylib.draw_rectangle(
        cx + 1,
        cy + 1,
        cell_w - 12,
        cell_h - 2,
        @raylib.Color::new(255, 255, 0, 15),
      )
    }
    // Level number
    let num_text = "\{i + 1}"
    let nw = @draw.measure_text(num_text, 28)
    @draw.draw_text(
      num_text,
      cx + (cell_w - 10 - nw) / 2,
      cy + 15,
      28,
      border_col,
    )
    // Stars
    let star_x = cx + (cell_w - 10 - 60) / 2
    draw_stars(star_x, cy + 55, score.stars, 20)
    // Best bounces
    if score.completed {
      let bounce_text = "Best: \{score.best_bounces}"
      let bw = @draw.measure_text(bounce_text, 12)
      @draw.draw_text(
        bounce_text,
        cx + (cell_w - 10 - bw) / 2,
        cy + 85,
        12,
        @types.color_hud_text,
      )
    }
  }
  // Controls
  @draw.draw_text(
    "ARROWS: Navigate  |  SPACE: Play  |  ESC: Back",
    330,
    440,
    18,
    @raylib.Color::new(150, 150, 180, 200),
  )
}

///|
/// Draw results screen after completing/failing a level.
pub fn draw_results(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Dim background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 10, 26, 200),
  )
  let all_hit = @types.all_targets_hit(level)
  let title = if all_hit { "LEVEL COMPLETE!" } else { "LEVEL FAILED" }
  let title_col = if all_hit {
    @types.color_title
  } else {
    @raylib.Color::new(255, 60, 60, 255)
  }
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (@types.screen_width - tw) / 2, 150, 40, title_col)
  if all_hit {
    // Bounces info
    let bounce_text = "Bounces: \{game.total_bounces}  |  Par: \{level.par_bounces}"
    let bw = @draw.measure_text(bounce_text, 22)
    @draw.draw_text(
      bounce_text,
      (@types.screen_width - bw) / 2,
      230,
      22,
      @types.color_hud_text,
    )
    // Stars earned
    let has_pickup = @types.pickup_collected(level)
    let under_par = game.total_bounces <= level.par_bounces
    let mut stars = 1
    if under_par {
      stars = 2
    }
    if under_par && has_pickup {
      stars = 3
    }
    // Draw big stars
    let star_size = 36
    let star_total_w = 3 * (star_size + 8)
    let sx = (@types.screen_width - star_total_w) / 2
    draw_stars(sx, 280, stars, star_size)
    // Star explanations
    @draw.draw_text("Hit all targets", 480, 340, 16, @types.color_hud_text)
    let par_col = if under_par {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("Under par bounces", 480, 365, 16, par_col)
    let pk_col = if has_pickup {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("Collected pickup", 480, 390, 16, pk_col)
  } else {
    // Failure info
    let hit = @types.count_targets_hit(level)
    let total = level.targets.length()
    let info = "Targets hit: \{hit} / \{total}"
    let iw = @draw.measure_text(info, 22)
    @draw.draw_text(
      info,
      (@types.screen_width - iw) / 2,
      260,
      22,
      @types.color_target,
    )
  }
  // Continue/retry
  @draw.draw_text(
    "SPACE: Continue  |  R: Retry  |  ESC: Back to Levels",
    280,
    500,
    18,
    @raylib.Color::new(180, 180, 220, 200),
  )
}

///|
/// Draw pause overlay.
pub fn draw_pause_overlay(_game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 10, 26, 180),
  )
  let title = "PAUSED"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    280,
    48,
    @types.color_title,
  )
  @draw.draw_text(
    "ESC: Resume  |  R: Restart  |  Q: Quit to Menu",
    320,
    380,
    18,
    @raylib.Color::new(150, 150, 180, 200),
  )
}
