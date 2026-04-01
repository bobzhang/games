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
pub fn absf(a : Float) -> Float {
  if a < 0.0 {
    -a
  } else {
    a
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
pub fn pi() -> Float {
  3.14159265
}

///|
/// Get the 6 hex neighbors of a cell using odd-r offset coordinates
pub fn hex_neighbors(coord : HexCoord) -> Array[HexCoord] {
  let row = coord.row
  let col = coord.col
  let parity = row % 2
  if parity == 0 {
    // Even row
    [
      { row, col: col + 1 },
      { row, col: col - 1 },
      { row: row - 1, col },
      { row: row - 1, col: col - 1 },
      { row: row + 1, col },
      { row: row + 1, col: col - 1 },
    ]
  } else {
    // Odd row
    [
      { row, col: col + 1 },
      { row, col: col - 1 },
      { row: row - 1, col: col + 1 },
      { row: row - 1, col },
      { row: row + 1, col: col + 1 },
      { row: row + 1, col },
    ]
  }
}

///|
/// Filter neighbors to only valid board positions
pub fn hex_neighbors_valid(coord : HexCoord, size : Int) -> Array[HexCoord] {
  let all = hex_neighbors(coord)
  let result : Array[HexCoord] = []
  for i in 0..<all.length() {
    let n = all[i]
    if n.row >= 0 && n.row < size && n.col >= 0 && n.col < size {
      result.push(n)
    }
  }
  result
}

///|
/// Convert hex coord to pixel position (flat-top hex, odd-r offset)
pub fn hex_to_pixel(coord : HexCoord, size : Float) -> (Float, Float) {
  let row = Float::from_int(coord.row)
  let col = Float::from_int(coord.col)
  let w = sqrtf(3.0) * size
  let h : Float = 2.0 * size
  let x_offset = if coord.row % 2 == 1 { w / 2.0 } else { 0.0 }
  let px = board_offset_x + col * w + x_offset
  let py : Float = board_offset_y + row * (h * 0.75)
  (px, py)
}

///|
/// Convert pixel position to nearest hex coord
pub fn pixel_to_hex(px : Float, py : Float, size : Float) -> HexCoord? {
  let mut best_row = 0
  let mut best_col = 0
  let mut best_dist : Float = 999999.0
  for r in 0..<board_size {
    for c in 0..<board_size {
      let coord : HexCoord = { row: r, col: c }
      let (hx, hy) = hex_to_pixel(coord, size)
      let dx = px - hx
      let dy = py - hy
      let dist = sqrtf(dx * dx + dy * dy)
      if dist < best_dist {
        best_dist = dist
        best_row = r
        best_col = c
      }
    }
  }
  if best_dist < size * 0.95 {
    Some({ row: best_row, col: best_col })
  } else {
    None
  }
}

///|
/// Check if a coord is on the board edge
pub fn is_edge(coord : HexCoord, size : Int) -> Bool {
  coord.row == 0 ||
  coord.row == size - 1 ||
  coord.col == 0 ||
  coord.col == size - 1
}

///|
/// Get cell state from board
pub fn get_cell(board : HexBoard, coord : HexCoord) -> CellState {
  if coord.row >= 0 &&
    coord.row < board.size &&
    coord.col >= 0 &&
    coord.col < board.size {
    board.cells[coord.row][coord.col]
  } else {
    Empty
  }
}

///|
/// Set cell state on board
pub fn set_cell(board : HexBoard, coord : HexCoord, state : CellState) -> Unit {
  if coord.row >= 0 &&
    coord.row < board.size &&
    coord.col >= 0 &&
    coord.col < board.size {
    board.cells[coord.row][coord.col] = state
  }
}

///|
/// Check if coord has a specific player's stone
pub fn has_stone(board : HexBoard, coord : HexCoord, player : Player) -> Bool {
  match get_cell(board, coord) {
    Occupied(p) => p == player
    Empty => false
  }
}

///|
/// Check if a hex coordinate is within the board
pub fn in_bounds(coord : HexCoord, size : Int) -> Bool {
  coord.row >= 0 && coord.row < size && coord.col >= 0 && coord.col < size
}

///|
/// Create a new empty board
pub fn new_board(size : Int) -> HexBoard {
  let cells : Array[Array[CellState]] = []
  for _r in 0..<size {
    let row : Array[CellState] = []
    for _c in 0..<size {
      row.push(Empty)
    }
    cells.push(row)
  }
  { size, cells }
}

///|
/// Clone a board
pub fn clone_board(board : HexBoard) -> HexBoard {
  let cells : Array[Array[CellState]] = []
  for r in 0..<board.size {
    let row : Array[CellState] = []
    for c in 0..<board.size {
      row.push(board.cells[r][c])
    }
    cells.push(row)
  }
  { size: board.size, cells }
}

///|
/// Create a new game
pub fn new_game() -> Game {
  {
    screen: Title,
    mode: VsAI,
    difficulty: Normal,
    play_state: WaitingForMove,
    board: new_board(board_size),
    current_player: Black,
    black_score: 0,
    white_score: 0,
    black_captures: 0,
    white_captures: 0,
    patterns_found: [],
    last_move: None,
    move_count: 0,
    black_passed: false,
    white_passed: false,
    frame_count: 0,
    ai_delay: 0.0,
    capture_anims: [],
    pattern_anims: [],
    score_anims: [],
    hover_hex: None,
    puzzle_levels: [],
    current_puzzle: 0,
    puzzle_score: 0,
    puzzle_solved: false,
    menu_selection: 0,
    winner: None,
    result_message: "",
  }
}

///|
/// Reset game state for a new round
pub fn reset_game(game : Game) -> Unit {
  let board = new_board(board_size)
  for r in 0..<board_size {
    for c in 0..<board_size {
      game.board.cells[r][c] = board.cells[r][c]
    }
  }
  game.current_player = Black
  game.black_score = 0
  game.white_score = 0
  game.black_captures = 0
  game.white_captures = 0
  game.patterns_found = []
  game.last_move = None
  game.move_count = 0
  game.black_passed = false
  game.white_passed = false
  game.play_state = WaitingForMove
  game.ai_delay = 0.0
  game.capture_anims = []
  game.pattern_anims = []
  game.score_anims = []
  game.hover_hex = None
  game.puzzle_score = 0
  game.puzzle_solved = false
  game.winner = None
  game.result_message = ""
}

///|
/// Get the opponent player
pub fn opponent(player : Player) -> Player {
  match player {
    Black => White
    White => Black
  }
}

///|
/// Get pattern points for a given kind
pub fn pattern_points(kind : PatternKind) -> Int {
  match kind {
    Bridge => bridge_points
    Chain => chain_points
    Triangle => triangle_points
    Diamond => diamond_points
    Fortress => fortress_points
    Ring => ring_points
    Star => star_points
    Wall => wall_points
  }
}

///|
/// Get pattern name as a string
pub fn pattern_name(kind : PatternKind) -> String {
  match kind {
    Bridge => "Bridge"
    Chain => "Chain"
    Triangle => "Triangle"
    Diamond => "Diamond"
    Fortress => "Fortress"
    Ring => "Ring"
    Star => "Star"
    Wall => "Wall"
  }
}

///|
/// Count total empty cells on the board
pub fn count_empty(board : HexBoard) -> Int {
  let mut count = 0
  for r in 0..<board.size {
    for c in 0..<board.size {
      match board.cells[r][c] {
        Empty => count = count + 1
        _ => ()
      }
    }
  }
  count
}

///|
/// Get all empty positions on the board
pub fn empty_positions(board : HexBoard) -> Array[HexCoord] {
  let result : Array[HexCoord] = []
  for r in 0..<board.size {
    for c in 0..<board.size {
      match board.cells[r][c] {
        Empty => result.push({ row: r, col: c })
        _ => ()
      }
    }
  }
  result
}

///|
/// Check if two hex coords are equal
pub fn hex_eq(a : HexCoord, b : HexCoord) -> Bool {
  a.row == b.row && a.col == b.col
}

///|
/// Check if an array of hex coords contains a given coord
pub fn hex_contains(arr : Array[HexCoord], coord : HexCoord) -> Bool {
  for i in 0..<arr.length() {
    if hex_eq(arr[i], coord) {
      return true
    }
  }
  false
}
