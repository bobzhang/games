///|
pub fn draw_title_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_bg)
  // Animated background particles
  let t = Float::from_int(game.frame_count) * 0.02
  for i in 0..<20 {
    let fi = Float::from_int(i)
    let x = (Float::from_double(@math.sin((t + fi * 0.7).to_double())) * 0.5 + 0.5) * Float::from_int(@types.screen_w)
    let y = (Float::from_double(@math.cos((t * 0.8 + fi * 1.1).to_double())) * 0.5 + 0.5) * Float::from_int(@types.screen_h)
    let alpha = 30 + ((Float::from_double(@math.sin((t + fi).to_double())) * 0.5 + 0.5) * 40.0).to_int()
    @raylib.draw_circle(x.to_int(), y.to_int(), 3.0 + fi * 0.3, @raylib.Color::new(80, 120, 200, alpha))
  }
  // Title
  let title = "ABYSSAL RIFT"
  let title_w = @raylib.measure_text(title, 60)
  @raylib.draw_text(title, (@types.screen_w - title_w) / 2, 200, 60, @raylib.Color::new(100, 200, 255, 255))
  // Subtitle
  let sub = "A Roguelite Dungeon Crawler"
  let sub_w = @raylib.measure_text(sub, 20)
  @raylib.draw_text(sub, (@types.screen_w - sub_w) / 2, 275, 20, @raylib.Color::new(150, 150, 170, 200))
  // Start prompt (blinking)
  if game.frame_count % 60 < 40 {
    let start = "Press ENTER to start"
    let start_w = @raylib.measure_text(start, 24)
    @raylib.draw_text(start, (@types.screen_w - start_w) / 2, 450, 24, @raylib.white)
  }
  // Controls
  let controls = "WASD: Move | Mouse: Aim | Click: Attack | Space: Dash | ESC: Pause"
  let ctrl_w = @raylib.measure_text(controls, 14)
  @raylib.draw_text(controls, (@types.screen_w - ctrl_w) / 2, @types.screen_h - 60, 14, @raylib.Color::new(120, 120, 140, 180))
}

///|
pub fn draw_pause_overlay(_game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, @raylib.Color::new(0, 0, 0, 150))
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(text, (@types.screen_w - tw) / 2, @types.screen_h / 2 - 40, 48, @raylib.white)
  let sub = "Press ESC to resume"
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(sub, (@types.screen_w - sw) / 2, @types.screen_h / 2 + 20, 20, @raylib.Color::new(180, 180, 180, 200))
}

///|
pub fn draw_game_over(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(30, 10, 10, 255))
  let text = "GAME OVER"
  let tw = @raylib.measure_text(text, 56)
  @raylib.draw_text(text, (@types.screen_w - tw) / 2, 200, 56, @raylib.Color::new(220, 50, 50, 255))
  // Stats
  let p = game.player
  let stats_text = "Gold: \{p.gold} | Floor: \{game.floor_num}"
  let stw = @raylib.measure_text(stats_text, 24)
  @raylib.draw_text(stats_text, (@types.screen_w - stw) / 2, 320, 24, @raylib.Color::new(200, 200, 200, 200))
  if game.frame_count % 60 < 40 {
    let restart = "Press ENTER to restart"
    let rw = @raylib.measure_text(restart, 20)
    @raylib.draw_text(restart, (@types.screen_w - rw) / 2, 420, 20, @raylib.white)
  }
}
