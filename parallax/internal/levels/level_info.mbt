// Level descriptions for display in level select
///|
pub fn get_level_description(index : Int) -> String {
  match index {
    0 => "Place a single column of voxels"
    1 => "Build a plus sign visible from all angles"
    2 => "An L-shaped corner piece"
    3 => "The classic L-tetromino shape"
    4 => "A T-shaped block formation"
    5 => "Three voxels on a diagonal"
    6 => "A hollow frame from every view"
    7 => "Ascending staircase pattern"
    8 => "A wall of pillars"
    9 => "Cross shape from the top"
    10 => "A tall tower of blocks"
    11 => "Span a gap between two pillars"
    12 => "An architectural archway"
    13 => "A pyramid rising from the base"
    14 => "A frame with a window hole"
    15 => "A snaking zigzag path"
    16 => "Castle walls with open courtyard"
    17 => "Ascending steps with budget limit"
    18 => "A tunnel you can see through"
    19 => "A diamond shape from all sides"
    20 => "A twisted helix - must stay connected"
    21 => "A knotted loop structure"
    22 => "Nested frames with center post"
    23 => "A star shape from every angle"
    24 => "Castle towers and battlements"
    25 => "A cube with a core removed"
    26 => "Temple with spire and base"
    27 => "A three-pronged claw"
    28 => "Interlocking ring silhouettes"
    _ => "The ultimate shape challenge"
  }
}

// Tier descriptions with constraints explained
///|
pub fn get_tier_description(tier : Int) -> String {
  match tier {
    0 =>
      "Learn the basics of perspective matching.\nSimple 3x3x3 grids, no constraints.\nMatch all three silhouettes to complete each level."
    1 =>
      "Larger 4x4x4 grids with voxel budget limits.\nYou can only place a limited number of voxels.\nPlan your placements carefully."
    _ =>
      "The ultimate challenge with 4x4 and 5x5 grids.\nAll filled voxels must be orthogonally connected.\nEvery piece must touch another."
  }
}

// Validate that a level's targets are self-consistent
// (there exists at least one grid configuration that satisfies all three)
///|
pub fn validate_level_targets(level : @types.Level) -> Bool {
  // Basic check: target dimensions match grid size
  let s = level.size
  if level.targets.top.width != s || level.targets.top.height != s {
    return false
  }
  if level.targets.front.width != s || level.targets.front.height != s {
    return false
  }
  if level.targets.side.width != s || level.targets.side.height != s {
    return false
  }
  // Check that each target cell count is at least 0
  let mut top_count = 0
  let mut front_count = 0
  let mut side_count = 0
  let total = s * s
  for i in 0..<total {
    if level.targets.top.cells[i] {
      top_count += 1
    }
    if level.targets.front.cells[i] {
      front_count += 1
    }
    if level.targets.side.cells[i] {
      side_count += 1
    }
  }
  // At least one cell must be filled in each target
  top_count > 0 && front_count > 0 && side_count > 0
}

// Get difficulty rating for a level (1-5)
///|
pub fn get_difficulty(index : Int) -> Int {
  let level = get_level(index)
  let size = level.size
  let mut rating = 1
  // Size contributes to difficulty
  if size >= 4 {
    rating += 1
  }
  if size >= 5 {
    rating += 1
  }
  // Constraints add difficulty
  if level.voxel_budget > 0 {
    rating += 1
  }
  if level.requires_connected {
    rating += 1
  }
  @types.mini(rating, 5)
}

// Count total filled cells across all three targets
///|
pub fn target_cell_count(level : @types.Level) -> Int {
  let s = level.size
  let mut count = 0
  let total = s * s
  for i in 0..<total {
    if level.targets.top.cells[i] {
      count += 1
    }
    if level.targets.front.cells[i] {
      count += 1
    }
    if level.targets.side.cells[i] {
      count += 1
    }
  }
  count
}
