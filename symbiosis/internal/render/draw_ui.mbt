///|
fn draw_ui(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      // Top bar
      let world_str = @types.world_name(level.world)
      @draw.draw_text(
        "World " +
        (level.world + 1).to_string() +
        ": " +
        world_str +
        " - Level " +
        (level.index + 1).to_string(),
        20,
        10,
        24,
        @types.color_title,
      )
      // Move counter
      let move_str = "Moves: " + game.move_count.to_string()
      @draw.draw_text(move_str, 20, 45, 20, @types.color_hud_text)
      // Par
      let par_str = "Par: " + level.par_moves.to_string()
      @draw.draw_text(par_str, 160, 45, 20, @types.color_hud_dim)
      // Goal
      let goal_str = match level.goal {
        BothExit => "Goal: Both reach exits"
        BothSwitch => "Goal: Both stand on switches"
        ExitInMoves(n) =>
          "Goal: Both reach exits in " + n.to_string() + " moves"
      }
      @draw.draw_text(goal_str, 350, 45, 18, @types.color_hud_dim)
      // Bottom controls
      let bottom_y = @types.screen_height - 60
      @draw.draw_text(
        "WASD/Arrows: Move  Space: Wait  Z: Undo  R: Restart  Esc: Back",
        20,
        bottom_y,
        16,
        @types.color_hud_dim,
      )
      // Play state messages
      match game.play_state {
        Won => {
          let stars = @types.compute_stars(game)
          let star_str = stars_string(stars)
          draw_center_message("LEVEL COMPLETE! " + star_str, @types.color_exit)
          @draw.draw_text(
            "Press ENTER to continue",
            480,
            @types.screen_height / 2 + 30,
            20,
            @types.color_hud_text,
          )
        }
        Failed => {
          draw_center_message(game.message, @types.color_pit)
          @draw.draw_text(
            "Press R to retry or Z to undo",
            460,
            @types.screen_height / 2 + 30,
            20,
            @types.color_hud_text,
          )
        }
        Paused => draw_center_message("PAUSED", @types.color_hud_text)
        Active => {
          // Show message if any
          if game.message_timer > 0.0 {
            draw_center_message(game.message, @types.color_highlight)
          }
        }
      }
    }
  }
}

///|
fn draw_center_message(msg : String, color : @raylib.Color) -> Unit {
  let w = @draw.measure_text(msg, 32)
  let x = (@types.screen_width - w) / 2
  let y = @types.screen_height / 2 - 16
  // Background
  @raylib.draw_rectangle(
    x - 20,
    y - 10,
    w + 40,
    52,
    @raylib.Color::new(0, 0, 0, 200),
  )
  @draw.draw_text(msg, x, y, 32, color)
}

///|
fn stars_string(n : Int) -> String {
  let mut s = ""
  for _i in 0..<n {
    s = s + "*"
  }
  for _i in n..<3 {
    s = s + "-"
  }
  "[" + s + "]"
}
