///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_1()
    1 => level_2()
    2 => level_3()
    3 => level_4()
    4 => level_5()
    5 => level_6()
    6 => level_7()
    7 => level_8()
    8 => level_9()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    20 => level_21()
    21 => level_22()
    22 => level_23()
    23 => level_24()
    24 => level_25()
    25 => level_26()
    26 => level_27()
    27 => level_28()
    28 => level_29()
    _ => level_30()
  }
}

// Tier 1: Squares - rectangular regions, simple pieces

///|
fn level_1() -> @types.Level {
  // 4x2 rectangle, 4 dominoes
  let region = @types.rect_region(3, 4, 4, 2)
  let pieces = [
    @types.domino_h(@types.piece_color_red),
    @types.domino_h(@types.piece_color_blue),
    @types.domino_h(@types.piece_color_green),
    @types.domino_h(@types.piece_color_yellow),
  ]
  { region, pieces, par_time: 30, par_rotations: 4 }
}

///|
fn level_2() -> @types.Level {
  // 3x3 rectangle, 3 triominoes
  let region = @types.rect_region(3, 3, 3, 3)
  let pieces = [
    @types.triomino_i(@types.piece_color_red),
    @types.triomino_l(@types.piece_color_blue),
    @types.triomino_l(@types.piece_color_green),
  ]
  { region, pieces, par_time: 45, par_rotations: 4 }
}

///|
fn level_3() -> @types.Level {
  // 4x3 rectangle, 3 tetrominoes
  let region = @types.rect_region(3, 3, 4, 3)
  let pieces = [
    @types.tetromino_i(@types.piece_color_purple),
    @types.tetromino_l(@types.piece_color_orange),
    @types.tetromino_t(@types.piece_color_cyan),
  ]
  { region, pieces, par_time: 45, par_rotations: 5 }
}

///|
fn level_4() -> @types.Level {
  // 4x4 rectangle, 4 tetrominoes
  let region = @types.rect_region(3, 3, 4, 4)
  let pieces = [
    @types.tetromino_o(@types.piece_color_yellow),
    @types.tetromino_t(@types.piece_color_red),
    @types.tetromino_s(@types.piece_color_blue),
    @types.tetromino_z(@types.piece_color_green),
  ]
  { region, pieces, par_time: 60, par_rotations: 6 }
}

///|
fn level_5() -> @types.Level {
  // 5x4 rectangle, 5 tetrominoes
  let region = @types.rect_region(2, 3, 5, 4)
  let pieces = [
    @types.tetromino_i(@types.piece_color_red),
    @types.tetromino_l(@types.piece_color_blue),
    @types.tetromino_j(@types.piece_color_green),
    @types.tetromino_t(@types.piece_color_purple),
    @types.tetromino_o(@types.piece_color_orange),
  ]
  { region, pieces, par_time: 60, par_rotations: 8 }
}

///|
fn level_6() -> @types.Level {
  // 6x2 rectangle, 3 tetrominoes
  let region = @types.rect_region(2, 4, 6, 2)
  let pieces = [
    @types.tetromino_i(@types.piece_color_cyan),
    @types.tetromino_l(@types.piece_color_pink),
    @types.tetromino_j(@types.piece_color_lime),
  ]
  { region, pieces, par_time: 45, par_rotations: 4 }
}

///|
fn level_7() -> @types.Level {
  // 6x3 rectangle, dominoes + triominoes + tetrominoes
  let region = @types.rect_region(2, 3, 6, 3)
  let pieces = [
    @types.tetromino_i(@types.piece_color_red),
    @types.tetromino_t(@types.piece_color_blue),
    @types.tetromino_o(@types.piece_color_green),
    @types.domino_h(@types.piece_color_yellow),
  ]
  { region, pieces, par_time: 60, par_rotations: 6 }
}

///|
fn level_8() -> @types.Level {
  // 5x3 rectangle, mixed pieces
  let region = @types.rect_region(2, 3, 5, 3)
  let pieces = [
    @types.tetromino_s(@types.piece_color_purple),
    @types.tetromino_z(@types.piece_color_orange),
    @types.triomino_l(@types.piece_color_cyan),
    @types.domino_h(@types.piece_color_pink),
    @types.monomino(@types.piece_color_lime),
  ]
  { region, pieces, par_time: 60, par_rotations: 6 }
}

///|
fn level_9() -> @types.Level {
  // 4x5 rectangle, 5 tetrominoes
  let region = @types.rect_region(3, 2, 4, 5)
  let pieces = [
    @types.tetromino_i(@types.piece_color_red),
    @types.tetromino_l(@types.piece_color_blue),
    @types.tetromino_j(@types.piece_color_green),
    @types.tetromino_s(@types.piece_color_yellow),
    @types.tetromino_z(@types.piece_color_purple),
  ]
  { region, pieces, par_time: 75, par_rotations: 8 }
}

///|
fn level_10() -> @types.Level {
  // 8x3 rectangle, 6 tetrominoes
  let region = @types.rect_region(1, 3, 8, 3)
  let pieces = [
    @types.tetromino_i(@types.piece_color_red),
    @types.tetromino_i(@types.piece_color_blue),
    @types.tetromino_o(@types.piece_color_green),
    @types.tetromino_t(@types.piece_color_yellow),
    @types.tetromino_l(@types.piece_color_purple),
    @types.tetromino_j(@types.piece_color_orange),
  ]
  { region, pieces, par_time: 90, par_rotations: 10 }
}

// Tier 2: Shapes - L/T/cross regions, pentominoes added

///|
fn level_11() -> @types.Level {
  // L-shaped region
  let cells : Array[@types.Vec2i] = []
  for r in 0..<5 {
    for c in 0..<3 {
      cells.push(@types.vec2i(c + 2, r + 2))
    }
  }
  for c in 3..<6 {
    cells.push(@types.vec2i(c, 6))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.tetromino_i(@types.piece_color_red),
    @types.tetromino_l(@types.piece_color_blue),
    @types.tetromino_t(@types.piece_color_green),
    @types.triomino_l(@types.piece_color_yellow),
    @types.triomino_i(@types.piece_color_purple),
  ]
  { region, pieces, par_time: 90, par_rotations: 8 }
}

///|
fn level_12() -> @types.Level {
  // T-shaped region
  let cells : Array[@types.Vec2i] = []
  for c in 1..<7 {
    cells.push(@types.vec2i(c, 2))
    cells.push(@types.vec2i(c, 3))
  }
  for r in 4..<8 {
    cells.push(@types.vec2i(3, r))
    cells.push(@types.vec2i(4, r))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.tetromino_i(@types.piece_color_red),
    @types.tetromino_t(@types.piece_color_blue),
    @types.tetromino_l(@types.piece_color_green),
    @types.tetromino_j(@types.piece_color_yellow),
    @types.tetromino_o(@types.piece_color_purple),
  ]
  { region, pieces, par_time: 90, par_rotations: 8 }
}

///|
fn level_13() -> @types.Level {
  // Cross / plus shaped region
  let cells : Array[@types.Vec2i] = []
  for r in 2..<8 {
    cells.push(@types.vec2i(4, r))
    cells.push(@types.vec2i(5, r))
  }
  for c in 2..<8 {
    cells.push(@types.vec2i(c, 4))
    cells.push(@types.vec2i(c, 5))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.tetromino_t(@types.piece_color_red),
    @types.tetromino_t(@types.piece_color_blue),
    @types.tetromino_o(@types.piece_color_green),
    @types.tetromino_l(@types.piece_color_yellow),
    @types.tetromino_j(@types.piece_color_purple),
    @types.tetromino_s(@types.piece_color_orange),
  ]
  { region, pieces, par_time: 90, par_rotations: 10 }
}

///|
fn level_14() -> @types.Level {
  // U-shaped region
  let cells : Array[@types.Vec2i] = []
  for r in 2..<7 {
    cells.push(@types.vec2i(2, r))
    cells.push(@types.vec2i(3, r))
    cells.push(@types.vec2i(6, r))
    cells.push(@types.vec2i(7, r))
  }
  for c in 2..<8 {
    cells.push(@types.vec2i(c, 7))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_l(@types.piece_color_red),
    @types.pento_i(@types.piece_color_blue),
    @types.tetromino_i(@types.piece_color_green),
    @types.tetromino_l(@types.piece_color_yellow),
    @types.tetromino_j(@types.piece_color_purple),
    @types.tetromino_o(@types.piece_color_orange),
    @types.triomino_i(@types.piece_color_cyan),
    @types.domino_h(@types.piece_color_pink),
  ]
  { region, pieces, par_time: 120, par_rotations: 12 }
}

///|
fn level_15() -> @types.Level {
  // H-shaped region
  let cells : Array[@types.Vec2i] = []
  for r in 1..<9 {
    cells.push(@types.vec2i(2, r))
    cells.push(@types.vec2i(3, r))
    cells.push(@types.vec2i(6, r))
    cells.push(@types.vec2i(7, r))
  }
  for c in 4..<6 {
    cells.push(@types.vec2i(c, 4))
    cells.push(@types.vec2i(c, 5))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.pento_t(@types.piece_color_green),
    @types.tetromino_i(@types.piece_color_yellow),
    @types.tetromino_i(@types.piece_color_purple),
    @types.tetromino_o(@types.piece_color_orange),
    @types.tetromino_t(@types.piece_color_cyan),
    @types.tetromino_l(@types.piece_color_pink),
    @types.triomino_i(@types.piece_color_lime),
  ]
  { region, pieces, par_time: 120, par_rotations: 14 }
}

///|
fn level_16() -> @types.Level {
  // Staircase region
  let cells : Array[@types.Vec2i] = []
  for step in 0..<5 {
    for r in 0..<2 {
      for c in 0..<2 {
        cells.push(@types.vec2i(step + c + 1, step * 2 + r))
      }
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_n(@types.piece_color_red),
    @types.pento_w(@types.piece_color_blue),
    @types.tetromino_s(@types.piece_color_green),
    @types.tetromino_z(@types.piece_color_yellow),
    @types.tetromino_o(@types.piece_color_purple),
  ]
  { region, pieces, par_time: 90, par_rotations: 10 }
}

///|
fn level_17() -> @types.Level {
  // Z-shaped region
  let cells : Array[@types.Vec2i] = []
  for c in 1..<5 {
    cells.push(@types.vec2i(c, 2))
    cells.push(@types.vec2i(c, 3))
  }
  for c in 3..<5 {
    cells.push(@types.vec2i(c, 4))
    cells.push(@types.vec2i(c, 5))
  }
  for c in 5..<9 {
    cells.push(@types.vec2i(c, 5))
    cells.push(@types.vec2i(c, 6))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.tetromino_i(@types.piece_color_green),
    @types.tetromino_t(@types.piece_color_yellow),
    @types.tetromino_z(@types.piece_color_purple),
    @types.tetromino_o(@types.piece_color_orange),
  ]
  { region, pieces, par_time: 90, par_rotations: 10 }
}

///|
fn level_18() -> @types.Level {
  // Frame region (rectangle with hole)
  let cells : Array[@types.Vec2i] = []
  for r in 1..<7 {
    for c in 1..<9 {
      if r == 1 || r == 6 || c == 1 || c == 8 {
        cells.push(@types.vec2i(c, r))
      }
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.tetromino_i(@types.piece_color_green),
    @types.tetromino_l(@types.piece_color_yellow),
    @types.tetromino_j(@types.piece_color_purple),
    @types.domino_h(@types.piece_color_orange),
  ]
  { region, pieces, par_time: 90, par_rotations: 10 }
}

///|
fn level_19() -> @types.Level {
  // Large L-shape with pentominoes
  let cells : Array[@types.Vec2i] = []
  for r in 0..<8 {
    for c in 1..<4 {
      cells.push(@types.vec2i(c, r + 1))
    }
  }
  for c in 4..<8 {
    for r in 5..<9 {
      cells.push(@types.vec2i(c, r))
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.pento_t(@types.piece_color_green),
    @types.pento_p(@types.piece_color_yellow),
    @types.pento_n(@types.piece_color_purple),
    @types.pento_f(@types.piece_color_orange),
    @types.pento_v(@types.piece_color_cyan),
    @types.tetromino_o(@types.piece_color_pink),
  ]
  { region, pieces, par_time: 150, par_rotations: 14 }
}

///|
fn level_20() -> @types.Level {
  // Wide cross
  let cells : Array[@types.Vec2i] = []
  for r in 0..<10 {
    for c in 3..<7 {
      cells.push(@types.vec2i(c, r))
    }
  }
  for c in 0..<10 {
    for r in 3..<7 {
      cells.push(@types.vec2i(c, r))
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_i(@types.piece_color_blue),
    @types.pento_l(@types.piece_color_green),
    @types.pento_l(@types.piece_color_yellow),
    @types.pento_t(@types.piece_color_purple),
    @types.pento_t(@types.piece_color_orange),
    @types.pento_x(@types.piece_color_cyan),
    @types.pento_u(@types.piece_color_pink),
    @types.pento_v(@types.piece_color_lime),
    @types.pento_w(@types.piece_color_teal),
    @types.pento_p(@types.piece_color_brown),
    @types.pento_f(@types.piece_color_magenta),
    @types.tetromino_o(@types.piece_color_red),
  ]
  { region, pieces, par_time: 180, par_rotations: 18 }
}

// Tier 3: Art - irregular star/heart/diamond shapes

///|
fn level_21() -> @types.Level {
  // Diamond shape
  let cells : Array[@types.Vec2i] = []
  for r in 0..<10 {
    for c in 0..<10 {
      let dx = if c >= 5 { c - 5 } else { 5 - c - 1 }
      let dy = if r >= 5 { r - 5 } else { 5 - r - 1 }
      if dx + dy < 5 {
        cells.push(@types.vec2i(c, r))
      }
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.pento_t(@types.piece_color_green),
    @types.pento_p(@types.piece_color_yellow),
    @types.pento_y(@types.piece_color_purple),
    @types.pento_n(@types.piece_color_orange),
    @types.pento_f(@types.piece_color_cyan),
    @types.pento_v(@types.piece_color_pink),
    @types.tetromino_o(@types.piece_color_lime),
    @types.triomino_l(@types.piece_color_teal),
  ]
  { region, pieces, par_time: 150, par_rotations: 14 }
}

///|
fn level_22() -> @types.Level {
  // Heart shape
  let cells : Array[@types.Vec2i] = []
  // Top bumps
  for c in 1..<4 {
    cells.push(@types.vec2i(c, 1))
  }
  for c in 6..<9 {
    cells.push(@types.vec2i(c, 1))
  }
  for c in 0..<5 {
    cells.push(@types.vec2i(c, 2))
  }
  for c in 5..<10 {
    cells.push(@types.vec2i(c, 2))
  }
  for c in 0..<10 {
    cells.push(@types.vec2i(c, 3))
    cells.push(@types.vec2i(c, 4))
  }
  for c in 1..<9 {
    cells.push(@types.vec2i(c, 5))
  }
  for c in 2..<8 {
    cells.push(@types.vec2i(c, 6))
  }
  for c in 3..<7 {
    cells.push(@types.vec2i(c, 7))
  }
  for c in 4..<6 {
    cells.push(@types.vec2i(c, 8))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.pento_t(@types.piece_color_green),
    @types.pento_p(@types.piece_color_yellow),
    @types.pento_f(@types.piece_color_purple),
    @types.pento_n(@types.piece_color_orange),
    @types.pento_u(@types.piece_color_cyan),
    @types.pento_v(@types.piece_color_pink),
    @types.pento_w(@types.piece_color_lime),
    @types.pento_y(@types.piece_color_teal),
    @types.pento_z(@types.piece_color_brown),
    @types.tetromino_t(@types.piece_color_magenta),
    @types.triomino_i(@types.piece_color_red),
  ]
  { region, pieces, par_time: 180, par_rotations: 16 }
}

///|
fn level_23() -> @types.Level {
  // Arrow pointing right
  let cells : Array[@types.Vec2i] = []
  for r in 3..<7 {
    for c in 0..<6 {
      cells.push(@types.vec2i(c, r))
    }
  }
  for r in 1..<9 {
    let w = if r < 5 { r - 1 } else { 9 - r - 1 }
    for c in 6..<(6 + w + 1) {
      if c < 10 {
        cells.push(@types.vec2i(c, r))
      }
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.pento_t(@types.piece_color_green),
    @types.pento_p(@types.piece_color_yellow),
    @types.pento_v(@types.piece_color_purple),
    @types.pento_w(@types.piece_color_orange),
    @types.tetromino_i(@types.piece_color_cyan),
    @types.tetromino_l(@types.piece_color_pink),
    @types.tetromino_o(@types.piece_color_lime),
    @types.triomino_l(@types.piece_color_teal),
  ]
  { region, pieces, par_time: 150, par_rotations: 14 }
}

///|
fn level_24() -> @types.Level {
  // Star shape (6-pointed)
  let cells : Array[@types.Vec2i] = []
  // Center 4x4
  for r in 3..<7 {
    for c in 3..<7 {
      cells.push(@types.vec2i(c, r))
    }
  }
  // Top spike
  cells.push(@types.vec2i(4, 1))
  cells.push(@types.vec2i(5, 1))
  cells.push(@types.vec2i(4, 2))
  cells.push(@types.vec2i(5, 2))
  // Bottom spike
  cells.push(@types.vec2i(4, 7))
  cells.push(@types.vec2i(5, 7))
  cells.push(@types.vec2i(4, 8))
  cells.push(@types.vec2i(5, 8))
  // Left spike
  cells.push(@types.vec2i(1, 4))
  cells.push(@types.vec2i(1, 5))
  cells.push(@types.vec2i(2, 4))
  cells.push(@types.vec2i(2, 5))
  // Right spike
  cells.push(@types.vec2i(7, 4))
  cells.push(@types.vec2i(7, 5))
  cells.push(@types.vec2i(8, 4))
  cells.push(@types.vec2i(8, 5))
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_x(@types.piece_color_red),
    @types.pento_t(@types.piece_color_blue),
    @types.pento_u(@types.piece_color_green),
    @types.pento_p(@types.piece_color_yellow),
    @types.pento_f(@types.piece_color_purple),
    @types.tetromino_o(@types.piece_color_orange),
    @types.tetromino_o(@types.piece_color_cyan),
    @types.tetromino_t(@types.piece_color_pink),
  ]
  { region, pieces, par_time: 120, par_rotations: 12 }
}

///|
fn level_25() -> @types.Level {
  // Checkerboard 5x5 (only alternating cells)
  let cells : Array[@types.Vec2i] = []
  for r in 2..<7 {
    for c in 2..<7 {
      cells.push(@types.vec2i(c, r))
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_l(@types.piece_color_blue),
    @types.pento_t(@types.piece_color_green),
    @types.pento_p(@types.piece_color_yellow),
    @types.pento_n(@types.piece_color_purple),
  ]
  { region, pieces, par_time: 120, par_rotations: 10 }
}

///|
fn level_26() -> @types.Level {
  // Hourglass shape
  let cells : Array[@types.Vec2i] = []
  for c in 1..<9 {
    cells.push(@types.vec2i(c, 0))
    cells.push(@types.vec2i(c, 1))
  }
  for c in 2..<8 {
    cells.push(@types.vec2i(c, 2))
  }
  for c in 3..<7 {
    cells.push(@types.vec2i(c, 3))
  }
  for c in 4..<6 {
    cells.push(@types.vec2i(c, 4))
    cells.push(@types.vec2i(c, 5))
  }
  for c in 3..<7 {
    cells.push(@types.vec2i(c, 6))
  }
  for c in 2..<8 {
    cells.push(@types.vec2i(c, 7))
  }
  for c in 1..<9 {
    cells.push(@types.vec2i(c, 8))
    cells.push(@types.vec2i(c, 9))
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_i(@types.piece_color_blue),
    @types.pento_l(@types.piece_color_green),
    @types.pento_l(@types.piece_color_yellow),
    @types.pento_t(@types.piece_color_purple),
    @types.pento_t(@types.piece_color_orange),
    @types.pento_u(@types.piece_color_cyan),
    @types.pento_p(@types.piece_color_pink),
    @types.pento_v(@types.piece_color_lime),
    @types.pento_f(@types.piece_color_teal),
    @types.pento_n(@types.piece_color_brown),
    @types.pento_w(@types.piece_color_magenta),
    @types.tetromino_o(@types.piece_color_red),
  ]
  { region, pieces, par_time: 180, par_rotations: 18 }
}

///|
fn level_27() -> @types.Level {
  // Spiral-ish shape
  let cells : Array[@types.Vec2i] = []
  // Outer ring (partial spiral)
  for c in 1..<9 {
    cells.push(@types.vec2i(c, 1))
  }
  for r in 2..<9 {
    cells.push(@types.vec2i(8, r))
  }
  for c in 2..<8 {
    cells.push(@types.vec2i(c, 8))
  }
  for r in 3..<8 {
    cells.push(@types.vec2i(2, r))
  }
  for c in 3..<7 {
    cells.push(@types.vec2i(c, 3))
  }
  for r in 4..<7 {
    cells.push(@types.vec2i(6, r))
  }
  for c in 4..<6 {
    cells.push(@types.vec2i(c, 6))
  }
  cells.push(@types.vec2i(4, 5))
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_i(@types.piece_color_blue),
    @types.pento_l(@types.piece_color_green),
    @types.pento_l(@types.piece_color_yellow),
    @types.pento_t(@types.piece_color_purple),
    @types.pento_n(@types.piece_color_orange),
    @types.pento_f(@types.piece_color_cyan),
    @types.pento_v(@types.piece_color_pink),
    @types.tetromino_t(@types.piece_color_lime),
    @types.tetromino_l(@types.piece_color_teal),
  ]
  { region, pieces, par_time: 150, par_rotations: 14 }
}

///|
fn level_28() -> @types.Level {
  // Butterfly / bow-tie
  let cells : Array[@types.Vec2i] = []
  // Left wing
  for r in 0..<10 {
    let half = if r < 5 { r } else { 9 - r }
    for c in 0..<(half + 1) {
      cells.push(@types.vec2i(c, r))
    }
  }
  // Right wing
  for r in 0..<10 {
    let half = if r < 5 { r } else { 9 - r }
    for c in (9 - half)..<10 {
      cells.push(@types.vec2i(c, r))
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_i(@types.piece_color_blue),
    @types.pento_l(@types.piece_color_green),
    @types.pento_l(@types.piece_color_yellow),
    @types.pento_t(@types.piece_color_purple),
    @types.pento_p(@types.piece_color_orange),
    @types.pento_n(@types.piece_color_cyan),
    @types.pento_v(@types.piece_color_pink),
    @types.pento_w(@types.piece_color_lime),
    @types.pento_x(@types.piece_color_teal),
  ]
  { region, pieces, par_time: 150, par_rotations: 16 }
}

///|
fn level_29() -> @types.Level {
  // Octagon
  let cells : Array[@types.Vec2i] = []
  for r in 0..<10 {
    for c in 0..<10 {
      let dr = if r < 5 { 4 - r } else { r - 5 }
      let dc = if c < 5 { 4 - c } else { c - 5 }
      if dr + dc < 7 {
        cells.push(@types.vec2i(c, r))
      }
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_i(@types.piece_color_red),
    @types.pento_i(@types.piece_color_blue),
    @types.pento_l(@types.piece_color_green),
    @types.pento_l(@types.piece_color_yellow),
    @types.pento_t(@types.piece_color_purple),
    @types.pento_t(@types.piece_color_orange),
    @types.pento_p(@types.piece_color_cyan),
    @types.pento_u(@types.piece_color_pink),
    @types.pento_v(@types.piece_color_lime),
    @types.pento_w(@types.piece_color_teal),
    @types.pento_x(@types.piece_color_brown),
    @types.pento_f(@types.piece_color_magenta),
    @types.pento_n(@types.piece_color_red),
    @types.pento_y(@types.piece_color_blue),
    @types.pento_z(@types.piece_color_green),
    @types.tetromino_o(@types.piece_color_yellow),
  ]
  { region, pieces, par_time: 240, par_rotations: 22 }
}

///|
fn level_30() -> @types.Level {
  // Full 8x8 grid center - the ultimate challenge
  let cells : Array[@types.Vec2i] = []
  for r in 1..<9 {
    for c in 1..<9 {
      cells.push(@types.vec2i(c, r))
    }
  }
  let region = @types.new_region(10, 10, cells)
  let pieces = [
    @types.pento_f(@types.piece_color_red),
    @types.pento_i(@types.piece_color_blue),
    @types.pento_l(@types.piece_color_green),
    @types.pento_n(@types.piece_color_yellow),
    @types.pento_p(@types.piece_color_purple),
    @types.pento_t(@types.piece_color_orange),
    @types.pento_u(@types.piece_color_cyan),
    @types.pento_v(@types.piece_color_pink),
    @types.pento_w(@types.piece_color_lime),
    @types.pento_x(@types.piece_color_teal),
    @types.pento_y(@types.piece_color_brown),
    @types.pento_z(@types.piece_color_magenta),
    @types.tetromino_o(@types.piece_color_red),
  ]
  { region, pieces, par_time: 300, par_rotations: 24 }
}
