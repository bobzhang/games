///|
/// Converts board coordinates to a linear board array index.
pub fn board_index(x : Int32, y : Int32) -> Int32 {
  y * board_cols + x
}

///|
/// Returns whether a piece at `(px, py)` intersects walls or locked blocks.
pub fn collides(
  game : Game,
  kind : Int32,
  rot : Int32,
  px : Int32,
  py : Int32,
) -> Bool {
  for i in 0..<4 {
    let c = piece_cell(kind, rot, i)
    let x = px + c.x
    let y = py + c.y
    if x < 0 || x >= board_cols || y >= board_rows {
      return true
    }
    if y >= 0 && game.board[board_index(x, y)] != 0 {
      return true
    }
  }
  false
}
