///|
/// Relative block coordinate inside a tetromino.
pub(all) struct Cell {
  x : Int32
  y : Int32
}

///|
/// Full mutable state for one Tetris match.
pub(all) struct Game {
  board : Array[Int32]
  mut piece_kind : Int32
  mut piece_rot : Int32
  mut piece_x : Int32
  mut piece_y : Int32
  mut next_kind : Int32
  mut hold_kind : Int32
  mut hold_used : Bool
  mut score : Int32
  mut lines : Int32
  mut level : Int32
  mut drop_timer : Float
  mut drop_interval : Float
  mut over : Bool
  bag : Array[Int32]
  mut bag_pos : Int32
}

///|
/// Allocates default game state and empty board buffers.
pub fn Game::Game() -> Game {
  {
    board: Array::make(board_cols * board_rows, 0),
    piece_kind: 0,
    piece_rot: 0,
    piece_x: board_cols / 2,
    piece_y: 0,
    next_kind: 0,
    hold_kind: -1,
    hold_used: false,
    score: 0,
    lines: 0,
    level: 1,
    drop_timer: 0.0,
    drop_interval: 0.65,
    over: false,
    bag: Array::make(bag_size, 0),
    bag_pos: bag_size,
  }
}
