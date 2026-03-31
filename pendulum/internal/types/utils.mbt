///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
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
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn vec2f(x : Float, y : Float) -> Vec2f {
  { x, y }
}

///|
pub fn vec2f_zero() -> Vec2f {
  { x: 0.0, y: 0.0 }
}

///|
pub fn grid_to_screen_x(gx : Int) -> Float {
  Float::from_int(grid_offset_x + gx * cell_size + cell_size / 2)
}

///|
pub fn grid_to_screen_y(gy : Int) -> Float {
  Float::from_int(grid_offset_y + gy * cell_size + cell_size / 2)
}

///|
pub fn screen_to_grid_x(sx : Float) -> Int {
  let v = (sx.to_int() - grid_offset_x) / cell_size
  if v < 0 {
    0
  } else if v >= grid_cols {
    grid_cols - 1
  } else {
    v
  }
}

///|
pub fn screen_to_grid_y(sy : Float) -> Int {
  let v = (sy.to_int() - grid_offset_y) / cell_size
  if v < 0 {
    0
  } else if v >= grid_rows {
    grid_rows - 1
  } else {
    v
  }
}

///|
pub fn dist_i(a : Vec2i, b : Vec2i) -> Float {
  let dx = Float::from_int(a.x - b.x)
  let dy = Float::from_int(a.y - b.y)
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn atan2f(y : Float, x : Float) -> Float {
  Float::from_double(@math.atan2(y.to_double(), x.to_double()))
}

///|
pub fn floorf(v : Float) -> Int {
  let d = v.to_double()
  let i = d.to_int()
  if d < 0.0 && Float::from_int(i) != v {
    i - 1
  } else {
    i
  }
}

///|
pub fn roundf(v : Float) -> Int {
  floorf(v + 0.5)
}

///|
pub fn compute_arc_points(
  anchor : Vec2i,
  length : Int
) -> Array[ArcPoint] {
  let points : Array[ArcPoint] = []
  if length <= 0 {
    return points
  }
  let r = length
  // Scan all grid positions within bounding box of circle
  // Only keep points at distance ~= r from anchor (on the circle)
  // and that are below or at anchor level (pendulum hangs down)
  let ax = anchor.x
  let ay = anchor.y
  for dy = 0; dy <= r; dy = dy + 1 {
    for dx = -r; dx <= r; dx = dx + 1 {
      let gx = ax + dx
      let gy = ay + dy
      if gx >= 0 && gx < grid_cols && gy >= 0 && gy < grid_rows {
        let dist_sq = dx * dx + dy * dy
        let r_sq = r * r
        // Accept points within a tolerance band for the circle
        // For discrete grid, we allow dist_sq to be within +-r of r_sq
        let diff = absi(dist_sq - r_sq)
        if diff <= r {
          let angle = atan2f(
            Float::from_int(dy),
            Float::from_int(dx),
          )
          points.push({ gx, gy, angle })
        }
      }
    }
  }
  // Sort by angle (left to right sweep)
  sort_arc_points(points)
  // Remove duplicates (same grid position)
  dedupe_arc_points(points)
  points
}

///|
fn sort_arc_points(points : Array[ArcPoint]) -> Unit {
  // Simple insertion sort by angle
  for i = 1; i < points.length(); i = i + 1 {
    let key = points[i]
    let mut j = i - 1
    while j >= 0 && points[j].angle > key.angle {
      points[j + 1] = points[j]
      j = j - 1
    }
    points[j + 1] = key
  }
}

///|
fn dedupe_arc_points(points : Array[ArcPoint]) -> Unit {
  if points.length() <= 1 {
    return
  }
  let mut write = 1
  for read = 1; read < points.length(); read = read + 1 {
    let prev = points[write - 1]
    let curr = points[read]
    if curr.gx != prev.gx || curr.gy != prev.gy {
      points[write] = curr
      write = write + 1
    }
  }
  // Truncate
  while points.length() > write {
    let _ = points.pop()

  }
}

///|
pub fn compute_launch_velocity(
  anchor : Vec2i,
  weight_pos : Vec2i,
  swing_dir : SwingDir
) -> Vec2f {
  let dx = Float::from_int(weight_pos.x - anchor.x)
  let dy = Float::from_int(weight_pos.y - anchor.y)
  let len = sqrtf(dx * dx + dy * dy)
  if len < 0.001 {
    return vec2f_zero()
  }
  // Tangent to circle: perpendicular to radius
  // For clockwise/left swing: tangent = (dy/len, -dx/len)
  // For right swing: tangent = (-dy/len, dx/len)
  let speed : Float = 1.0
  match swing_dir {
    Left => vec2f(dy / len * speed, -dx / len * speed)
    Right => vec2f(-dy / len * speed, dx / len * speed)
  }
}

///|
pub fn new_empty_grid() -> Array[Array[CellKind]] {
  let grid : Array[Array[CellKind]] = []
  for _row = 0; _row < grid_rows; _row = _row + 1 {
    let row : Array[CellKind] = []
    for _col = 0; _col < grid_cols; _col = _col + 1 {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, best_ticks: 9999, collectibles_got: 0 }
}

///|
pub fn new_weight() -> Weight {
  {
    pos: vec2i(0, 0),
    state: Swinging,
    swing_dir: Right,
    arc_index: 0,
    launch_vel: vec2f_zero(),
    launch_pos: vec2f_zero(),
  }
}

///|
pub fn new_rope() -> Rope {
  { anchor: vec2i(0, 0), length: 0, wrapped_pegs: [] }
}

///|
pub fn new_history_entry(
  w : Weight,
  r : Rope,
  tick : Int,
  collected : Array[Bool]
) -> HistoryEntry {
  let wp : Array[Vec2i] = []
  for i = 0; i < r.wrapped_pegs.length(); i = i + 1 {
    wp.push(r.wrapped_pegs[i])
  }
  let coll : Array[Bool] = []
  for i = 0; i < collected.length(); i = i + 1 {
    coll.push(collected[i])
  }
  {
    weight_pos: w.pos,
    weight_state: w.state,
    swing_dir: w.swing_dir,
    arc_index: w.arc_index,
    anchor: r.anchor,
    rope_length: r.length,
    wrapped_pegs: wp,
    tick_count: tick,
    collected: coll,
    launch_vel: vec2f(w.launch_vel.x, w.launch_vel.y),
    launch_pos: vec2f(w.launch_pos.x, w.launch_pos.y),
  }
}

///|
pub fn restore_from_history(
  entry : HistoryEntry,
  w : Weight,
  r : Rope,
  collected : Array[Bool]
) -> Int {
  w.pos = entry.weight_pos
  w.state = entry.weight_state
  w.swing_dir = entry.swing_dir
  w.arc_index = entry.arc_index
  w.launch_vel = vec2f(entry.launch_vel.x, entry.launch_vel.y)
  w.launch_pos = vec2f(entry.launch_pos.x, entry.launch_pos.y)
  r.anchor = entry.anchor
  r.length = entry.rope_length
  r.wrapped_pegs = []
  for i = 0; i < entry.wrapped_pegs.length(); i = i + 1 {
    r.wrapped_pegs.push(entry.wrapped_pegs[i])
  }
  for i = 0; i < collected.length() && i < entry.collected.length(); i = i + 1 {
    collected[i] = entry.collected[i]
  }
  entry.tick_count
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i = 0; _i < total_levels; _i = _i + 1 {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Swing,
    selected_level: 0,
    current_level: None,
    play_state: Ready,
    weight: new_weight(),
    rope: new_rope(),
    arc_points: [],
    tick_count: 0,
    collected: [],
    history: [],
    scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
    title_angle: 0.0,
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Swing => "Swing"
    Wrap => "Wrap"
    Launch => "Launch"
  }
}

///|
pub fn tier_color(t : Tier) -> @raylib.Color {
  match t {
    Swing => color_tier_swing
    Wrap => color_tier_wrap
    Launch => color_tier_launch
  }
}

///|
pub fn tier_level_count(t : Tier) -> Int {
  match t {
    Swing => tier1_count
    Wrap => tier2_count
    Launch => tier3_count
  }
}

///|
pub fn tier_level_offset(t : Tier) -> Int {
  match t {
    Swing => 0
    Wrap => tier1_count
    Launch => tier1_count + tier2_count
  }
}

///|
pub fn find_arc_index_for_pos(
  arc : Array[ArcPoint],
  pos : Vec2i
) -> Int {
  for i = 0; i < arc.length(); i = i + 1 {
    if arc[i].gx == pos.x && arc[i].gy == pos.y {
      return i
    }
  }
  // Find closest
  let mut best = 0
  let mut best_dist : Float = 99999.0
  for i = 0; i < arc.length(); i = i + 1 {
    let d = dist_i(pos, vec2i(arc[i].gx, arc[i].gy))
    if d < best_dist {
      best_dist = d
      best = i
    }
  }
  best
}
