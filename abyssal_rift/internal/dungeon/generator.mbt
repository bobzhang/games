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
  let base_chance : Float = 60.0 / 100.0 +
    Float::from_int(@types.clampi(floor_num, 1, 10)) * (2.0 / 100.0)
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
    if !(grid[idx]) {
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

  // Pick one random non-start, non-boss, non-treasure cell for shrine (on floors with 5+ rooms)
  if cell_indices.length() >= 5 {
    let mut attempts = 0
    while attempts < 20 {
      let result = @types.rng_int(state, 1, cell_indices.length() - 2)
      state = result.0
      let si = result.1
      if room_kinds[si] == Combat {
        room_kinds[si] = Shrine
        break
      }
      attempts += 1
    }
  }

  // Pick one random Combat cell for EliteVault on floors 4+ (skip boss floors)
  if floor_num >= 4 && floor_num % 5 != 0 {
    let mut attempts = 0
    while attempts < 20 {
      let result = @types.rng_int(state, 1, cell_indices.length() - 2)
      state = result.0
      let ei = result.1
      if room_kinds[ei] == Combat {
        room_kinds[ei] = EliteVault
        break
      }
      attempts += 1
    }
  }

  // Pick one random Combat cell for Challenge on floors 6+ (skip boss floors)
  if floor_num >= 6 && floor_num % 5 != 0 {
    let mut attempts = 0
    while attempts < 20 {
      let result = @types.rng_int(state, 1, cell_indices.length() - 2)
      state = result.0
      let ci = result.1
      if room_kinds[ci] == Combat {
        room_kinds[ci] = Challenge
        break
      }
      attempts += 1
    }
  }

  // --- build Room structs from templates -------------------------------------
  let rooms : Array[@types.Room] = []

  // Store world-space door positions keyed as (grid_index * 4 + dir_index).
  // dir_index: 0=Up, 1=Down, 2=Left, 3=Right
  let door_positions : Array[(Int, Int, Int)] = [] // (key, world_x, world_y)

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
      Shrine => 7
      EliteVault => 8 // Use boss-size arena for elite vault
      Challenge => 8 // Use boss-size arena for challenge
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

    // Punch door openings for each connection and record world-space positions
    for d in 0..<connections.length() {
      let dir = connections[d]
      let (door_tx, door_ty) = place_door(tiles, tw, th, dir)
      let world_door_x = wx + door_tx
      let world_door_y = wy + door_ty
      let dir_index = match dir {
        Up => 0
        Down => 1
        Left => 2
        Right => 3
      }
      let key = idx * 4 + dir_index
      door_positions.push((key, world_door_x, world_door_y))
    }

    let enemies_remaining = match kind {
      Start | Treasure | Corridor | Shrine => 0
      Combat => 3 + floor_num
      Boss => 1
      EliteVault => 3 // 2-3 elites
      Challenge => 5 + floor_num // Waves
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
  // Corridors now use actual door world-space positions as endpoints, creating
  // L-shaped paths when doors don't share the same row/column.
  let corridor_set : Array[(Int, Int)] = []
  for ci in 0..<cell_indices.length() {
    let idx = cell_indices[ci]
    let gx = idx % grid_cols
    let gy = idx / grid_cols
    // Horizontal corridor to right neighbour
    if gx + 1 < grid_cols && grid[gy * grid_cols + gx + 1] {
      let key_a = idx
      let key_b = gy * grid_cols + gx + 1
      if !(corridor_exists(corridor_set, key_a, key_b)) {
        corridor_set.push((key_a, key_b))
        // room_a's Right door -> room_b's Left door
        let door_key_a = key_a * 4 + 3 // Right = 3
        let door_key_b = key_b * 4 + 2 // Left = 2
        match
          (
            lookup_door(door_positions, door_key_a),
            lookup_door(door_positions, door_key_b),
          ) {
          (Some((x1, y1)), Some((x2, y2))) => {
            let corr = create_corridor_between(x1, y1, x2, y2, true)
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
      if !(corridor_exists(corridor_set, key_a, key_b)) {
        corridor_set.push((key_a, key_b))
        // room_a's Down door -> room_b's Up door
        let door_key_a = key_a * 4 + 1 // Down = 1
        let door_key_b = key_b * 4 + 0 // Up = 0
        match
          (
            lookup_door(door_positions, door_key_a),
            lookup_door(door_positions, door_key_b),
          ) {
          (Some((x1, y1)), Some((x2, y2))) => {
            let corr = create_corridor_between(x1, y1, x2, y2, false)
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
/// Look up a door's world-space position by key in the flat array.
fn lookup_door(positions : Array[(Int, Int, Int)], key : Int) -> (Int, Int)? {
  for i in 0..<positions.length() {
    let (k, x, y) = positions[i]
    if k == key {
      return Some((x, y))
    }
  }
  None
}

///|
/// Set a tile to floor (1) if it is within bounds.
fn carve(tiles : Array[Int], cw : Int, ch : Int, x : Int, y : Int) -> Unit {
  if x >= 0 && x < cw && y >= 0 && y < ch {
    tiles[y * cw + x] = 1
  }
}

///|
/// Carve a 3-wide horizontal strip of floor tiles from x_start to x_end
/// (inclusive) centred on row cy.
fn carve_h_strip(
  tiles : Array[Int],
  cw : Int,
  ch : Int,
  x_start : Int,
  x_end : Int,
  cy : Int,
) -> Unit {
  let lo = @types.mini(x_start, x_end)
  let hi = @types.maxi(x_start, x_end)
  let mut x = lo
  while x <= hi {
    carve(tiles, cw, ch, x, cy - 1)
    carve(tiles, cw, ch, x, cy)
    carve(tiles, cw, ch, x, cy + 1)
    x = x + 1
  }
}

///|
/// Carve a 3-wide vertical strip of floor tiles from y_start to y_end
/// (inclusive) centred on column cx.
fn carve_v_strip(
  tiles : Array[Int],
  cw : Int,
  ch : Int,
  cx : Int,
  y_start : Int,
  y_end : Int,
) -> Unit {
  let lo = @types.mini(y_start, y_end)
  let hi = @types.maxi(y_start, y_end)
  let mut y = lo
  while y <= hi {
    carve(tiles, cw, ch, cx - 1, y)
    carve(tiles, cw, ch, cx, y)
    carve(tiles, cw, ch, cx + 1, y)
    y = y + 1
  }
}

///|
/// Create an L-shaped corridor room connecting two door positions.
///
/// `horizontal` = true means the primary direction is left-to-right (the
/// start door faces Right, the end door faces Left).  When false the primary
/// direction is top-to-bottom.
///
/// The corridor is 3 tiles wide (1 wall + 1 floor + 1 wall) along its
/// cross-axis.  If the two doors are not aligned on the cross-axis the path
/// makes a single L-bend at the midpoint of the primary axis.
fn create_corridor_between(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  horizontal : Bool,
) -> @types.Room {
  // Padding: 1 tile of wall on each side of the 1-tile-wide walkable centre.
  let pad = 2
  if horizontal {
    // Primary axis: X.  Cross axis: Y.
    let left_x = x1
    let right_x = x2
    let mid_x = (left_x + right_x) / 2
    // Bounding box in world coords
    let min_y = @types.mini(y1, y2) - pad
    let max_y = @types.maxi(y1, y2) + pad
    let cw = right_x - left_x + 1
    let ch = max_y - min_y + 1
    let tiles = Array::make(cw * ch, 0)
    // Local Y coords of each door within the tile array
    let ly1 = y1 - min_y
    let ly2 = y2 - min_y
    let lmid = mid_x - left_x
    // Carve: horizontal from door1 to mid, vertical bend, horizontal from mid to door2
    carve_h_strip(tiles, cw, ch, 0, lmid, ly1)
    carve_h_strip(tiles, cw, ch, lmid, cw - 1, ly2)
    carve_v_strip(tiles, cw, ch, lmid, ly1, ly2)
    // Punch door openings at corridor ends
    tiles[ly1 * cw + 0] = 2
    if ly1 - 1 >= 0 {
      tiles[(ly1 - 1) * cw + 0] = 2
    }
    tiles[ly2 * cw + (cw - 1)] = 2
    if ly2 - 1 >= 0 {
      tiles[(ly2 - 1) * cw + (cw - 1)] = 2
    }
    {
      x: left_x,
      y: min_y,
      w: cw,
      h: ch,
      kind: Corridor,
      state: Cleared,
      tiles,
      enemies_remaining: 0,
      connections: [Left, Right],
      visited: false,
    }
  } else {
    // Primary axis: Y.  Cross axis: X.
    let top_y = y1
    let bot_y = y2
    let mid_y = (top_y + bot_y) / 2
    let min_x = @types.mini(x1, x2) - pad
    let max_x = @types.maxi(x1, x2) + pad
    let cw = max_x - min_x + 1
    let ch = bot_y - top_y + 1
    let tiles = Array::make(cw * ch, 0)
    // Local X coords of each door within the tile array
    let lx1 = x1 - min_x
    let lx2 = x2 - min_x
    let lmid = mid_y - top_y
    // Carve: vertical from door1 to mid, horizontal bend, vertical from mid to door2
    carve_v_strip(tiles, cw, ch, lx1, 0, lmid)
    carve_v_strip(tiles, cw, ch, lx2, lmid, ch - 1)
    carve_h_strip(tiles, cw, ch, lx1, lx2, lmid)
    // Punch door openings at corridor ends
    tiles[0 * cw + lx1] = 2
    if lx1 - 1 >= 0 {
      tiles[0 * cw + (lx1 - 1)] = 2
    }
    tiles[(ch - 1) * cw + lx2] = 2
    if lx2 - 1 >= 0 {
      tiles[(ch - 1) * cw + (lx2 - 1)] = 2
    }
    {
      x: min_x,
      y: top_y,
      w: cw,
      h: ch,
      kind: Corridor,
      state: Cleared,
      tiles,
      enemies_remaining: 0,
      connections: [Up, Down],
      visited: false,
    }
  }
}

///|
/// Ensure every occupied cell is reachable from cell 0 by enabling bridge
/// cells along the shortest grid path when disconnected components exist.
fn ensure_connectivity(grid : Array[Bool], cols : Int, rows : Int) -> Unit {
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
      if grid[ni] && !(visited[ni]) {
        visited[ni] = true
        queue.push(ni)
      }
    }
  }

  // For every occupied-but-unvisited cell, carve a path towards cell 0
  for i in 0..<count {
    if grid[i] && !(visited[i]) {
      // Walk towards 0,0 enabling cells until we hit a visited cell
      let mut cx = i % cols
      let mut cy = i / cols
      while !(visited[cy * cols + cx]) {
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
