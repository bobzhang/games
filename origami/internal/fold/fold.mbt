///|
pub fn execute_fold(
  paper : @types.Paper,
  dir : @types.FoldDir,
  line_pos : Int
) -> @types.Paper {
  let result = @types.clone_paper(paper)
  match dir {
    Left => fold_left(paper, result, line_pos)
    Right => fold_right(paper, result, line_pos)
    Up => fold_up(paper, result, line_pos)
    Down => fold_down(paper, result, line_pos)
  }
  result
}

///|
fn fold_left(
  src : @types.Paper,
  dst : @types.Paper,
  line : Int
) -> Unit {
  // Fold right side onto left side along vertical line at column 'line'
  // Cells at x >= line get mirrored to x' = 2*line - 1 - x
  // First, clear cells on the right side of fold line in dst
  for y in 0..<src.height {
    for x in line..<src.width {
      let cell = @types.get_cell(src, x, y)
      if cell.has_paper {
        let mirror_x = 2 * line - 1 - x
        if mirror_x >= 0 && mirror_x < src.width {
          let dst_cell = @types.get_cell(dst, mirror_x, y)
          if dst_cell.has_paper {
            @types.set_cell(dst, mirror_x, y, true, dst_cell.layers + cell.layers)
          } else {
            @types.set_cell(dst, mirror_x, y, true, cell.layers)
          }
        }
        // Remove from original position
        @types.set_cell(dst, x, y, false, 0)
      }
    }
  }
}

///|
fn fold_right(
  src : @types.Paper,
  dst : @types.Paper,
  line : Int
) -> Unit {
  // Fold left side onto right side along vertical line at column 'line'
  // Cells at x < line get mirrored to x' = 2*line - 1 - x
  for y in 0..<src.height {
    for x = line - 1; x >= 0; x = x - 1 {
      let cell = @types.get_cell(src, x, y)
      if cell.has_paper {
        let mirror_x = 2 * line - 1 - x
        if mirror_x >= 0 && mirror_x < src.width {
          let dst_cell = @types.get_cell(dst, mirror_x, y)
          if dst_cell.has_paper {
            @types.set_cell(
              dst, mirror_x, y, true, dst_cell.layers + cell.layers,
            )
          } else {
            @types.set_cell(dst, mirror_x, y, true, cell.layers)
          }
        }
        @types.set_cell(dst, x, y, false, 0)
      }
    }
  }
}

///|
fn fold_up(
  src : @types.Paper,
  dst : @types.Paper,
  line : Int
) -> Unit {
  // Fold bottom half onto top half along horizontal line at row 'line'
  // Cells at y >= line get mirrored to y' = 2*line - 1 - y
  for y in line..<src.height {
    for x in 0..<src.width {
      let cell = @types.get_cell(src, x, y)
      if cell.has_paper {
        let mirror_y = 2 * line - 1 - y
        if mirror_y >= 0 && mirror_y < src.height {
          let dst_cell = @types.get_cell(dst, x, mirror_y)
          if dst_cell.has_paper {
            @types.set_cell(
              dst, x, mirror_y, true, dst_cell.layers + cell.layers,
            )
          } else {
            @types.set_cell(dst, x, mirror_y, true, cell.layers)
          }
        }
        @types.set_cell(dst, x, y, false, 0)
      }
    }
  }
}

///|
fn fold_down(
  src : @types.Paper,
  dst : @types.Paper,
  line : Int
) -> Unit {
  // Fold top half onto bottom half along horizontal line at row 'line'
  // Cells at y < line get mirrored to y' = 2*line - 1 - y
  for y = line - 1; y >= 0; y = y - 1 {
    for x in 0..<src.width {
      let cell = @types.get_cell(src, x, y)
      if cell.has_paper {
        let mirror_y = 2 * line - 1 - y
        if mirror_y >= 0 && mirror_y < src.height {
          let dst_cell = @types.get_cell(dst, x, mirror_y)
          if dst_cell.has_paper {
            @types.set_cell(
              dst, x, mirror_y, true, dst_cell.layers + cell.layers,
            )
          } else {
            @types.set_cell(dst, x, mirror_y, true, cell.layers)
          }
        }
        @types.set_cell(dst, x, y, false, 0)
      }
    }
  }
}

///|
pub fn is_valid_fold(
  paper : @types.Paper,
  dir : @types.FoldDir,
  line_pos : Int
) -> Bool {
  // Must have at least 1 cell on folding side
  match dir {
    Left => {
      if line_pos <= 0 || line_pos >= paper.width {
        return false
      }
      for y in 0..<paper.height {
        for x in line_pos..<paper.width {
          if @types.get_cell(paper, x, y).has_paper {
            return true
          }
        }
      }
      false
    }
    Right => {
      if line_pos <= 0 || line_pos >= paper.width {
        return false
      }
      for y in 0..<paper.height {
        for x = line_pos - 1; x >= 0; x = x - 1 {
          if @types.get_cell(paper, x, y).has_paper {
            return true
          }
        }
      }
      false
    }
    Up => {
      if line_pos <= 0 || line_pos >= paper.height {
        return false
      }
      for y in line_pos..<paper.height {
        for x in 0..<paper.width {
          if @types.get_cell(paper, x, y).has_paper {
            return true
          }
        }
      }
      false
    }
    Down => {
      if line_pos <= 0 || line_pos >= paper.height {
        return false
      }
      for y = line_pos - 1; y >= 0; y = y - 1 {
        for x in 0..<paper.width {
          if @types.get_cell(paper, x, y).has_paper {
            return true
          }
        }
      }
      false
    }
  }
}
