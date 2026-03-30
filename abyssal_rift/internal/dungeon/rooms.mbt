///|
/// Room template registry.  Each template returns (tiles, width, height).
/// Tile values: 0 = wall, 1 = floor, 2 = door placeholder.

///|
pub fn get_template(index : Int) -> (Array[Int], Int, Int) {
  match index {
    0 => small_arena()
    1 => medium_arena()
    2 => large_arena()
    3 => pillared_arena()
    4 => l_shaped_room()
    5 => corridor_h()
    6 => corridor_v()
    7 => treasure_room()
    8 => boss_arena()
    9 => start_room()
    _ => small_arena()
  }
}

///|
pub fn template_count() -> Int {
  10
}

///|
/// 12x10 open room
fn small_arena() -> (Array[Int], Int, Int) {
  let w = 12
  let h = 10
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  (tiles, w, h)
}

///|
/// 16x12 open room
fn medium_arena() -> (Array[Int], Int, Int) {
  let w = 16
  let h = 12
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  (tiles, w, h)
}

///|
/// 20x15 open room
fn large_arena() -> (Array[Int], Int, Int) {
  let w = 20
  let h = 15
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  // Four small alcoves (2x2 indents) near corners
  // Top-left alcove
  tiles[1 * w + 1] = 0
  tiles[1 * w + 2] = 0
  tiles[2 * w + 1] = 0
  // Bottom-right alcove
  tiles[(h - 2) * w + (w - 2)] = 0
  tiles[(h - 2) * w + (w - 3)] = 0
  tiles[(h - 3) * w + (w - 2)] = 0
  (tiles, w, h)
}

///|
/// 16x12 room with four 2x2 pillars
fn pillared_arena() -> (Array[Int], Int, Int) {
  let w = 16
  let h = 12
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  // Four symmetrical 2x2 pillars
  let pillar_positions : Array[(Int, Int)] = [(4, 3), (10, 3), (4, 7), (10, 7)]
  for i in 0..<pillar_positions.length() {
    let (px, py) = pillar_positions[i]
    tiles[py * w + px] = 0
    tiles[py * w + px + 1] = 0
    tiles[(py + 1) * w + px] = 0
    tiles[(py + 1) * w + px + 1] = 0
  }
  (tiles, w, h)
}

///|
/// 16x16 L-shaped room (top-right corner blocked)
fn l_shaped_room() -> (Array[Int], Int, Int) {
  let w = 16
  let h = 16
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  // Block the top-right quadrant (from x=9..15, y=0..7) with walls
  for y in 0..<8 {
    for x in 9..<w {
      tiles[y * w + x] = 0
    }
  }
  // Create the inner corner edge
  for y in 1..<8 {
    tiles[y * w + 9] = 0
  }
  for x in 9..<(w - 1) {
    tiles[7 * w + x] = 0
  }
  // Open the inner corner tile for aesthetics
  tiles[8 * w + 9] = 1
  tiles[8 * w + 10] = 1
  (tiles, w, h)
}

///|
/// 12x6 horizontal corridor
fn corridor_h() -> (Array[Int], Int, Int) {
  let w = 12
  let h = 6
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  // Door placeholders at left and right midpoints
  tiles[h / 2 * w + 0] = 2
  tiles[(h / 2 - 1) * w + 0] = 2
  tiles[h / 2 * w + (w - 1)] = 2
  tiles[(h / 2 - 1) * w + (w - 1)] = 2
  (tiles, w, h)
}

///|
/// 6x12 vertical corridor
fn corridor_v() -> (Array[Int], Int, Int) {
  let w = 6
  let h = 12
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  // Door placeholders at top and bottom midpoints
  tiles[0 * w + w / 2] = 2
  tiles[0 * w + (w / 2 - 1)] = 2
  tiles[(h - 1) * w + w / 2] = 2
  tiles[(h - 1) * w + (w / 2 - 1)] = 2
  (tiles, w, h)
}

///|
/// 10x10 treasure room with alcoves on sides
fn treasure_room() -> (Array[Int], Int, Int) {
  let w = 10
  let h = 10
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  // Side alcoves - small wall protrusions on left and right
  tiles[3 * w + 1] = 0
  tiles[4 * w + 1] = 0
  tiles[5 * w + 1] = 0
  tiles[6 * w + 1] = 0
  tiles[3 * w + (w - 2)] = 0
  tiles[4 * w + (w - 2)] = 0
  tiles[5 * w + (w - 2)] = 0
  tiles[6 * w + (w - 2)] = 0
  (tiles, w, h)
}

///|
/// 24x20 large boss arena with pillars and open center
fn boss_arena() -> (Array[Int], Int, Int) {
  let w = 24
  let h = 20
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  // Four large 2x2 pillars near corners
  let pillar_positions : Array[(Int, Int)] = [
    (5, 4),
    (17, 4),
    (5, 14),
    (17, 14),
  ]
  for i in 0..<pillar_positions.length() {
    let (px, py) = pillar_positions[i]
    tiles[py * w + px] = 0
    tiles[py * w + px + 1] = 0
    tiles[(py + 1) * w + px] = 0
    tiles[(py + 1) * w + px + 1] = 0
  }
  // Small wall protrusions on sides for cover
  tiles[9 * w + 1] = 0
  tiles[10 * w + 1] = 0
  tiles[9 * w + (w - 2)] = 0
  tiles[10 * w + (w - 2)] = 0
  (tiles, w, h)
}

///|
/// 14x10 starting room - safe, with door on right side
fn start_room() -> (Array[Int], Int, Int) {
  let w = 14
  let h = 10
  let tiles = Array::make(w * h, 1)
  for y in 0..<h {
    for x in 0..<w {
      if x == 0 || x == w - 1 || y == 0 || y == h - 1 {
        tiles[y * w + x] = 0
      }
    }
  }
  (tiles, w, h)
}

///|
/// Place door markers on a room's tile array at the given edge.
/// Returns the tile-local (x, y) of one door cell for corridor connection.
pub fn place_door(
  tiles : Array[Int],
  w : Int,
  h : Int,
  dir : @types.Direction,
) -> (Int, Int) {
  match dir {
    Up => {
      let mx = w / 2
      tiles[0 * w + mx] = 2
      tiles[0 * w + mx - 1] = 2
      (mx, 0)
    }
    Down => {
      let mx = w / 2
      tiles[(h - 1) * w + mx] = 2
      tiles[(h - 1) * w + mx - 1] = 2
      (mx, h - 1)
    }
    Left => {
      let my = h / 2
      tiles[my * w + 0] = 2
      tiles[(my - 1) * w + 0] = 2
      (0, my)
    }
    Right => {
      let my = h / 2
      tiles[my * w + (w - 1)] = 2
      tiles[(my - 1) * w + (w - 1)] = 2
      (w - 1, my)
    }
  }
}
