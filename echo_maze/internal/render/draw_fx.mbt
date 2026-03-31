///|
/// Draw scanline overlay for retro effect
pub fn draw_scanlines(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let step = 4
  for y_idx in 0..<(sh / step) {
    let y = y_idx * step
    let offset = (game.frame_count / 4) % step
    if (y + offset) % (step * 2) < step {
      @raylib.draw_line(
        0,
        y,
        sw,
        y,
        @raylib.Color::new(0, 0, 0, 8),
      )
    }
  }
}

///|
/// Draw a pulsing border when player is in danger (near max ticks)
pub fn draw_danger_border(game : @types.Game) -> Unit {
  let ratio : Float = Float::from_int(game.tick) / Float::from_int(
    game.max_ticks,
  )
  if ratio < 0.75 {
    return
  }
  let maze = match game.maze {
    Some(m) => m
    None => return
  }
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let gw = maze.width * @types.tile_size
  let gh = maze.height * @types.tile_size
  let urgency = (ratio - 0.75) * 4.0 // 0 to 1
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.2) * 0.5 + 0.5
  let alpha_f : Float = 30.0 * urgency + 30.0 * urgency * pulse
  let danger_color = @raylib.Color::new(240, 50, 50, alpha_f.to_int())
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(ox - 2),
      Float::from_int(oy - 2),
      Float::from_int(gw + 4),
      Float::from_int(gh + 4),
    ),
    2.0,
    danger_color,
  )
}

///|
/// Draw the failed state overlay
pub fn draw_failed_overlay(game : @types.Game) -> Unit {
  if !(game.play_state is Failed) {
    return
  }
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Red flash
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.15) * 0.5 + 0.5
  let alpha_f : Float = 40.0 * pulse
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(240, 20, 20, alpha_f.to_int()))
  // Text
  let text = "CAUGHT!"
  let size = 48
  let tw = @draw.measure_text(text, size)
  @draw.draw_text(
    text,
    sw / 2 - tw / 2,
    sh / 3,
    size,
    @raylib.Color::new(240, 50, 50, 255),
  )
  let hint = "Press R to retry"
  let hw = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    sw / 2 - hw / 2,
    sh / 3 + 60,
    18,
    @types.color_hud_text,
  )
}

///|
/// Draw ghost trail effect (fading positions from ghost recording)
pub fn draw_ghost_trails(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  // Only show trails when enough timeline entries exist
  if game.timeline.length() < 2 {
    return
  }
  // Show last few positions as fading dots
  let trail_length = @types.mini(8, game.timeline.length())
  let start_idx = game.timeline.length() - trail_length
  for i in start_idx..<game.timeline.length() {
    let entry = game.timeline[i]
    let age : Float = Float::from_int(game.timeline.length() - i)
    let alpha_f : Float = 30.0 / age
    let alpha = @types.clampi(alpha_f.to_int(), 5, 30)
    // Player trail
    let ppx = Float::from_int(ox + entry.player_pos.x * ts + ts / 2)
    let ppy = Float::from_int(oy + entry.player_pos.y * ts + ts / 2)
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ppx, ppy),
      4.0,
      @raylib.Color::new(0, 220, 240, alpha),
    )
    // Ghost trails
    for j in 0..<entry.ghost_positions.length() {
      let gpos = entry.ghost_positions[j]
      let gpx = Float::from_int(ox + gpos.x * ts + ts / 2)
      let gpy = Float::from_int(oy + gpos.y * ts + ts / 2)
      let gc = @types.ghost_color_for_index(j)
      let trail_color = match gc {
        Green => @raylib.Color::new(60, 220, 80, alpha)
        Yellow => @raylib.Color::new(240, 220, 40, alpha)
        Orange => @raylib.Color::new(240, 140, 40, alpha)
      }
      @raylib.draw_circle_v(
        @raylib.Vector2::new(gpx, gpy),
        3.0,
        trail_color,
      )
    }
  }
}
