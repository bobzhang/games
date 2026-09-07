///|
fn level_15() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 2, 1, 2, 4)
  set_land_rect(grid, 6, 0, 1, 3)
  set_land_rect(grid, 9, 4, 2, 3)
  set_land_rect(grid, 0, 7, 3, 1)
  set_tile(grid, 4, 6, Reef)
  set_tile(grid, 7, 8, Reef)
  set_tile(grid, 5, 3, Current(East))
  set_tile(grid, 8, 1, Current(South))
  set_tile(grid, 3, 9, Landmark)
  set_tile(grid, 11, 6, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0, },
    lighthouse: { x: 11, y: 6, },
    par_steps: 20,
    landmark_count: count_landmarks(grid),
    tier: 3,
  }
}

///|
fn level_16() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 1, 2, 3, 2)
  set_land_rect(grid, 5, 5, 2, 3)
  set_land_rect(grid, 9, 1, 1, 3)
  set_tile(grid, 4, 0, Reef)
  set_tile(grid, 7, 3, Reef)
  set_tile(grid, 10, 8, Reef)
  set_tile(grid, 0, 6, Current(East))
  set_tile(grid, 8, 5, Current(North))
  set_tile(grid, 3, 8, Current(South))
  set_tile(grid, 11, 4, Landmark)
  set_tile(grid, 0, 9, Lighthouse)
  {
    grid,
    start: { x: 11, y: 0, },
    lighthouse: { x: 0, y: 9, },
    par_steps: 26,
    landmark_count: count_landmarks(grid),
    tier: 3,
  }
}

///|
fn level_17() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 3, 0, 2, 3)
  set_land_rect(grid, 7, 4, 3, 2)
  set_land_rect(grid, 0, 5, 2, 2)
  set_land_rect(grid, 10, 7, 2, 2)
  set_tile(grid, 5, 6, Reef)
  set_tile(grid, 2, 8, Reef)
  set_tile(grid, 9, 2, Reef)
  set_tile(grid, 6, 1, Current(South))
  set_tile(grid, 4, 7, Current(East))
  set_tile(grid, 11, 3, Current(West))
  set_tile(grid, 8, 9, Landmark)
  set_tile(grid, 5, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0, },
    lighthouse: { x: 5, y: 9, },
    par_steps: 18,
    landmark_count: count_landmarks(grid),
    tier: 3,
  }
}

///|
fn level_18() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 1, 1, 2, 3)
  set_land_rect(grid, 5, 3, 1, 5)
  set_land_rect(grid, 8, 0, 2, 2)
  set_land_rect(grid, 10, 5, 2, 3)
  set_tile(grid, 3, 6, Reef)
  set_tile(grid, 7, 2, Reef)
  set_tile(grid, 0, 9, Reef)
  set_tile(grid, 9, 8, Reef)
  set_tile(grid, 4, 0, Current(East))
  set_tile(grid, 6, 8, Current(North))
  set_tile(grid, 2, 5, Current(South))
  set_tile(grid, 7, 5, Landmark)
  set_tile(grid, 11, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0, },
    lighthouse: { x: 11, y: 9, },
    par_steps: 28,
    landmark_count: count_landmarks(grid),
    tier: 3,
  }
}

///|
fn level_19() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 2, 0, 1, 4)
  set_land_rect(grid, 4, 4, 3, 2)
  set_land_rect(grid, 8, 2, 2, 3)
  set_land_rect(grid, 0, 7, 2, 2)
  set_land_rect(grid, 10, 6, 2, 2)
  set_tile(grid, 3, 7, Reef)
  set_tile(grid, 6, 1, Reef)
  set_tile(grid, 9, 8, Reef)
  set_tile(grid, 11, 0, Reef)
  set_tile(grid, 5, 8, Current(West))
  set_tile(grid, 7, 0, Current(South))
  set_tile(grid, 1, 4, Current(East))
  set_tile(grid, 3, 3, Landmark)
  set_tile(grid, 7, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0, },
    lighthouse: { x: 7, y: 9, },
    par_steps: 22,
    landmark_count: count_landmarks(grid),
    tier: 3,
  }
}

///|
fn level_20() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 1, 1, 2, 2)
  set_land_rect(grid, 4, 3, 2, 3)
  set_land_rect(grid, 7, 0, 1, 4)
  set_land_rect(grid, 9, 5, 3, 2)
  set_land_rect(grid, 0, 6, 1, 3)
  set_tile(grid, 3, 5, Reef)
  set_tile(grid, 6, 8, Reef)
  set_tile(grid, 10, 2, Reef)
  set_tile(grid, 2, 9, Reef)
  set_tile(grid, 8, 7, Reef)
  set_tile(grid, 3, 0, Current(South))
  set_tile(grid, 6, 6, Current(East))
  set_tile(grid, 1, 5, Current(North))
  set_tile(grid, 11, 3, Current(West))
  set_tile(grid, 9, 9, Landmark)
  set_tile(grid, 11, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0, },
    lighthouse: { x: 11, y: 9, },
    par_steps: 30,
    landmark_count: count_landmarks(grid),
    tier: 3,
  }
}
