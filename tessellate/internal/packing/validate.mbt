///|
pub fn can_place_piece(
  region : @types.Region,
  grid : Array[Array[Int]],
  cells : Array[@types.Vec2i],
  pos : @types.Vec2i
) -> Bool {
  for i in 0..<cells.length() {
    let gx = pos.x + cells[i].x
    let gy = pos.y + cells[i].y
    if gx < 0 || gx >= region.width || gy < 0 || gy >= region.height {
      return false
    }
    if !(region.active[gy][gx]) {
      return false
    }
    if grid[gy][gx] >= 0 {
      return false
    }
  }
  true
}

///|
pub fn place_piece(
  grid : Array[Array[Int]],
  cells : Array[@types.Vec2i],
  pos : @types.Vec2i,
  piece_id : Int
) -> Unit {
  for i in 0..<cells.length() {
    let gx = pos.x + cells[i].x
    let gy = pos.y + cells[i].y
    grid[gy][gx] = piece_id
  }
}

///|
pub fn remove_piece(
  grid : Array[Array[Int]],
  piece_id : Int
) -> Unit {
  for r in 0..<grid.length() {
    for c in 0..<grid[r].length() {
      if grid[r][c] == piece_id {
        grid[r][c] = -1
      }
    }
  }
}

///|
pub fn is_region_complete(
  region : @types.Region,
  grid : Array[Array[Int]]
) -> Bool {
  for r in 0..<region.height {
    for c in 0..<region.width {
      if region.active[r][c] && grid[r][c] < 0 {
        return false
      }
    }
  }
  true
}

///|
pub fn count_empty_cells(
  region : @types.Region,
  grid : Array[Array[Int]]
) -> Int {
  let mut count = 0
  for r in 0..<region.height {
    for c in 0..<region.width {
      if region.active[r][c] && grid[r][c] < 0 {
        count += 1
      }
    }
  }
  count
}

///|
pub fn is_piece_used(
  placed : Array[@types.PlacedPiece],
  piece_index : Int
) -> Bool {
  for i in 0..<placed.length() {
    if placed[i].piece_index == piece_index {
      return true
    }
  }
  false
}

///|
pub fn count_placed(placed : Array[@types.PlacedPiece]) -> Int {
  placed.length()
}

///|
pub fn calculate_stars(
  time_seconds : Int,
  rotations : Int,
  par_time : Int,
  par_rotations : Int
) -> Int {
  let mut stars = 1
  if time_seconds <= par_time {
    stars = 2
    if rotations <= par_rotations {
      stars = 3
    }
  }
  stars
}
