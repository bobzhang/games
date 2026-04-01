///|
/// Draw in-game HUD: bounces, targets, controls.
pub fn draw_hud(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  let left_x = 10
  let top_y = 15
  // World and level info
  let world_label = match game.world {
    0 => "LINES"
    1 => "SPLITS"
    2 => "GATES"
    _ => "???"
  }
  @draw.draw_text(
    "World: \{world_label}  Level: \{game.level_index + 1}",
    left_x,
    top_y,
    18,
    @types.color_hud_text,
  )
  // Bounces
  @draw.draw_text(
    "Bounces: \{game.total_bounces} / Par: \{level.par_bounces}",
    left_x,
    top_y + 25,
    18,
    @types.color_hud_text,
  )
  // Targets
  let hit = @types.count_targets_hit(level)
  let total = level.targets.length()
  @draw.draw_text(
    "Targets: \{hit} / \{total}",
    left_x,
    top_y + 50,
    18,
    @types.color_target,
  )
  // Ball state
  let state_text = match game.ball_state {
    Aiming => "AIM & LAUNCH"
    Moving => "WATCHING..."
    Complete => "COMPLETE!"
    Failed => "MISSED - Press R"
  }
  @draw.draw_text(state_text, left_x, top_y + 75, 16, @types.color_ball)
  // Controls help at bottom
  let cy = @types.screen_height - 25
  match game.ball_state {
    Aiming =>
      @draw.draw_text(
        "LEFT/RIGHT: Aim  |  SPACE: Launch  |  ESC: Pause",
        left_x,
        cy,
        14,
        @raylib.Color::new(150, 150, 180, 200),
      )
    Moving =>
      @draw.draw_text(
        "R: Restart  |  ESC: Pause",
        left_x,
        cy,
        14,
        @raylib.Color::new(150, 150, 180, 200),
      )
    _ =>
      @draw.draw_text(
        "SPACE: Continue  |  R: Retry  |  ESC: Back",
        left_x,
        cy,
        14,
        @raylib.Color::new(150, 150, 180, 200),
      )
  }
  // Message overlay
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 28)
    @draw.draw_text(
      game.message,
      (@types.screen_width - mw) / 2,
      @types.screen_height / 2 - 14,
      28,
      @types.color_title,
    )
  }
}

///|
/// Draw star rating display.
fn draw_stars(x : Int, y : Int, stars : Int, size : Int) -> Unit {
  for i in 0..<3 {
    let sx = x + i * (size + 4)
    let col = if i < stars {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, y, size, col)
  }
}

///|
/// Draw the playing screen.
pub fn draw_playing(game : @types.Game) -> Unit {
  draw_arena(game)
  match game.ball_state {
    Aiming => draw_aim(game)
    _ => ()
  }
  draw_balls(game)
  draw_hud(game)
}
