///|
pub fn new_cell() -> TreeCell {
  { kind: Empty, growth_dir: Up, age: 0, stagnant_turns: 0, }
}

///|
pub fn new_grid(w : Int, h : Int) -> TreeGrid {
  let cells : Array[TreeCell] = Array(capacity=w * h)
  for _i in 0..<(w * h) {
    cells.push(new_cell())
  }
  { width: w, height: h, cells, }
}

///|
pub fn grid_index(g : TreeGrid, x : Int, y : Int) -> Int {
  y * g.width + x
}

///|
pub fn grid_in_bounds(g : TreeGrid, x : Int, y : Int) -> Bool {
  x >= 0 && x < g.width && y >= 0 && y < g.height
}

///|
pub fn grid_get(g : TreeGrid, x : Int, y : Int) -> TreeCell {
  g.cells[grid_index(g, x, y)]
}

///|
pub fn grid_set_kind(
  g : TreeGrid,
  x : Int,
  y : Int,
  kind : CellKind,
  dir : GrowthDir,
) -> Unit {
  let idx = grid_index(g, x, y)
  g.cells[idx].kind = kind
  g.cells[idx].growth_dir = dir
  g.cells[idx].age = 0
  g.cells[idx].stagnant_turns = 0
}

///|
pub fn clone_grid(g : TreeGrid) -> TreeGrid {
  let cells : Array[TreeCell] = Array(capacity=g.cells.length())
  for i in 0..<g.cells.length() {
    let c = g.cells[i]
    cells.push({
      kind: c.kind,
      growth_dir: c.growth_dir,
      age: c.age,
      stagnant_turns: c.stagnant_turns,
    })
  }
  { width: g.width, height: g.height, cells, }
}

///|
pub fn snapshot_grid(g : TreeGrid) -> GridSnapshot {
  let cells : Array[TreeCell] = Array(capacity=g.cells.length())
  for i in 0..<g.cells.length() {
    let c = g.cells[i]
    cells.push({
      kind: c.kind,
      growth_dir: c.growth_dir,
      age: c.age,
      stagnant_turns: c.stagnant_turns,
    })
  }
  { cells, }
}

///|
pub fn restore_grid(g : TreeGrid, snap : GridSnapshot) -> Unit {
  for i in 0..<g.cells.length() {
    g.cells[i].kind = snap.cells[i].kind
    g.cells[i].growth_dir = snap.cells[i].growth_dir
    g.cells[i].age = snap.cells[i].age
    g.cells[i].stagnant_turns = snap.cells[i].stagnant_turns
  }
}

///|
pub fn fork_interval(species : Species) -> Int {
  match species {
    Pine => pine_fork_interval
    Maple => maple_fork_interval
    Cherry => cherry_fork_interval
  }
}

///|
pub fn species_name(species : Species) -> String {
  match species {
    Pine => "Pine"
    Maple => "Maple"
    Cherry => "Cherry"
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Tier1 => "Pine Grove"
    Tier2 => "Maple Garden"
    Tier3 => "Cherry Orchard"
  }
}

///|
pub fn tier_species(tier : Tier) -> Species {
  match tier {
    Tier1 => Pine
    Tier2 => Maple
    Tier3 => Cherry
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Tier1 => 8
    Tier2 => 9
    Tier3 => 8
  }
}

///|
pub fn tier_level_offset(tier : Tier) -> Int {
  match tier {
    Tier1 => 0
    Tier2 => 8
    Tier3 => 17
  }
}

///|
pub fn branch_color(species : Species) -> @raylib.Color {
  match species {
    Pine => color_branch_pine
    Maple => color_branch_maple
    Cherry => color_branch_cherry
  }
}

///|
pub fn leaf_color(species : Species) -> @raylib.Color {
  match species {
    Pine => color_leaf_pine
    Maple => color_leaf_maple
    Cherry => color_leaf_cherry
  }
}

///|
pub fn is_branch_or_trunk(kind : CellKind) -> Bool {
  match kind {
    Trunk | Branch => true
    _ => false
  }
}

///|
pub fn is_solid(kind : CellKind) -> Bool {
  match kind {
    Trunk | Branch | Leaf => true
    _ => false
  }
}

///|
pub fn cell_screen_x(gx : Int) -> Int {
  grid_offset_x + gx * cell_render_size
}

///|
pub fn cell_screen_y(gy : Int) -> Int {
  grid_offset_y + gy * cell_render_size
}

///|
pub fn screen_to_grid_x(sx : Int) -> Int {
  (sx - grid_offset_x) / cell_render_size
}

///|
pub fn screen_to_grid_y(sy : Int) -> Int {
  (sy - grid_offset_y) / cell_render_size
}

///|
pub fn dir_dx(dir : GrowthDir) -> Int {
  match dir {
    Up => 0
    UpLeft => -1
    UpRight => 1
    Left => -1
    Right => 1
  }
}

///|
pub fn dir_dy(dir : GrowthDir) -> Int {
  match dir {
    Up => -1
    UpLeft => -1
    UpRight => -1
    Left => 0
    Right => 0
  }
}

///|
pub fn new_level_scores() -> Array[LevelScore] {
  let scores : Array[LevelScore] = Array(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push({ stars: 0, completed: false, })
  }
  scores
}

///|
pub fn new_game() -> Game {
  {
    screen: Title,
    tree: new_grid(grid_width, grid_height),
    turn: 0,
    prunes_this_turn: 0,
    total_prunes: 0,
    history: [],
    current_level: None,
    current_tier: Tier1,
    selected_level: 0,
    play_state: Waiting,
    show_ghost: false,
    ghost_tree: None,
    hover_cell: None,
    scores: new_level_scores(),
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
    title_seed_angle: 0.0,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
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
pub fn absi(a : Int) -> Int {
  if a < 0 {
    -a
  } else {
    a
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
