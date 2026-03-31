///|
/// Draw scanline overlay for cyberpunk effect
pub fn draw_scanlines(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Subtle horizontal scanlines
  let step = 3
  for y_idx in 0..<(sh / step) {
    let y = y_idx * step
    let offset = (game.frame_count / 3) % step
    if (y + offset) % (step * 2) < step {
      @raylib.draw_line(
        0,
        y,
        sw,
        y,
        @raylib.Color::new(0, 0, 0, 12),
      )
    }
  }
}

///|
/// Draw a pulsing border around the grid when alert is active
pub fn draw_alert_border(game : @types.Game) -> Unit {
  let mut has_alert = false
  for i in 0..<game.level.guards.length() {
    if game.level.guards[i].active && game.level.guards[i].alert_state is Alert {
      has_alert = true
      break
    }
  }
  if !has_alert {
    return
  }
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let gw = @types.grid_width * @types.tile_size
  let gh = @types.grid_height * @types.tile_size
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.15) * 0.5 +
    0.5
  let alpha_f : Float = 40.0 + 40.0 * pulse
  let alert_color = @raylib.Color::new(255, 30, 30, alpha_f.to_int())
  // Inner border
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(ox - 2),
      Float::from_int(oy - 2),
      Float::from_int(gw + 4),
      Float::from_int(gh + 4),
    ),
    2.0,
    alert_color,
  )
  // Outer border
  let alpha_f2 : Float = 20.0 + 20.0 * pulse
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(ox - 5),
      Float::from_int(oy - 5),
      Float::from_int(gw + 10),
      Float::from_int(gh + 10),
    ),
    1.0,
    @raylib.Color::new(255, 30, 30, alpha_f2.to_int()),
  )
}

///|
/// Draw the grid border
pub fn draw_grid_border() -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let gw = @types.grid_width * @types.tile_size
  let gh = @types.grid_height * @types.tile_size
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(ox - 1),
      Float::from_int(oy - 1),
      Float::from_int(gw + 2),
      Float::from_int(gh + 2),
    ),
    1.0,
    @raylib.Color::new(40, 60, 80, 255),
  )
}

///|
/// Draw shadow overlay on shadow tiles (extra darkening)
pub fn draw_shadow_overlay(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<@types.grid_height {
    for x in 0..<@types.grid_width {
      if game.level.tiles[y][x] is Shadow {
        let px = ox + x * ts
        let py = oy + y * ts
        // Subtle shadow particle effect
        let flicker = @types.sinf(
          Float::from_int(x * 7 + y * 13 + game.frame_count) * 0.1,
        )
        let alpha_f : Float = 30.0 + 15.0 * flicker
        @raylib.draw_rectangle(
          px + 2,
          py + 2,
          ts - 4,
          ts - 4,
          @raylib.Color::new(0, 20, 40, alpha_f.to_int()),
        )
      }
    }
  }
}

///|
/// Draw interaction prompt when near interactable objects
pub fn draw_interaction_prompt(game : @types.Game) -> Unit {
  let px = game.player.gx
  let py = game.player.gy
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  // Check for nearby terminals
  for i in 0..<game.level.terminals.length() {
    let t = game.level.terminals[i]
    if !t.hacked && @types.is_adjacent(px, py, t.gx, t.gy) {
      let cx = ox + t.gx * ts + ts / 2
      let cy = oy + t.gy * ts - 5
      let label = if t.high_security { "E: HACK [SEC]" } else { "E: HACK" }
      let lw = @draw.measure_text(label, 10)
      @draw.draw_text(
        label,
        cx - lw / 2,
        cy,
        10,
        @types.color_neon_green,
      )
      return
    }
  }
  // Check for nearby power nodes
  for i in 0..<game.level.power_nodes.length() {
    let pn = game.level.power_nodes[i]
    if @types.is_adjacent(px, py, pn.gx, pn.gy) {
      let cx = ox + pn.gx * ts + ts / 2
      let cy = oy + pn.gy * ts - 5
      let label = "E: TOGGLE"
      let lw = @draw.measure_text(label, 10)
      @draw.draw_text(
        label,
        cx - lw / 2,
        cy,
        10,
        @types.color_power_node,
      )
      return
    }
  }
}

///|
/// Draw door labels (OPEN/LOCKED)
pub fn draw_door_labels(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for i in 0..<game.level.doors.length() {
    let d = game.level.doors[i]
    let cx = ox + d.gx * ts + ts / 2
    let cy = oy + d.gy * ts + ts / 2
    if d.open {
      let label = "O"
      let lw = @draw.measure_text(label, 10)
      @draw.draw_text(
        label,
        cx - lw / 2,
        cy - 5,
        10,
        @types.color_door_open,
      )
    } else {
      let label = "X"
      let lw = @draw.measure_text(label, 10)
      @draw.draw_text(
        label,
        cx - lw / 2,
        cy - 5,
        10,
        @types.color_door_closed,
      )
    }
  }
}

///|
/// Draw power node status indicators
pub fn draw_power_indicators(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for i in 0..<game.level.power_nodes.length() {
    let pn = game.level.power_nodes[i]
    let cx = Float::from_int(ox + pn.gx * ts + ts / 2)
    let cy = Float::from_int(oy + pn.gy * ts + ts / 2)
    if pn.powered {
      // Glowing ring
      let pulse = @types.sinf(
        Float::from_int(game.frame_count) * 0.12,
      ) * 3.0 +
        Float::from_int(ts / 2 - 2)
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(cx, cy),
        pulse,
        @raylib.Color::new(255, 160, 0, 60),
      )
    } else {
      // Dim indicator
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx, cy),
        3.0,
        @raylib.Color::new(60, 30, 0, 255),
      )
    }
  }
}
