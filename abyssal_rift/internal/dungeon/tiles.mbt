///|
pub fn is_wall(tile : Int) -> Bool {
  tile == 0
}

///|
pub fn is_floor(tile : Int) -> Bool {
  tile == 1
}

///|
pub fn is_door(tile : Int) -> Bool {
  tile == 2
}

///|
pub fn is_walkable(tile : Int) -> Bool {
  tile == 1 || tile == 2
}

///|
/// Get the tile value at a world-pixel position by checking all rooms on
/// the floor.  Returns 0 (wall) when the position falls outside every room.
pub fn get_tile_at(
  floor : @types.Floor,
  world_x : Float,
  world_y : Float,
) -> Int {
  let ts = @types.tile_sizef
  for i in 0..<floor.rooms.length() {
    let room = floor.rooms[i]
    let rx = Float::from_int(room.x) * ts
    let ry = Float::from_int(room.y) * ts
    let rw = Float::from_int(room.w) * ts
    let rh = Float::from_int(room.h) * ts
    if world_x >= rx && world_x < rx + rw && world_y >= ry && world_y < ry + rh {
      let tx = ((world_x - rx) / ts).to_int()
      let ty = ((world_y - ry) / ts).to_int()
      if tx >= 0 && tx < room.w && ty >= 0 && ty < room.h {
        return room.tiles[ty * room.w + tx]
      }
    }
  }
  0
}

///|
/// Find which room index the world position is inside, or -1 if none.
pub fn room_at(floor : @types.Floor, world_x : Float, world_y : Float) -> Int {
  let ts = @types.tile_sizef
  for i in 0..<floor.rooms.length() {
    let room = floor.rooms[i]
    let rx = Float::from_int(room.x) * ts
    let ry = Float::from_int(room.y) * ts
    let rw = Float::from_int(room.w) * ts
    let rh = Float::from_int(room.h) * ts
    if world_x >= rx && world_x < rx + rw && world_y >= ry && world_y < ry + rh {
      return i
    }
  }
  -1
}

///|
/// Get the world-pixel center of a room.
pub fn room_center(room : @types.Room) -> (Float, Float) {
  let ts = @types.tile_sizef
  let cx = Float::from_int(room.x) * ts + Float::from_int(room.w) * ts / 2.0
  let cy = Float::from_int(room.y) * ts + Float::from_int(room.h) * ts / 2.0
  (cx, cy)
}
