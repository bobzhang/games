///|
pub fn draw_minimap(game : @types.Game) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      // Minimap background
      let mx = @types.screen_w - 180
      let my = 55
      let mw = 170
      let mh = 130
      @raylib.draw_rectangle(
        mx,
        my,
        mw,
        mh,
        @raylib.Color::new(0, 0, 0, 150),
      )
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(
          Float::from_int(mx),
          Float::from_int(my),
          Float::from_int(mw),
          Float::from_int(mh),
        ),
        1.0,
        @raylib.Color::new(80, 80, 100, 200),
      )
      // Find bounds of all rooms for scaling
      let mut min_rx = 9999
      let mut min_ry = 9999
      let mut max_rx = -9999
      let mut max_ry = -9999
      for i in 0..<floor.rooms.length() {
        let r = floor.rooms[i]
        if r.x < min_rx {
          min_rx = r.x
        }
        if r.y < min_ry {
          min_ry = r.y
        }
        if r.x + r.w > max_rx {
          max_rx = r.x + r.w
        }
        if r.y + r.h > max_ry {
          max_ry = r.y + r.h
        }
      }
      let range_x = max_rx - min_rx
      let range_y = max_ry - min_ry
      if range_x <= 0 || range_y <= 0 {
        return
      }
      let scale_x = Float::from_int(mw - 10) / Float::from_int(range_x)
      let scale_y = Float::from_int(mh - 10) / Float::from_int(range_y)
      let scale = if scale_x < scale_y { scale_x } else { scale_y }
      // Draw rooms
      for i in 0..<floor.rooms.length() {
        let r = floor.rooms[i]
        if not(r.visited) {
          continue
        }
        let rx = mx + 5 + (Float::from_int(r.x - min_rx) * scale).to_int()
        let ry = my + 5 + (Float::from_int(r.y - min_ry) * scale).to_int()
        let rw = (Float::from_int(r.w) * scale).to_int()
        let rh = (Float::from_int(r.h) * scale).to_int()
        let color = if i == floor.current_room {
          @raylib.Color::new(100, 200, 255, 200) // Current room - bright
        } else {
          match r.kind {
            Start => @raylib.Color::new(80, 130, 200, 150)
            Combat => @raylib.Color::new(80, 80, 90, 150)
            Treasure => @raylib.Color::new(200, 180, 50, 150)
            Boss => @raylib.Color::new(200, 50, 50, 150)
            Corridor => @raylib.Color::new(50, 50, 60, 100)
          }
        }
        @raylib.draw_rectangle(rx, ry, rw, rh, color)
      }
      // Draw player dot
      let p = game.player
      let ts = @types.tile_sizef
      let px = mx +
        5 +
        ((p.x / ts - Float::from_int(min_rx)) * scale).to_int()
      let py = my +
        5 +
        ((p.y / ts - Float::from_int(min_ry)) * scale).to_int()
      @raylib.draw_circle(px, py, 2.0, @raylib.white)
    }
  }
}
