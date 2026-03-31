///|
fn draw_game_ui(game : @types.Game, level : @types.Level) -> Unit {
  let w = @types.screen_width
  // Timer
  let time_s = game.timer.to_int()
  let time_text = "Time: " + time_s.to_string() + "s"
  @draw.draw_text(time_text, 40, 10, 22, @types.color_text)
  // Par time
  let par_text = "Par: " + level.par_time.to_string() + "s"
  @draw.draw_text(par_text, 200, 10, 18, @types.color_star)
  // Rotation counter
  let rot_text = "Rotations: " + game.rotation_count.to_string()
  @draw.draw_text(rot_text, 360, 10, 22, @types.color_text)
  // Par rotations
  let par_rot = "Par: " + level.par_rotations.to_string()
  @draw.draw_text(par_rot, 540, 10, 18, @types.color_star)
  // Empty cells count
  let empty = @packing.count_empty_cells(level.region, game.grid)
  let total = @types.count_active_cells(level.region)
  let fill_text = "Filled: " + (total - empty).to_string() + "/" + total.to_string()
  @draw.draw_text(fill_text, 40, @types.screen_height - 35, 20, @types.color_text)
  // Level info
  let level_num = game.current_level + 1
  let tier_name = @types.tier_name(game.current_tier)
  let info = tier_name + " - Level " + level_num.to_string()
  let info_w = @draw.measure_text(info, 20)
  @draw.draw_text(info, w - info_w - 20, 10, 20, @types.color_title)
  // Controls help
  let ctrl1 = "R: Rotate  F: Flip"
  @draw.draw_text(
    ctrl1,
    @types.palette_x,
    @types.screen_height - 60,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
  let ctrl2 = "Click: Place  Right-Click: Remove"
  @draw.draw_text(
    ctrl2,
    @types.palette_x,
    @types.screen_height - 35,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
  let ctrl3 = "ESC: Back  C: Clear All"
  @draw.draw_text(
    ctrl3,
    @types.palette_x + 400,
    @types.screen_height - 35,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
  // Current piece info
  if game.selected_piece >= 0 && game.selected_piece < level.pieces.length() {
    let piece = level.pieces[game.selected_piece]
    let sel_text = "Selected: Piece " + (game.selected_piece + 1).to_string() + " (" + piece.cells.length().to_string() + " cells)"
    @draw.draw_text(
      sel_text,
      40,
      @types.screen_height - 60,
      18,
      @types.color_selected,
    )
    let rot_info = "Rot: " + (game.rotation * 90).to_string() + "deg" + (if game.flipped { " Flipped" } else { "" })
    @draw.draw_text(
      rot_info,
      300,
      @types.screen_height - 60,
      18,
      @types.color_selected,
    )
  }
  // Message
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (@types.screen_width - msg_w) / 2,
      @types.screen_height / 2 + 200,
      24,
      @types.color_title,
    )
  }
}
