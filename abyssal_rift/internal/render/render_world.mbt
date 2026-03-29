///|
fn get_floor_colors(floor_num : Int) -> (@raylib.Color, @raylib.Color, @raylib.Color, @raylib.Color) {
  if floor_num <= 5 {
    // Stone Crypt
    (
      @raylib.Color::new(55, 50, 62, 255),
      @raylib.Color::new(38, 35, 45, 255),
      @raylib.Color::new(42, 38, 48, 255),
      @raylib.Color::new(30, 28, 35, 255),
    )
  } else {
    // Fungal Caverns
    (
      @raylib.Color::new(30, 55, 40, 255),
      @raylib.Color::new(25, 42, 35, 255),
      @raylib.Color::new(28, 46, 38, 255),
      @raylib.Color::new(18, 32, 22, 255),
    )
  }
}

///|
fn draw_wall_shadow(px : Int, py : Int, ts : Int) -> Unit {
  @raylib.draw_rectangle(px, py + ts - 3, ts, 3, @raylib.Color::new(0, 0, 0, 30))
}

///|
fn draw_door_glow(px : Int, py : Int, ts : Int, floor_num : Int) -> Unit {
  let glow_color = if floor_num <= 5 {
    @raylib.Color::new(150, 130, 80, 60)
  } else {
    @raylib.Color::new(80, 180, 80, 60)
  }
  @raylib.draw_rectangle(px + 2, py + 2, ts - 4, ts - 4, glow_color)
}

///|
fn draw_floor_decoration(px : Int, py : Int, ts : Int, tx : Int, ty : Int) -> Unit {
  // Simple hash based on tile position to get pseudo-random decorations
  let hash = (tx * 7919 + ty * 6271) % 100
  if hash < 5 {
    // Crack mark
    let cx = px + ts / 3
    let cy = py + ts / 2
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy)),
      @raylib.Vector2::new(
        Float::from_int(cx + ts / 3),
        Float::from_int(cy + ts / 4),
      ),
      1.0,
      @raylib.Color::new(0, 0, 0, 20),
    )
  } else if hash < 8 {
    // Moss dot
    let mx = px + (hash * 3) % ts
    let my = py + (hash * 5) % ts
    @raylib.draw_circle(mx, my, 2.0, @raylib.Color::new(60, 90, 50, 25))
  }
}

///|
pub fn draw_world(game : @types.Game) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let ts = @types.tile_size
      let tsf = @types.tile_sizef
      let (wall_col, floor_col, floor_alt_col, wall_edge_col) = get_floor_colors(game.floor_num)
      // Draw all visited rooms so corridors and adjacent rooms are visible
      for ri in 0..<floor.rooms.length() {
        let room = floor.rooms[ri]
        if not(room.visited) {
          continue
        }
        let room_px = room.x * ts
        let room_py = room.y * ts
        for y in 0..<room.h {
          for x in 0..<room.w {
            let tile = room.tiles[y * room.w + x]
            let px = room_px + x * ts
            let py = room_py + y * ts
            if tile == 0 {
              // Wall
              @raylib.draw_rectangle(px, py, ts, ts, wall_col)
              // Darker edge for depth
              @raylib.draw_rectangle_lines_ex(
                @raylib.Rectangle::new(
                  Float::from_int(px),
                  Float::from_int(py),
                  tsf,
                  tsf,
                ),
                2.0,
                wall_edge_col,
              )
              // Wall shadow on south side if adjacent tile below is floor
              if y + 1 < room.h {
                let below_tile = room.tiles[(y + 1) * room.w + x]
                if below_tile != 0 {
                  draw_wall_shadow(px, py, ts)
                }
              }
            } else if tile == 2 {
              // Door tile with checker + glow
              let color = if (x + y) % 2 == 0 {
                floor_col
              } else {
                floor_alt_col
              }
              @raylib.draw_rectangle(px, py, ts, ts, color)
              draw_door_glow(px, py, ts, game.floor_num)
            } else {
              // Floor tile with subtle checker
              let color = if (x + y) % 2 == 0 {
                floor_col
              } else {
                floor_alt_col
              }
              @raylib.draw_rectangle(px, py, ts, ts, color)
              // Occasional decorative floor marks
              draw_floor_decoration(px, py, ts, x + room.x, y + room.y)
            }
          }
        }
      }
      // Room state indicators for current room
      let room = floor.rooms[floor.current_room]
      let room_px = room.x * ts
      let room_py = room.y * ts
      match room.state {
        Sealed => {
          // Red border flash indicating locked room
          let pulse = Float::from_double(
              @math.sin(game.frame_count.to_double() * 0.1),
            ) *
            0.5 +
            0.5
          let alpha = (pulse * 60.0 + 30.0).to_int()
          let border_color = @raylib.Color::new(255, 40, 40, alpha)
          let rx = Float::from_int(room_px)
          let ry = Float::from_int(room_py)
          let rw = Float::from_int(room.w * ts)
          let rh = Float::from_int(room.h * ts)
          @raylib.draw_rectangle_lines_ex(
            @raylib.Rectangle::new(rx, ry, rw, rh),
            3.0,
            border_color,
          )
        }
        Cleared => {
          let border_color = @raylib.Color::new(40, 200, 40, 30)
          let rx = Float::from_int(room_px)
          let ry = Float::from_int(room_py)
          let rw = Float::from_int(room.w * ts)
          let rh = Float::from_int(room.h * ts)
          @raylib.draw_rectangle_lines_ex(
            @raylib.Rectangle::new(rx, ry, rw, rh),
            2.0,
            border_color,
          )
        }
        _ => ()
      }
    }
  }
}
