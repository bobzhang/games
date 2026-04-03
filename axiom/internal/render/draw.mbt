///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    WorldSelect => draw_world_select(game)
    LevelSelect => draw_level_select(game)
    Programming => draw_programming(game)
    Results => draw_results(game)
    Sandbox => draw_programming(game)
  }
  // Draw message overlay
  if game.message_timer > 0.0 {
    let alpha = if game.message_timer < 0.5 {
      (game.message_timer * 2.0 * 255.0).to_int()
    } else {
      255
    }
    let a = if alpha > 255 { 255 } else if alpha < 0 { 0 } else { alpha }
    let col = @raylib.Color::new(255, 255, 255, a)
    let tw = @draw.measure_text(game.message, 20)
    @draw.draw_text(
      game.message,
      @types.screen_width / 2 - tw / 2,
      @types.screen_height - 50,
      20,
      col,
    )
  }
  @raylib.end_drawing()
}

///|
fn sinf(x : Float) -> Float {
  Float::from_double(@math.sin(x.to_double()))
}
