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
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn gear_radius(kind : GearKind) -> Int {
  match kind {
    Small => 1
    Medium => 2
    Large => 3
    Belt => 0
    Ratchet => 2
  }
}

///|
pub fn gear_pixel_radius(kind : GearKind) -> Float {
  Float::from_int(gear_radius(kind)) * Float::from_int(peg_spacing) * 0.45
}

///|
pub fn gear_tooth_count(kind : GearKind) -> Int {
  match kind {
    Small => 8
    Medium => 12
    Large => 16
    Belt => 0
    Ratchet => 12
  }
}

///|
pub fn can_mesh(r1 : Int, r2 : Int, dist_sq : Int) -> Bool {
  let mesh_dist = r1 + r2
  dist_sq == mesh_dist * mesh_dist
}

///|
pub fn grid_dist_sq(a : Vec2i, b : Vec2i) -> Int {
  let dx = a.x - b.x
  let dy = a.y - b.y
  dx * dx + dy * dy
}

///|
pub fn speed_ratio(driving_radius : Int, driven_radius : Int) -> Float {
  if driven_radius == 0 {
    1.0
  } else {
    Float::from_int(driving_radius) / Float::from_int(driven_radius)
  }
}

///|
pub fn flip_dir(d : RotDir) -> RotDir {
  match d {
    CW => CCW
    CCW => CW
  }
}

///|
pub fn peg_screen_x(col : Int) -> Float {
  Float::from_int(grid_offset_x + col * peg_spacing)
}

///|
pub fn peg_screen_y(row : Int) -> Float {
  Float::from_int(grid_offset_y + row * peg_spacing)
}

///|
pub fn screen_to_grid(sx : Float, sy : Float) -> Vec2i? {
  let half = Float::from_int(peg_spacing) / 2.0
  let col = ((sx - Float::from_int(grid_offset_x) + half) /
  Float::from_int(peg_spacing)).to_int()
  let row = ((sy - Float::from_int(grid_offset_y) + half) /
  Float::from_int(peg_spacing)).to_int()
  if col >= 0 && col < grid_cols && row >= 0 && row < grid_rows {
    let px = peg_screen_x(col)
    let py = peg_screen_y(row)
    let dx = sx - px
    let dy = sy - py
    if dx * dx + dy * dy < half * half {
      Some({ x: col, y: row, })
    } else {
      None
    }
  } else {
    None
  }
}

///|
pub fn gear_color(kind : GearKind) -> @raylib.Color {
  match kind {
    Small => color_gear_small
    Medium => color_gear_medium
    Large => color_gear_large
    Belt => color_belt
    Ratchet => color_ratchet
  }
}

///|
pub fn new_gear(pos : Vec2i, kind : GearKind) -> Gear {
  {
    pos,
    kind,
    radius: gear_radius(kind),
    rpm: 0.0,
    dir: CW,
    angle: 0.0,
    active: true,
  }
}

///|
pub fn new_output(
  pos : Vec2i,
  target_rpm : Float,
  target_dir : RotDir,
) -> Output {
  { pos, target_rpm, target_dir, satisfied: false, }
}

///|
pub fn new_belt(from_pos : Vec2i, to_pos : Vec2i) -> BeltLink {
  { from_pos, to_pos, active: true, }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, gears_used: 0, completed: false, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Gears,
    selected_level: 0,
    play_state: Placing,
    placed_gears: [],
    belts: [],
    connections: [],
    current_level: None,
    selected_gear_kind: Small,
    belt_start: None,
    scores,
    hover_peg: None,
    sim_time: 0.0,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    anim_timer: 0.0,
    title_gear_angle: 0.0,
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Gears => "Gears"
    Trains => "Trains"
    Workshop => "Workshop"
  }
}

///|
pub fn tier_level_offset(t : Tier) -> Int {
  match t {
    Gears => 0
    Trains => tier1_count
    Workshop => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(t : Tier) -> Int {
  match t {
    Gears => tier1_count
    Trains => tier2_count
    Workshop => tier3_count
  }
}

///|
pub fn rpm_satisfied(actual : Float, target : Float) -> Bool {
  if target == 0.0 {
    return absf(actual) < 1.0
  }
  let diff = absf(actual - target) / absf(target)
  diff <= rpm_tolerance
}

///|
pub fn check_output(output : Output, rpm : Float, dir : RotDir) -> Bool {
  rpm_satisfied(rpm, output.target_rpm) && dir == output.target_dir
}

///|
pub fn count_placed_gears(gears : Array[Gear]) -> Int {
  let mut count = 0
  for i in 0..<gears.length() {
    if gears[i].active {
      count += 1
    }
  }
  count
}

///|
pub fn find_gear_at(gears : Array[Gear], pos : Vec2i) -> Int {
  for i in 0..<gears.length() {
    if gears[i].active && gears[i].pos == pos {
      return i
    }
  }
  -1
}

///|
pub fn gears_overlap(g1 : Gear, g2 : Gear) -> Bool {
  let dsq = grid_dist_sq(g1.pos, g2.pos)
  let min_dist = g1.radius + g2.radius
  dsq < min_dist * min_dist
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}
