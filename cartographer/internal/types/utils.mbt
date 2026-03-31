///|
pub fn manhattan_distance(a : Vec2i, b : Vec2i) -> Int {
  absi(a.x - b.x) + absi(a.y - b.y)
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
pub fn direction_check(from : Vec2i, to : Vec2i, dir : CompassDir) -> Bool {
  match dir {
    N => to.y < from.y
    S => to.y > from.y
    E => to.x > from.x
    W => to.x < from.x
    NE => to.y < from.y && to.x > from.x
    NW => to.y < from.y && to.x < from.x
    SE => to.y > from.y && to.x > from.x
    SW => to.y > from.y && to.x < from.x
  }
}

///|
pub fn is_adjacent(a : Vec2i, b : Vec2i) -> Bool {
  let dx = absi(a.x - b.x)
  let dy = absi(a.y - b.y)
  (dx + dy == 1) || (dx == 1 && dy == 1)
}

///|
pub fn is_between(
  target : Vec2i,
  end_a : Vec2i,
  end_b : Vec2i
) -> Bool {
  // Check if target is on the line between end_a and end_b
  // Must be collinear and between the two endpoints
  let dx_ab = end_b.x - end_a.x
  let dy_ab = end_b.y - end_a.y
  let dx_at = target.x - end_a.x
  let dy_at = target.y - end_a.y
  // Cross product must be zero (collinear)
  let cross = dx_ab * dy_at - dy_ab * dx_at
  if cross != 0 {
    return false
  }
  // Dot product must be positive and within range
  let dot = dx_at * dx_ab + dy_at * dy_ab
  let len_sq = dx_ab * dx_ab + dy_ab * dy_ab
  if len_sq == 0 {
    return false
  }
  dot > 0 && dot < len_sq
}

///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn pos_to_index(pos : Vec2i, size : Int) -> Int {
  pos.y * size + pos.x
}

///|
pub fn index_to_pos(idx : Int, size : Int) -> Vec2i {
  { x: idx % size, y: idx / size }
}

///|
pub fn feature_color(kind : FeatureKind) -> @raylib.Color {
  match kind {
    Mountain => color_mountain
    River => color_river
    Forest => color_forest
    Town => color_town
    Lake => color_lake
    Desert => color_desert
    Road => color_road
  }
}

///|
pub fn feature_name(kind : FeatureKind) -> String {
  match kind {
    Mountain => "Mountain"
    River => "River"
    Forest => "Forest"
    Town => "Town"
    Lake => "Lake"
    Desert => "Desert"
    Road => "Road"
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Surveyor => "Surveyor"
    Explorer => "Explorer"
    Master => "Master"
  }
}

///|
pub fn compass_name(dir : CompassDir) -> String {
  match dir {
    N => "north"
    S => "south"
    E => "east"
    W => "west"
    NE => "northeast"
    NW => "northwest"
    SE => "southeast"
    SW => "southwest"
  }
}

///|
pub fn new_clue(
  kind : ClueKind,
  feature_a : FeatureKind,
  feature_b~ : FeatureKind = Mountain,
  distance~ : Int = 0,
  direction~ : CompassDir = N,
  row_col~ : Int = 0,
  count~ : Int = 0,
  text~ : String = ""
) -> Clue {
  {
    kind,
    feature_a,
    feature_b,
    distance,
    direction,
    row_col,
    count,
    text,
    status: Pending,
  }
}

///|
pub fn new_level(
  name : String,
  tier : Tier,
  features : Array[FeatureKind],
  clues : Array[Clue],
  par : Int,
  description~ : String = ""
) -> Level {
  {
    name,
    tier,
    grid_size,
    features_to_place: features,
    clues,
    par_placements: par,
    description,
  }
}

///|
pub fn new_score() -> LevelScore {
  { completed: false, stars: 0, best_placements: 999 }
}

///|
pub fn new_game(levels : Array[Level]) -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<levels.length() {
    scores.push(new_score())
  }
  {
    screen: Title,
    grid: Array::make(grid_size * grid_size, None),
    placements: [],
    incorrect_count: 0,
    total_placements: 0,
    selected_feature: None,
    current_level: 0,
    current_tier: Surveyor,
    levels,
    scores,
    hover_cell: None,
    play_state: Placing,
    message: "",
    message_timer: 0.0,
    anim_timer: 0.0,
    hint_cells: [],
    show_hints: false,
    frame_count: 0,
  }
}

///|
pub fn reset_level(game : Game) -> Unit {
  game.grid = Array::make(grid_size * grid_size, None)
  game.placements = []
  game.incorrect_count = 0
  game.total_placements = 0
  game.play_state = Placing
  game.hint_cells = []
  game.show_hints = false
  game.message = ""
  game.message_timer = 0.0
  // Reset clue statuses
  let level = game.levels[game.current_level]
  for i in 0..<level.clues.length() {
    level.clues[i].status = Pending
  }
}

///|
pub fn find_feature_pos(
  grid : Array[FeatureKind?],
  size : Int,
  kind : FeatureKind
) -> Vec2i? {
  for i in 0..<grid.length() {
    match grid[i] {
      Some(f) => if f == kind { return Some(index_to_pos(i, size)) }
      None => ()
    }
  }
  None
}

///|
pub fn find_all_feature_positions(
  grid : Array[FeatureKind?],
  size : Int,
  kind : FeatureKind
) -> Array[Vec2i] {
  let result : Array[Vec2i] = []
  for i in 0..<grid.length() {
    match grid[i] {
      Some(f) => if f == kind { result.push(index_to_pos(i, size)) }
      None => ()
    }
  }
  result
}

///|
pub fn tier_level_range(tier : Tier) -> (Int, Int) {
  match tier {
    Surveyor => (0, 8)
    Explorer => (8, 17)
    Master => (17, 25)
  }
}

///|
pub fn level_tier(level_index : Int) -> Tier {
  if level_index < 8 {
    Surveyor
  } else if level_index < 17 {
    Explorer
  } else {
    Master
  }
}
