///|
pub fn try_move(state : @types.LevelState, dir : @types.Direction) -> Unit {
  if state.phase is Playing {
    let dx = @types.direction_dx(dir)
    let dy = @types.direction_dy(dir)
    let nx = state.ship.pos.x + dx
    let ny = state.ship.pos.y + dy
    if !@types.in_bounds(nx, ny) {
      set_message(state, "Edge of the world!", 1.5)
      return
    }
    let tile = state.data.grid[ny][nx]
    match tile {
      Land => set_message(state, "Blocked by land!", 1.5)
      _ => {
        state.ship.pos = { x: nx, y: ny, }
        state.ship.steps += 1
        handle_tile_effect(state, nx, ny)
        update_compass(state)
      }
    }
  }
}

///|
fn handle_tile_effect(state : @types.LevelState, x : Int, y : Int) -> Unit {
  let tile = state.data.grid[y][x]
  match tile {
    Lighthouse => {
      state.phase = LevelComplete
      set_message(state, "Lighthouse reached!", 5.0)
    }
    Reef => {
      state.ship.hp -= 1
      set_message(state, "Hit a reef! -1 HP", 2.0)
      if state.ship.hp <= 0 {
        state.phase = GameOver
        set_message(state, "Ship sunk!", 5.0)
      }
    }
    Landmark => {
      if !state.revealed[y][x] {
        state.ship.landmarks_found += 1
        set_message(state, "Landmark found! Area revealed.", 2.0)
      }
      @levels.reveal_area(state.revealed, x, y)
    }
    Current(dir) => {
      let cdx = @types.direction_dx(dir)
      let cdy = @types.direction_dy(dir)
      let px = state.ship.pos.x + cdx
      let py = state.ship.pos.y + cdy
      if @types.in_bounds(px, py) {
        let pushed_tile = state.data.grid[py][px]
        if !(pushed_tile is Land) {
          state.ship.pos = { x: px, y: py, }
          set_message(
            state,
            "Current pushes you \{@types.direction_name(dir)}!",
            1.5,
          )
          // Handle the tile we got pushed onto (but not recursively for currents)
          let landed = state.data.grid[py][px]
          match landed {
            Lighthouse => {
              state.phase = LevelComplete
              set_message(state, "Lighthouse reached!", 5.0)
            }
            Reef => {
              state.ship.hp -= 1
              set_message(state, "Pushed onto reef! -1 HP", 2.0)
              if state.ship.hp <= 0 {
                state.phase = GameOver
                set_message(state, "Ship sunk!", 5.0)
              }
            }
            Landmark => {
              if !state.revealed[py][px] {
                state.ship.landmarks_found += 1
              }
              @levels.reveal_area(state.revealed, px, py)
            }
            _ => ()
          }
        }
      }
    }
    _ => ()
  }
}

///|
fn update_compass(state : @types.LevelState) -> Unit {
  let bearing = @types.compute_bearing(state.ship.pos, state.data.lighthouse)
  state.ship.heading = bearing
  // Check adjacent tiles for land proximity (compass beep)
  state.compass_beep = false
  let dirs : Array[@types.Direction] = [North, South, East, West]
  for dir in dirs {
    let ax = state.ship.pos.x + @types.direction_dx(dir)
    let ay = state.ship.pos.y + @types.direction_dy(dir)
    if @types.in_bounds(ax, ay) && state.data.grid[ay][ax] is Land {
      state.compass_beep = true
      state.near_land_dir = dir
      break
    }
  }
}

///|
fn set_message(state : @types.LevelState, msg : String, timer : Float) -> Unit {
  state.message = msg
  state.message_timer = timer
}

///|
pub fn compute_star_rating(state : @types.LevelState) -> @types.StarRating {
  if state.phase is GameOver {
    return None
  }
  let under_par = state.ship.steps <= state.data.par_steps
  let all_landmarks = state.ship.landmarks_found >= state.data.landmark_count
  if under_par && all_landmarks {
    Three
  } else if under_par {
    Two
  } else {
    One
  }
}

///|
pub fn can_reach_adjacent(
  state : @types.LevelState,
  dir : @types.Direction,
) -> Bool {
  let nx = state.ship.pos.x + @types.direction_dx(dir)
  let ny = state.ship.pos.y + @types.direction_dy(dir)
  if !@types.in_bounds(nx, ny) {
    return false
  }
  !(state.data.grid[ny][nx] is Land)
}
