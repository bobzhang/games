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
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
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
pub fn sinf(a : Float) -> Float {
  Float::from_double(@moonbitlang/core/math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@moonbitlang/core/math.cos(a.to_double()))
}

///|
let rng_state : Ref[Int] = { val: 12345 }

///|
pub fn seed_rng(s : Int) -> Unit {
  rng_state.val = s
}

///|
pub fn rng_next() -> Int {
  rng_state.val = rng_state.val * 1103515245 + 12345
  let v = rng_state.val / 65536
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn rng_int(max : Int) -> Int {
  if max <= 0 {
    0
  } else {
    rng_next() % max
  }
}

///|
pub fn rng_float() -> Float {
  Float::from_int(rng_next() % 10000) / 10000.0
}

///|
pub fn rng_range(lo : Float, hi : Float) -> Float {
  lo + rng_float() * (hi - lo)
}

// Constructors

///|
pub fn new_cell() -> Cell {
  {
    component: Empty,
    fixed: false,
    powered: false,
    voltage: 0.0,
    current: 0.0,
    connections: [false, false, false, false],
  }
}

///|
pub fn new_cell_with(comp : ComponentKind, is_fixed : Bool) -> Cell {
  {
    component: comp,
    fixed: is_fixed,
    powered: false,
    voltage: 0.0,
    current: 0.0,
    connections: [false, false, false, false],
  }
}

///|
pub fn new_level_state(
  budget : Int,
  par : Int,
  fuse_b : Int,
  switch_b : Int,
) -> LevelState {
  let cells : Array[Array[Cell]] = []
  for _r in 0..<grid_rows {
    let row : Array[Cell] = []
    for _c in 0..<grid_cols {
      row.push(new_cell())
    }
    cells.push(row)
  }
  {
    cells,
    batteries_used: 0,
    battery_budget: budget,
    fuses_used: 0,
    fuse_budget: fuse_b,
    switches_used: 0,
    switch_budget: switch_b,
    par_batteries: par,
    devices_total: 0,
    devices_satisfied: 0,
    any_fuse_blown: false,
    simulated: false,
  }
}

///|
pub fn new_level_result() -> LevelResult {
  {
    stars: 0,
    completed: false,
    devices_powered: 0,
    devices_total: 0,
    batteries_used: 0,
    fuses_blown: 0,
  }
}

///|
pub fn new_spark() -> Spark {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    color: @raylib.Color::new(255, 220, 80, 255),
  }
}

///|
pub fn new_game() -> Game {
  let results : Array[LevelResult] = []
  for _i in 0..<total_levels {
    results.push(new_level_result())
  }
  let sparks : Array[Spark] = []
  for _i in 0..<64 {
    sparks.push(new_spark())
  }
  {
    screen: Title,
    current_level: 0,
    level_state: None,
    level_results: results,
    cursor_col: 0,
    cursor_row: 0,
    tool: PlaceBattery,
    sparks,
    animation_timer: 0.0,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    level_select_scroll: 0,
    show_help: false,
  }
}

///|
pub fn cell_center_x(col : Int) -> Float {
  Float::from_int(grid_offset_x + col * cell_size + cell_size / 2)
}

///|
pub fn cell_center_y(row : Int) -> Float {
  Float::from_int(grid_offset_y + row * cell_size + cell_size / 2)
}

///|
pub fn set_message(game : Game, msg : String, dur : Float) -> Unit {
  game.message = msg
  game.message_timer = dur
}

///|
pub fn alloc_spark(sparks : Array[Spark]) -> Int {
  for i in 0..<sparks.length() {
    if !sparks[i].active {
      return i
    }
  }
  0
}

///|
pub fn spawn_sparks(
  sparks : Array[Spark],
  cx : Float,
  cy : Float,
  count : Int,
  color : @raylib.Color,
) -> Unit {
  for _i in 0..<count {
    let idx = alloc_spark(sparks)
    let s = sparks[idx]
    s.active = true
    s.x = cx
    s.y = cy
    let angle = rng_range(0.0, 6.283)
    let speed = rng_range(40.0, 160.0)
    s.vx = cosf(angle) * speed
    s.vy = sinf(angle) * speed
    s.life = rng_range(0.2, spark_lifetime)
    s.color = color
  }
}

///|
pub fn direction_index(d : Direction) -> Int {
  match d {
    Up => 0
    Down => 1
    Left => 2
    Right => 3
  }
}

///|
pub fn opposite_direction(d : Direction) -> Direction {
  match d {
    Up => Down
    Down => Up
    Left => Right
    Right => Left
  }
}

///|
pub fn direction_delta(d : Direction) -> (Int, Int) {
  match d {
    Up => (0, -1)
    Down => (0, 1)
    Left => (-1, 0)
    Right => (1, 0)
  }
}

///|
pub fn all_directions() -> Array[Direction] {
  [Up, Down, Left, Right]
}

///|
pub fn in_bounds(col : Int, row : Int) -> Bool {
  col >= 0 && col < grid_cols && row >= 0 && row < grid_rows
}

///|
pub fn is_connectable(comp : ComponentKind) -> Bool {
  match comp {
    Empty => false
    _ => true
  }
}

///|
pub fn is_conductor(comp : ComponentKind) -> Bool {
  match comp {
    Empty => false
    Switch(on) => on
    Fuse(rating) => rating > 0.0
    _ => true
  }
}
