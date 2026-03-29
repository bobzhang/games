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
  } else if floor_num <= 10 {
    // Fungal Caverns
    (
      @raylib.Color::new(30, 55, 40, 255),
      @raylib.Color::new(25, 42, 35, 255),
      @raylib.Color::new(28, 46, 38, 255),
      @raylib.Color::new(18, 32, 22, 255),
    )
  } else {
    // Molten Depths
    (
      @raylib.Color::new(62, 35, 30, 255),
      @raylib.Color::new(45, 28, 25, 255),
      @raylib.Color::new(48, 32, 28, 255),
      @raylib.Color::new(35, 18, 15, 255),
    )
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
            } else {
              // Floor tile (1) or door tile (2) with subtle checker
              let color = if (x + y) % 2 == 0 {
                floor_col
              } else {
                floor_alt_col
              }
              @raylib.draw_rectangle(px, py, ts, ts, color)
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
