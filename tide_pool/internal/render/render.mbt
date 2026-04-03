///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  match game.screen {
    Title => draw_title_screen(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing_screen(game)
    Simulating => draw_simulating_screen(game)
    Results => draw_results_screen(game)
  }
  @raylib.end_drawing()
}

///|
fn draw_playing_screen(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  match game.current_level {
    None => ()
    Some(level) => {
      @draw.draw_text(level.name, 40, 10, 24, @types.color_title)
      @draw.draw_text(level.description, 40, 40, 14, @types.color_hud_dim)
    }
  }
  draw_grid(game)
  draw_water_overlay(game)
  draw_hover(game)
  draw_tide_indicator(game)
  draw_depth_labels(game)
  draw_palette(game)
  draw_hud(game)
  draw_message(game)
  let btn_y = @types.screen_height - 56
  draw_button("SIMULATE", 40, btn_y, 140, 40, game)
  draw_button("CLEAR", 200, btn_y, 100, 40, game)
  draw_button("BACK", 320, btn_y, 100, 40, game)
}

///|
fn draw_simulating_screen(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  match game.current_level {
    None => ()
    Some(level) =>
      @draw.draw_text(
        "Simulating: \{level.name}",
        40,
        10,
        24,
        @types.color_title,
      )
  }
  draw_grid(game)
  draw_water_overlay(game)
  draw_tide_indicator(game)
  draw_depth_labels(game)
  draw_hud(game)
  let progress_text = "Turn \{game.current_turn}/\{@types.max_turns} - Cycle \{game.current_cycle + 1}/\{@types.total_cycles}"
  let pw = @draw.measure_text(progress_text, 20)
  @draw.draw_text(
    progress_text,
    @types.screen_width / 2 - pw / 2,
    @types.screen_height - 50,
    20,
    @types.color_tide_indicator,
  )
  if game.sim_log.length() > 0 {
    let last_log = game.sim_log[game.sim_log.length() - 1]
    if last_log.events.length() > 0 {
      let evt = last_log.events[last_log.events.length() - 1]
      let max_len = 80
      let display = if evt.length() > max_len {
        let mut truncated = ""
        let mut chars = 0
        for c in evt {
          if chars >= max_len {
            break
          }
          truncated = truncated + c.to_string()
          chars += 1
        }
        truncated + "..."
      } else {
        evt
      }
      let ew = @draw.measure_text(display, 14)
      @draw.draw_text(
        display,
        @types.screen_width / 2 - ew / 2,
        @types.screen_height - 28,
        14,
        @types.color_hud_dim,
      )
    }
  }
}
