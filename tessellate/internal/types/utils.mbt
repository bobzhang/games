///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn rotate_cell(cell : Vec2i, times : Int) -> Vec2i {
  let mut cx = cell.x
  let mut cy = cell.y
  let n = (times % 4 + 4) % 4
  for _i in 0..<n {
    let tmp = cx
    cx = -cy
    cy = tmp
  }
  { x: cx, y: cy }
}

///|
pub fn flip_cell(cell : Vec2i) -> Vec2i {
  { x: -cell.x, y: cell.y }
}

///|
pub fn transform_cells(
  cells : Array[Vec2i],
  rotation : Int,
  flipped : Bool,
) -> Array[Vec2i] {
  let result : Array[Vec2i] = []
  for i in 0..<cells.length() {
    let mut c = cells[i]
    if flipped {
      c = flip_cell(c)
    }
    c = rotate_cell(c, rotation)
    result.push(c)
  }
  result
}

///|
pub fn piece_bounds(cells : Array[Vec2i]) -> (Int, Int, Int, Int) {
  let mut min_x = 100
  let mut min_y = 100
  let mut max_x = -100
  let mut max_y = -100
  for i in 0..<cells.length() {
    let c = cells[i]
    if c.x < min_x {
      min_x = c.x
    }
    if c.y < min_y {
      min_y = c.y
    }
    if c.x > max_x {
      max_x = c.x
    }
    if c.y > max_y {
      max_y = c.y
    }
  }
  (min_x, min_y, max_x, max_y)
}

///|
pub fn new_region(
  width : Int,
  height : Int,
  active_cells : Array[Vec2i],
) -> Region {
  let active : Array[Array[Bool]] = []
  for _r in 0..<height {
    let row : Array[Bool] = []
    for _c in 0..<width {
      row.push(false)
    }
    active.push(row)
  }
  for i in 0..<active_cells.length() {
    let c = active_cells[i]
    if c.y >= 0 && c.y < height && c.x >= 0 && c.x < width {
      active[c.y][c.x] = true
    }
  }
  { width, height, active }
}

///|
pub fn full_region(width : Int, height : Int) -> Region {
  let active : Array[Array[Bool]] = []
  for _r in 0..<height {
    let row : Array[Bool] = []
    for _c in 0..<width {
      row.push(true)
    }
    active.push(row)
  }
  { width, height, active }
}

///|
pub fn rect_region(x : Int, y : Int, w : Int, h : Int) -> Region {
  let cells : Array[Vec2i] = []
  for row in y..<(y + h) {
    for col in x..<(x + w) {
      cells.push(vec2i(col, row))
    }
  }
  new_region(grid_cols, grid_rows, cells)
}

///|
pub fn count_active_cells(region : Region) -> Int {
  let mut count = 0
  for r in 0..<region.height {
    for c in 0..<region.width {
      if region.active[r][c] {
        count += 1
      }
    }
  }
  count
}

///|
pub fn make_piece(cells : Array[Vec2i], color : @raylib.Color) -> Piece {
  { cells, color }
}

// Standard polyomino definitions

///|
pub fn monomino(color : @raylib.Color) -> Piece {
  make_piece([vec2i(0, 0)], color)
}

///|
pub fn domino_h(color : @raylib.Color) -> Piece {
  make_piece([vec2i(0, 0), vec2i(1, 0)], color)
}

///|
pub fn triomino_i(color : @raylib.Color) -> Piece {
  make_piece([vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0)], color)
}

///|
pub fn triomino_l(color : @raylib.Color) -> Piece {
  make_piece([vec2i(0, 0), vec2i(1, 0), vec2i(0, 1)], color)
}

///|
pub fn tetromino_i(color : @raylib.Color) -> Piece {
  make_piece([vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0), vec2i(2, 0)], color)
}

///|
pub fn tetromino_o(color : @raylib.Color) -> Piece {
  make_piece([vec2i(0, 0), vec2i(1, 0), vec2i(0, 1), vec2i(1, 1)], color)
}

///|
pub fn tetromino_t(color : @raylib.Color) -> Piece {
  make_piece([vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0), vec2i(0, 1)], color)
}

///|
pub fn tetromino_s(color : @raylib.Color) -> Piece {
  make_piece([vec2i(0, 0), vec2i(1, 0), vec2i(-1, 1), vec2i(0, 1)], color)
}

///|
pub fn tetromino_z(color : @raylib.Color) -> Piece {
  make_piece([vec2i(-1, 0), vec2i(0, 0), vec2i(0, 1), vec2i(1, 1)], color)
}

///|
pub fn tetromino_l(color : @raylib.Color) -> Piece {
  make_piece([vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0), vec2i(1, 1)], color)
}

///|
pub fn tetromino_j(color : @raylib.Color) -> Piece {
  make_piece([vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0), vec2i(-1, 1)], color)
}

// Pentominoes

///|
pub fn pento_f(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(0, 0), vec2i(1, 0), vec2i(-1, 1), vec2i(0, 1), vec2i(0, 2)],
    color,
  )
}

///|
pub fn pento_i(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(-2, 0), vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0), vec2i(2, 0)],
    color,
  )
}

///|
pub fn pento_l(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0), vec2i(2, 0), vec2i(2, 1)],
    color,
  )
}

///|
pub fn pento_n(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(0, 0), vec2i(1, 0), vec2i(-1, 1), vec2i(0, 1), vec2i(-1, 2)],
    color,
  )
}

///|
pub fn pento_p(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(0, 0), vec2i(1, 0), vec2i(0, 1), vec2i(1, 1), vec2i(0, 2)],
    color,
  )
}

///|
pub fn pento_t(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(-1, 0), vec2i(0, 0), vec2i(1, 0), vec2i(0, 1), vec2i(0, 2)],
    color,
  )
}

///|
pub fn pento_u(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(-1, 0), vec2i(1, 0), vec2i(-1, 1), vec2i(0, 1), vec2i(1, 1)],
    color,
  )
}

///|
pub fn pento_v(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(0, 0), vec2i(0, 1), vec2i(0, 2), vec2i(1, 2), vec2i(2, 2)],
    color,
  )
}

///|
pub fn pento_w(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(0, 0), vec2i(0, 1), vec2i(1, 1), vec2i(1, 2), vec2i(2, 2)],
    color,
  )
}

///|
pub fn pento_x(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(0, 0), vec2i(-1, 1), vec2i(0, 1), vec2i(1, 1), vec2i(0, 2)],
    color,
  )
}

///|
pub fn pento_y(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(0, 0), vec2i(-1, 1), vec2i(0, 1), vec2i(0, 2), vec2i(0, 3)],
    color,
  )
}

///|
pub fn pento_z(color : @raylib.Color) -> Piece {
  make_piece(
    [vec2i(-1, 0), vec2i(0, 0), vec2i(0, 1), vec2i(0, 2), vec2i(1, 2)],
    color,
  )
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_time: 9999, best_rotations: 9999 }
}

///|
pub fn new_grid() -> Array[Array[Int]] {
  let grid : Array[Array[Int]] = []
  for _r in 0..<grid_rows {
    let row : Array[Int] = []
    for _c in 0..<grid_cols {
      row.push(-1)
    }
    grid.push(row)
  }
  grid
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Placing,
    current_tier: Squares,
    current_level: 0,
    selected_piece: -1,
    hover_x: -1,
    hover_y: -1,
    rotation: 0,
    flipped: false,
    placed_pieces: [],
    grid: new_grid(),
    timer: 0.0,
    rotation_count: 0,
    level_scores: scores,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    tier_page: 0,
  }
}

///|
pub fn reset_level(game : Game) -> Unit {
  game.play_state = Placing
  game.selected_piece = -1
  game.hover_x = -1
  game.hover_y = -1
  game.rotation = 0
  game.flipped = false
  game.placed_pieces = []
  game.grid = new_grid()
  game.timer = 0.0
  game.rotation_count = 0
  game.message = ""
  game.message_timer = 0.0
}

///|
pub fn tier_index(tier : Tier) -> Int {
  match tier {
    Squares => 0
    Shapes => 1
    Art => 2
  }
}

///|
pub fn tier_from_index(i : Int) -> Tier {
  match i {
    0 => Squares
    1 => Shapes
    _ => Art
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Squares => "Squares"
    Shapes => "Shapes"
    Art => "Art"
  }
}

///|
pub fn level_index(tier : Tier, level_in_tier : Int) -> Int {
  tier_index(tier) * levels_per_tier + level_in_tier
}

///|
pub fn piece_color_by_index(index : Int) -> @raylib.Color {
  let colors : Array[@raylib.Color] = [
    piece_color_red, piece_color_blue, piece_color_green, piece_color_yellow, piece_color_purple,
    piece_color_orange, piece_color_cyan, piece_color_pink, piece_color_lime, piece_color_teal,
    piece_color_brown, piece_color_magenta,
  ]
  colors[index % colors.length()]
}
