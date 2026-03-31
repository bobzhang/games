///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    LevelSelect => draw_level_select(game)
    Playing => {
      draw_grid(game)
      draw_fences(game)
      draw_hover_fence(game)
      draw_region_shading(game)
      draw_ui_panel(game)
      draw_constraint_panel(game)
      draw_controls_hint(game)
    }
    Results => draw_results(game)
  }
  // Message overlay
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (@types.screen_width - msg_w) / 2,
      @types.screen_height - 60,
      24,
      @types.color_title,
    )
  }
  @raylib.end_drawing()
}
