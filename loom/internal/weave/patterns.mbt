///|
/// Generate a plain weave pattern: alternating warp/weft in checkerboard
pub fn generate_plain(
  rows : Int,
  cols : Int,
  warp_colors : Array[Int],
  weft_colors : Array[Int],
) -> @types.FabricPattern {
  let p = @types.new_fabric_pattern(rows, cols, warp_colors, weft_colors)
  for row in 0..<rows {
    for col in 0..<cols {
      let is_warp_over = (row + col) % 2 == 0
      let state : @types.CellState = if is_warp_over {
        WarpOver
      } else {
        WeftOver
      }
      let ci = if is_warp_over { warp_colors[col] } else { weft_colors[row] }
      @types.pattern_set(p, row, col, { state, color_index: ci })
    }
  }
  p
}

///|
/// Generate a 2/2 twill pattern: diagonal lines going right
pub fn generate_twill(
  rows : Int,
  cols : Int,
  warp_colors : Array[Int],
  weft_colors : Array[Int],
  twill_width : Int,
) -> @types.FabricPattern {
  let p = @types.new_fabric_pattern(rows, cols, warp_colors, weft_colors)
  let w = if twill_width < 1 { 2 } else { twill_width }
  let period = w * 2
  for row in 0..<rows {
    for col in 0..<cols {
      let pos = ((col + row) % period + period) % period
      let is_warp_over = pos < w
      let state : @types.CellState = if is_warp_over {
        WarpOver
      } else {
        WeftOver
      }
      let ci = if is_warp_over { warp_colors[col] } else { weft_colors[row] }
      @types.pattern_set(p, row, col, { state, color_index: ci })
    }
  }
  p
}

///|
/// Generate a satin weave: warp floats spread evenly, with offset
pub fn generate_satin(
  rows : Int,
  cols : Int,
  warp_colors : Array[Int],
  weft_colors : Array[Int],
  repeat : Int,
  offset : Int,
) -> @types.FabricPattern {
  let p = @types.new_fabric_pattern(rows, cols, warp_colors, weft_colors)
  let r = if repeat < 2 { 5 } else { repeat }
  let o = if offset < 1 { 2 } else { offset }
  for row in 0..<rows {
    for col in 0..<cols {
      let pos = ((col - row * o) % r + r) % r
      let is_warp_over = pos == 0
      let state : @types.CellState = if is_warp_over {
        WarpOver
      } else {
        WeftOver
      }
      let ci = if is_warp_over { warp_colors[col] } else { weft_colors[row] }
      @types.pattern_set(p, row, col, { state, color_index: ci })
    }
  }
  p
}

///|
/// Generate a herringbone pattern: twill that reverses direction
pub fn generate_herringbone(
  rows : Int,
  cols : Int,
  warp_colors : Array[Int],
  weft_colors : Array[Int],
  width : Int,
) -> @types.FabricPattern {
  let p = @types.new_fabric_pattern(rows, cols, warp_colors, weft_colors)
  let w = if width < 2 { 4 } else { width }
  let period = w * 2
  for row in 0..<rows {
    for col in 0..<cols {
      // Determine direction based on column position in the repeat
      let col_in_repeat = col % period
      let effective_row = if col_in_repeat < w { row } else { -row }
      let twill_pos = ((col + effective_row) % w + w) % w
      let is_warp_over = twill_pos < w / 2
      let state : @types.CellState = if is_warp_over {
        WarpOver
      } else {
        WeftOver
      }
      let ci = if is_warp_over { warp_colors[col] } else { weft_colors[row] }
      @types.pattern_set(p, row, col, { state, color_index: ci })
    }
  }
  p
}

///|
/// Generate a diamond twill pattern
pub fn generate_diamond(
  rows : Int,
  cols : Int,
  warp_colors : Array[Int],
  weft_colors : Array[Int],
  size : Int,
) -> @types.FabricPattern {
  let p = @types.new_fabric_pattern(rows, cols, warp_colors, weft_colors)
  let s = if size < 2 { 4 } else { size }
  let period = s * 2
  for row in 0..<rows {
    for col in 0..<cols {
      let r_pos = row % period
      let c_pos = col % period
      let r_dist = if r_pos < s { r_pos } else { period - r_pos }
      let c_dist = if c_pos < s { c_pos } else { period - c_pos }
      let is_warp_over = (r_dist + c_dist) % s < s / 2
      let state : @types.CellState = if is_warp_over {
        WarpOver
      } else {
        WeftOver
      }
      let ci = if is_warp_over { warp_colors[col] } else { weft_colors[row] }
      @types.pattern_set(p, row, col, { state, color_index: ci })
    }
  }
  p
}

///|
/// Generate heddle rows from a fabric pattern (extract which warps are raised per row)
pub fn heddles_from_pattern(
  pattern : @types.FabricPattern,
) -> Array[@types.HeddleRow] {
  let heddles : Array[@types.HeddleRow] = []
  for row in 0..<pattern.rows {
    let h = @types.new_heddle_row(pattern.cols)
    for col in 0..<pattern.cols {
      let cell = @types.pattern_get(pattern, row, col)
      h.raised[col] = cell.state == WarpOver
    }
    heddles.push(h)
  }
  heddles
}

///|
/// Count minimum heddle changes between consecutive rows
pub fn count_heddle_changes(heddles : Array[@types.HeddleRow]) -> Int {
  let mut changes = 0
  for i in 1..<heddles.length() {
    let prev = heddles[i - 1]
    let curr = heddles[i]
    let mut row_changed = false
    for j in 0..<prev.raised.length() {
      if prev.raised[j] != curr.raised[j] {
        row_changed = true
        break
      }
    }
    if row_changed {
      changes = changes + 1
    }
  }
  changes
}

///|
/// Identify weave type from a pattern
pub fn identify_weave_type(pattern : @types.FabricPattern) -> @types.WeaveType {
  if is_plain_weave(pattern) {
    return Plain
  }
  if is_diamond_weave(pattern) {
    return Diamond
  }
  if is_herringbone_weave(pattern) {
    return Herringbone
  }
  if is_twill_weave(pattern) {
    return Twill
  }
  if is_satin_weave(pattern) {
    return Satin
  }
  Custom
}

///|
fn is_plain_weave(p : @types.FabricPattern) -> Bool {
  for row in 0..<p.rows {
    for col in 0..<p.cols {
      let cell = @types.pattern_get(p, row, col)
      let expected = (row + col) % 2 == 0
      if (cell.state == WarpOver) != expected {
        return false
      }
    }
  }
  true
}

///|
fn is_twill_weave(p : @types.FabricPattern) -> Bool {
  // Check for consistent diagonal: each row shifts by 1
  if p.rows < 2 || p.cols < 2 {
    return false
  }
  // Get first row pattern
  let first_row : Array[Bool] = []
  for col in 0..<p.cols {
    let cell = @types.pattern_get(p, 0, col)
    first_row.push(cell.state == WarpOver)
  }
  // Check each subsequent row is shifted by 1
  for row in 1..<p.rows {
    for col in 0..<p.cols {
      let cell = @types.pattern_get(p, row, col)
      let is_warp = cell.state == WarpOver
      let expected_col = (col - row + p.cols * p.rows) % p.cols
      if is_warp != first_row[expected_col] {
        return false
      }
    }
  }
  true
}

///|
fn is_satin_weave(p : @types.FabricPattern) -> Bool {
  // Satin: very few warp-over points, spread evenly
  if p.rows < 3 {
    return false
  }
  let mut warp_count = 0
  let total = p.rows * p.cols
  for i in 0..<total {
    if p.cells[i].state == WarpOver {
      warp_count = warp_count + 1
    }
  }
  // Satin has roughly 1/N warp-over (N >= 4)
  let ratio = warp_count * 100 / total
  ratio >= 10 && ratio <= 30
}

///|
fn is_herringbone_weave(p : @types.FabricPattern) -> Bool {
  // Herringbone: twill that reverses direction
  if p.rows < 4 || p.cols < 4 {
    return false
  }
  // Check for reversal in column direction
  let mut has_right_diag = false
  let mut has_left_diag = false
  for col in 0..<(p.cols - 1) {
    if p.rows < 2 {
      break
    }
    let c0 = @types.pattern_get(p, 0, col)
    let c1 = @types.pattern_get(p, 1, col + 1)
    let c0b = @types.pattern_get(p, 1, col)
    let c1b = @types.pattern_get(p, 0, col + 1)
    if c0.state == c1.state {
      has_right_diag = true
    }
    if c0b.state == c1b.state {
      has_left_diag = true
    }
  }
  has_right_diag && has_left_diag
}

///|
fn is_diamond_weave(p : @types.FabricPattern) -> Bool {
  // Diamond: symmetric in both axes
  if p.rows < 4 || p.cols < 4 {
    return false
  }
  // Check for vertical symmetry within some period
  let mut sym_count = 0
  let mut check_count = 0
  for row in 0..<p.rows {
    for col in 0..<(p.cols / 2) {
      check_count = check_count + 1
      let c1 = @types.pattern_get(p, row, col)
      let mirror_col = p.cols - 1 - col
      let c2 = @types.pattern_get(p, row, mirror_col)
      if c1.state == c2.state {
        sym_count = sym_count + 1
      }
    }
  }
  if check_count == 0 {
    return false
  }
  sym_count * 100 / check_count > 70
}
