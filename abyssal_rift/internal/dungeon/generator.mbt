///|
/// Generate a test room for Phase 1 vertical slice
pub fn generate_test_floor() -> @types.Floor {
  let room_w = 20
  let room_h = 15
  let tiles : Array[Int] = Array::make(room_w * room_h, 1)
  // Set walls around edges
  for y in 0..<room_h {
    for x in 0..<room_w {
      if x == 0 || x == room_w - 1 || y == 0 || y == room_h - 1 {
        tiles[y * room_w + x] = 0
      }
    }
  }
  let room : @types.Room = {
    x: 0, y: 0, w: room_w, h: room_h,
    kind: Combat, state: Idle,
    tiles,
    enemies_remaining: 0,
    connections: [],
  }
  { rooms: [room], current_room: 0, floor_num: 1 }
}
