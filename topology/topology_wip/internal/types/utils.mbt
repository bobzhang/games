///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn new_shape(cells : Array[Vec2i]) -> Shape {
  { cells, }
}

///|
pub fn shape_clone(s : Shape) -> Shape {
  let cells : Array[Vec2i] = Array::new(capacity=s.cells.length())
  for i in 0..<s.cells.length() {
    cells.push(s.cells[i])
  }
  { cells, }
}

///|
pub fn shape_contains(s : Shape, v : Vec2i) -> Bool {
  for i in 0..<s.cells.length() {
    if s.cells[i].x == v.x && s.cells[i].y == v.y {
      return true
    }
  }
  false
}

///|
pub fn shape_center_x(s : Shape) -> Float {
  if s.cells.length() == 0 {
    return 0.0
  }
  let mut sum = 0
  for i in 0..<s.cells.length() {
    sum = sum + s.cells[i].x
  }
  Float::from_int(sum) / Float::from_int(s.cells.length())
}

///|
pub fn shape_center_y(s : Shape) -> Float {
  if s.cells.length() == 0 {
    return 0.0
  }
  let mut sum = 0
  for i in 0..<s.cells.length() {
    sum = sum + s.cells[i].y
  }
  Float::from_int(sum) / Float::from_int(s.cells.length())
}

///|
pub fn shape_min_x(s : Shape) -> Int {
  let mut mn = 999
  for i in 0..<s.cells.length() {
    if s.cells[i].x < mn {
      mn = s.cells[i].x
    }
  }
  mn
}

///|
pub fn shape_min_y(s : Shape) -> Int {
  let mut mn = 999
  for i in 0..<s.cells.length() {
    if s.cells[i].y < mn {
      mn = s.cells[i].y
    }
  }
  mn
}

///|
pub fn shape_max_x(s : Shape) -> Int {
  let mut mx = -999
  for i in 0..<s.cells.length() {
    if s.cells[i].x > mx {
      mx = s.cells[i].x
    }
  }
  mx
}

///|
pub fn shape_max_y(s : Shape) -> Int {
  let mut mx = -999
  for i in 0..<s.cells.length() {
    if s.cells[i].y > mx {
      mx = s.cells[i].y
    }
  }
  mx
}

///|
pub fn shape_normalize(s : Shape) -> Shape {
  if s.cells.length() == 0 {
    return new_shape([])
  }
  let min_x = shape_min_x(s)
  let min_y = shape_min_y(s)
  let cells : Array[Vec2i] = Array::new(capacity=s.cells.length())
  for i in 0..<s.cells.length() {
    cells.push(vec2i(s.cells[i].x - min_x, s.cells[i].y - min_y))
  }
  cells.sort_by(fn(a, b) {
    let cmp_x = a.x.compare(b.x)
    if cmp_x != 0 {
      cmp_x
    } else {
      a.y.compare(b.y)
    }
  })
  { cells, }
}

///|
pub fn shape_equals(a : Shape, b : Shape) -> Bool {
  let na = shape_normalize(a)
  let nb = shape_normalize(b)
  if na.cells.length() != nb.cells.length() {
    return false
  }
  for i in 0..<na.cells.length() {
    if na.cells[i].x != nb.cells[i].x || na.cells[i].y != nb.cells[i].y {
      return false
    }
  }
  true
}

///|
pub fn shape_exact_match(a : Shape, b : Shape) -> Bool {
  if a.cells.length() != b.cells.length() {
    return false
  }
  for i in 0..<a.cells.length() {
    if !(shape_contains(b, a.cells[i])) {
      return false
    }
  }
  true
}

///|
pub fn shape_match_count(current : Shape, target : Shape) -> Int {
  let mut count = 0
  for i in 0..<current.cells.length() {
    if shape_contains(target, current.cells[i]) {
      count = count + 1
    }
  }
  count
}

///|
pub fn shape_adjacent_empty(s : Shape) -> Array[Vec2i] {
  let result : Array[Vec2i] = []
  let dirs = [vec2i(0, -1), vec2i(1, 0), vec2i(0, 1), vec2i(-1, 0)]
  for i in 0..<s.cells.length() {
    let c = s.cells[i]
    for d in 0..<dirs.length() {
      let neighbor = vec2i(c.x + dirs[d].x, c.y + dirs[d].y)
      if neighbor.x >= 0 &&
        neighbor.x < grid_cols &&
        neighbor.y >= 0 &&
        neighbor.y < grid_rows &&
        !(shape_contains(s, neighbor)) {
        // Check not already in result
        let mut found = false
        for r in 0..<result.length() {
          if result[r].x == neighbor.x && result[r].y == neighbor.y {
            found = true
            break
          }
        }
        if !found {
          result.push(neighbor)
        }
      }
    }
  }
  result
}

///|
pub fn shape_edge_cells(s : Shape) -> Array[Vec2i] {
  let result : Array[Vec2i] = []
  let dirs = [vec2i(0, -1), vec2i(1, 0), vec2i(0, 1), vec2i(-1, 0)]
  for i in 0..<s.cells.length() {
    let c = s.cells[i]
    let mut has_empty_neighbor = false
    for d in 0..<dirs.length() {
      let neighbor = vec2i(c.x + dirs[d].x, c.y + dirs[d].y)
      if !(shape_contains(s, neighbor)) {
        has_empty_neighbor = true
        break
      }
    }
    // Also allow removal if shape has more than 1 cell
    if has_empty_neighbor && s.cells.length() > 1 {
      result.push(c)
    }
  }
  result
}

///|
pub fn op_cost(kind : OpKind) -> Int {
  match kind {
    Shift => cost_shift
    Rotate => cost_rotate
    Flip => cost_flip
    Grow => cost_grow
    Shrink => cost_shrink
  }
}

///|
pub fn op_name(kind : OpKind) -> String {
  match kind {
    Shift => "Shift"
    Rotate => "Rotate"
    Flip => "Flip"
    Grow => "Grow"
    Shrink => "Shrink"
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Morph => "Morph"
    Sculpt => "Sculpt"
    Transform => "Transform"
  }
}

///|
pub fn tier_color(t : Tier) -> @raylib.Color {
  match t {
    Morph => color_tier_morph
    Sculpt => color_tier_sculpt
    Transform => color_tier_transform
  }
}

///|
pub fn star_count(s : StarRating) -> Int {
  match s {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, best_cost: 9999, stars: Zero }
}

///|
pub fn new_game() -> Game {
  let level_scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    level_scores.push(new_level_score())
  }
  {
    screen: Title,
    current_shape: new_shape([]),
    target_shape: new_shape([]),
    ops_history: [],
    shape_history: [],
    total_cost: 0,
    play_state: Idle,
    selected_op: None,
    current_level_idx: 0,
    current_tier: Morph,
    level_scores,
    hover_cell: None,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
    anim_shape_before: None,
  }
}

///|
pub fn tier_start_index(t : Tier) -> Int {
  match t {
    Morph => 0
    Sculpt => morph_levels
    Transform => morph_levels + sculpt_levels
  }
}

///|
pub fn tier_level_count(t : Tier) -> Int {
  match t {
    Morph => morph_levels
    Sculpt => sculpt_levels
    Transform => transform_levels
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
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn absi(a : Int) -> Int {
  if a < 0 {
    -a
  } else {
    a
  }
}
