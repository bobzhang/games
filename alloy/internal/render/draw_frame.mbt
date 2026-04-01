///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Blending => draw_blending(game)
    LevelComplete => draw_level_complete(game)
    LevelFailed => draw_level_failed(game)
  }
  if game.message_timer > 0.0 {
    draw_message(game)
  }
  @fps.draw()
  @raylib.end_drawing()
}

///|
fn draw_message(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let msg_w = @draw.measure_text(game.message, 20)
  let alpha = @types.clampf(game.message_timer * 255.0, 0.0, 255.0).to_int()
  @raylib.draw_rectangle(
    (w - msg_w) / 2 - 12,
    @types.screen_height - 60,
    msg_w + 24,
    32,
    @raylib.Color::new(0, 0, 0, alpha),
  )
  @draw.draw_text(
    game.message,
    (w - msg_w) / 2,
    @types.screen_height - 55,
    20,
    @raylib.Color::new(255, 220, 150, alpha),
  )
}
