///|
pub fn rotate_orientation(o : Orientation, steps : Int) -> Orientation {
  let idx = orientation_index(o)
  let new_idx = (idx + steps % 4 + 4) % 4
  index_to_orientation(new_idx)
}

///|
pub fn orientation_cw(o : Orientation) -> Orientation {
  rotate_orientation(o, 1)
}

///|
pub fn orientation_ccw(o : Orientation) -> Orientation {
  rotate_orientation(o, 3)
}

///|
pub fn orientation_flip(o : Orientation) -> Orientation {
  rotate_orientation(o, 2)
}

///|
pub fn is_symmetric_shape(s : TileShape) -> Bool {
  match s {
    Square | Circle => true
    _ => false
  }
}

///|
pub fn tile_eq(a : Tile, b : Tile) -> Bool {
  if a.color != b.color || a.shape != b.shape {
    return false
  }
  if is_symmetric_shape(a.shape) {
    return true
  }
  a.orientation == b.orientation
}

///|
pub fn new_tile(
  color : TileColor,
  shape : TileShape,
  orientation : Orientation,
) -> Tile {
  { color, shape, orientation, }
}

///|
pub fn copy_tile(t : Tile) -> Tile {
  { color: t.color, shape: t.shape, orientation: t.orientation, }
}

///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y, }
}

///|
pub fn vec2i_eq(a : Vec2i, b : Vec2i) -> Bool {
  a.x == b.x && a.y == b.y
}

///|
pub fn is_hole(grid : MosaicGrid, pos : Vec2i) -> Bool {
  for i in 0..<grid.holes.length() {
    if vec2i_eq(grid.holes[i], pos) {
      return true
    }
  }
  false
}

///|
pub fn grid_index(x : Int, y : Int, width : Int) -> Int {
  y * width + x
}

///|
pub fn get_tile(grid : MosaicGrid, x : Int, y : Int) -> Tile? {
  if x < 0 || x >= grid.width || y < 0 || y >= grid.height {
    return None
  }
  grid.tiles[grid_index(x, y, grid.width)]
}

///|
pub fn set_tile(grid : MosaicGrid, x : Int, y : Int, tile : Tile?) -> Unit {
  if x >= 0 && x < grid.width && y >= 0 && y < grid.height {
    grid.tiles[grid_index(x, y, grid.width)] = tile
  }
}

///|
pub fn new_grid(width : Int, height : Int) -> MosaicGrid {
  let tiles : Array[Tile?] = Array::make(width * height, None)
  { width, height, tiles, holes: [], }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, errors: 0, guessed_symmetry: false, }
}

///|
pub fn mirror_orient_h(o : Orientation) -> Orientation {
  match o {
    N => S
    S => N
    E => E
    W => W
  }
}

///|
pub fn mirror_orient_v(o : Orientation) -> Orientation {
  match o {
    N => N
    S => S
    E => W
    W => E
  }
}

///|
pub fn mirror_orient_d(o : Orientation) -> Orientation {
  match o {
    N => E
    E => N
    S => W
    W => S
  }
}

///|
pub fn rotate_orient_180(o : Orientation) -> Orientation {
  orientation_flip(o)
}

///|
pub fn rotate_orient_90(o : Orientation) -> Orientation {
  orientation_cw(o)
}

///|
pub fn rotate_orient_270(o : Orientation) -> Orientation {
  orientation_ccw(o)
}

///|
pub fn tier_color(t : Tier) -> @raylib.Color {
  match t {
    Repair => color_tier_repair
    Restore => color_tier_restore
    Master => color_tier_master
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Repair => "REPAIR"
    Restore => "RESTORE"
    Master => "MASTER"
  }
}

///|
pub fn tier_index(t : Tier) -> Int {
  match t {
    Repair => 0
    Restore => 1
    Master => 2
  }
}

///|
pub fn index_to_tier(i : Int) -> Tier {
  match i {
    0 => Repair
    1 => Restore
    _ => Master
  }
}

///|
pub fn symmetry_name(s : SymmetryKind) -> String {
  match s {
    MirrorH => "Mirror Horizontal"
    MirrorV => "Mirror Vertical"
    MirrorD => "Mirror Diagonal"
    Rotate2 => "Rotation 180"
    Rotate4 => "Rotation 90"
    Glide => "Glide Reflection"
  }
}

///|
pub fn symmetry_index(s : SymmetryKind) -> Int {
  match s {
    MirrorH => 0
    MirrorV => 1
    MirrorD => 2
    Rotate2 => 3
    Rotate4 => 4
    Glide => 5
  }
}

///|
pub fn index_to_symmetry(i : Int) -> SymmetryKind {
  match i {
    0 => MirrorH
    1 => MirrorV
    2 => MirrorD
    3 => Rotate2
    4 => Rotate4
    _ => Glide
  }
}

///|
pub fn all_colors() -> Array[TileColor] {
  [Red, Blue, Green, Gold, Purple, White]
}

///|
pub fn all_shapes() -> Array[TileShape] {
  [Square, Triangle, Arrow, Diamond, Circle, Cross]
}

///|
pub fn all_orientations() -> Array[Orientation] {
  [N, E, S, W]
}

///|
pub fn clamp_int(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn new_game(levels : Array[Level]) -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<levels.length() {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Placing,
    current_tier: Repair,
    current_level: 0,
    selected_color: Red,
    selected_shape: Square,
    selected_orientation: N,
    hover_cell: None,
    errors: 0,
    no_errors: true,
    guessed_symmetry: false,
    symmetry_guess: None,
    levels,
    scores,
    placed_tiles: [],
    undo_stack: [],
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    show_symmetry_hint: false,
    anim_timer: 0.0,
  }
}

///|
pub fn levels_for_tier(game : Game, tier : Tier) -> Array[Int] {
  let result : Array[Int] = []
  for i in 0..<game.levels.length() {
    if game.levels[i].tier == tier {
      result.push(i)
    }
  }
  result
}

///|
pub fn tier_completed(game : Game, tier : Tier) -> Bool {
  let lvls = levels_for_tier(game, tier)
  for i in 0..<lvls.length() {
    if !game.scores[lvls[i]].completed {
      return false
    }
  }
  lvls.length() > 0
}

///|
pub fn total_stars(game : Game) -> Int {
  let mut total = 0
  for i in 0..<game.scores.length() {
    total = total + game.scores[i].stars
  }
  total
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn count_remaining_holes(game : Game) -> Int {
  let level = game.levels[game.current_level]
  let mut count = 0
  for i in 0..<level.grid.holes.length() {
    let h = level.grid.holes[i]
    match get_tile(level.grid, h.x, h.y) {
      None => count = count + 1
      Some(_) => ()
    }
  }
  count
}
