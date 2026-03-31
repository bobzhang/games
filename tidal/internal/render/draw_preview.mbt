///|
fn draw_preview(game : @types.Game) -> Unit {
  match game.play_state {
    Simulating | Stepping => {
      // Show tick counter and state
      let tick_text = "Tick: " +
        game.sim_tick.to_string() +
        " / " +
        @types.max_ticks.to_string()
      @draw.draw_text(tick_text, @types.palette_x + 10, 530, 22, @types.color_ui_text)
      // Show target status
      let targets = @types.count_target_info(game.grid)
      let tgt_text = "Targets: " +
        targets.0.to_string() +
        " / " +
        targets.1.to_string()
      @draw.draw_text(tgt_text, @types.palette_x + 10, 560, 22, @types.color_ui_text)
      // Controls hint
      match game.play_state {
        Stepping =>
          @draw.draw_text(
            "SPACE: next tick  P: auto  R: reset",
            @types.palette_x + 10,
            620,
            16,
            @types.color_ui_dim,
          )
        Simulating =>
          @draw.draw_text(
            "R: reset  ESC: back",
            @types.palette_x + 10,
            620,
            16,
            @types.color_ui_dim,
          )
        _ => ()
      }
    }
    Editing => {
      // Show controls hint
      @draw.draw_text(
        "ENTER: simulate  S: step  ESC: back",
        @types.palette_x + 10,
        590,
        16,
        @types.color_ui_dim,
      )
      @draw.draw_text(
        "L-Click: place  R-Click: remove",
        @types.palette_x + 10,
        612,
        16,
        @types.color_ui_dim,
      )
      @draw.draw_text(
        "TAB: cycle emitter phase",
        @types.palette_x + 10,
        634,
        16,
        @types.color_ui_dim,
      )
      // Hover preview
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let gx = @types.screen_to_grid_x(mx)
      let gy = @types.screen_to_grid_y(my)
      if @types.grid_in_bounds(gx, gy) {
        let sx = @types.tile_screen_x(gx)
        let sy = @types.tile_screen_y(gy)
        let hover_color = @raylib.Color::new(255, 255, 255, 40)
        @raylib.draw_rectangle(
          sx.to_int(),
          sy.to_int(),
          @types.tile_size,
          @types.tile_size,
          hover_color,
        )
      }
    }
    Complete => {
      // Victory overlay
      let overlay = @raylib.Color::new(0, 0, 0, 120)
      @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, overlay)
      let text = "Level Complete!"
      let tw = @draw.measure_text(text, 48)
      @draw.draw_text(
        text,
        (@types.screen_width - tw) / 2,
        280,
        48,
        @types.color_target_ok,
      )
      let score = game.scores[game.current_level]
      let star_text = "Stars: " + star_string(score.stars)
      let stw = @draw.measure_text(star_text, 32)
      @draw.draw_text(
        star_text,
        (@types.screen_width - stw) / 2,
        340,
        32,
        @types.color_star_gold,
      )
      @draw.draw_text(
        "ENTER: results  ESC: level select",
        (@types.screen_width - 300) / 2,
        420,
        20,
        @types.color_ui_dim,
      )
    }
    Failed => {
      let overlay = @raylib.Color::new(0, 0, 0, 120)
      @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, overlay)
      let text = "Simulation Failed"
      let tw = @draw.measure_text(text, 48)
      @draw.draw_text(
        text,
        (@types.screen_width - tw) / 2,
        300,
        48,
        @types.color_target_fail,
      )
      @draw.draw_text(
        "R: retry  ESC: back",
        (@types.screen_width - 200) / 2,
        380,
        20,
        @types.color_ui_dim,
      )
    }
  }
}

///|
fn star_string(stars : Int) -> String {
  match stars {
    1 => "* . ."
    2 => "* * ."
    3 => "* * *"
    _ => ". . ."
  }
}
