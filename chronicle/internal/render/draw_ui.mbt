///|
fn draw_mode_indicator(game : @types.Game) -> Unit {
  // Mode indicator bar at bottom
  let bar_y = @types.screen_height - 35
  let bar_w = Float::to_int(
    Float::from_int(@types.screen_width) - @types.clue_panel_width,
  )
  @raylib.draw_rectangle(
    0,
    bar_y,
    bar_w,
    35,
    @raylib.Color::new(30, 25, 35, 230),
  )
  let mode_str = match game.play_state {
    Arranging => "MODE: ARRANGE (drag cards to timeline)"
    Linking => "MODE: LINK (click two cards to connect cause->effect)"
    Validated => "VALIDATED - review results"
  }
  let mode_color = match game.play_state {
    Arranging => @types.color_mode_arrange
    Linking => @types.color_mode_link
    Validated => @types.color_correct
  }
  @draw.draw_text(mode_str, 20, bar_y + 8, 18, mode_color)
  // Placed card count
  let case_ = @levels.get_case(game.current_tier, game.current_case_index)
  let placed = @types.count_placed(game.timeline_slots)
  let total = case_.cards.length()
  let count_str = "Cards: " + placed.to_string() + "/" + total.to_string()
  @draw.draw_text(count_str, 500, bar_y + 8, 18, @types.color_hud)
  // Link count
  let link_str = "Links: " + game.placed_links.length().to_string()
  @draw.draw_text(link_str, 650, bar_y + 8, 18, @types.color_hud)
}
