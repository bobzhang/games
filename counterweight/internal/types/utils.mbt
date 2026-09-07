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
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
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
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y, }
}

///|
pub fn grid_to_screen_x(gx : Int, offset_x : Int) -> Int {
  offset_x + gx * cell_size + cell_size / 2
}

///|
pub fn grid_to_screen_y(gy : Int, offset_y : Int) -> Int {
  offset_y + gy * cell_size + cell_size / 2
}

///|
pub fn node_screen_x(node : Node, offset_x : Int) -> Int {
  grid_to_screen_x(node.pos.x, offset_x)
}

///|
pub fn node_screen_y(node : Node, offset_y : Int) -> Int {
  grid_to_screen_y(node.pos.y, offset_y) +
  (node.height * Float::from_int(cell_size)).to_int()
}

///|
pub fn screen_to_grid_x(sx : Int, offset_x : Int) -> Int {
  (sx - offset_x) / cell_size
}

///|
pub fn screen_to_grid_y(sy : Int, offset_y : Int) -> Int {
  (sy - offset_y) / cell_size
}

///|
pub fn new_node(id : Int, gx : Int, gy : Int, kind : NodeKind) -> Node {
  {
    id,
    pos: vec2i(gx, gy),
    kind,
    left_conn: -1,
    right_conn: -1,
    height: 0.0,
    base_height: 0.0,
    locked: false,
  }
}

///|
pub fn new_rope() -> Rope {
  {
    active: false,
    from_node: -1,
    to_node: -1,
    from_side: LeftSide,
    to_side: RightSide,
    max_load: 999.0,
    broken: false,
    breakable: false,
  }
}

///|
pub fn new_weight(node_id : Int, mass : Float) -> Weight {
  {
    active: true,
    node_id,
    mass,
    current_y: 0.0,
    target_y: 0.0,
    bob_timer: 0.0,
  }
}

///|
pub fn new_crate(node_id : Int, mass : Float, target_height : Float) -> Crate {
  {
    active: true,
    node_id,
    mass,
    current_y: 0.0,
    target_y: 0.0,
    target_height,
    at_target: false,
  }
}

///|
pub fn new_platform(node_id : Int, width : Float) -> Platform {
  { active: true, node_id, width, height_val: 0.0, connected_to: -1, }
}

///|
pub fn new_bucket(
  node_id : Int,
  mass : Float,
  max_mass : Float,
  fill_rate : Float,
) -> Bucket {
  {
    active: true,
    node_id,
    mass,
    max_mass,
    fill_rate,
    filling: false,
    current_y: 0.0,
    target_y: 0.0,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, connections_used: 0, rehooks: 0, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  let grid_w = grid_cols * cell_size
  let grid_h = grid_rows * cell_size
  let ox = (screen_width - grid_w) / 2
  let oy = (screen_height - grid_h) / 2 + 20
  {
    screen: Title,
    play_state: Idle,
    current_tier: Basics,
    current_level: 0,
    selected_tier: 0,
    selected_level: 0,
    nodes: [],
    ropes: [],
    weights: [],
    crates: [],
    platforms: [],
    buckets: [],
    targets: [],
    par_connections: 3,
    par_rehooks: 0,
    connections_used: 0,
    rehooks: 0,
    has_waterfall: false,
    waterfall_x: 0,
    settle_timer: 0.0,
    anim_timer: 0.0,
    hover_node: -1,
    message: "",
    message_timer: 0.0,
    scores,
    frame_count: 0,
    grid_offset_x: ox,
    grid_offset_y: oy,
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Basics => "Basics"
    Chains => "Chains"
    Workshop => "Workshop"
  }
}

///|
pub fn tier_from_index(i : Int) -> Tier {
  if i == 0 {
    Basics
  } else if i == 1 {
    Chains
  } else {
    Workshop
  }
}

///|
pub fn level_index_for_tier(tier : Int, idx : Int) -> Int {
  if tier == 0 {
    idx
  } else if tier == 1 {
    tier1_levels + idx
  } else {
    tier1_levels + tier2_levels + idx
  }
}

///|
pub fn levels_in_tier(tier : Int) -> Int {
  if tier == 0 {
    tier1_levels
  } else if tier == 1 {
    tier2_levels
  } else {
    tier3_levels
  }
}

///|
pub fn tier_unlocked(scores : Array[LevelScore], tier : Int) -> Bool {
  if tier == 0 {
    true
  } else if tier == 1 {
    let mut cleared = 0
    for i in 0..<tier1_levels {
      if scores[i].completed {
        cleared += 1
      }
    }
    cleared >= 4
  } else {
    let mut cleared = 0
    for i in tier1_levels..<(tier1_levels + tier2_levels) {
      if scores[i].completed {
        cleared += 1
      }
    }
    cleared >= 5
  }
}

///|
pub fn total_stars(scores : Array[LevelScore]) -> Int {
  let mut total = 0
  for i in 0..<scores.length() {
    total += scores[i].stars
  }
  total
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn find_node_at(nodes : Array[Node], gx : Int, gy : Int) -> Int {
  for i in 0..<nodes.length() {
    if nodes[i].pos.x == gx && nodes[i].pos.y == gy {
      return i
    }
  }
  -1
}

///|
pub fn can_connect(node : Node, side : RopeSide) -> Bool {
  match side {
    LeftSide => node.left_conn == -1
    RightSide => node.right_conn == -1
  }
}

///|
pub fn get_mass_on_side(game : Game, node_id : Int, side : RopeSide) -> Float {
  let conn = match side {
    LeftSide => game.nodes[node_id].left_conn
    RightSide => game.nodes[node_id].right_conn
  }
  if conn < 0 {
    return 0.0
  }
  // Find what's connected
  let mut mass : Float = 0.0
  for i in 0..<game.weights.length() {
    if game.weights[i].active && game.weights[i].node_id == conn {
      mass = mass + game.weights[i].mass
    }
  }
  for i in 0..<game.crates.length() {
    if game.crates[i].active && game.crates[i].node_id == conn {
      mass = mass + game.crates[i].mass
    }
  }
  for i in 0..<game.buckets.length() {
    if game.buckets[i].active && game.buckets[i].node_id == conn {
      mass = mass + game.buckets[i].mass
    }
  }
  mass
}

///|
pub fn count_connections(game : Game) -> Int {
  let mut count = 0
  for i in 0..<game.ropes.length() {
    if game.ropes[i].active && !game.ropes[i].broken {
      count += 1
    }
  }
  count
}
