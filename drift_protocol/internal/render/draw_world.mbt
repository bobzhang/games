///|
/// Draw the tile grid
pub fn draw_tiles(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<@types.grid_height {
    for x in 0..<@types.grid_width {
      let px = ox + x * ts
      let py = oy + y * ts
      let tile = game.level.tiles[y][x]
      let color = tile_color(tile, game, x, y)
      @raylib.draw_rectangle(px, py, ts, ts, color)
      // Draw grid lines
      @raylib.draw_rectangle_lines(
        px,
        py,
        ts,
        ts,
        @raylib.Color::new(30, 30, 50, 80),
      )
    }
  }
}

///|
fn tile_color(
  tile : @types.TileKind,
  game : @types.Game,
  x : Int,
  y : Int
) -> @raylib.Color {
  match tile {
    Floor => @types.color_floor
    Wall => @types.color_wall
    Shadow => @types.color_shadow_zone
    Terminal => {
      // Check if hacked
      for i in 0..<game.level.terminals.length() {
        let t = game.level.terminals[i]
        if t.gx == x && t.gy == y {
          if t.hacked {
            return @types.color_terminal_hacked
          }
          break
        }
      }
      @types.color_terminal
    }
    HighTerminal => {
      for i in 0..<game.level.terminals.length() {
        let t = game.level.terminals[i]
        if t.gx == x && t.gy == y {
          if t.hacked {
            return @types.color_terminal_hacked
          }
          break
        }
      }
      @types.color_high_terminal
    }
    Door => {
      let idx = @types.find_door_at(game.level, x, y)
      if idx >= 0 && game.level.doors[idx].open {
        @types.color_door_open
      } else {
        @types.color_door_closed
      }
    }
    LaserGrid => {
      let idx = @types.find_laser_at(game.level, x, y)
      if idx >= 0 && game.level.lasers[idx].active {
        @types.color_laser
      } else {
        @types.color_laser_off
      }
    }
    PowerNode => {
      for i in 0..<game.level.power_nodes.length() {
        let pn = game.level.power_nodes[i]
        if pn.gx == x && pn.gy == y {
          if pn.powered {
            return @types.color_power_node
          } else {
            return @types.color_power_off
          }
        }
      }
      @types.color_power_node
    }
    Exit => @types.color_exit
    CameraTile => @types.color_floor
    Start => @types.color_start
  }
}

///|
/// Draw wall edges for depth effect
pub fn draw_wall_edges(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<@types.grid_height {
    for x in 0..<@types.grid_width {
      if game.level.tiles[y][x] is Wall {
        let px = ox + x * ts
        let py = oy + y * ts
        // Draw edge on non-wall neighbors
        if y + 1 < @types.grid_height && !(game.level.tiles[y + 1][x] is Wall) {
          @raylib.draw_line(
            px,
            py + ts,
            px + ts,
            py + ts,
            @types.color_wall_edge,
          )
        }
        if x + 1 < @types.grid_width && !(game.level.tiles[y][x + 1] is Wall) {
          @raylib.draw_line(
            px + ts,
            py,
            px + ts,
            py + ts,
            @types.color_wall_edge,
          )
        }
      }
    }
  }
}

///|
/// Draw active laser beam effects
pub fn draw_laser_beams(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let pulse : Float = @types.sinf(
    Float::from_int(game.frame_count) * 0.15,
  )
  let alpha = 150 + (pulse * 50.0).to_int()
  let beam_color = @raylib.Color::new(255, 30, 30, alpha)
  for i in 0..<game.level.lasers.length() {
    let l = game.level.lasers[i]
    if !l.active {
      continue
    }
    let px = ox + l.gx * ts + ts / 2
    let py = oy + l.gy * ts + ts / 2
    if l.horizontal {
      let len = l.length * ts
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(px - ts / 2), Float::from_int(py)),
        @raylib.Vector2::new(
          Float::from_int(px - ts / 2 + len),
          Float::from_int(py),
        ),
        3.0,
        beam_color,
      )
    } else {
      let len = l.length * ts
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(px), Float::from_int(py - ts / 2)),
        @raylib.Vector2::new(
          Float::from_int(px),
          Float::from_int(py - ts / 2 + len),
        ),
        3.0,
        beam_color,
      )
    }
  }
}

///|
/// Draw power node connections
pub fn draw_power_connections(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for i in 0..<game.level.power_nodes.length() {
    let pn = game.level.power_nodes[i]
    let px1 = Float::from_int(ox + pn.gx * ts + ts / 2)
    let py1 = Float::from_int(oy + pn.gy * ts + ts / 2)
    let conn_color = if pn.powered {
      @raylib.Color::new(255, 160, 0, 40)
    } else {
      @raylib.Color::new(100, 60, 0, 30)
    }
    // Draw lines to connected doors/lasers
    for j in 0..<game.level.doors.length() {
      let d = game.level.doors[j]
      if d.power_id == pn.node_id {
        let px2 = Float::from_int(ox + d.gx * ts + ts / 2)
        let py2 = Float::from_int(oy + d.gy * ts + ts / 2)
        @raylib.draw_line_ex(
          @raylib.Vector2::new(px1, py1),
          @raylib.Vector2::new(px2, py2),
          1.0,
          conn_color,
        )
      }
    }
    for j in 0..<game.level.lasers.length() {
      let l = game.level.lasers[j]
      if l.power_id == pn.node_id {
        let px2 = Float::from_int(ox + l.gx * ts + ts / 2)
        let py2 = Float::from_int(oy + l.gy * ts + ts / 2)
        @raylib.draw_line_ex(
          @raylib.Vector2::new(px1, py1),
          @raylib.Vector2::new(px2, py2),
          1.0,
          conn_color,
        )
      }
    }
  }
}

///|
/// Draw terminal glow effect
pub fn draw_terminal_glow(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.08) * 0.3 +
    0.7
  for i in 0..<game.level.terminals.length() {
    let t = game.level.terminals[i]
    if t.hacked {
      continue
    }
    let cx = Float::from_int(ox + t.gx * ts + ts / 2)
    let cy = Float::from_int(oy + t.gy * ts + ts / 2)
    let radius = Float::from_int(ts / 2) + 4.0 * pulse
    let glow_a : Float = if t.high_security { 30.0 * pulse } else { 25.0 * pulse }
    let color = if t.high_security {
      @raylib.Color::new(255, 200, 0, glow_a.to_int())
    } else {
      @raylib.Color::new(0, 255, 100, glow_a.to_int())
    }
    @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), radius, color)
  }
}

///|
/// Draw exit glow
pub fn draw_exit_glow(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.1) * 0.4 +
    0.6
  let cx = Float::from_int(ox + game.level.exit_x * ts + ts / 2)
  let cy = Float::from_int(oy + game.level.exit_y * ts + ts / 2)
  let radius = Float::from_int(ts / 2) + 6.0 * pulse
  @raylib.draw_circle_v(
    @raylib.Vector2::new(cx, cy),
    radius,
    { let a : Float = 25.0 * pulse; @raylib.Color::new(0, 200, 255, a.to_int()) },
  )
}

///|
/// Draw noise ring with expanding ripple effect
pub fn draw_noise_ring(game : @types.Game) -> Unit {
  if game.noise_timer <= 0.0 || game.noise_radius == 0 {
    return
  }
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cx = Float::from_int(ox + game.noise_x * ts + ts / 2)
  let cy = Float::from_int(oy + game.noise_y * ts + ts / 2)
  let max_r = Float::from_int(game.noise_radius * ts)
  let alpha_ratio = game.noise_timer / @types.noise_decay_time
  // Expanding ring: starts small, grows to full radius
  let expand_t : Float = 1.0 - alpha_ratio
  let current_r : Float = max_r * (0.3 + 0.7 * expand_t)
  let alpha_f : Float = 60.0 * alpha_ratio
  let alpha = alpha_f.to_int()
  // Outer ring
  @raylib.draw_circle_lines_v(
    @raylib.Vector2::new(cx, cy),
    current_r,
    @raylib.Color::new(255, 255, 100, alpha),
  )
  // Inner ring (slightly delayed)
  let inner_alpha_f : Float = 40.0 * alpha_ratio
  let inner_r = current_r * 0.6
  if inner_r > 5.0 {
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(cx, cy),
      inner_r,
      @raylib.Color::new(255, 255, 100, inner_alpha_f.to_int()),
    )
  }
  // Tile highlight: tint tiles within noise radius
  let nr = game.noise_radius
  let tile_alpha_f : Float = 20.0 * alpha_ratio
  let tile_alpha = tile_alpha_f.to_int()
  if tile_alpha > 0 {
    for dy in -nr..=nr {
      for dx in -nr..=nr {
        let tx = game.noise_x + dx
        let ty = game.noise_y + dy
        if @types.in_bounds(tx, ty) &&
          @types.manhattan_dist(game.noise_x, game.noise_y, tx, ty) <= nr {
          let px = ox + tx * ts
          let py = oy + ty * ts
          @raylib.draw_rectangle(
            px,
            py,
            ts,
            ts,
            @raylib.Color::new(255, 255, 100, tile_alpha),
          )
        }
      }
    }
  }
}

///|
/// Draw coin indicator
pub fn draw_coin(game : @types.Game) -> Unit {
  if !game.coin_active {
    return
  }
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cx = Float::from_int(ox + game.coin_target_x * ts + ts / 2)
  let cy = Float::from_int(oy + game.coin_target_y * ts + ts / 2)
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.3) * 2.0 +
    6.0
  @raylib.draw_circle_v(
    @raylib.Vector2::new(cx, cy),
    pulse,
    @types.color_coin,
  )
}
