///|
fn level_1() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 3, 0, 2, 3)
  set_land_rect(grid, 8, 4, 2, 2)
  set_tile(grid, 6, 2, Landmark)
  set_tile(grid, 4, 7, Landmark)
  set_tile(grid, 10, 8, Lighthouse)
  {
    grid,
    start: { x: 1, y: 1 },
    lighthouse: { x: 10, y: 8 },
    par_steps: 18,
    landmark_count: count_landmarks(grid),
    tier: 1,
  }
}

///|
fn level_2() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 5, 2, 1, 6)
  set_land_rect(grid, 9, 0, 1, 4)
  set_tile(grid, 2, 4, Landmark)
  set_tile(grid, 7, 3, Landmark)
  set_tile(grid, 8, 8, Landmark)
  set_tile(grid, 11, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 11, y: 9 },
    par_steps: 22,
    landmark_count: count_landmarks(grid),
    tier: 1,
  }
}

///|
fn level_3() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 2, 3, 3, 1)
  set_land_rect(grid, 7, 5, 1, 3)
  set_tile(grid, 1, 6, Landmark)
  set_tile(grid, 5, 1, Landmark)
  set_tile(grid, 9, 7, Landmark)
  set_tile(grid, 10, 1, Lighthouse)
  {
    grid,
    start: { x: 0, y: 9 },
    lighthouse: { x: 10, y: 1 },
    par_steps: 20,
    landmark_count: count_landmarks(grid),
    tier: 1,
  }
}

///|
fn level_4() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 4, 0, 1, 5)
  set_land_rect(grid, 8, 3, 2, 1)
  set_tile(grid, 2, 2, Landmark)
  set_tile(grid, 6, 5, Landmark)
  set_tile(grid, 10, 7, Landmark)
  set_tile(grid, 1, 8, Landmark)
  set_tile(grid, 11, 0, Lighthouse)
  {
    grid,
    start: { x: 0, y: 5 },
    lighthouse: { x: 11, y: 0 },
    par_steps: 18,
    landmark_count: count_landmarks(grid),
    tier: 1,
  }
}

///|
fn level_5() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 3, 2, 1, 4)
  set_land_rect(grid, 6, 6, 3, 1)
  set_land_rect(grid, 10, 1, 1, 2)
  set_tile(grid, 1, 4, Landmark)
  set_tile(grid, 5, 8, Landmark)
  set_tile(grid, 8, 2, Landmark)
  set_tile(grid, 0, 9, Lighthouse)
  {
    grid,
    start: { x: 11, y: 0 },
    lighthouse: { x: 0, y: 9 },
    par_steps: 22,
    landmark_count: count_landmarks(grid),
    tier: 1,
  }
}

///|
fn level_6() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 2, 1, 2, 2)
  set_land_rect(grid, 7, 4, 1, 3)
  set_tile(grid, 5, 0, Landmark)
  set_tile(grid, 0, 5, Landmark)
  set_tile(grid, 9, 8, Landmark)
  set_tile(grid, 4, 6, Landmark)
  set_tile(grid, 11, 5, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 11, y: 5 },
    par_steps: 16,
    landmark_count: count_landmarks(grid),
    tier: 1,
  }
}

///|
fn level_7() -> @types.LevelData {
  let grid = make_ocean_grid()
  set_land_rect(grid, 1, 3, 3, 1)
  set_land_rect(grid, 6, 1, 1, 4)
  set_land_rect(grid, 9, 7, 2, 1)
  set_tile(grid, 4, 5, Landmark)
  set_tile(grid, 8, 3, Landmark)
  set_tile(grid, 2, 8, Landmark)
  set_tile(grid, 10, 0, Landmark)
  set_tile(grid, 5, 9, Lighthouse)
  {
    grid,
    start: { x: 0, y: 0 },
    lighthouse: { x: 5, y: 9 },
    par_steps: 15,
    landmark_count: count_landmarks(grid),
    tier: 1,
  }
}
