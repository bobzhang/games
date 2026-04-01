///|
pub fn orientation_dx(o : Orientation) -> Int {
  match o {
    N => 0
    NE => 1
    E => 1
    SE => 1
    S => 0
    SW => -1
    W => -1
    NW => -1
  }
}

///|
pub fn orientation_dy(o : Orientation) -> Int {
  match o {
    N => -1
    NE => -1
    E => 0
    SE => 1
    S => 1
    SW => 1
    W => 0
    NW => -1
  }
}

///|
pub fn perpendicular_orientations(
  o : Orientation,
) -> (Orientation, Orientation) {
  match o {
    N | S => (W, E)
    E | W => (N, S)
    NE | SW => (NW, SE)
    NW | SE => (NE, SW)
  }
}

///|
pub fn next_orientation(o : Orientation) -> Orientation {
  match o {
    N => NE
    NE => E
    E => SE
    SE => S
    S => SW
    SW => W
    W => NW
    NW => N
  }
}

///|
pub fn prev_orientation(o : Orientation) -> Orientation {
  match o {
    N => NW
    NE => N
    E => NE
    SE => E
    S => SE
    SW => S
    W => SW
    NW => W
  }
}

///|
pub fn orientation_angle(o : Orientation) -> Float {
  match o {
    N => -90.0
    NE => -45.0
    E => 0.0
    SE => 45.0
    S => 90.0
    SW => 135.0
    W => 180.0
    NW => -135.0
  }
}

///|
pub fn all_orientations() -> Array[Orientation] {
  [N, NE, E, SE, S, SW, W, NW]
}

///|
pub fn kind_color(kind : DominoKind) -> @raylib.Color {
  match kind {
    Normal => color_normal
    Heavy => color_heavy
    Splitter => color_splitter
    Delay => color_delay
  }
}

///|
pub fn kind_name(kind : DominoKind) -> String {
  match kind {
    Normal => "Normal"
    Heavy => "Heavy"
    Splitter => "Splitter"
    Delay => "Delay"
  }
}

///|
pub fn kind_range(kind : DominoKind) -> Int {
  match kind {
    Normal => 1
    Heavy => 2
    Splitter => 1
    Delay => 1
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Chains => "Chains"
    Splits => "Splits"
    Timing => "Timing"
  }
}

///|
pub fn tier_color(t : Tier) -> @raylib.Color {
  match t {
    Chains => color_tier_chains
    Splits => color_tier_splits
    Timing => color_tier_timing
  }
}

///|
pub fn tier_index(t : Tier) -> Int {
  match t {
    Chains => 0
    Splits => 1
    Timing => 2
  }
}

///|
pub fn index_to_tier(i : Int) -> Tier {
  match i {
    0 => Chains
    1 => Splits
    _ => Timing
  }
}

///|
pub fn socket_to_screen_x(gx : Int) -> Int {
  grid_offset_x + gx * socket_spacing
}

///|
pub fn socket_to_screen_y(gy : Int) -> Int {
  grid_offset_y + gy * socket_spacing
}

///|
pub fn screen_to_socket_x(sx : Int) -> Int {
  let rel = sx - grid_offset_x + socket_spacing / 2
  rel / socket_spacing
}

///|
pub fn screen_to_socket_y(sy : Int) -> Int {
  let rel = sy - grid_offset_y + socket_spacing / 2
  rel / socket_spacing
}

///|
pub fn in_grid(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gx < grid_cols && gy >= 0 && gy < grid_rows
}

///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn vec2i_eq(a : Vec2i, b : Vec2i) -> Bool {
  a.x == b.x && a.y == b.y
}

///|
pub fn new_domino(
  pos : Vec2i,
  kind : DominoKind,
  orientation : Orientation,
  is_target : Bool,
  is_starter : Bool,
) -> Domino {
  {
    pos,
    kind,
    orientation,
    state: Standing,
    is_target,
    is_starter,
    topple_tick: -1,
    delay_remaining: 0,
    anim_progress: 0.0,
  }
}

///|
pub fn clone_domino(d : Domino) -> Domino {
  {
    pos: vec2i(d.pos.x, d.pos.y),
    kind: d.kind,
    orientation: d.orientation,
    state: d.state,
    is_target: d.is_target,
    is_starter: d.is_starter,
    topple_tick: d.topple_tick,
    delay_remaining: d.delay_remaining,
    anim_progress: d.anim_progress,
  }
}

///|
pub fn clone_dominoes(arr : Array[Domino]) -> Array[Domino] {
  let result : Array[Domino] = Array::new(capacity=arr.length())
  for i in 0..<arr.length() {
    result.push(clone_domino(arr[i]))
  }
  result
}

///|
pub fn find_domino_at(dominoes : Array[Domino], pos : Vec2i) -> Int {
  for i in 0..<dominoes.length() {
    if vec2i_eq(dominoes[i].pos, pos) {
      return i
    }
  }
  -1
}

///|
pub fn count_targets(dominoes : Array[Domino]) -> Int {
  let mut count = 0
  for i in 0..<dominoes.length() {
    if dominoes[i].is_target {
      count += 1
    }
  }
  count
}

///|
pub fn count_fallen_targets(dominoes : Array[Domino]) -> Int {
  let mut count = 0
  for i in 0..<dominoes.length() {
    if dominoes[i].is_target && dominoes[i].state == Fallen {
      count += 1
    }
  }
  count
}

///|
pub fn budget_for_kind(budget : DominoBudget, kind : DominoKind) -> Int {
  match kind {
    Normal => budget.normal
    Heavy => budget.heavy
    Splitter => budget.splitter
    Delay => budget.delay
  }
}

///|
pub fn budget_remaining(
  budget : DominoBudget,
  dominoes : Array[Domino],
  kind : DominoKind,
) -> Int {
  let total = budget_for_kind(budget, kind)
  let mut placed = 0
  for i in 0..<dominoes.length() {
    if dominoes[i].kind == kind &&
      !dominoes[i].is_target &&
      !dominoes[i].is_starter {
      placed += 1
    }
  }
  total - placed
}

///|
pub fn new_budget(
  normal : Int,
  heavy : Int,
  splitter : Int,
  delay : Int,
) -> DominoBudget {
  { normal, heavy, splitter, delay }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, dominoes_used: 0, ticks_taken: 0 }
}

///|
pub fn level_index(tier : Tier, level_in_tier : Int) -> Int {
  tier_index(tier) * levels_per_tier + level_in_tier
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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
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
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Editing,
    selected_tier: Chains,
    selected_level: 0,
    current_level: None,
    dominoes: [],
    events: [],
    current_tick: 0,
    max_tick: 0,
    tick_timer: 0.0,
    tick_speed: 2,
    scores,
    selected_kind: Normal,
    hover_pos: vec2i(0, 0),
    show_hover: false,
    hover_orientation: E,
    message: "",
    message_timer: 0.0,
    replay_mode: false,
    replay_tick: 0,
    replay_timer: 0.0,
    frame_count: 0,
    dominoes_placed: 0,
    title_anim: 0.0,
    result_anim: 0.0,
  }
}
