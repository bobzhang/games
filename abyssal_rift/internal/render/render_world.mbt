///|
pub fn draw_world(game : @types.Game) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_size
      let tsf = @types.tile_sizef
      let room_px = room.x * ts
      let room_py = room.y * ts
      for y in 0..<room.h {
        for x in 0..<room.w {
          let tile = room.tiles[y * room.w + x]
          let px = room_px + x * ts
          let py = room_py + y * ts
          if tile == 0 {
            // Wall
            @raylib.draw_rectangle(px, py, ts, ts, @types.color_wall)
            // Darker edge for depth
            @raylib.draw_rectangle_lines_ex(
              @raylib.Rectangle::new(Float::from_int(px), Float::from_int(py), tsf, tsf),
              2.0,
              @raylib.Color::new(30, 28, 35, 255),
            )
          } else {
            // Floor tile with subtle checker
            let color = if (x + y) % 2 == 0 {
              @types.color_floor
            } else {
              @types.color_floor_alt
            }
            @raylib.draw_rectangle(px, py, ts, ts, color)
          }
        }
      }
    }
  }
}
