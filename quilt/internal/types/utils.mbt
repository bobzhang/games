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
pub fn new_patch(
  n : EdgePattern,
  e : EdgePattern,
  s : EdgePattern,
  w : EdgePattern,
) -> Patch {
  {
    edges: [n, e, s, w],
    wildcard_edges: [false, false, false, false],
    pinned: false,
  }
}

///|
pub fn new_patch_pinned(
  n : EdgePattern,
  e : EdgePattern,
  s : EdgePattern,
  w : EdgePattern,
) -> Patch {
  {
    edges: [n, e, s, w],
    wildcard_edges: [false, false, false, false],
    pinned: true,
  }
}

///|
pub fn new_patch_wildcard(
  n : EdgePattern,
  e : EdgePattern,
  s : EdgePattern,
  w : EdgePattern,
  wn : Bool,
  we : Bool,
  ws : Bool,
  ww : Bool,
) -> Patch {
  { edges: [n, e, s, w], wildcard_edges: [wn, we, ws, ww], pinned: false }
}

///|
pub fn rotate_patch(p : Patch) -> Patch {
  // Rotate 90 CW: N->E, E->S, S->W, W->N
  // So new edges are [W, N, E, S] of old
  {
    edges: [p.edges[3], p.edges[0], p.edges[1], p.edges[2]],
    wildcard_edges: [
      p.wildcard_edges[3],
      p.wildcard_edges[0],
      p.wildcard_edges[1],
      p.wildcard_edges[2],
    ],
    pinned: p.pinned,
  }
}

///|
pub fn edges_match(
  pattern_a : EdgePattern,
  wildcard_a : Bool,
  pattern_b : EdgePattern,
  wildcard_b : Bool,
) -> Bool {
  if wildcard_a || wildcard_b {
    true
  } else {
    pattern_a == pattern_b
  }
}

///|
pub fn new_board(size : Int) -> Board {
  let cells : Array[Patch?] = Array::make(size * size, None)
  { size, cells }
}

///|
pub fn board_get(board : Board, row : Int, col : Int) -> Patch? {
  if row >= 0 && row < board.size && col >= 0 && col < board.size {
    board.cells[row * board.size + col]
  } else {
    None
  }
}

///|
pub fn board_set(board : Board, row : Int, col : Int, patch : Patch?) -> Unit {
  if row >= 0 && row < board.size && col >= 0 && col < board.size {
    board.cells[row * board.size + col] = patch
  }
}

///|
pub fn cell_size_for(board_size : Int) -> Int {
  if board_size <= 3 {
    cell_size_3x3
  } else if board_size <= 4 {
    cell_size_4x4
  } else {
    cell_size_5x5
  }
}

///|
pub fn pattern_color(p : EdgePattern) -> @raylib.Color {
  match p {
    Zigzag => color_zigzag
    Dots => color_dots
    Stripes => color_stripes
    Waves => color_waves
    Diamonds => color_diamonds
    Stars => color_stars
  }
}

///|
pub fn pattern_name(p : EdgePattern) -> String {
  match p {
    Zigzag => "Zigzag"
    Dots => "Dots"
    Stripes => "Stripes"
    Waves => "Waves"
    Diamonds => "Diamonds"
    Stars => "Stars"
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Scraps => "Scraps"
    Quilting => "Quilting"
    Masterwork => "Masterwork"
  }
}

///|
pub fn tier_levels(t : Tier) -> (Int, Int) {
  match t {
    Scraps => (0, tier1_count)
    Quilting => (tier1_count, tier2_count)
    Masterwork => (tier1_count + tier2_count, tier3_count)
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_rotations: 999, best_swaps: 999 }
}

///|
pub fn new_game() -> Game {
  let level_scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    level_scores.push(new_level_score())
  }
  {
    screen: Title,
    board: new_board(3),
    tray: [],
    selected_tray: -1,
    selected_board: -1,
    play_state: Placing,
    rotations: 0,
    swaps: 0,
    current_level: 0,
    current_tier: Scraps,
    level_scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    daily_seed: 0,
    is_daily: false,
    daily_score: new_level_score(),
    anim_timer: 0.0,
    tier_select_index: 0,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn all_patterns() -> Array[EdgePattern] {
  [Zigzag, Dots, Stripes, Waves, Diamonds, Stars]
}

///|
pub fn pattern_at(idx : Int) -> EdgePattern {
  let pats = all_patterns()
  pats[idx % pats.length()]
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
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}
