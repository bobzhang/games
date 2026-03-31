///|
pub fn validate_level(
  level : @types.LevelDef,
  fences : Array[@types.FenceEdge],
  regions : Array[@types.Region]
) -> Array[@types.ConstraintStatus] {
  let statuses : Array[@types.ConstraintStatus] = []
  for i in 0..<level.houses.length() {
    let house = level.houses[i]
    let status = @types.new_constraint_status(i)
    // Find which region contains this house
    let region_idx = find_region_for_tile(regions, house.pos.x, house.pos.y)
    if region_idx < 0 {
      // House not in any region (shouldn't happen)
      status.one_house = Violated
      status.correct_area = Violated
      status.road_access = Violated
      status.shape_ok = Violated
      statuses.push(status)
      continue
    }
    let region = regions[region_idx]
    // Check: exactly one house in region
    if region.houses.length() == 1 {
      status.one_house = Satisfied
    } else {
      status.one_house = Violated
    }
    // Check: area matches requirement
    if region.area == house.required_area {
      status.correct_area = Satisfied
    } else {
      status.correct_area = Violated
    }
    // Check: road access
    if region.has_road {
      status.road_access = Satisfied
    } else {
      // Check if there are any road tiles on the grid at all
      let has_any_road = grid_has_road(level.grid)
      if has_any_road {
        status.road_access = Violated
      } else {
        status.road_access = Satisfied
      }
    }
    // Check: shape constraints
    if level.constraints.must_be_rectangular {
      if @types.is_region_rectangular(region) {
        status.shape_ok = Satisfied
      } else {
        status.shape_ok = Violated
      }
    } else {
      status.shape_ok = Satisfied
    }
    // Check: water constraint
    if level.constraints.must_not_touch_water {
      if @types.region_touches_water(region, level.grid) {
        status.shape_ok = Violated
      }
    }
    let _ = fences
    statuses.push(status)
  }
  statuses
}

///|
fn grid_has_road(grid : @types.Grid) -> Bool {
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      match @types.grid_get(grid, x, y) {
        Road => return true
        _ => ()
      }
    }
  }
  false
}

///|
pub fn all_constraints_satisfied(
  statuses : Array[@types.ConstraintStatus]
) -> Bool {
  for i in 0..<statuses.length() {
    let s = statuses[i]
    if s.one_house != Satisfied ||
      s.correct_area != Satisfied ||
      s.road_access != Satisfied ||
      s.shape_ok != Satisfied {
      return false
    }
  }
  statuses.length() > 0
}

///|
pub fn compute_stars(
  level : @types.LevelDef,
  fence_count : Int,
  satisfied : Bool
) -> Int {
  if !(satisfied) {
    return 0
  }
  // 1 star: all constraints met
  let mut stars = 1
  // 2 stars: within par fence count
  if fence_count <= level.par_fences {
    stars = 2
  }
  // 3 stars: also within par total length
  if fence_count <= level.par_length {
    stars = 3
  }
  stars
}
