///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y, }
}

///|
pub fn vec2i_add(a : Vec2i, b : Vec2i) -> Vec2i {
  { x: a.x + b.x, y: a.y + b.y, }
}

///|
pub fn vec2i_eq(a : Vec2i, b : Vec2i) -> Bool {
  a.x == b.x && a.y == b.y
}

///|
pub fn dir_dx(d : Direction) -> Int {
  match d {
    East => 1
    West => -1
    _ => 0
  }
}

///|
pub fn dir_dy(d : Direction) -> Int {
  match d {
    South => 1
    North => -1
    _ => 0
  }
}

///|
pub fn dir_delta(d : Direction) -> Vec2i {
  vec2i(dir_dx(d), dir_dy(d))
}

///|
pub fn turn_left(d : Direction) -> Direction {
  match d {
    North => West
    West => South
    South => East
    East => North
  }
}

///|
pub fn turn_right(d : Direction) -> Direction {
  match d {
    North => East
    East => South
    South => West
    West => North
  }
}

///|
pub fn dir_name(d : Direction) -> String {
  match d {
    North => "North"
    South => "South"
    East => "East"
    West => "West"
  }
}

///|
pub fn new_grid(w : Int, h : Int) -> Grid {
  let tiles : Array[Array[Tile]] = []
  for _y in 0..<h {
    let row : Array[Tile] = []
    for _x in 0..<w {
      row.push({ kind: Floor, })
    }
    tiles.push(row)
  }
  { tiles, width: w, height: h, }
}

///|
pub fn grid_in_bounds(g : Grid, x : Int, y : Int) -> Bool {
  x >= 0 && x < g.width && y >= 0 && y < g.height
}

///|
pub fn grid_get(g : Grid, x : Int, y : Int) -> TileKind {
  if grid_in_bounds(g, x, y) {
    g.tiles[y][x].kind
  } else {
    Wall
  }
}

///|
pub fn grid_set(g : Grid, x : Int, y : Int, kind : TileKind) -> Unit {
  if grid_in_bounds(g, x, y) {
    g.tiles[y][x].kind = kind
  }
}

///|
pub fn new_robot(x : Int, y : Int, dir : Direction) -> Robot {
  { pos: vec2i(x, y), dir, alive: true, }
}

///|
pub fn new_program() -> Program {
  { commands: [], max_slots: max_instructions, }
}

///|
pub fn new_editor_state(available : Array[CommandKind]) -> EditorState {
  {
    cursor: 0,
    palette_cursor: 0,
    palette_open: false,
    palette_commands: available,
    loop_count: 2,
    condition_index: 0,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, best_instructions: 999, medal: None_, }
}

///|
pub fn clone_robot(r : Robot) -> Robot {
  { pos: vec2i(r.pos.x, r.pos.y), dir: r.dir, alive: r.alive, }
}

///|
pub fn clone_goals_collected(gc : Array[Bool]) -> Array[Bool] {
  let out : Array[Bool] = []
  for i in 0..<gc.length() {
    out.push(gc[i])
  }
  out
}

///|
pub fn clone_blocks(blocks : Array[Vec2i]) -> Array[Vec2i] {
  let out : Array[Vec2i] = []
  for i in 0..<blocks.length() {
    out.push(vec2i(blocks[i].x, blocks[i].y))
  }
  out
}

///|
pub fn make_robot_state(
  robot : Robot,
  goals_collected : Array[Bool],
  blocks : Array[Vec2i],
  cmd_index : Int,
) -> RobotState {
  {
    pos: vec2i(robot.pos.x, robot.pos.y),
    dir: robot.dir,
    alive: robot.alive,
    goals_collected: clone_goals_collected(goals_collected),
    blocks: clone_blocks(blocks),
    cmd_index,
  }
}

///|
pub fn all_goals_collected(gc : Array[Bool]) -> Bool {
  for i in 0..<gc.length() {
    if !gc[i] {
      return false
    }
  }
  true
}

///|
pub fn count_goals_collected(gc : Array[Bool]) -> Int {
  let mut count = 0
  for i in 0..<gc.length() {
    if gc[i] {
      count += 1
    }
  }
  count
}

///|
pub fn tile_color_name(c : TileColor) -> String {
  match c {
    Red => "Red"
    Blue => "Blue"
    Green => "Green"
  }
}

///|
pub fn condition_name(c : Condition) -> String {
  match c {
    PathAhead => "PathAhead"
    WallAhead => "WallAhead"
    AtGoal => "AtGoal"
    OnColor(tc) => "On" + tile_color_name(tc)
  }
}

///|
pub fn medal_from_instructions(count : Int, par : Int, optimal : Int) -> Medal {
  if count <= optimal {
    Gold
  } else if count <= par {
    Silver
  } else {
    Bronze
  }
}

///|
pub fn medal_stars(m : Medal) -> Int {
  match m {
    Gold => 3
    Silver => 2
    Bronze => 1
    None_ => 0
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
pub fn absf(a : Float) -> Float {
  if a < 0.0 {
    -a
  } else {
    a
  }
}

///|
pub fn new_game() -> Game {
  let scores : Array[Array[LevelScore]] = []
  for _w in 0..<num_worlds {
    let world_scores : Array[LevelScore] = []
    for _l in 0..<levels_per_world {
      world_scores.push(new_level_score())
    }
    scores.push(world_scores)
  }
  {
    screen: Title,
    current_world: 0,
    current_level: 0,
    level: None,
    level_def: None,
    program: new_program(),
    editor: new_editor_state([]),
    run_state: Editing,
    trace: None,
    trace_step: 0,
    trace_timer: 0.0,
    run_speed: 1,
    scores,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    title_anim: 0.0,
    total_stars: 0,
  }
}

///|
pub fn is_tile_walkable(kind : TileKind) -> Bool {
  match kind {
    Floor | Goal | Start => true
    ColorTile(_) => true
    _ => false
  }
}

///|
pub fn is_tile_solid(kind : TileKind) -> Bool {
  match kind {
    Wall => true
    _ => false
  }
}

///|
pub fn is_tile_gap(kind : TileKind) -> Bool {
  match kind {
    Gap => true
    _ => false
  }
}

///|
pub fn has_block_at(blocks : Array[Vec2i], x : Int, y : Int) -> Bool {
  for i in 0..<blocks.length() {
    if blocks[i].x == x && blocks[i].y == y {
      return true
    }
  }
  false
}

///|
pub fn find_block_index(blocks : Array[Vec2i], x : Int, y : Int) -> Int {
  for i in 0..<blocks.length() {
    if blocks[i].x == x && blocks[i].y == y {
      return i
    }
  }
  -1
}

///|
pub fn tile_screen_x(gx : Int) -> Int {
  grid_offset_x + gx * tile_size
}

///|
pub fn tile_screen_y(gy : Int) -> Int {
  grid_offset_y + gy * tile_size
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
pub fn world_color(world : Int) -> @raylib.Color {
  match world {
    0 => color_world1
    1 => color_world2
    2 => color_world3
    3 => color_world4
    _ => color_text
  }
}

///|
pub fn world_name(world : Int) -> String {
  match world {
    0 => "Basics"
    1 => "Leaps"
    2 => "Logic"
    3 => "Mastery"
    _ => "???"
  }
}

///|
pub fn calculate_total_stars(scores : Array[Array[LevelScore]]) -> Int {
  let mut total = 0
  for w in 0..<scores.length() {
    for l in 0..<scores[w].length() {
      total += medal_stars(scores[w][l].medal)
    }
  }
  total
}
