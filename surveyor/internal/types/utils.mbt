///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y, }
}

///|
pub fn make_grid(width : Int, height : Int, tiles : Array[TileKind]) -> Grid {
  { width, height, tiles, }
}

///|
pub fn grid_get(g : Grid, x : Int, y : Int) -> TileKind {
  if x < 0 || x >= g.width || y < 0 || y >= g.height {
    Water // out of bounds treated as impassable
  } else {
    g.tiles[y * g.width + x]
  }
}

///|
pub fn grid_set(g : Grid, x : Int, y : Int, tile : TileKind) -> Unit {
  if x >= 0 && x < g.width && y >= 0 && y < g.height {
    g.tiles[y * g.width + x] = tile
  }
}

///|
pub fn make_house(x : Int, y : Int, color_id : Int, area : Int) -> House {
  { pos: vec2i(x, y), color_id, required_area: area, }
}

///|
pub fn make_fence(row : Int, col : Int, orient : Orientation) -> FenceEdge {
  { row, col, orient, }
}

///|
pub fn fence_eq(a : FenceEdge, b : FenceEdge) -> Bool {
  a.row == b.row && a.col == b.col && a.orient == b.orient
}

///|
pub fn has_fence(fences : Array[FenceEdge], f : FenceEdge) -> Bool {
  for i in 0..<fences.length() {
    if fence_eq(fences[i], f) {
      return true
    }
  }
  false
}

///|
pub fn toggle_fence(fences : Array[FenceEdge], f : FenceEdge) -> Unit {
  for i in 0..<fences.length() {
    if fence_eq(fences[i], f) {
      // Remove by swapping with last
      let last = fences.length() - 1
      if i != last {
        fences[i] = fences[last]
      }
      let _ = fences.pop()
      return
    }
  }
  // Not found, add it
  fences.push(f)
}

///|
pub fn copy_fences(fences : Array[FenceEdge]) -> Array[FenceEdge] {
  let result : Array[FenceEdge] = Array::new(capacity=fences.length())
  for i in 0..<fences.length() {
    result.push(fences[i])
  }
  result
}

///|
pub fn make_constraint(rectangular : Bool, no_water : Bool) -> LevelConstraint {
  { must_be_rectangular: rectangular, must_not_touch_water: no_water, }
}

///|
pub fn make_level(
  grid : Grid,
  houses : Array[House],
  constraints : LevelConstraint,
  par_fences : Int,
  par_length : Int,
  tier : Tier,
  name : String,
) -> LevelDef {
  { grid, houses, constraints, par_fences, par_length, tier, name, }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, fence_count: 0, }
}

///|
pub fn new_constraint_status(idx : Int) -> ConstraintStatus {
  {
    house_idx: idx,
    one_house: Unchecked,
    correct_area: Unchecked,
    road_access: Unchecked,
    shape_ok: Unchecked,
  }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Drawing,
    current_tier: Plots,
    current_level_idx: 0,
    current_level: None,
    fences: [],
    regions: [],
    constraint_status: [],
    undo_stack: [],
    hover_fence: None,
    level_scores: scores,
    result_stars: 0,
    result_fence_count: 0,
    frame_count: 0,
    transition_timer: 0.0,
    message: "",
    message_timer: 0.0,
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Plots => "Plots"
    Districts => "Districts"
    Zoning => "Zoning"
  }
}

///|
pub fn tier_start_idx(t : Tier) -> Int {
  match t {
    Plots => 0
    Districts => tier1_count
    Zoning => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(t : Tier) -> Int {
  match t {
    Plots => tier1_count
    Districts => tier2_count
    Zoning => tier3_count
  }
}

///|
pub fn is_region_rectangular(region : Region) -> Bool {
  if region.tiles.length() == 0 {
    return true
  }
  let mut min_x = region.tiles[0].x
  let mut max_x = region.tiles[0].x
  let mut min_y = region.tiles[0].y
  let mut max_y = region.tiles[0].y
  for i in 1..<region.tiles.length() {
    let t = region.tiles[i]
    if t.x < min_x {
      min_x = t.x
    }
    if t.x > max_x {
      max_x = t.x
    }
    if t.y < min_y {
      min_y = t.y
    }
    if t.y > max_y {
      max_y = t.y
    }
  }
  let expected = (max_x - min_x + 1) * (max_y - min_y + 1)
  expected == region.tiles.length()
}

///|
pub fn region_touches_water(region : Region, grid : Grid) -> Bool {
  for i in 0..<region.tiles.length() {
    let t = region.tiles[i]
    // Check 4 neighbors
    let neighbors : Array[Vec2i] = [
      vec2i(t.x - 1, t.y),
      vec2i(t.x + 1, t.y),
      vec2i(t.x, t.y - 1),
      vec2i(t.x, t.y + 1),
    ]
    for j in 0..<neighbors.length() {
      let n = neighbors[j]
      if n.x >= 0 && n.x < grid.width && n.y >= 0 && n.y < grid.height {
        match grid_get(grid, n.x, n.y) {
          Water => return true
          _ => ()
        }
      }
    }
  }
  false
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
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
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
