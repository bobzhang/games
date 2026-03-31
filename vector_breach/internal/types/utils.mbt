///|
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn abs_int(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn manhattan(x1 : Int, y1 : Int, x2 : Int, y2 : Int) -> Int {
  abs_int(x1 - x2) + abs_int(y1 - y2)
}

///|
pub fn direction_dx(dir : Direction) -> Int {
  match dir {
    North => 0
    South => 0
    East => 1
    West => -1
  }
}

///|
pub fn direction_dy(dir : Direction) -> Int {
  match dir {
    North => -1
    South => 1
    East => 0
    West => 0
  }
}

///|
pub fn direction_from_delta(dx : Int, dy : Int) -> Direction {
  if abs_int(dx) >= abs_int(dy) {
    if dx >= 0 {
      East
    } else {
      West
    }
  } else {
    if dy >= 0 {
      South
    } else {
      North
    }
  }
}

///|
pub fn opposite_direction(dir : Direction) -> Direction {
  match dir {
    North => South
    South => North
    East => West
    West => East
  }
}

///|
pub fn rand_next(state : Ref[UInt]) -> UInt {
  let mut x = state.val
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  state.val = x
  x
}

///|
pub fn rand_range(state : Ref[UInt], low : Int, high : Int) -> Int {
  if high <= low {
    return low
  }
  let r = rand_next(state)
  let range = (high - low + 1).reinterpret_as_uint()
  low + (r % range).reinterpret_as_int()
}

///|
pub fn tile_to_screen_x(gx : Int) -> Int {
  grid_offset_x + gx * tile_size
}

///|
pub fn tile_to_screen_y(gy : Int) -> Int {
  grid_offset_y + gy * tile_size
}

///|
pub fn screen_to_tile_x(sx : Int) -> Int {
  (sx - grid_offset_x) / tile_size
}

///|
pub fn screen_to_tile_y(sy : Int) -> Int {
  (sy - grid_offset_y) / tile_size
}

///|
pub fn tile_center_x(gx : Int) -> Int {
  grid_offset_x + gx * tile_size + tile_size / 2
}

///|
pub fn tile_center_y(gy : Int) -> Int {
  grid_offset_y + gy * tile_size + tile_size / 2
}

///|
pub fn draw_shadow_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  @draw.draw_text(text, x + 1, y + 1, size, @raylib.black)
  @draw.draw_text(text, x, y, size, color)
}

///|
pub fn draw_center_text(
  text : String,
  cx : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let w = @draw.measure_text(text, size)
  draw_shadow_text(text, cx - w / 2, y, size, color)
}

///|
pub fn make_default_unit(
  id : Int,
  team : UnitTeam,
  x : Int,
  y : Int,
) -> CombatUnit {
  let (hp, max_hp, max_heat, mech_class, enemy_type) = match team {
    Player => (5, 5, max_heat, Vanguard, Rammer)
    Enemy => (3, 3, 0, Vanguard, Rammer)
  }
  {
    id,
    active: true,
    team,
    x,
    y,
    hp,
    max_hp,
    shield: 0,
    heat: 0,
    max_heat,
    stunned: false,
    moved_this_turn: false,
    acted_this_turn: false,
    mech_class,
    enemy_type,
    intent: March(x, y),
  }
}

///|
pub fn new_battle(objective : Objective) -> BattleState {
  {
    grid: Grid::new(grid_w, grid_h),
    units: [],
    turn: 1,
    phase: Battle,
    objective,
    objective_progress: 0,
    player_commands: [],
    selected_mech: 0,
    cursor_x: 0,
    cursor_y: 0,
    turn_log: [],
  }
}
