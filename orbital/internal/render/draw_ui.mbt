///|
fn draw_play_hud(game : @types.Game, level : @types.Level) -> Unit {
  let w = @types.screen_width
  // Top bar background
  @raylib.draw_rectangle(0, 0, w, 40, @raylib.Color::new(0, 0, 0, 150))
  // Level name
  @draw.draw_text(level.name, 10, 10, 18, @types.tier_color(level.tier))
  // Tier label
  let tier_str = @types.tier_name(level.tier)
  @draw.draw_text(
    tier_str,
    10 + @draw.measure_text(level.name, 18) + 15,
    12,
    14,
    @raylib.Color::new(150, 150, 170, 180),
  )
  // Tick counter
  let tick_str = "Ticks: " +
    game.tick_count.to_string() +
    " / " +
    level.par_ticks.to_string()
  let tw = @draw.measure_text(tick_str, 16)
  @draw.draw_text(tick_str, w - tw - 10, 12, 16, @types.color_hud)
  // Star indicators (par)
  let par_label = "Par: " + level.par_ticks.to_string()
  let pw = @draw.measure_text(par_label, 14)
  @draw.draw_text(
    par_label,
    w - tw - pw - 30,
    12,
    14,
    @raylib.Color::new(150, 160, 180, 180),
  )
  // State indicator
  let state_str = match game.play_state {
    Aiming => "AIM - Left/Right to rotate, Space to launch"
    Flying => "FLYING - R to restart"
    Won => "SUCCESS! Press Enter to continue"
    Failed => "FAILED - R to restart"
  }
  let state_color = match game.play_state {
    Aiming => @raylib.Color::new(100, 200, 255, 200)
    Flying => @raylib.Color::new(200, 200, 200, 180)
    Won => @types.color_station
    Failed => @raylib.Color::new(255, 80, 80, 220)
  }
  let sw = @draw.measure_text(state_str, 14)
  @draw.draw_text(
    state_str,
    (w - sw) / 2,
    @types.screen_height - 30,
    14,
    state_color,
  )
  // Angle display in aiming mode
  match game.play_state {
    Aiming => {
      let angle_deg = game.launch_angle * 180.0 / @types.pi
      let angle_str = "Angle: " + angle_deg.to_int().to_string() + " deg"
      @draw.draw_text(
        angle_str,
        (w - @draw.measure_text(angle_str, 14)) / 2,
        12,
        14,
        @types.color_hud,
      )
    }
    _ => ()
  }
  // Waypoint status
  let wp_total = level.waypoints.length()
  let mut wp_got = 0
  for i in 0..<level.waypoints.length() {
    if level.waypoints[i].collected {
      wp_got += 1
    }
  }
  if wp_total > 0 {
    let wp_str = "Waypoints: " + wp_got.to_string() + "/" + wp_total.to_string()
    @draw.draw_text(
      wp_str,
      10,
      @types.screen_height - 30,
      14,
      @types.color_waypoint,
    )
  }
  ignore(wp_total)
}
