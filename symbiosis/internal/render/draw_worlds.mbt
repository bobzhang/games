///|
fn draw_worlds(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      // Draw floor world (left side)
      draw_grid_bg(
        @types.left_grid_x, @types.left_grid_y, @types.color_floor_tint,
      )
      draw_grid(
        level.floor_tiles,
        @types.left_grid_x,
        @types.left_grid_y,
        game.door_states,
        game.frame_count,
      )
      draw_gems(
        level.gems,
        game.floor_gems_collected,
        @types.left_grid_x,
        @types.left_grid_y,
        game.frame_count,
      )
      draw_character(
        game.luna,
        @types.left_grid_x,
        @types.left_grid_y,
        @types.color_luna,
        "L",
      )
      // Draw ceiling world (right side)
      draw_grid_bg(
        @types.right_grid_x, @types.right_grid_y, @types.color_ceiling_tint,
      )
      draw_grid(
        level.ceiling_tiles,
        @types.right_grid_x,
        @types.right_grid_y,
        game.door_states,
        game.frame_count,
      )
      draw_gems(
        level.ceiling_gems,
        game.ceiling_gems_collected,
        @types.right_grid_x,
        @types.right_grid_y,
        game.frame_count,
      )
      draw_character(
        game.sol,
        @types.right_grid_x,
        @types.right_grid_y,
        @types.color_sol,
        "S",
      )
      // Labels
      @draw.draw_text(
        "Floor World - Luna",
        @types.left_grid_x,
        @types.left_grid_y - 30,
        20,
        @types.color_luna,
      )
      @draw.draw_text(
        "Ceiling World - Sol",
        @types.right_grid_x,
        @types.right_grid_y - 30,
        20,
        @types.color_sol,
      )
      // Anchor indicator
      if game.luna.on_anchor {
        @draw.draw_text(
          "ANCHORED",
          @types.left_grid_x + 180,
          @types.left_grid_y - 30,
          16,
          @types.color_anchor,
        )
      }
      if game.sol.on_anchor {
        @draw.draw_text(
          "ANCHORED",
          @types.right_grid_x + 180,
          @types.right_grid_y - 30,
          16,
          @types.color_anchor,
        )
      }
    }
  }
}

///|
fn draw_grid_bg(ox : Int, oy : Int, tint : @raylib.Color) -> Unit {
  let w = @types.grid_width * @types.tile_size
  let h = @types.grid_height * @types.tile_size
  @raylib.draw_rectangle(ox - 2, oy - 2, w + 4, h + 4, tint)
}

///|
fn draw_grid(
  tiles : Array[Array[@types.TileKind]],
  ox : Int,
  oy : Int,
  door_states : Array[Bool],
  frame_count : Int,
) -> Unit {
  let ts = @types.tile_size
  for y in 0..<@types.grid_height {
    for x in 0..<@types.grid_width {
      let px = ox + x * ts
      let py = oy + y * ts
      let tile = if y < tiles.length() && x < tiles[y].length() {
        tiles[y][x]
      } else {
        Wall
      }
      let color = tile_color(tile, door_states, frame_count)
      @raylib.draw_rectangle(px + 1, py + 1, ts - 2, ts - 2, color)
      // Draw special markers
      match tile {
        Exit => {
          // Draw an X mark
          let cx = px + ts / 2
          let cy = py + ts / 2
          @raylib.draw_line(
            px + 8,
            py + 8,
            px + ts - 8,
            py + ts - 8,
            @raylib.white,
          )
          @raylib.draw_line(
            px + ts - 8,
            py + 8,
            px + 8,
            py + ts - 8,
            @raylib.white,
          )
          ignore(cx)
          ignore(cy)
        }
        Switch(_) =>
          // Draw a circle
          @raylib.draw_circle(px + ts / 2, py + ts / 2, 8.0, @raylib.white)
        Door(id) => {
          let is_open = if id >= 0 && id < door_states.length() {
            door_states[id]
          } else {
            false
          }
          if !is_open {
            // Draw bars for closed door
            for i in 0..<3 {
              let bx = px + 6 + i * 10
              @raylib.draw_rectangle(bx, py + 4, 4, ts - 8, @raylib.white)
            }
          }
        }
        Pit =>
          // Draw skull-like pattern
          @raylib.draw_circle(
            px + ts / 2,
            py + ts / 2,
            10.0,
            @raylib.Color::new(40, 0, 0, 255),
          )
        Ice => {
          // Draw sparkle lines
          let cx = px + ts / 2
          let cy = py + ts / 2
          @raylib.draw_line(cx - 6, cy, cx + 6, cy, @raylib.white)
          @raylib.draw_line(cx, cy - 6, cx, cy + 6, @raylib.white)
        }
        Anchor => {
          // Draw anchor symbol
          let cx = px + ts / 2
          let cy = py + ts / 2
          @raylib.draw_circle(
            cx,
            cy,
            6.0,
            @raylib.Color::new(180, 160, 30, 255),
          )
          @raylib.draw_circle(cx, cy, 3.0, @types.color_anchor)
        }
        _ => ()
      }
    }
  }
}

///|
fn tile_color(
  tile : @types.TileKind,
  door_states : Array[Bool],
  _frame_count : Int,
) -> @raylib.Color {
  match tile {
    Floor => @types.color_floor
    Wall => @types.color_wall
    Exit => @types.color_exit
    Switch(_) => @types.color_switch
    Door(id) => {
      let is_open = if id >= 0 && id < door_states.length() {
        door_states[id]
      } else {
        false
      }
      if is_open {
        @types.color_door_open
      } else {
        @types.color_door_closed
      }
    }
    Pit => @types.color_pit
    Ice => @types.color_ice
    Anchor => @types.color_anchor
    Gem => @types.color_floor
  }
}

///|
fn draw_gems(
  gems : Array[@types.Vec2i],
  collected : Array[Bool],
  ox : Int,
  oy : Int,
  frame_count : Int,
) -> Unit {
  let ts = @types.tile_size
  for i in 0..<gems.length() {
    if i < collected.length() && !collected[i] {
      let gp = gems[i]
      let px = ox + gp.x * ts + ts / 2
      let py = oy + gp.y * ts + ts / 2
      // Pulsing gem
      let pulse : Float = Float::from_int(frame_count % 60) / 60.0
      let size : Float = 6.0 + pulse * 2.0
      @raylib.draw_circle(px, py, size, @types.color_gem)
      @raylib.draw_circle(
        px,
        py,
        size - 2.0,
        @raylib.Color::new(255, 120, 240, 255),
      )
    }
  }
}

///|
fn draw_character(
  ch : @types.Character,
  ox : Int,
  oy : Int,
  color : @raylib.Color,
  label : String,
) -> Unit {
  if !ch.alive {
    return
  }
  let ts = @types.tile_size
  let px = ox + ch.pos.x * ts + ts / 2
  let py = oy + ch.pos.y * ts + ts / 2
  // Body
  @raylib.draw_circle(px, py, 14.0, color)
  // Inner circle (darker)
  @raylib.draw_circle(
    px,
    py,
    10.0,
    @raylib.Color::new(
      color.r.to_int() * 3 / 4,
      color.g.to_int() * 3 / 4,
      color.b.to_int() * 3 / 4,
      255,
    ),
  )
  // Label
  let lw = @draw.measure_text(label, 14)
  @draw.draw_text(label, px - lw / 2, py - 7, 14, @raylib.white)
  // Exit reached indicator
  if ch.reached_exit {
    @raylib.draw_circle_lines(px, py, 18.0, @types.color_exit)
  }
  // Anchor indicator
  if ch.on_anchor {
    @raylib.draw_circle_lines(px, py, 18.0, @types.color_anchor)
  }
}
