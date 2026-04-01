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
/// Draw ghost trail effect using per-ghost trail_positions for colored paths
pub fn draw_ghost_trails(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  // Draw per-ghost colored trail lines from their trail_positions
  for ghost in game.ghosts {
    if ghost.trail_positions.length() < 2 {
      continue
    }
    let trail = ghost.trail_positions
    let trail_len = trail.length()
    let max_trail = @types.mini(trail_len, 30)
    let start_idx = trail_len - max_trail
    // Draw connected line segments for the trail
    for i in start_idx..<(trail_len - 1) {
      let from_pos = trail[i]
      let to_pos = trail[i + 1]
      // Fade based on age - newer segments are brighter
      let age_ratio = (i - start_idx).to_double() / max_trail.to_double()
      let alpha = (20.0 + 60.0 * age_ratio).to_int()
      let base_color = match ghost.color {
        Green => (60, 220, 80)
        Yellow => (240, 220, 40)
        Orange => (240, 140, 40)
      }
      let trail_color = @raylib.Color::new(
        base_color.0,
        base_color.1,
        base_color.2,
        alpha,
      )
      let fx = Float::from_int(ox + from_pos.x * ts + ts / 2)
      let fy = Float::from_int(oy + from_pos.y * ts + ts / 2)
      let tx = Float::from_int(ox + to_pos.x * ts + ts / 2)
      let ty = Float::from_int(oy + to_pos.y * ts + ts / 2)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(fx, fy),
        @raylib.Vector2::new(tx, ty),
        2.0,
        trail_color,
      )
    }
    // Draw dots at each trail position
    for i in start_idx..<trail_len {
      let pos = trail[i]
      let age_ratio = (i - start_idx).to_double() / max_trail.to_double()
      let alpha = (10.0 + 40.0 * age_ratio).to_int()
      let dot_size = Float::from_double(2.0 + 2.0 * age_ratio)
      let base_color = match ghost.color {
        Green => (60, 220, 80)
        Yellow => (240, 220, 40)
        Orange => (240, 140, 40)
      }
      @raylib.draw_circle_v(
        @raylib.Vector2::new(
          Float::from_int(ox + pos.x * ts + ts / 2),
          Float::from_int(oy + pos.y * ts + ts / 2),
        ),
        dot_size,
        @raylib.Color::new(base_color.0, base_color.1, base_color.2, alpha),
      )
    }
  }
  // Player trail from timeline (last 8 ticks)
  if game.timeline.length() >= 2 {
    let trail_length = @types.mini(8, game.timeline.length())
    let start_idx = game.timeline.length() - trail_length
    for i in start_idx..<game.timeline.length() {
      let entry = game.timeline[i]
      let age_ratio = (i - start_idx).to_double() / trail_length.to_double()
      let alpha = (10.0 + 30.0 * age_ratio).to_int()
      let ppx = Float::from_int(ox + entry.player_pos.x * ts + ts / 2)
      let ppy = Float::from_int(oy + entry.player_pos.y * ts + ts / 2)
      @raylib.draw_circle_v(
        @raylib.Vector2::new(ppx, ppy),
        Float::from_double(3.0 + 1.0 * age_ratio),
        @raylib.Color::new(0, 220, 240, alpha),
      )
    }
  }
}

///|
/// Draw ghost collision preview markers
pub fn draw_ghost_collision_preview(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  match game.maze_state {
    Some(maze_state) => {
      let collisions = @simulation.preview_ghost_guard_collisions(
        game.ghosts,
        maze_state,
      )
      for collision in collisions {
        let gi = collision.0
        if gi < game.ghosts.length() {
          let ghost = game.ghosts[gi]
          let gx = Float::from_int(ox + ghost.pos.x * ts + ts / 2)
          let gy = Float::from_int(oy + ghost.pos.y * ts + ts / 2)
          // Warning ring around ghost about to be caught
          let pulse = @types.sinf(
            Float::from_int(game.frame_count) * 0.4,
          ) * 4.0 + 20.0
          @raylib.draw_circle_lines_v(
            @raylib.Vector2::new(gx, gy),
            pulse,
            @raylib.Color::new(240, 50, 50, 150),
          )
          // Danger X
          @draw.draw_text(
            "X",
            (gx - 6.0).to_int(),
            (gy - 8.0).to_int(),
            16,
            @raylib.Color::new(240, 50, 50, 200),
          )
        }
      }
    }
    None => ()
  }
}

///|
/// Draw ghost button press feedback
pub fn draw_ghost_button_feedback(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  match game.maze {
    Some(maze) => {
      for fb in game.ghost_button_feedback {
        if fb.ghost_index >= game.ghosts.length() {
          continue
        }
        let ghost = game.ghosts[fb.ghost_index]
        let ghost_color = @types.ghost_color_value(ghost.color)
        // Find button position
        for y in 0..<maze.height {
          for x in 0..<maze.width {
            if maze.tiles[y][x].kind is Button(bid) && bid == fb.button_id {
              let bx = Float::from_int(ox + x * ts + ts / 2)
              let by = Float::from_int(oy + y * ts + ts / 2)
              // Expanding ring effect with ghost's color
              let progress = (1.0 - fb.timer.to_double() / 0.8)
              let radius = Float::from_double(8.0 + 20.0 * progress)
              let alpha = (200.0 * (1.0 - progress)).to_int()
              let gr = ghost_color.r.to_int()
              let gg = ghost_color.g.to_int()
              let gb = ghost_color.b.to_int()
              @raylib.draw_circle_lines_v(
                @raylib.Vector2::new(bx, by),
                radius,
                @raylib.Color::new(gr, gg, gb, alpha),
              )
              // "HELD" text indicator
              if fb.timer > 0.3 {
                let text_alpha = (200.0 * fb.timer.to_double() / 0.8).to_int()
                @draw.draw_text(
                  "HELD",
                  (bx - 12.0).to_int(),
                  (by - Float::from_int(ts) / 2.0 - 14.0).to_int(),
                  10,
                  @raylib.Color::new(gr, gg, gb, text_alpha),
                )
              }
            }
          }
        }
      }
    }
    None => ()
  }
}

///|
/// Draw restart flash overlay
pub fn draw_restart_flash(game : @types.Game) -> Unit {
  if game.restart_flash_timer <= 0.0 {
    return
  }
  let progress = game.restart_flash_timer.to_double() / 0.3
  let alpha = (40.0 * progress).to_int()
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 220, 240, alpha),
  )
}

///|
/// Draw loop transition effect
pub fn draw_loop_transition(game : @types.Game) -> Unit {
  if game.loop_transition_timer <= 0.0 {
    return
  }
  let progress = game.loop_transition_timer.to_double() / 0.3
  let alpha = (60.0 * progress).to_int()
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(60, 220, 80, alpha),
  )
  // "NEW LOOP" text flash
  if progress > 0.5 {
    let text = "NEW LOOP"
    let size = 32
    let tw = @draw.measure_text(text, size)
    let text_alpha = (255.0 * (progress - 0.5) * 2.0).to_int()
    @draw.draw_text(
      text,
      @types.screen_width / 2 - tw / 2,
      @types.screen_height / 2 - 16,
      size,
      @raylib.Color::new(60, 220, 80, text_alpha),
    )
  }
}
