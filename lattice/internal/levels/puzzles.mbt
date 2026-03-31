///|
/// Create all 20 puzzle levels
pub fn create_puzzles() -> Array[@types.PuzzleLevel] {
  let puzzles : Array[@types.PuzzleLevel] = []
  // Puzzle 1: Complete a Bridge
  puzzles.push(make_puzzle(1, "Complete the Bridge", 2, fn(b) {
    place(b, 2, 2, Black)
    // Player needs to place at (2, 4) to bridge through (2,3)
  }))
  // Puzzle 2: Form a Chain of 3
  puzzles.push(make_puzzle(2, "Form a Chain of 3", 3, fn(b) {
    place(b, 3, 1, Black)
    place(b, 3, 2, Black)
    // Player places at (3,3) to make chain
  }))
  // Puzzle 3: Form a Triangle
  puzzles.push(make_puzzle(3, "Form a Triangle", 4, fn(b) {
    place(b, 2, 3, Black)
    place(b, 3, 3, Black)
    // Player places to close the triangle
  }))
  // Puzzle 4: Capture opponent stones
  puzzles.push(make_puzzle(4, "Capture surrounded stones", 2, fn(b) {
    place(b, 3, 3, White)
    place(b, 2, 3, Black)
    place(b, 2, 4, Black)
    place(b, 3, 4, Black)
    place(b, 4, 3, Black)
    place(b, 4, 4, Black)
    // Player needs to close last liberty
  }))
  // Puzzle 5: Build a Diamond
  puzzles.push(make_puzzle(5, "Complete the Diamond", 5, fn(b) {
    place(b, 2, 3, Black)
    place(b, 3, 2, Black)
    place(b, 3, 3, Black)
    // Player places to complete diamond
  }))
  // Puzzle 6: Wall of 4
  puzzles.push(make_puzzle(6, "Build a Wall", 3, fn(b) {
    place(b, 0, 0, Black)
    place(b, 0, 1, Black)
    place(b, 0, 2, Black)
    // Player places at (0,3) for wall
  }))
  // Puzzle 7: Fortress
  puzzles.push(make_puzzle(7, "Build a Fortress", 6, fn(b) {
    place(b, 3, 3, Black)
    place(b, 2, 3, Black)
    place(b, 2, 4, Black)
    place(b, 3, 4, Black)
    // Player places to surround center
  }))
  // Puzzle 8: Chain + Capture combo
  puzzles.push(make_puzzle(8, "Chain and Capture combo", 5, fn(b) {
    place(b, 3, 1, Black)
    place(b, 3, 2, Black)
    place(b, 2, 4, White)
    place(b, 2, 3, Black)
    place(b, 3, 4, Black)
    place(b, 1, 4, Black)
    // Player extends chain and captures
  }))
  // Puzzle 9: Double Triangle
  puzzles.push(make_puzzle(9, "Score with 2 Triangles", 8, fn(b) {
    place(b, 2, 2, Black)
    place(b, 2, 3, Black)
    place(b, 3, 3, Black)
    place(b, 3, 4, Black)
    // Player places to form 2 triangles at once
  }))
  // Puzzle 10: Capture cascading
  puzzles.push(make_puzzle(10, "Trigger cascade capture", 4, fn(b) {
    place(b, 3, 3, White)
    place(b, 2, 2, White)
    place(b, 2, 3, Black)
    place(b, 2, 4, Black)
    place(b, 3, 4, Black)
    place(b, 4, 3, Black)
    place(b, 4, 4, Black)
    place(b, 1, 2, Black)
    place(b, 1, 3, Black)
    place(b, 3, 2, Black)
  }))
  // Puzzle 11: Block opponent triangle
  puzzles.push(make_puzzle(11, "Block and score", 4, fn(b) {
    place(b, 4, 2, White)
    place(b, 4, 3, White)
    place(b, 2, 2, Black)
    place(b, 2, 3, Black)
  }))
  // Puzzle 12: Ring attempt
  puzzles.push(make_puzzle(12, "Complete the Ring", 7, fn(b) {
    // Set up 5 of 6 ring stones around center (3,3)
    let neighbors = @types.hex_neighbors({ row: 3, col: 3 })
    for i in 0..<5 {
      let n = neighbors[i]
      if @types.in_bounds(n, @types.board_size) {
        place(b, n.row, n.col, Black)
      }
    }
  }))
  // Puzzle 13: Star setup
  puzzles.push(make_puzzle(13, "Almost a Star", 8, fn(b) {
    place(b, 3, 3, Black)
    let neighbors = @types.hex_neighbors({ row: 3, col: 3 })
    for i in 0..<5 {
      let n = neighbors[i]
      if @types.in_bounds(n, @types.board_size) {
        place(b, n.row, n.col, Black)
      }
    }
  }))
  // Puzzle 14: Chain of 4
  puzzles.push(make_puzzle(14, "Long Chain", 3, fn(b) {
    place(b, 3, 0, Black)
    place(b, 3, 1, Black)
    place(b, 3, 2, Black)
    // Player places at (3,3) for chain of 4
  }))
  // Puzzle 15: Multi-capture
  puzzles.push(make_puzzle(15, "Multi-group capture", 4, fn(b) {
    place(b, 2, 3, White)
    place(b, 4, 3, White)
    place(b, 1, 3, Black)
    place(b, 1, 4, Black)
    place(b, 2, 4, Black)
    place(b, 3, 4, Black)
    place(b, 4, 4, Black)
    place(b, 5, 3, Black)
    place(b, 5, 4, Black)
    place(b, 3, 2, Black)
    place(b, 2, 2, Black)
    place(b, 4, 2, Black)
  }))
  // Puzzle 16: Defensive wall
  puzzles.push(make_puzzle(16, "Build defensive Wall", 3, fn(b) {
    place(b, 6, 1, Black)
    place(b, 6, 2, Black)
    place(b, 6, 3, Black)
    place(b, 5, 2, White)
    place(b, 5, 3, White)
  }))
  // Puzzle 17: Diamond + Chain
  puzzles.push(make_puzzle(17, "Diamond and Chain", 8, fn(b) {
    place(b, 2, 3, Black)
    place(b, 3, 2, Black)
    place(b, 3, 3, Black)
    place(b, 3, 4, Black)
    place(b, 3, 5, Black)
  }))
  // Puzzle 18: Fortress + Wall
  puzzles.push(make_puzzle(18, "Fortress near Wall", 9, fn(b) {
    place(b, 0, 0, Black)
    place(b, 0, 1, Black)
    place(b, 0, 2, Black)
    place(b, 1, 0, Black)
    place(b, 1, 1, Black)
  }))
  // Puzzle 19: Complex capture + pattern
  puzzles.push(make_puzzle(19, "Capture into Triangle", 6, fn(b) {
    place(b, 3, 3, White)
    place(b, 2, 3, Black)
    place(b, 2, 4, Black)
    place(b, 3, 4, Black)
    place(b, 4, 3, Black)
    place(b, 4, 4, Black)
    place(b, 3, 2, Black)
  }))
  // Puzzle 20: Grand finale - maximum score
  puzzles.push(make_puzzle(20, "Maximum score move", 10, fn(b) {
    // Set up a situation where one move scores big
    place(b, 2, 2, Black)
    place(b, 2, 3, Black)
    place(b, 3, 4, Black)
    place(b, 4, 3, Black)
    place(b, 4, 2, Black)
    place(b, 3, 1, Black)
    // Opponent stones to capture
    place(b, 3, 2, White)
    place(b, 3, 3, White)
  }))
  puzzles
}

///|
fn make_puzzle(
  id : Int,
  hint : String,
  target_score : Int,
  setup : (Array[Array[@types.CellState]]) -> Unit
) -> @types.PuzzleLevel {
  let board = @types.new_board(@types.board_size)
  setup(board.cells)
  { id, board, current_player: Black, target_score, hint }
}

///|
fn place(
  cells : Array[Array[@types.CellState]],
  row : Int,
  col : Int,
  player : @types.Player
) -> Unit {
  if row >= 0 && row < @types.board_size && col >= 0 && col < @types.board_size {
    cells[row][col] = Occupied(player)
  }
}
