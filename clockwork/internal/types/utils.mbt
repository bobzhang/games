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
pub fn atan2f(y : Float, x : Float) -> Float {
  Float::from_double(@math.atan2(y.to_double(), x.to_double()))
}

///|
pub fn fmodf(a : Float, b : Float) -> Float {
  a - Float::from_int((a / b).to_int()) * b
}

///|
pub fn gear_radius(size : GearSize) -> Float {
  match size {
    Small => gear_small_radius
    Medium => gear_medium_radius
    Large => gear_large_radius
  }
}

///|
pub fn gear_teeth(size : GearSize) -> Int {
  match size {
    Small => gear_small_teeth
    Medium => gear_medium_teeth
    Large => gear_large_teeth
  }
}

///|
pub fn gear_speed_ratio(size : GearSize) -> Float {
  match size {
    Small => gear_small_speed_ratio
    Medium => gear_medium_speed_ratio
    Large => gear_large_speed_ratio
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
pub fn component_color(kind : ComponentKind) -> @raylib.Color {
  match kind {
    Gear(Small) => color_gear_copper
    Gear(Medium) => color_gear_gold
    Gear(Large) => color_gear_silver
    Cam => color_cam
    Spring => color_spring
    Escapement => color_escapement
    Bell => color_bell
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Ticks => "Ticks"
    Timing => "Timing"
    Clockwork => "Clockwork"
  }
}

///|
pub fn new_component(kind : ComponentKind, col : Int, row : Int) -> Component {
  {
    active: true,
    kind,
    col,
    row,
    rotation: 0.0,
    rotation_speed: 0.0,
    clockwise: true,
    cam_dir: PushUp,
    cam_offset: 0.0,
    spring_energy: 0.0,
    spring_released: false,
    escapement_phase: 0.0,
    escapement_locked: false,
    bell_target_tick: 0,
    bell_rung: false,
    bell_ring_timer: 0.0,
    connected_to: [],
    fixed: false,
    dragging: false,
  }
}

///|
pub fn new_fixed_component(
  kind : ComponentKind,
  col : Int,
  row : Int,
) -> Component {
  let c = new_component(kind, col, row)
  c.fixed = true
  c
}

///|
pub fn new_bell(col : Int, row : Int, target_tick : Int) -> Component {
  let c = new_fixed_component(Bell, col, row)
  c.bell_target_tick = target_tick
  c
}

///|
pub fn new_palette() -> Palette {
  { available: [], counts: [], }
}

///|
pub fn palette_add(p : Palette, kind : ComponentKind, count : Int) -> Unit {
  p.available.push(kind)
  p.counts.push(count)
}

///|
pub fn palette_remaining(p : Palette, idx : Int) -> Int {
  if idx >= 0 && idx < p.counts.length() {
    p.counts[idx]
  } else {
    0
  }
}

///|
pub fn new_level_def() -> LevelDef {
  {
    id: 0,
    name: "",
    tier: Ticks,
    fixed_components: [],
    palette: new_palette(),
    bell_targets: [],
    par_components: 1,
    description: "",
  }
}

///|
pub fn new_simulation() -> Simulation {
  {
    state: Idle,
    tick: 0,
    tick_timer: 0.0,
    tick_interval: 0.5,
    bells_rung: [],
    bells_order: [],
    total_bells: 0,
    speed_mult: 1.0,
  }
}

///|
pub fn reset_simulation(sim : Simulation) -> Unit {
  sim.state = Idle
  sim.tick = 0
  sim.tick_timer = 0.0
  sim.bells_rung = []
  sim.bells_order = []
  sim.speed_mult = 1.0
}

///|
pub fn new_grid() -> Array[Array[Int]] {
  let grid : Array[Array[Int]] = []
  for _r in 0..<grid_rows {
    let row : Array[Int] = []
    for _c in 0..<grid_cols {
      row.push(-1)
    }
    grid.push(row)
  }
  grid
}

///|
pub fn new_game() -> Game {
  let stars : Array[Int] = []
  for _i in 0..<total_levels {
    stars.push(0)
  }
  {
    screen: Title,
    grid: new_grid(),
    components: [],
    selected_palette: -1,
    dragging_component: -1,
    hover_col: -1,
    hover_row: -1,
    current_level: 0,
    level_def: new_level_def(),
    sim: new_simulation(),
    level_stars: stars,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    tier_scroll: 0,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn grid_valid(col : Int, row : Int) -> Bool {
  col >= 0 && col < grid_cols && row >= 0 && row < grid_rows
}

///|
pub fn grid_get(game : Game, col : Int, row : Int) -> Int {
  if grid_valid(col, row) {
    game.grid[row][col]
  } else {
    -1
  }
}

///|
pub fn grid_set(game : Game, col : Int, row : Int, idx : Int) -> Unit {
  if grid_valid(col, row) {
    game.grid[row][col] = idx
  }
}

///|
pub fn clear_grid(game : Game) -> Unit {
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      game.grid[r][c] = -1
    }
  }
}

///|
pub fn count_placed_components(game : Game) -> Int {
  let mut count = 0
  for i in 0..<game.components.length() {
    if game.components[i].active && !game.components[i].fixed {
      count += 1
    }
  }
  count
}

///|
pub fn mouse_to_grid_col(mx : Int) -> Int {
  (mx - grid_offset_x) / cell_size
}

///|
pub fn mouse_to_grid_row(my : Int) -> Int {
  (my - grid_offset_y) / cell_size
}
