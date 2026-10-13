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
pub fn atan2f(y : Float, x : Float) -> Float {
  Float::from_double(@math.atan2(y.to_double(), x.to_double()))
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
pub fn absi(v : Int32) -> Int32 {
  if v < 0 {
    -v
  } else {
    v
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
pub fn clampi(v : Int32, lo : Int32, hi : Int32) -> Int32 {
  if v < lo {
    lo
  } else if v > hi {
    hi
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
pub fn maxi(a : Int32, b : Int32) -> Int32 {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int32, b : Int32) -> Int32 {
  if a < b {
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
pub fn tile_to_pixel_x(gx : Int32) -> Float {
  Float::from_int(grid_offset_x + gx * tile_size + tile_size / 2)
}

///|
pub fn tile_to_pixel_y(gy : Int32) -> Float {
  Float::from_int(grid_offset_y + gy * tile_size + tile_size / 2)
}

///|
pub fn pixel_to_tile_x(px : Float) -> Int32 {
  (px.to_int() - grid_offset_x) / tile_size
}

///|
pub fn pixel_to_tile_y(py : Float) -> Int32 {
  (py.to_int() - grid_offset_y) / tile_size
}

///|
pub fn in_bounds(x : Int32, y : Int32) -> Bool {
  x >= 0 && x < grid_width && y >= 0 && y < grid_height
}

///|
pub fn tile_walkable(tile : TileKind) -> Bool {
  match tile {
    Wall => false
    _ => true
  }
}

///|
pub fn direction_dx(d : Direction) -> Int32 {
  match d {
    Left => -1
    Right => 1
    _ => 0
  }
}

///|
pub fn direction_dy(d : Direction) -> Int32 {
  match d {
    Up => -1
    Down => 1
    _ => 0
  }
}

///|
pub fn direction_angle(d : Direction) -> Float {
  match d {
    Right => 0.0
    Down => pi / 2.0
    Left => pi
    Up => -pi / 2.0
  }
}

///|
pub fn manhattan_dist(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32) -> Int32 {
  absi(x1 - x2) + absi(y1 - y2)
}

///|
pub fn grid_dist(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32) -> Float {
  let dx = Float::from_int(x1 - x2)
  let dy = Float::from_int(y1 - y2)
  sqrtf(dx * dx + dy * dy)
}

// Line of sight raycast on tile grid (Bresenham-style)

///|
pub fn has_line_of_sight(
  tiles : Array[Array[TileKind]],
  x0 : Int32,
  y0 : Int32,
  x1 : Int32,
  y1 : Int32,
) -> Bool {
  let dx = absi(x1 - x0)
  let dy = absi(y1 - y0)
  let sx = if x0 < x1 { 1 } else { -1 }
  let sy = if y0 < y1 { 1 } else { -1 }
  let mut err = dx - dy
  let mut cx = x0
  let mut cy = y0
  while cx != x1 || cy != y1 {
    if cx != x0 || cy != y0 {
      if !in_bounds(cx, cy) {
        return false
      }
      match tiles[cy][cx] {
        Wall | Door => return false
        _ => ()
      }
    }
    let e2 = 2 * err
    if e2 > -dy {
      err -= dy
      cx += sx
    }
    if e2 < dx {
      err += dx
      cy += sy
    }
  }
  true
}

// RNG

///|
let rng_state : Ref[Int32] = { val: 42, }

///|
pub fn seed_rng(s : Int32) -> Unit {
  rng_state.val = s
}

///|
pub fn rng_next() -> Int32 {
  rng_state.val = rng_state.val * 1103515245 + 12345
  let v = rng_state.val / 65536
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn rng_int(max : Int32) -> Int32 {
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

// Constructors

///|
pub fn new_agent(gx : Int32, gy : Int32) -> Agent {
  {
    gx,
    gy,
    px: tile_to_pixel_x(gx),
    py: tile_to_pixel_y(gy),
    target_px: tile_to_pixel_x(gx),
    target_py: tile_to_pixel_y(gy),
    moving: false,
    running: false,
    facing: Right,
    visible: true,
    coins: 3,
    hacked_terminals: 0,
    detected_count: 0,
    alert_triggered: false,
    in_shadow: false,
  }
}

///|
pub fn new_guard(
  gx : Int32,
  gy : Int32,
  kind : GuardKind,
  patrol : Array[Vec2i],
) -> Guard {
  let range : Float = match kind {
    Patrol => 4.0
    Sentinel => 6.0
    Hunter => 5.0
  }
  let cone : Float = match kind {
    Patrol => pi / 3.0
    Sentinel => pi / 2.0
    Hunter => pi / 4.0
  }
  let spd : Float = match kind {
    Patrol => 0.6
    Sentinel => 0.0
    Hunter => 0.4
  }
  {
    gx,
    gy,
    px: tile_to_pixel_x(gx),
    py: tile_to_pixel_y(gy),
    kind,
    alert_state: Patrolling,
    facing: Down,
    facing_angle: pi / 2.0,
    vision_range: range,
    vision_cone: cone,
    patrol_points: patrol,
    patrol_index: 0,
    patrol_forward: true,
    suspicious_timer: 0.0,
    alert_timer: 0.0,
    investigate_x: gx,
    investigate_y: gy,
    detection_meter: 0.0,
    active: true,
    speed: spd,
    move_timer: 0.0,
    search_offsets: [],
    search_index: 0,
    searching: false,
    look_timer: 0.0,
  }
}

///|
pub fn new_camera(gx : Int32, gy : Int32) -> Camera {
  {
    gx,
    gy,
    facing_angle: 0.0,
    rotation_speed: camera_rotation_speed,
    vision_range: camera_vision_range,
    active: true,
    powered: true,
  }
}

///|
pub fn new_terminal(
  gx : Int32,
  gy : Int32,
  high_security : Bool,
  connected_id : Int32,
) -> Terminal {
  { gx, gy, hacked: false, high_security, connected_id, data_value: 100, }
}

///|
pub fn new_door(gx : Int32, gy : Int32, power_id : Int32) -> Door {
  { gx, gy, open: false, locked: true, power_id, }
}

///|
pub fn new_laser(
  gx : Int32,
  gy : Int32,
  power_id : Int32,
  horizontal : Bool,
  length : Int32,
) -> LaserGrid {
  { gx, gy, active: true, power_id, horizontal, length, }
}

///|
pub fn new_power_node(
  gx : Int32,
  gy : Int32,
  node_id : Int32,
  connected : Array[Int32],
) -> PowerNode {
  { gx, gy, powered: true, node_id, connected_ids: connected, }
}

///|
pub fn new_hack_minigame() -> HackMiniGame {
  {
    active: false,
    sequence: [],
    input: [],
    timer: 0.0,
    max_time: hack_time_limit,
    current_pos: 0,
    success: false,
    failed: false,
    target_terminal: -1,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  {
    base_score: 0,
    ghost_bonus: 0,
    no_alert_bonus: 0,
    speed_bonus: 0,
    data_bonus: 0,
    total: 0,
    grade: C,
    time_taken: 0.0,
    all_data: false,
    ghost: false,
    no_alerts: false,
  }
}

///|
pub fn new_empty_level() -> Level {
  let tiles : Array[Array[TileKind]] = Array(capacity=grid_height)
  for _y in 0..<grid_height {
    let row : Array[TileKind] = Array(capacity=grid_width)
    for _x in 0..<grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  {
    name: "Empty",
    tier: Corporate,
    width: grid_width,
    height: grid_height,
    tiles,
    guards: [],
    cameras: [],
    terminals: [],
    doors: [],
    lasers: [],
    power_nodes: [],
    start_x: 1,
    start_y: 1,
    exit_x: 18,
    exit_y: 13,
    par_time: 60.0,
    total_data: 0,
  }
}

///|
pub fn new_game() -> Game {
  let level_scores : Array[LevelScore?] = Array(capacity=total_levels)
  for _i in 0..<total_levels {
    level_scores.push(None)
  }
  {
    screen: Title,
    player: new_agent(1, 1),
    level: new_empty_level(),
    level_index: 0,
    hack_game: new_hack_minigame(),
    score: new_level_score(),
    level_scores,
    sound_queue: [],
    time_played: 0.0,
    message: "",
    message_timer: 0.0,
    rng: 42,
    frame_count: 0,
    menu_selection: 0,
    coin_target_x: 0,
    coin_target_y: 0,
    coin_active: false,
    coin_timer: 0.0,
    move_cooldown: 0.0,
    level_complete: false,
    fade_timer: 0.0,
    all_levels_complete: false,
    noise_x: 0,
    noise_y: 0,
    noise_radius: 0,
    noise_timer: 0.0,
    detection_pause: 0.0,
    camera_offset_x: 0.0,
    camera_offset_y: 0.0,
  }
}

///|
pub fn guard_color(state : AlertState) -> @raylib.Color {
  match state {
    Patrolling => color_guard_patrol
    Suspicious => color_guard_suspicious
    Alert => color_guard_alert
  }
}

///|
pub fn grade_color(grade : ScoreGrade) -> @raylib.Color {
  match grade {
    S => color_grade_s
    A => color_grade_a
    B => color_grade_b
    C => color_grade_c
  }
}

///|
pub fn push_sound(game : Game, event : SoundEvent) -> Unit {
  game.sound_queue.push(event)
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn is_adjacent(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32) -> Bool {
  manhattan_dist(x1, y1, x2, y2) == 1
}

///|
pub fn find_door_at(level : Level, gx : Int32, gy : Int32) -> Int32 {
  for i in 0..<level.doors.length() {
    if level.doors[i].gx == gx && level.doors[i].gy == gy {
      return i
    }
  }
  -1
}

///|
pub fn find_laser_at(level : Level, gx : Int32, gy : Int32) -> Int32 {
  for i in 0..<level.lasers.length() {
    let l = level.lasers[i]
    if l.horizontal {
      if l.gy == gy && gx >= l.gx && gx < l.gx + l.length {
        return i
      }
    } else if l.gx == gx && gy >= l.gy && gy < l.gy + l.length {
      return i
    }
  }
  -1
}

///|
pub fn is_tile_blocked(game : Game, gx : Int32, gy : Int32) -> Bool {
  if !in_bounds(gx, gy) {
    return true
  }
  let tile = game.level.tiles[gy][gx]
  if !tile_walkable(tile) {
    return true
  }
  // Check closed doors
  let door_idx = find_door_at(game.level, gx, gy)
  if door_idx >= 0 && !game.level.doors[door_idx].open {
    return true
  }
  // Check active lasers
  let laser_idx = find_laser_at(game.level, gx, gy)
  if laser_idx >= 0 && game.level.lasers[laser_idx].active {
    return true
  }
  false
}
