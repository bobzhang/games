///|
pub fn xyz_to_idx(x : Int, y : Int, z : Int, size : Int) -> Int {
  x + y * size + z * size * size
}

///|
pub fn idx_to_xyz(idx : Int, size : Int) -> Vec3i {
  let x = idx % size
  let y = (idx / size) % size
  let z = idx / (size * size)
  { x, y, z }
}

///|
pub fn new_voxel_grid(size : Int) -> VoxelGrid {
  let count = size * size * size
  let cells : Array[Bool] = Array::make(count, false)
  { size, cells }
}

///|
pub fn copy_grid(g : VoxelGrid) -> VoxelGrid {
  let cells : Array[Bool] = Array::make(g.cells.length(), false)
  for i in 0..<g.cells.length() {
    cells[i] = g.cells[i]
  }
  { size: g.size, cells }
}

///|
pub fn new_silhouette(width : Int, height : Int) -> Silhouette {
  let cells : Array[Bool] = Array::make(width * height, false)
  { width, height, cells }
}

///|
pub fn silhouette_from_bits(
  width : Int,
  height : Int,
  bits : Array[Int]
) -> Silhouette {
  let cells : Array[Bool] = Array::make(width * height, false)
  for row = 0; row < height; row = row + 1 {
    let row_bits = bits[row]
    for col = 0; col < width; col = col + 1 {
      let bit = (row_bits >> (width - 1 - col)) & 1
      if bit == 1 {
        cells[col + row * width] = true
      }
    }
  }
  { width, height, cells }
}

///|
pub fn new_target_set(
  top : Silhouette,
  front : Silhouette,
  side : Silhouette
) -> TargetSet {
  { top, front, side }
}

///|
pub fn cell_size_for_grid(size : Int) -> Int {
  if size <= 3 {
    cell_size_3
  } else if size <= 4 {
    cell_size_4
  } else {
    cell_size_5
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_moves: 9999, best_voxels: 9999 }
}

///|
pub fn new_hover() -> HoverInfo {
  { active: false, vx: 0, vy: 0, vz: 0, view: Top }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Editing,
    current_tier: 0,
    current_level: 0,
    grid: new_voxel_grid(3),
    moves: 0,
    undo_stack: [],
    hover: new_hover(),
    scores,
    frame_count: 0,
    anim_timer: 0.0,
    message: "",
    message_timer: 0.0,
    result_stars: 0,
  }
}

///|
pub fn tier_name(tier : Int) -> String {
  match tier {
    0 => "Shapes"
    1 => "Structures"
    _ => "Sculptures"
  }
}

///|
pub fn tier_color(tier : Int) -> @raylib.Color {
  match tier {
    0 => color_tier_shapes
    1 => color_tier_structures
    _ => color_tier_sculptures
  }
}

///|
pub fn level_index(tier : Int, level_in_tier : Int) -> Int {
  tier * levels_per_tier + level_in_tier
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
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
pub fn minf(a : Float, b : Float) -> Float {
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
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}
