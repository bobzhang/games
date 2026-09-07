///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y, }
}

///|
pub fn island(x : Int, y : Int, count : Int) -> Island {
  { pos: vec2i(x, y), required_count: count, }
}

///|
pub fn new_bridge(a : Int, b : Int, dir : BridgeDir) -> Bridge {
  { island_a: a, island_b: b, count: 1, direction: dir, }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_bridges: 0, best_no_removals: false, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Active,
    current_tier: Shores,
    current_level: 0,
    islands: [],
    bridges: [],
    selected_island: -1,
    removal_count: 0,
    grid_size: 5,
    par_bridges: 0,
    level_scores: scores,
    frame_count: 0,
    hint_island_a: -1,
    hint_island_b: -1,
    hint_timer: 0.0,
    undo_stack: [],
    message: "",
    message_timer: 0.0,
    satisfaction_timers: [],
    prev_satisfied: [],
  }
}

///|
pub fn cell_size_for_grid(grid : Int) -> Int {
  if grid <= 5 {
    cell_size_5
  } else if grid <= 7 {
    cell_size_7
  } else {
    cell_size_9
  }
}

///|
pub fn island_radius_for_grid(grid : Int) -> Float {
  if grid <= 5 {
    island_radius_5
  } else if grid <= 7 {
    island_radius_7
  } else {
    island_radius_9
  }
}

///|
pub fn island_screen_x(isl : Island, grid : Int) -> Int {
  let cs = cell_size_for_grid(grid)
  grid_offset_x + isl.pos.x * cs + cs / 2
}

///|
pub fn island_screen_y(isl : Island, grid : Int) -> Int {
  let cs = cell_size_for_grid(grid)
  grid_offset_y + isl.pos.y * cs + cs / 2
}

///|
pub fn count_bridges_for_island(
  bridges : Array[Bridge],
  island_idx : Int,
) -> Int {
  let mut total = 0
  for b in bridges {
    if b.island_a == island_idx || b.island_b == island_idx {
      total = total + b.count
    }
  }
  total
}

///|
pub fn find_bridge(bridges : Array[Bridge], a : Int, b : Int) -> Int {
  for i, br in bridges {
    if (br.island_a == a && br.island_b == b) ||
      (br.island_a == b && br.island_b == a) {
      return i
    }
  }
  -1
}

///|
pub fn same_row(islands : Array[Island], a : Int, b : Int) -> Bool {
  islands[a].pos.y == islands[b].pos.y
}

///|
pub fn same_col(islands : Array[Island], a : Int, b : Int) -> Bool {
  islands[a].pos.x == islands[b].pos.x
}

///|
pub fn can_connect(islands : Array[Island], a : Int, b : Int) -> Bool {
  if a == b {
    return false
  }
  same_row(islands, a, b) || same_col(islands, a, b)
}

///|
pub fn has_island_between(islands : Array[Island], a : Int, b : Int) -> Bool {
  let pa = islands[a].pos
  let pb = islands[b].pos
  if pa.y == pb.y {
    // Horizontal - check for islands between
    let min_x = if pa.x < pb.x { pa.x } else { pb.x }
    let max_x = if pa.x > pb.x { pa.x } else { pb.x }
    for i, isl in islands {
      if i != a &&
        i != b &&
        isl.pos.y == pa.y &&
        isl.pos.x > min_x &&
        isl.pos.x < max_x {
        return true
      }
    }
    false
  } else if pa.x == pb.x {
    // Vertical - check for islands between
    let min_y = if pa.y < pb.y { pa.y } else { pb.y }
    let max_y = if pa.y > pb.y { pa.y } else { pb.y }
    for i, isl in islands {
      if i != a &&
        i != b &&
        isl.pos.x == pa.x &&
        isl.pos.y > min_y &&
        isl.pos.y < max_y {
        return true
      }
    }
    false
  } else {
    false
  }
}

///|
pub fn bridges_cross(
  islands : Array[Island],
  br1_a : Int,
  br1_b : Int,
  br2_a : Int,
  br2_b : Int,
) -> Bool {
  let a1 = islands[br1_a].pos
  let b1 = islands[br1_b].pos
  let a2 = islands[br2_a].pos
  let b2 = islands[br2_b].pos
  // One horizontal, one vertical - determine which is which
  if a1.y == b1.y && a2.x == b2.x {
    // br1 horizontal, br2 vertical
    let h_min_x = if a1.x < b1.x { a1.x } else { b1.x }
    let h_max_x = if a1.x > b1.x { a1.x } else { b1.x }
    let h_y = a1.y
    let v_min_y = if a2.y < b2.y { a2.y } else { b2.y }
    let v_max_y = if a2.y > b2.y { a2.y } else { b2.y }
    let v_x = a2.x
    v_x > h_min_x && v_x < h_max_x && h_y > v_min_y && h_y < v_max_y
  } else if a1.x == b1.x && a2.y == b2.y {
    // br1 vertical, br2 horizontal
    let h_min_x = if a2.x < b2.x { a2.x } else { b2.x }
    let h_max_x = if a2.x > b2.x { a2.x } else { b2.x }
    let h_y = a2.y
    let v_min_y = if a1.y < b1.y { a1.y } else { b1.y }
    let v_max_y = if a1.y > b1.y { a1.y } else { b1.y }
    let v_x = a1.x
    v_x > h_min_x && v_x < h_max_x && h_y > v_min_y && h_y < v_max_y
  } else {
    false // Both same direction, can't cross
  }
}

///|
pub fn would_cross_existing(
  islands : Array[Island],
  bridges : Array[Bridge],
  a : Int,
  b : Int,
) -> Bool {
  for br in bridges {
    if bridges_cross(islands, a, b, br.island_a, br.island_b) {
      return true
    }
  }
  false
}

///|
pub fn bridge_direction(islands : Array[Island], a : Int, b : Int) -> BridgeDir {
  if islands[a].pos.y == islands[b].pos.y {
    Horizontal
  } else {
    Vertical
  }
}

///|
pub fn is_connected(islands : Array[Island], bridges : Array[Bridge]) -> Bool {
  if islands.length() <= 1 {
    return true
  }
  if bridges.length() == 0 {
    return false
  }
  let visited : Array[Bool] = []
  for _i in 0..<islands.length() {
    visited.push(false)
  }
  let queue : Array[Int] = [0]
  visited[0] = true
  while queue.length() > 0 {
    let current = queue.unsafe_pop()
    for br in bridges {
      if br.island_a == current && !visited[br.island_b] {
        visited[br.island_b] = true
        queue.push(br.island_b)
      } else if br.island_b == current && !visited[br.island_a] {
        visited[br.island_a] = true
        queue.push(br.island_a)
      }
    }
  }
  for v in visited {
    if !v {
      return false
    }
  }
  true
}

///|
pub fn total_bridge_segments(bridges : Array[Bridge]) -> Int {
  let mut total = 0
  for b in bridges {
    total = total + b.count
  }
  total
}

///|
pub fn clone_bridges(bridges : Array[Bridge]) -> Array[Bridge] {
  let result : Array[Bridge] = []
  for b in bridges {
    result.push({
      island_a: b.island_a,
      island_b: b.island_b,
      count: b.count,
      direction: b.direction,
    })
  }
  result
}

///|
pub fn tier_for_level(level : Int) -> Tier {
  if level < tier1_count {
    Shores
  } else if level < tier1_count + tier2_count {
    Straits
  } else {
    Ocean
  }
}

///|
pub fn tier_start_level(tier : Tier) -> Int {
  match tier {
    Shores => 0
    Straits => tier1_count
    Ocean => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Shores => tier1_count
    Straits => tier2_count
    Ocean => tier3_count
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Shores => "Shores"
    Straits => "Straits"
    Ocean => "Ocean"
  }
}

///|
pub fn absf(a : Float) -> Float {
  if a < 0.0 {
    0.0 - a
  } else {
    a
  }
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn find_nearest_island(
  islands : Array[Island],
  grid_size : Int,
  mx : Int,
  my : Int,
) -> Int {
  let radius = island_radius_for_grid(grid_size)
  let click_radius = radius + 10.0
  let mut best = -1
  let mut best_dist = click_radius * click_radius
  for i, isl in islands {
    let sx = island_screen_x(isl, grid_size)
    let sy = island_screen_y(isl, grid_size)
    let dx = Float::from_int(mx - sx)
    let dy = Float::from_int(my - sy)
    let dist = dx * dx + dy * dy
    if dist < best_dist {
      best_dist = dist
      best = i
    }
  }
  best
}

///|
pub fn find_connectable_island_at(
  islands : Array[Island],
  bridges : Array[Bridge],
  selected : Int,
  grid_size : Int,
  mx : Int,
  my : Int,
) -> Int {
  let idx = find_nearest_island(islands, grid_size, mx, my)
  if idx < 0 || idx == selected {
    return -1
  }
  if !can_connect(islands, selected, idx) {
    return -1
  }
  if has_island_between(islands, selected, idx) {
    return -1
  }
  if would_cross_existing(islands, bridges, selected, idx) {
    return -1
  }
  idx
}

///|
pub fn set_message(game : Game, msg : String) -> Unit {
  game.message = msg
  game.message_timer = 2.0
}
