///|
pub fn new_cell() -> Cell {
  { glaze: Empty, fired: FEmpty, }
}

///|
pub fn new_grid() -> Grid {
  let cells : Array[Cell] = []
  for _i in 0..<(grid_cols * grid_rows) {
    cells.push(new_cell())
  }
  { cells, }
}

///|
pub fn grid_index(row : Int, col : Int) -> Int {
  row * grid_cols + col
}

///|
pub fn get_cell(grid : Grid, row : Int, col : Int) -> Cell {
  grid.cells[grid_index(row, col)]
}

///|
pub fn set_glaze(grid : Grid, row : Int, col : Int, color : GlazeColor) -> Unit {
  grid.cells[grid_index(row, col)].glaze = color
}

///|
pub fn clear_grid(grid : Grid) -> Unit {
  for i in 0..<grid.cells.length() {
    grid.cells[i].glaze = Empty
    grid.cells[i].fired = FEmpty
  }
}

///|
pub fn new_score() -> LevelScore {
  {
    stars: 0,
    matched_cells: 0,
    cracked_cells: 0,
    total_cells: grid_cols * grid_rows,
    moves_used: 0,
  }
}

///|
pub fn new_game() -> Game {
  let scores : Array[Int] = []
  for _i in 0..<20 {
    scores.push(0)
  }
  {
    screen: Title,
    selected_tier: Beginner,
    selected_level: 0,
    current_level: None,
    grid: new_grid(),
    target_grid: [],
    play_state: Placing,
    selected_glaze: Red,
    hover_row: -1,
    hover_col: -1,
    moves_used: 0,
    max_moves: 0,
    score: None,
    level_scores: scores,
    undo_stack: [],
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    fire_timer: 0.0,
    fire_phase: 0,
    title_anim_timer: 0.0,
    allowed_glazes: [Red, Blue, Green, Gold, White, Black],
  }
}

///|
pub fn glaze_name(g : GlazeColor) -> String {
  match g {
    Red => "Red"
    Blue => "Blue"
    Green => "Green"
    Gold => "Gold"
    White => "White"
    Black => "Black"
    Empty => "Empty"
  }
}

///|
pub fn glaze_to_raylib(g : GlazeColor) -> @raylib.Color {
  match g {
    Red => @raylib.Color::new(210, 50, 50, 255)
    Blue => @raylib.Color::new(50, 80, 200, 255)
    Green => @raylib.Color::new(50, 170, 70, 255)
    Gold => @raylib.Color::new(220, 180, 40, 255)
    White => @raylib.Color::new(240, 238, 232, 255)
    Black => @raylib.Color::new(30, 28, 25, 255)
    Empty => @raylib.Color::new(80, 72, 90, 120)
  }
}

///|
pub fn fired_to_raylib(f : FiredColor) -> @raylib.Color {
  match f {
    FRed => @raylib.Color::new(200, 55, 55, 255)
    FBlue => @raylib.Color::new(55, 85, 195, 255)
    FGreen => @raylib.Color::new(55, 165, 75, 255)
    FGold => @raylib.Color::new(215, 175, 45, 255)
    FWhite => @raylib.Color::new(235, 232, 225, 255)
    FBlack => @raylib.Color::new(35, 32, 28, 255)
    FPurple => @raylib.Color::new(140, 50, 180, 255)
    FDeepRed => @raylib.Color::new(160, 30, 30, 255)
    FDeepBlue => @raylib.Color::new(30, 50, 160, 255)
    FDeepGreen => @raylib.Color::new(30, 130, 50, 255)
    FDeepGold => @raylib.Color::new(180, 145, 20, 255)
    FDeepWhite => @raylib.Color::new(255, 255, 248, 255)
    FDeepBlack => @raylib.Color::new(15, 12, 10, 255)
    FCracked => @raylib.Color::new(120, 100, 80, 255)
    FEmpty => @raylib.Color::new(80, 72, 90, 120)
  }
}

///|
pub fn fired_name(f : FiredColor) -> String {
  match f {
    FRed => "Red"
    FBlue => "Blue"
    FGreen => "Green"
    FGold => "Gold"
    FWhite => "White"
    FBlack => "Black"
    FPurple => "Purple"
    FDeepRed => "Deep Red"
    FDeepBlue => "Deep Blue"
    FDeepGreen => "Deep Green"
    FDeepGold => "Deep Gold"
    FDeepWhite => "Pearl"
    FDeepBlack => "Obsidian"
    FCracked => "Cracked!"
    FEmpty => "Empty"
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Beginner => "Beginner"
    Intermediate => "Intermediate"
    Advanced => "Advanced"
  }
}

///|
pub fn tier_index(t : Tier) -> Int {
  match t {
    Beginner => 0
    Intermediate => 1
    Advanced => 2
  }
}

///|
pub fn tier_from_index(i : Int) -> Tier {
  if i == 0 {
    Beginner
  } else if i == 1 {
    Intermediate
  } else {
    Advanced
  }
}

///|
pub fn tier_level_range(t : Tier) -> (Int, Int) {
  match t {
    Beginner => (0, 7)
    Intermediate => (7, 14)
    Advanced => (14, 20)
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
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn glaze_index(g : GlazeColor) -> Int {
  match g {
    Red => 0
    Blue => 1
    Green => 2
    Gold => 3
    White => 4
    Black => 5
    Empty => -1
  }
}

///|
pub fn glaze_from_index(i : Int) -> GlazeColor {
  match i {
    0 => Red
    1 => Blue
    2 => Green
    3 => Gold
    4 => White
    5 => Black
    _ => Empty
  }
}

///|
pub fn is_incompatible(a : GlazeColor, b : GlazeColor) -> Bool {
  // Red + Green crack, Gold + Black crack
  match (a, b) {
    (Red, Green) | (Green, Red) => true
    (Gold, Black) | (Black, Gold) => true
    _ => false
  }
}

///|
pub fn blend_result(a : GlazeColor, b : GlazeColor) -> FiredColor {
  // Red + Blue -> Purple
  match (a, b) {
    (Red, Blue) | (Blue, Red) => FPurple
    _ => FCracked
  }
}
