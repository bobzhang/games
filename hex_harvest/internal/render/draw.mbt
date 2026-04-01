///|
/// Main draw dispatch
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    WorldSelect => draw_world_select(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Results => draw_results(game)
  }
  @raylib.end_drawing()
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  // Draw hex grid
  draw_hex_grid(game)
  // Draw water overlays
  draw_water_overlays(game)
  // Draw channels
  draw_channels(game)
  // Draw crops
  draw_crops(game)
  // Draw goal markers
  draw_goals(game)
  // Draw hover highlight
  draw_hover(game)
  // Draw click feedback
  draw_click_feedback(game)
  // Draw water flow preview
  draw_water_preview(game)
  // Draw adjacency preview
  draw_adjacency_preview(game)
  // Draw turn phase indicator
  draw_phase_indicator(game)
  // Draw harvest animation
  draw_harvest_anim(game)
  // Draw UI
  draw_hud(game)
  draw_projected_yield(game)
  draw_crop_palette(game)
  draw_controls_help(game)
  // Draw message
  draw_message(game)
}
