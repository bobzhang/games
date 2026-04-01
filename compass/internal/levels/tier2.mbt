///|
fn level_8() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 2, 1, 2, 3)
  set_land_rect(grid, 6, 5, 3, 2)
  set_land_rect(grid, 10, 0, 2, 2)
  set_tile(grid, 0, 6, Current(East))
  set_tile(grid, 4, 4, Current(South))
  set_tile(grid, 9, 3, Landmark)
  set_tile(grid, 5, 8, Landmark)
  set_tile(grid, 11, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 11, y: 9 },
    par_steps: 24,
    landmark_count: count_landmarks(grid),
    tier: 2,
  }
}

///|
fn level_9() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 3, 0, 1, 4)
  set_land_rect(grid, 7, 3, 2, 3)
  set_land_rect(grid, 1, 7, 3, 1)
  set_tile(grid, 5, 5, Current(East))
  set_tile(grid, 9, 1, Current(South))
  set_tile(grid, 10, 6, Current(West))
  set_tile(grid, 6, 8, Landmark)
  set_tile(grid, 2, 3, Landmark)
  set_tile(grid, 0, 9, Lighthouse)
  {
    grid,
    start: { x: 11, y: 0 },
    lighthouse: { x: 0, y: 9 },
    par_steps: 24,
    landmark_count: count_landmarks(grid),
    tier: 2,
  }
}

///|
fn level_10() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 4, 2, 2, 2)
  set_land_rect(grid, 8, 5, 1, 4)
  set_land_rect(grid, 0, 4, 2, 1)
  set_tile(grid, 2, 6, Current(North))
  set_tile(grid, 6, 0, Current(East))
  set_tile(grid, 10, 3, Current(South))
  set_tile(grid, 3, 8, Landmark)
  set_tile(grid, 7, 1, Landmark)
  set_tile(grid, 11, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 11, y: 9 },
    par_steps: 26,
    landmark_count: count_landmarks(grid),
    tier: 2,
  }
}

///|
fn level_11() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 1, 2, 3, 2)
  set_land_rect(grid, 5, 6, 2, 2)
  set_land_rect(grid, 9, 0, 1, 3)
  set_tile(grid, 4, 0, Current(South))
  set_tile(grid, 7, 4, Current(East))
  set_tile(grid, 3, 9, Current(West))
  set_tile(grid, 11, 5, Current(North))
  set_tile(grid, 8, 7, Landmark)
  set_tile(grid, 0, 5, Landmark)
  set_tile(grid, 10, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 10, y: 9 },
    par_steps: 22,
    landmark_count: count_landmarks(grid),
    tier: 2,
  }
}

///|
fn level_12() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 2, 0, 1, 5)
  set_land_rect(grid, 6, 3, 3, 1)
  set_land_rect(grid, 9, 6, 2, 2)
  set_tile(grid, 0, 3, Current(East))
  set_tile(grid, 5, 7, Current(North))
  set_tile(grid, 8, 1, Current(West))
  set_tile(grid, 4, 5, Landmark)
  set_tile(grid, 11, 3, Landmark)
  set_tile(grid, 7, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 7, y: 9 },
    par_steps: 20,
    landmark_count: count_landmarks(grid),
    tier: 2,
  }
}

///|
fn level_13() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 3, 1, 2, 3)
  set_land_rect(grid, 7, 5, 1, 4)
  set_land_rect(grid, 10, 2, 2, 2)
  set_tile(grid, 1, 5, Current(East))
  set_tile(grid, 5, 8, Current(North))
  set_tile(grid, 9, 0, Current(South))
  set_tile(grid, 6, 3, Landmark)
  set_tile(grid, 2, 7, Landmark)
  set_tile(grid, 0, 9, Lighthouse)
  {
    grid,
    start: { x: 11, y: 0 },
    lighthouse: { x: 0, y: 9 },
    par_steps: 26,
    landmark_count: count_landmarks(grid),
    tier: 2,
  }
}

///|
fn level_14() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 0, 3, 3, 1)
  set_land_rect(grid, 4, 5, 2, 3)
  set_land_rect(grid, 8, 1, 2, 2)
  set_land_rect(grid, 10, 7, 2, 1)
  set_tile(grid, 3, 0, Current(South))
  set_tile(grid, 6, 2, Current(East))
  set_tile(grid, 1, 8, Current(North))
  set_tile(grid, 9, 5, Current(West))
  set_tile(grid, 7, 7, Landmark)
  set_tile(grid, 2, 5, Landmark)
  set_tile(grid, 11, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 11, y: 9 },
    par_steps: 24,
    landmark_count: count_landmarks(grid),
    tier: 2,
  }
}
