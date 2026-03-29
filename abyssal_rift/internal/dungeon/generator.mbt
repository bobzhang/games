///|
/// Generate a complete Floor with interconnected rooms placed on a grid.
///
/// The algorithm:
/// 1. Lay out a grid of potential room positions (cols x rows).
/// 2. Decide which cells are occupied (probability-based, scaling with depth).
/// 3. Guarantee a start cell and a boss/stairs cell.
/// 4. Connect adjacent occupied cells with corridor rooms.
/// 5. Assign room kinds and build tile data from templates.
pub fn generate_floor(floor_num : Int, rng : UInt) -> (@types.Floor, UInt) {
  let mut state = rng
  let grid_cols = 4
  let grid_rows = 3
  let spacing_x = 28
  let spacing_y = 24

  // --- decide which grid cells are occupied ----------------------------------
  let cell_count = grid_cols * grid_rows
  let grid : Array[Bool] = Array::make(cell_count, false)

  // Start is always top-left
  grid[0] = true

  // Boss cell is always bottom-right
  let boss_idx = cell_count - 1
  grid[boss_idx] = true

  // Fill other cells with 60-80 % probability, scaling slightly with depth
  let base_chance : Float = 60.0 / 100.0 + Float::from_int(@types.clampi(floor_num, 1, 10)) * (2.0 / 100.0)
  for i in 1..<cell_count {
    if i == boss_idx {
      continue
    }
    let result = @types.rng_next(state)
    state = result.0
    let roll = result.1
    if roll < base_chance {
      grid[i] = true
    }
  }

  // Guarantee a minimum room count (6)
  let mut occupied = 0
  for i in 0..<cell_count {
    if grid[i] {
      occupied = occupied + 1
    }
  }
  // If too few, randomly enable more
  while occupied < 6 {
    let result = @types.rng_int(state, 0, cell_count - 1)
    state = result.0
    let idx = result.1
    if not(grid[idx]) {
      grid[idx] = true
      occupied = occupied + 1
    }
  }

  // Guarantee connectivity: BFS from start, enable cells on shortest path to
  // any disconnected cell.
  ensure_connectivity(grid, grid_cols, grid_rows)

  // --- collect occupied cells in order ---------------------------------------
  let cell_indices : Array[Int] = []
  for i in 0..<cell_count {
    if grid[i] {
      cell_indices.push(i)
    }
  }

  // --- assign room kinds -----------------------------------------------------
  let room_kinds : Array[@types.RoomKind] = Array::make(
    cell_indices.length(),
    Combat,
  )
  // First cell -> Start
  room_kinds[0] = Start
  // Last cell in order -> Boss on every 5th floor, otherwise Combat
  let last = cell_indices.length() - 1
  if floor_num % 5 == 0 {
    room_kinds[last] = Boss
  }

  // Pick one random non-start, non-boss cell for treasure
  if cell_indices.length() > 2 {
    let result = @types.rng_int(state, 1, cell_indices.length() - 2)
    state = result.0
    let ti = result.1
    room_kinds[ti] = Treasure
  }

  // --- build Room structs from templates -------------------------------------
  let rooms : Array[@types.Room] = []

  for ci in 0..<cell_indices.length() {
    let idx = cell_indices[ci]
    let gx = idx % grid_cols
    let gy = idx / grid_cols
    let kind = room_kinds[ci]

    // Pick a template based on kind
    let template_idx : Int = match kind {
      Start => 9
      Boss => 8
      Treasure => 7
      Combat => {
        let result = @types.rng_int(state, 0, 4)
        state = result.0
        result.1
      }
      Corridor => 5
    }

    let (tiles, tw, th) = get_template(template_idx)

    // World position in tile coords
    let wx = gx * spacing_x
    let wy = gy * spacing_y

    // Determine connections to neighbours
    let connections : Array[@types.Direction] = []
    // Right neighbour
    if gx + 1 < grid_cols && grid[gy * grid_cols + gx + 1] {
      connections.push(Right)
    }
    // Left neighbour
    if gx > 0 && grid[gy * grid_cols + gx - 1] {
      connections.push(Left)
    }
    // Down neighbour
    if gy + 1 < grid_rows && grid[(gy + 1) * grid_cols + gx] {
      connections.push(Down)
    }
    // Up neighbour
    if gy > 0 && grid[(gy - 1) * grid_cols + gx] {
      connections.push(Up)
    }

    // Punch door openings for each connection
    for d in 0..<connections.length() {
      let dir = connections[d]
      ignore(place_door(tiles, tw, th, dir))
    }

    let enemies_remaining = match kind {
      Start | Treasure | Corridor => 0
      Combat => 3 + floor_num
      Boss => 1
    }

    let room : @types.Room = {
      x: wx,
      y: wy,
      w: tw,
      h: th,
      kind,
      state: Idle,
      tiles,
      enemies_remaining,
      connections,
      visited: false,
    }
    rooms.push(room)
  }

  // --- generate corridor rooms between connected cells -----------------------
  // NOTE (known limitation): Corridor alignment uses room center averages
  // rather than actual door positions, which can cause misalignment when rooms
  // have different heights or widths.  The boss arena template already has
  // doors punched on all 4 sides so at least one corridor can always connect.
  // A more robust approach would thread the door tile coordinates through
  // place_door and use them directly for corridor endpoint placement.
  // For now this is acceptable since all templates receive doors via
  // the connection loop above and uniform-height rooms mitigate the issue.
  let corridor_set : Array[(Int, Int)] = []
  for ci in 0..<cell_indices.length() {
    let idx = cell_indices[ci]
    let gx = idx % grid_cols
    let gy = idx / grid_cols
    // Horizontal corridor to right neighbour
    if gx + 1 < grid_cols && grid[gy * grid_cols + gx + 1] {
      let key_a = idx
      let key_b = gy * grid_cols + gx + 1
      if not(corridor_exists(corridor_set, key_a, key_b)) {
        corridor_set.push((key_a, key_b))
        let room_a = find_room_at_grid(
          rooms, cell_indices, idx, grid_cols, spacing_x, spacing_y,
        )
        let room_b = find_room_at_grid(
          rooms, cell_indices, key_b, grid_cols, spacing_x, spacing_y,
        )
        match (room_a, room_b) {
          (Some(ra), Some(rb)) => {
            let corr = make_h_corridor(ra, rb)
            rooms.push(corr)
          }
          _ => ()
        }
      }
    }
    // Vertical corridor to down neighbour
    if gy + 1 < grid_rows && grid[(gy + 1) * grid_cols + gx] {
      let key_a = idx
      let key_b = (gy + 1) * grid_cols + gx
      if not(corridor_exists(corridor_set, key_a, key_b)) {
        corridor_set.push((key_a, key_b))
        let room_a = find_room_at_grid(
          rooms, cell_indices, idx, grid_cols, spacing_x, spacing_y,
        )
        let room_b = find_room_at_grid(
          rooms, cell_indices, key_b, grid_cols, spacing_x, spacing_y,
        )
        match (room_a, room_b) {
          (Some(ra), Some(rb)) => {
            let corr = make_v_corridor(ra, rb)
            rooms.push(corr)
          }
          _ => ()
        }
      }
    }
  }

  // Mark the start room as visited
  if rooms.length() > 0 {
    rooms[0].visited = true
  }

  let floor : @types.Floor = { rooms, current_room: 0, floor_num }
  (floor, state)
}

///|
/// Legacy entry point kept for backward-compat.
pub fn generate_test_floor() -> @types.Floor {
  let (floor, _) = generate_floor(1, 42U)
  floor
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

///|
fn corridor_exists(set : Array[(Int, Int)], a : Int, b : Int) -> Bool {
  for i in 0..<set.length() {
    let (sa, sb) = set[i]
    if (sa == a && sb == b) || (sa == b && sb == a) {
      return true
    }
  }
  false
}

///|
fn find_room_at_grid(
  rooms : Array[@types.Room],
  cell_indices : Array[Int],
  grid_idx : Int,
  grid_cols : Int,
  spacing_x : Int,
  spacing_y : Int
) -> @types.Room? {
  let gx = grid_idx % grid_cols
  let gy = grid_idx / grid_cols
  let wx = gx * spacing_x
  let wy = gy * spacing_y
  for i in 0..<rooms.length() {
    if rooms[i].x == wx && rooms[i].y == wy {
      return Some(rooms[i])
    }
  }
  ignore(cell_indices)
  None
}

///|
/// Create a horizontal corridor room bridging two rooms (left-to-right).
fn make_h_corridor(left : @types.Room, right : @types.Room) -> @types.Room {
  let left_edge_x = left.x + left.w
  let right_edge_x = right.x
  let gap = right_edge_x - left_edge_x
  let corridor_w = if gap > 2 { gap } else { 4 }
  let corridor_h = 6
  let corridor_x = left_edge_x
  // Vertically centre between the two rooms
  let left_cy = left.y + left.h / 2
  let right_cy = right.y + right.h / 2
  let avg_cy = (left_cy + right_cy) / 2
  let corridor_y = avg_cy - corridor_h / 2
  let tiles = Array::make(corridor_w * corridor_h, 1)
  for y in 0..<corridor_h {
    for x in 0..<corridor_w {
      if y == 0 || y == corridor_h - 1 {
        tiles[y * corridor_w + x] = 0
      }
    }
  }
  // Door openings at left and right ends
  let my = corridor_h / 2
  tiles[my * corridor_w + 0] = 2
  tiles[(my - 1) * corridor_w + 0] = 2
  tiles[my * corridor_w + (corridor_w - 1)] = 2
  tiles[(my - 1) * corridor_w + (corridor_w - 1)] = 2
  {
    x: corridor_x,
    y: corridor_y,
    w: corridor_w,
    h: corridor_h,
    kind: Corridor,
    state: Cleared,
    tiles,
    enemies_remaining: 0,
    connections: [Left, Right],
    visited: false,
  }
}

///|
/// Create a vertical corridor room bridging two rooms (top-to-bottom).
fn make_v_corridor(top : @types.Room, bottom : @types.Room) -> @types.Room {
  let top_edge_y = top.y + top.h
  let bottom_edge_y = bottom.y
  let gap = bottom_edge_y - top_edge_y
  let corridor_h = if gap > 2 { gap } else { 4 }
  let corridor_w = 6
  // Horizontally centre between the two rooms
  let top_cx = top.x + top.w / 2
  let bottom_cx = bottom.x + bottom.w / 2
  let avg_cx = (top_cx + bottom_cx) / 2
  let corridor_x = avg_cx - corridor_w / 2
  let corridor_y = top_edge_y
  let tiles = Array::make(corridor_w * corridor_h, 1)
  for y in 0..<corridor_h {
    for x in 0..<corridor_w {
      if x == 0 || x == corridor_w - 1 {
        tiles[y * corridor_w + x] = 0
      }
    }
  }
  // Door openings at top and bottom ends
  let mx = corridor_w / 2
  tiles[0 * corridor_w + mx] = 2
  tiles[0 * corridor_w + mx - 1] = 2
  tiles[(corridor_h - 1) * corridor_w + mx] = 2
  tiles[(corridor_h - 1) * corridor_w + mx - 1] = 2
  {
    x: corridor_x,
    y: corridor_y,
    w: corridor_w,
    h: corridor_h,
    kind: Corridor,
    state: Cleared,
    tiles,
    enemies_remaining: 0,
    connections: [Up, Down],
    visited: false,
  }
}

///|
/// Ensure every occupied cell is reachable from cell 0 by enabling bridge
/// cells along the shortest grid path when disconnected components exist.
fn ensure_connectivity(
  grid : Array[Bool],
  cols : Int,
  rows : Int
) -> Unit {
  let count = cols * rows
  let visited : Array[Bool] = Array::make(count, false)
  // BFS from cell 0
  let queue : Array[Int] = [0]
  visited[0] = true
  let mut head = 0
  while head < queue.length() {
    let idx = queue[head]
    head = head + 1
    let gx = idx % cols
    let gy = idx / cols
    // Four neighbours
    let neighbours : Array[Int] = []
    if gx > 0 {
      neighbours.push(gy * cols + gx - 1)
    }
    if gx + 1 < cols {
      neighbours.push(gy * cols + gx + 1)
    }
    if gy > 0 {
      neighbours.push((gy - 1) * cols + gx)
    }
    if gy + 1 < rows {
      neighbours.push((gy + 1) * cols + gx)
    }
    for n in 0..<neighbours.length() {
      let ni = neighbours[n]
      if grid[ni] && not(visited[ni]) {
        visited[ni] = true
        queue.push(ni)
      }
    }
  }

  // For every occupied-but-unvisited cell, carve a path towards cell 0
  for i in 0..<count {
    if grid[i] && not(visited[i]) {
      // Walk towards 0,0 enabling cells until we hit a visited cell
      let mut cx = i % cols
      let mut cy = i / cols
      while not(visited[cy * cols + cx]) {
        let ci = cy * cols + cx
        grid[ci] = true
        visited[ci] = true
        // Move towards (0,0)
        if cx > 0 {
          cx = cx - 1
        } else if cy > 0 {
          cy = cy - 1
        } else {
          break
        }
      }
    }
  }
}
