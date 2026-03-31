///|
fn draw_hud(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  // Top HUD bar
  @raylib.draw_rectangle(0, 0, sw, 36, @types.color_hud_bg)
  // Turn counter
  let turn_str = "Turn: " +
    game.turn.to_string() +
    "/" +
    game.turn_limit.to_string()
  @draw.draw_text(turn_str, 10, 8, 18, @types.color_hud_text)
  // Prune budget
  let prune_str = "Prunes: " +
    game.prunes_used.to_string() +
    "/" +
    game.prune_budget.to_string()
  @draw.draw_text(prune_str, 200, 8, 18, @types.color_hud_text)
  // Level name
  let tier_str = match game.current_tier {
    Seedling => "Seedling"
    Grove => "Grove"
    Forest => "Forest"
  }
  let level_in_tier = game.current_level -
    @levels.tier_start_level(game.current_tier) +
    1
  let level_str = tier_str + " - Level " + level_in_tier.to_string()
  let lw = @draw.measure_text(level_str, 18)
  @draw.draw_text(level_str, (sw - lw) / 2, 8, 18, @types.color_hud_text)
  // Controls hint
  let hint = "SPACE: Next Turn | Z: Undo | R: Restart | ESC: Menu"
  let hw = @draw.measure_text(hint, 12)
  @draw.draw_text(
    hint,
    sw - hw - 10,
    12,
    12,
    @raylib.Color::new(150, 160, 170, 200),
  )
}

///|
fn draw_target_status(game : @types.Game) -> Unit {
  let panel_x = @types.grid_offset_x + @types.grid_cols * @types.cell_size + 20
  let panel_y = @types.grid_offset_y
  // Target panel
  @raylib.draw_rectangle(panel_x, panel_y, 200, 30 + game.targets.length() * 35, @types.color_hud_bg)
  @draw.draw_text("Targets", panel_x + 10, panel_y + 6, 16, @types.color_sun)
  for i in 0..<game.targets.length() {
    let target = game.targets[i]
    let y = panel_y + 30 + i * 35
    let met = @growth.target_met(game, i)
    let color = if met { @types.color_target_met } else { @types.color_target_marker }
    let tree_label = "Tree " + (target.tree_index + 1).to_string()
    @draw.draw_text(tree_label, panel_x + 10, y + 2, 14, @types.color_hud_text)
    let height_label = if target.tree_index >= 0 && target.tree_index < game.trees.length() {
      game.trees[target.tree_index].height.to_string() +
      "/" +
      target.required_height.to_string()
    } else {
      "?/" + target.required_height.to_string()
    }
    @draw.draw_text(height_label, panel_x + 100, y + 2, 14, color)
    // Check mark or X
    let mark = if met { "[OK]" } else { "[..]" }
    @draw.draw_text(mark, panel_x + 155, y + 2, 14, color)
  }
}

///|
fn draw_water_legend(game : @types.Game) -> Unit {
  let panel_x = @types.grid_offset_x + @types.grid_cols * @types.cell_size + 20
  let panel_y = @types.grid_offset_y + 40 + game.targets.length() * 35
  @raylib.draw_rectangle(panel_x, panel_y, 200, 80, @types.color_hud_bg)
  @draw.draw_text("Water", panel_x + 10, panel_y + 6, 16, @types.color_water)
  @draw.draw_text(
    "Rain every 5 turns",
    panel_x + 10,
    panel_y + 28,
    12,
    @types.color_hud_text,
  )
  let next_rain = @types.rain_interval - game.turn % @types.rain_interval
  let rain_str = "Next rain in: " + next_rain.to_string()
  @draw.draw_text(rain_str, panel_x + 10, panel_y + 48, 12, @types.color_water)
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let sw = @types.screen_width
    let sh = @types.screen_height
    let mw = @draw.measure_text(game.message, 24)
    let mx = (sw - mw) / 2
    let my = sh - 80
    @raylib.draw_rectangle(mx - 10, my - 5, mw + 20, 34, @types.color_hud_bg)
    @draw.draw_text(game.message, mx, my, 24, @types.color_sun)
  }
}

///|
fn draw_play_state_overlay(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  match game.play_state {
    Won => {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 120))
      let stars = @growth.calculate_stars(game)
      let msg = "Level Complete!"
      let mw = @draw.measure_text(msg, 36)
      @draw.draw_text(msg, (sw - mw) / 2, sh / 3, 36, @types.color_target_met)
      // Stars
      draw_stars(stars, sw / 2, sh / 3 + 60)
      let cont = "Press ENTER to continue"
      let cw = @draw.measure_text(cont, 18)
      @draw.draw_text(cont, (sw - cw) / 2, sh / 3 + 120, 18, @types.color_hud_text)
    }
    Lost => {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 120))
      let msg = "Out of turns!"
      let mw = @draw.measure_text(msg, 36)
      @draw.draw_text(msg, (sw - mw) / 2, sh / 3, 36, @types.color_target_marker)
      let cont = "Press R to retry or ESC for menu"
      let cw = @draw.measure_text(cont, 18)
      @draw.draw_text(cont, (sw - cw) / 2, sh / 3 + 60, 18, @types.color_hud_text)
    }
    _ => ()
  }
}

///|
fn draw_stars(count : Int, cx : Int, cy : Int) -> Unit {
  for i in 0..<3 {
    let x = cx - 60 + i * 45
    let color = if i < count { @types.color_star_gold } else { @types.color_star_empty }
    // Draw star as a filled circle with points
    @raylib.draw_circle(x, cy, 15.0, color)
    // Small highlight
    if i < count {
      @raylib.draw_circle(x - 3, cy - 3, 5.0, @raylib.Color::new(255, 240, 180, 180))
    }
  }
}

///|
pub fn draw_playing(game : @types.Game) -> Unit {
  draw_forest(game)
  draw_hud(game)
  draw_target_status(game)
  draw_water_legend(game)
  draw_message(game)
  draw_play_state_overlay(game)
}
