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
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn pt(x : Float, y : Float) -> Point {
  { x, y }
}

///|
pub fn point_dist(a : Point, b : Point) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn point_dist_sq(a : Point, b : Point) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  dx * dx + dy * dy
}

///|
pub fn cross_product(o : Point, a : Point, b : Point) -> Float {
  (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
}

///|
pub fn dot_product(a : Point, b : Point, c : Point, d : Point) -> Float {
  (b.x - a.x) * (d.x - c.x) + (b.y - a.y) * (d.y - c.y)
}

///|
pub fn snap_to_grid(v : Float) -> Float {
  let snapped = (v / grid_snap + 0.5).to_int()
  Float::from_int(snapped) * grid_snap
}

///|
pub fn snap_point(p : Point) -> Point {
  { x: snap_to_grid(p.x), y: snap_to_grid(p.y) }
}

///|
pub fn point_in_plane(p : Point) -> Bool {
  p.x >= plane_x &&
  p.x <= plane_x + plane_width &&
  p.y >= plane_y &&
  p.y <= plane_y + plane_height
}

///|
pub fn point_in_polygon(p : Point, poly : Array[Point]) -> Bool {
  let n = poly.length()
  if n < 3 {
    return false
  }
  let mut inside = false
  let mut j = n - 1
  for i in 0..<n {
    let pi = poly[i]
    let pj = poly[j]
    if (pi.y > p.y) != (pj.y > p.y) {
      let x_intersect = pj.x + (p.y - pj.y) / (pi.y - pj.y) * (pi.x - pj.x)
      if p.x < x_intersect {
        inside = !inside
      }
    }
    j = i
  }
  inside
}

///|
pub fn point_to_segment_dist(p : Point, a : Point, b : Point) -> Float {
  let dx = b.x - a.x
  let dy = b.y - a.y
  let len_sq = dx * dx + dy * dy
  if len_sq < 0.001 {
    return point_dist(p, a)
  }
  let mut t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / len_sq
  if t < 0.0 {
    t = 0.0
  }
  if t > 1.0 {
    t = 1.0
  }
  let proj = { x: a.x + t * dx, y: a.y + t * dy }
  point_dist(p, proj)
}

///|
pub fn make_polygon(verts : Array[Point]) -> Polygon {
  { vertices: verts }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, points_used: 0 }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Placing,
    selected_tier: Vertices,
    selected_level: 0,
    placed_points: [],
    current_hull: [],
    target: make_polygon([]),
    match_pct: 0.0,
    hull_matches: false,
    level_index: 0,
    undo_stack: [],
    scores,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    snap_preview: None,
    hover_remove: -1,
  }
}

///|
pub fn clone_points(pts : Array[Point]) -> Array[Point] {
  let result : Array[Point] = Array::new(capacity=pts.length())
  for i in 0..<pts.length() {
    result.push({ x: pts[i].x, y: pts[i].y })
  }
  result
}

///|
pub fn push_undo(game : Game) -> Unit {
  let entry : UndoEntry = { points: clone_points(game.placed_points) }
  game.undo_stack.push(entry)
  if game.undo_stack.length() > 50 {
    let new_stack : Array[UndoEntry] = Array::new(capacity=50)
    for i in 1..<game.undo_stack.length() {
      new_stack.push(game.undo_stack[i])
    }
    game.undo_stack = new_stack
  }
}

///|
pub fn pop_undo(game : Game) -> Bool {
  if game.undo_stack.length() > 0 {
    let entry = game.undo_stack[game.undo_stack.length() - 1]
    let old_len = game.undo_stack.length()
    let new_stack : Array[UndoEntry] = Array::new(capacity=old_len - 1)
    let limit = old_len - 1
    for i in 0..<limit {
      new_stack.push(game.undo_stack[i])
    }
    game.undo_stack = new_stack
    game.placed_points = entry.points
    true
  } else {
    false
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Vertices => color_tier_vertices
    Edges => color_tier_edges
    Sculpt => color_tier_sculpt
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Vertices => "VERTICES"
    Edges => "EDGES"
    Sculpt => "SCULPT"
  }
}

///|
pub fn tier_start_index(tier : Tier) -> Int {
  match tier {
    Vertices => 0
    Edges => tier1_count
    Sculpt => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Vertices => tier1_count
    Edges => tier2_count
    Sculpt => tier3_count
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn atan2f(y : Float, x : Float) -> Float {
  Float::from_double(@math.atan2(y.to_double(), x.to_double()))
}

///|
pub let pi : Float = 3.14159265

///|
pub fn floorf(v : Float) -> Float {
  Float::from_int(
    v.to_int() -
    (if v < 0.0 && v != Float::from_int(v.to_int()) { 1 } else { 0 }),
  )
}
