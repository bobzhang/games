///|
pub fn get_voxel(g : @types.VoxelGrid, x : Int, y : Int, z : Int) -> Bool {
  if x < 0 || x >= g.size || y < 0 || y >= g.size || z < 0 || z >= g.size {
    return false
  }
  g.cells[@types.xyz_to_idx(x, y, z, g.size)]
}

///|
pub fn set_voxel(
  g : @types.VoxelGrid,
  x : Int,
  y : Int,
  z : Int,
  val : Bool
) -> Unit {
  if x >= 0 && x < g.size && y >= 0 && y < g.size && z >= 0 && z < g.size {
    g.cells[@types.xyz_to_idx(x, y, z, g.size)] = val
  }
}

///|
pub fn count_filled(g : @types.VoxelGrid) -> Int {
  let mut count = 0
  for i in 0..<g.cells.length() {
    if g.cells[i] {
      count += 1
    }
  }
  count
}

// Compute silhouette for Top view (X-Z plane, looking down Y axis)
// For each (x, z), silhouette is true if any y has a voxel
///|
pub fn compute_top_silhouette(g : @types.VoxelGrid) -> @types.Silhouette {
  let s = @types.new_silhouette(g.size, g.size)
  for x in 0..<g.size {
    for z in 0..<g.size {
      for y in 0..<g.size {
        if get_voxel(g, x, y, z) {
          s.cells[x + z * g.size] = true
          break
        }
      }
    }
  }
  s
}

// Compute silhouette for Front view (X-Y plane, looking along Z axis)
// For each (x, y), silhouette is true if any z has a voxel
///|
pub fn compute_front_silhouette(g : @types.VoxelGrid) -> @types.Silhouette {
  let s = @types.new_silhouette(g.size, g.size)
  for x in 0..<g.size {
    for y in 0..<g.size {
      for z in 0..<g.size {
        if get_voxel(g, x, y, z) {
          // Front view: x is column, y is row (invert y for display, row 0 = top)
          s.cells[x + (g.size - 1 - y) * g.size] = true
          break
        }
      }
    }
  }
  s
}

// Compute silhouette for Side view (Z-Y plane, looking along X axis)
// For each (z, y), silhouette is true if any x has a voxel
///|
pub fn compute_side_silhouette(g : @types.VoxelGrid) -> @types.Silhouette {
  let s = @types.new_silhouette(g.size, g.size)
  for z in 0..<g.size {
    for y in 0..<g.size {
      for x in 0..<g.size {
        if get_voxel(g, x, y, z) {
          // Side view: z is column, y is row (invert y for display)
          s.cells[z + (g.size - 1 - y) * g.size] = true
          break
        }
      }
    }
  }
  s
}

///|
pub fn compute_silhouette(
  g : @types.VoxelGrid,
  view : @types.ViewKind
) -> @types.Silhouette {
  match view {
    Top => compute_top_silhouette(g)
    Front => compute_front_silhouette(g)
    Side => compute_side_silhouette(g)
  }
}

///|
pub fn silhouettes_match(
  a : @types.Silhouette,
  b : @types.Silhouette
) -> Bool {
  if a.width != b.width || a.height != b.height {
    return false
  }
  for i in 0..<a.cells.length() {
    if a.cells[i] != b.cells[i] {
      return false
    }
  }
  true
}

///|
pub fn check_completion(
  g : @types.VoxelGrid,
  targets : @types.TargetSet
) -> Bool {
  let top = compute_top_silhouette(g)
  let front = compute_front_silhouette(g)
  let side = compute_side_silhouette(g)
  silhouettes_match(top, targets.top) &&
  silhouettes_match(front, targets.front) &&
  silhouettes_match(side, targets.side)
}

// Ray toggle for Top view: click at grid cell (col, row) = (x, z)
// Toggle voxels along Y axis
///|
pub fn ray_toggle_top(
  g : @types.VoxelGrid,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  let x = col
  let z = row
  // First try to find an empty cell to fill (first empty from bottom)
  for y in 0..<g.size {
    if !get_voxel(g, x, y, z) {
      set_voxel(g, x, y, z, true)
      return Some({ x, y, z })
    }
  }
  // All filled, remove the last one (from top)
  for y = g.size - 1; y >= 0; y = y - 1 {
    if get_voxel(g, x, y, z) {
      set_voxel(g, x, y, z, false)
      return Some({ x, y, z })
    }
  }
  None
}

// Ray toggle for Front view: click at grid cell (col, row) = (x, inverted y)
// Toggle voxels along Z axis
///|
pub fn ray_toggle_front(
  g : @types.VoxelGrid,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  let x = col
  let y = g.size - 1 - row
  // First try to find an empty cell to fill
  for z in 0..<g.size {
    if !get_voxel(g, x, y, z) {
      set_voxel(g, x, y, z, true)
      return Some({ x, y, z })
    }
  }
  // All filled, remove the last one
  for z = g.size - 1; z >= 0; z = z - 1 {
    if get_voxel(g, x, y, z) {
      set_voxel(g, x, y, z, false)
      return Some({ x, y, z })
    }
  }
  None
}

// Ray toggle for Side view: click at grid cell (col, row) = (z, inverted y)
// Toggle voxels along X axis
///|
pub fn ray_toggle_side(
  g : @types.VoxelGrid,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  let z = col
  let y = g.size - 1 - row
  // First try to find an empty cell to fill
  for x in 0..<g.size {
    if !get_voxel(g, x, y, z) {
      set_voxel(g, x, y, z, true)
      return Some({ x, y, z })
    }
  }
  // All filled, remove the last one
  for x = g.size - 1; x >= 0; x = x - 1 {
    if get_voxel(g, x, y, z) {
      set_voxel(g, x, y, z, false)
      return Some({ x, y, z })
    }
  }
  None
}

///|
pub fn ray_toggle(
  g : @types.VoxelGrid,
  view : @types.ViewKind,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  match view {
    Top => ray_toggle_top(g, col, row)
    Front => ray_toggle_front(g, col, row)
    Side => ray_toggle_side(g, col, row)
  }
}

// Find what voxel would be toggled (for preview) without actually toggling
///|
pub fn ray_preview_top(
  g : @types.VoxelGrid,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  let x = col
  let z = row
  for y in 0..<g.size {
    if !get_voxel(g, x, y, z) {
      return Some({ x, y, z })
    }
  }
  for y = g.size - 1; y >= 0; y = y - 1 {
    if get_voxel(g, x, y, z) {
      return Some({ x, y, z })
    }
  }
  None
}

///|
pub fn ray_preview_front(
  g : @types.VoxelGrid,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  let x = col
  let y = g.size - 1 - row
  for z in 0..<g.size {
    if !get_voxel(g, x, y, z) {
      return Some({ x, y, z })
    }
  }
  for z = g.size - 1; z >= 0; z = z - 1 {
    if get_voxel(g, x, y, z) {
      return Some({ x, y, z })
    }
  }
  None
}

///|
pub fn ray_preview_side(
  g : @types.VoxelGrid,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  let z = col
  let y = g.size - 1 - row
  for x in 0..<g.size {
    if !get_voxel(g, x, y, z) {
      return Some({ x, y, z })
    }
  }
  for x = g.size - 1; x >= 0; x = x - 1 {
    if get_voxel(g, x, y, z) {
      return Some({ x, y, z })
    }
  }
  None
}

///|
pub fn ray_preview(
  g : @types.VoxelGrid,
  view : @types.ViewKind,
  col : Int,
  row : Int
) -> @types.Vec3i? {
  match view {
    Top => ray_preview_top(g, col, row)
    Front => ray_preview_front(g, col, row)
    Side => ray_preview_side(g, col, row)
  }
}

// Connectivity check using flood fill
///|
pub fn check_connected(g : @types.VoxelGrid) -> Bool {
  let count = count_filled(g)
  if count <= 1 {
    return true
  }
  // Find first filled voxel
  let mut start_idx = -1
  for i in 0..<g.cells.length() {
    if g.cells[i] {
      start_idx = i
      break
    }
  }
  if start_idx < 0 {
    return true
  }
  let visited : Array[Bool] = Array::make(g.cells.length(), false)
  let stack : Array[Int] = [start_idx]
  visited[start_idx] = true
  let mut visited_count = 1
  while stack.length() > 0 {
    let idx = stack.unsafe_pop()
    let pos = @types.idx_to_xyz(idx, g.size)
    // Check 6 orthogonal neighbors
    let neighbors : Array[@types.Vec3i] = [
      { x: pos.x - 1, y: pos.y, z: pos.z },
      { x: pos.x + 1, y: pos.y, z: pos.z },
      { x: pos.x, y: pos.y - 1, z: pos.z },
      { x: pos.x, y: pos.y + 1, z: pos.z },
      { x: pos.x, y: pos.y, z: pos.z - 1 },
      { x: pos.x, y: pos.y, z: pos.z + 1 },
    ]
    for i in 0..<neighbors.length() {
      let n = neighbors[i]
      if n.x >= 0 &&
        n.x < g.size &&
        n.y >= 0 &&
        n.y < g.size &&
        n.z >= 0 &&
        n.z < g.size {
        let ni = @types.xyz_to_idx(n.x, n.y, n.z, g.size)
        if g.cells[ni] && !visited[ni] {
          visited[ni] = true
          visited_count += 1
          stack.push(ni)
        }
      }
    }
  }
  visited_count == count
}
