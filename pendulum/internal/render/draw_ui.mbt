///|
fn draw_hud(game : @types.Game, level : @types.Level) -> Unit {
  let sw = @types.screen_width
  // Top bar
  @raylib.draw_rectangle(0, 0, sw, 64, @types.color_hud_bg)
  // Level name
  @draw.draw_text(level.name, 16, 8, 24, @types.color_text)
  // Tier badge
  let tier_col = @types.tier_color(level.tier)
  let tier_str = @types.tier_name(level.tier)
  @draw.draw_text(tier_str, 16, 36, 16, tier_col)
  // Tick counter
  let tick_str = "Tick: " + game.tick_count.to_string()
  @draw.draw_text(tick_str, 300, 8, 24, @types.color_text)
  // Par
  let par_str = "Par: " + level.par_ticks.to_string()
  @draw.draw_text(par_str, 300, 36, 16, @types.color_text_dim)
  // State
  let state_str = match game.weight.state {
    Swinging => {
      let dir = match game.weight.swing_dir {
        Left => "<< Left"
        Right => "Right >>"
      }
      "Swinging " + dir
    }
    Launched => "Launched!"
    Stopped => "Stopped"
    AtGoal => "Goal!"
  }
  @draw.draw_text(state_str, 500, 8, 20, @types.color_weight)
  // Play state
  match game.play_state {
    Won => @draw.draw_text("LEVEL COMPLETE!", 500, 36, 16, @types.color_goal)
    Lost =>
      @draw.draw_text(
        "Weight stopped - Press R to retry",
        500,
        36,
        16,
        @raylib.Color::new(255, 80, 80, 255),
      )
    _ => ()
  }
  // Collectibles
  let mut got = 0
  for i = 0; i < game.collected.length(); i = i + 1 {
    if game.collected[i] {
      got = got + 1
    }
  }
  if level.collectibles.length() > 0 {
    let coll_str = "Items: " +
      got.to_string() +
      "/" +
      level.collectibles.length().to_string()
    @draw.draw_text(coll_str, 800, 8, 20, @types.color_collectible)
  }
  // Controls at bottom
  let bot_y = @types.screen_height - 40
  @raylib.draw_rectangle(0, bot_y - 8, sw, 48, @types.color_hud_bg)
  @draw.draw_text(
    "[Space] Tick  [C] Cut  [Z] Undo  [R] Restart  [Esc] Back",
    16,
    bot_y,
    18,
    @types.color_text_dim,
  )
  // Message
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 28)
    let mx = (sw - mw) / 2
    @draw.draw_text(game.message, mx, 340, 28, @types.color_weight)
  }
}
