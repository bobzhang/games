///|
pub fn shift(s : @types.Shape, dir : @types.Direction) -> @types.Shape {
  let dx : Int = match dir {
    E => 1
    W => -1
    _ => 0
  }
  let dy : Int = match dir {
    S => 1
    N => -1
    _ => 0
  }
  let cells : Array[@types.Vec2i] = Array(capacity=s.cells.length())
  for i in 0..<s.cells.length() {
    let nx = s.cells[i].x + dx
    let ny = s.cells[i].y + dy
    if nx >= 0 && nx < @types.grid_cols && ny >= 0 && ny < @types.grid_rows {
      cells.push(@types.vec2i(nx, ny))
    }
  }
  if cells.length() != s.cells.length() {
    return @types.shape_clone(s)
  }
  @types.new_shape(cells)
}

///|
pub fn rotate_cw(s : @types.Shape) -> @types.Shape {
  if s.cells.length() == 0 {
    return @types.new_shape([])
  }
  let min_x = @types.shape_min_x(s)
  let min_y = @types.shape_min_y(s)
  let max_x = @types.shape_max_x(s)
  let max_y = @types.shape_max_y(s)
  let cx2 = min_x + max_x
  let cy2 = min_y + max_y
  let cells : Array[@types.Vec2i] = Array(capacity=s.cells.length())
  for i in 0..<s.cells.length() {
    let rx2 = s.cells[i].x * 2 - cx2
    let ry2 = s.cells[i].y * 2 - cy2
    let new_rx2 = -ry2
    let new_ry2 = rx2
    let nx = (new_rx2 + cx2) / 2
    let ny = (new_ry2 + cy2) / 2
    cells.push(@types.vec2i(nx, ny))
  }
  fit_to_grid(cells)
  @types.new_shape(cells)
}

///|
fn fit_to_grid(cells : Array[@types.Vec2i]) -> Unit {
  if cells.length() == 0 {
    return
  }
  let mut min_x = 999
  let mut min_y = 999
  for i in 0..<cells.length() {
    if cells[i].x < min_x {
      min_x = cells[i].x
    }
    if cells[i].y < min_y {
      min_y = cells[i].y
    }
  }
  let shift_x = if min_x < 0 { -min_x } else { 0 }
  let shift_y = if min_y < 0 { -min_y } else { 0 }
  if shift_x != 0 || shift_y != 0 {
    for i in 0..<cells.length() {
      cells[i] = @types.vec2i(cells[i].x + shift_x, cells[i].y + shift_y)
    }
  }
  let mut max_x = 0
  let mut max_y = 0
  for i in 0..<cells.length() {
    if cells[i].x > max_x {
      max_x = cells[i].x
    }
    if cells[i].y > max_y {
      max_y = cells[i].y
    }
  }
  let clip_x = if max_x >= @types.grid_cols {
    max_x - @types.grid_cols + 1
  } else {
    0
  }
  let clip_y = if max_y >= @types.grid_rows {
    max_y - @types.grid_rows + 1
  } else {
    0
  }
  if clip_x != 0 || clip_y != 0 {
    for i in 0..<cells.length() {
      cells[i] = @types.vec2i(cells[i].x - clip_x, cells[i].y - clip_y)
    }
  }
}

///|
pub fn flip_h(s : @types.Shape) -> @types.Shape {
  if s.cells.length() == 0 {
    return @types.new_shape([])
  }
  let min_x = @types.shape_min_x(s)
  let max_x = @types.shape_max_x(s)
  let axis = min_x + max_x
  let cells : Array[@types.Vec2i] = Array(capacity=s.cells.length())
  for i in 0..<s.cells.length() {
    let nx = axis - s.cells[i].x
    cells.push(@types.vec2i(nx, s.cells[i].y))
  }
  @types.new_shape(cells)
}

///|
pub fn flip_v(s : @types.Shape) -> @types.Shape {
  if s.cells.length() == 0 {
    return @types.new_shape([])
  }
  let min_y = @types.shape_min_y(s)
  let max_y = @types.shape_max_y(s)
  let axis = min_y + max_y
  let cells : Array[@types.Vec2i] = Array(capacity=s.cells.length())
  for i in 0..<s.cells.length() {
    let ny = axis - s.cells[i].y
    cells.push(@types.vec2i(s.cells[i].x, ny))
  }
  @types.new_shape(cells)
}

///|
pub fn grow(s : @types.Shape, cell : @types.Vec2i) -> @types.Shape {
  if @types.shape_contains(s, cell) {
    return @types.shape_clone(s)
  }
  let adjacent = @types.shape_adjacent_empty(s)
  let mut is_adj = false
  for i in 0..<adjacent.length() {
    if adjacent[i].x == cell.x && adjacent[i].y == cell.y {
      is_adj = true
      break
    }
  }
  if !is_adj {
    return @types.shape_clone(s)
  }
  let cells : Array[@types.Vec2i] = Array(capacity=s.cells.length() + 1)
  for i in 0..<s.cells.length() {
    cells.push(s.cells[i])
  }
  cells.push(cell)
  @types.new_shape(cells)
}

///|
pub fn shrink(s : @types.Shape, cell : @types.Vec2i) -> @types.Shape {
  if !@types.shape_contains(s, cell) {
    return @types.shape_clone(s)
  }
  if s.cells.length() <= 1 {
    return @types.shape_clone(s)
  }
  let edges = @types.shape_edge_cells(s)
  let mut is_edge = false
  for i in 0..<edges.length() {
    if edges[i].x == cell.x && edges[i].y == cell.y {
      is_edge = true
      break
    }
  }
  if !is_edge {
    return @types.shape_clone(s)
  }
  let cells : Array[@types.Vec2i] = Array(capacity=s.cells.length() - 1)
  for i in 0..<s.cells.length() {
    if s.cells[i].x != cell.x || s.cells[i].y != cell.y {
      cells.push(s.cells[i])
    }
  }
  if !is_connected(cells) {
    return @types.shape_clone(s)
  }
  @types.new_shape(cells)
}

///|
fn is_connected(cells : Array[@types.Vec2i]) -> Bool {
  if cells.length() <= 1 {
    return true
  }
  let visited : Array[Bool] = Array(capacity=cells.length())
  for _i in 0..<cells.length() {
    visited.push(false)
  }
  let queue : Array[Int] = [0]
  visited[0] = true
  let mut visited_count = 1
  let dirs = [
    @types.vec2i(0, -1),
    @types.vec2i(1, 0),
    @types.vec2i(0, 1),
    @types.vec2i(-1, 0),
  ]
  while queue.length() > 0 {
    let current_idx = queue.unsafe_pop()
    let current = cells[current_idx]
    for d in 0..<dirs.length() {
      let nx = current.x + dirs[d].x
      let ny = current.y + dirs[d].y
      for j in 0..<cells.length() {
        if !visited[j] && cells[j].x == nx && cells[j].y == ny {
          visited[j] = true
          visited_count = visited_count + 1
          queue.push(j)
        }
      }
    }
  }
  visited_count == cells.length()
}
