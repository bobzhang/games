///|
/// Advances 2048 simulation by one frame, including input and tile animation.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.handle_input()
  game.update_animations(dt)
}

///|
fn @types.Game::reset(game : @types.Game) -> Unit {
  for i in 0..<@types.cell_count {
    game.tiles[i].value = 0
    game.tiles[i].scale = 1.0
    game.tiles[i].is_new = false
    game.tiles[i].is_merged = false
  }
  game.score = 0
  game.can_undo = false
  game.animating = false
  game.keep_playing = false
  game.msg = ""
  game.msg_t = 0.0
  game.spawn_tile()
  game.spawn_tile()
  game.snap_positions()
  game.state = Play
}

///|
fn @types.Game::snap_positions(game : @types.Game) -> Unit {
  for r in 0..<@types.grid_size {
    for c in 0..<@types.grid_size {
      let idx = r * @types.grid_size + c
      let sx = @types.cell_screen_x(c)
      let sy = @types.cell_screen_y(r)
      game.tiles[idx].anim_x = sx
      game.tiles[idx].anim_y = sy
      game.tiles[idx].target_x = sx
      game.tiles[idx].target_y = sy
    }
  }
}

///|
fn @types.Game::spawn_tile(game : @types.Game) -> Unit {
  let empty : Array[Int] = []
  for i in 0..<@types.cell_count {
    if game.tiles[i].value == 0 {
      empty.push(i)
    }
  }
  if empty.length() == 0 {
    return
  }
  let pick = @raylib.get_random_value(0, empty.length() - 1)
  let idx = empty[pick]
  let val = if @raylib.get_random_value(0, 9) == 0 { 4 } else { 2 }
  game.tiles[idx].value = val
  game.tiles[idx].is_new = true
  game.tiles[idx].scale = 0.0
  let r = idx / @types.grid_size
  let c = idx % @types.grid_size
  game.tiles[idx].anim_x = @types.cell_screen_x(c)
  game.tiles[idx].anim_y = @types.cell_screen_y(r)
  game.tiles[idx].target_x = @types.cell_screen_x(c)
  game.tiles[idx].target_y = @types.cell_screen_y(r)
}

///|
fn @types.Game::save_state(game : @types.Game) -> Unit {
  for i in 0..<@types.cell_count {
    game.prev_values[i] = game.tiles[i].value
  }
  game.prev_score = game.score
  game.can_undo = true
}

///|
fn @types.Game::undo(game : @types.Game) -> Unit {
  if not(game.can_undo) {
    return
  }
  for i in 0..<@types.cell_count {
    game.tiles[i].value = game.prev_values[i]
    game.tiles[i].is_new = false
    game.tiles[i].is_merged = false
    game.tiles[i].scale = 1.0
  }
  game.score = game.prev_score
  game.can_undo = false
  game.snap_positions()
  if game.state is Over {
    game.state = Play
  }
  game.msg = "Undo"
  game.msg_t = 1.5
}

///|
fn @types.Game::try_move(game : @types.Game, dr : Int, dc : Int) -> Bool {
  let old_can_undo = game.can_undo
  let old_prev_score = game.prev_score
  let old_prev : Array[Int] = Array::make(@types.cell_count, 0)
  for i in 0..<@types.cell_count {
    old_prev[i] = game.prev_values[i]
  }
  game.save_state()
  let mut moved = false
  let mut merge_score = 0
  for i in 0..<@types.cell_count {
    game.tiles[i].is_merged = false
    game.tiles[i].is_new = false
  }
  if dc != 0 {
    for r in 0..<@types.grid_size {
      let start = if dc > 0 { @types.grid_size - 1 } else { 0 }
      let step = if dc > 0 { -1 } else { 1 }
      for i = start; i >= 0 && i < @types.grid_size; i = i + step {
        let idx = r * @types.grid_size + i
        if game.tiles[idx].value == 0 {
          continue i + step
        }
        let mut target_c = i
        let mut j = i + dc
        while j >= 0 && j < @types.grid_size {
          let jidx = r * @types.grid_size + j
          if game.tiles[jidx].value == 0 {
            target_c = j
            j = j + dc
          } else if game.tiles[jidx].value == game.tiles[idx].value &&
            not(game.tiles[jidx].is_merged) {
            target_c = j
            break
          } else {
            break
          }
        }
        if target_c != i {
          let tidx = r * @types.grid_size + target_c
          if game.tiles[tidx].value == game.tiles[idx].value &&
            game.tiles[tidx].value != 0 {
            game.tiles[tidx].value = game.tiles[tidx].value * 2
            game.tiles[tidx].is_merged = true
            merge_score = merge_score + game.tiles[tidx].value
            game.tiles[idx].value = 0
          } else {
            game.tiles[tidx].value = game.tiles[idx].value
            game.tiles[idx].value = 0
          }
          game.tiles[tidx].anim_x = @types.cell_screen_x(i)
          game.tiles[tidx].anim_y = @types.cell_screen_y(r)
          game.tiles[tidx].target_x = @types.cell_screen_x(target_c)
          game.tiles[tidx].target_y = @types.cell_screen_y(r)
          moved = true
        }
      }
    }
  } else {
    for c in 0..<@types.grid_size {
      let start = if dr > 0 { @types.grid_size - 1 } else { 0 }
      let step = if dr > 0 { -1 } else { 1 }
      for i = start; i >= 0 && i < @types.grid_size; i = i + step {
        let idx = i * @types.grid_size + c
        if game.tiles[idx].value == 0 {
          continue i + step
        }
        let mut target_r = i
        let mut j = i + dr
        while j >= 0 && j < @types.grid_size {
          let jidx = j * @types.grid_size + c
          if game.tiles[jidx].value == 0 {
            target_r = j
            j = j + dr
          } else if game.tiles[jidx].value == game.tiles[idx].value &&
            not(game.tiles[jidx].is_merged) {
            target_r = j
            break
          } else {
            break
          }
        }
        if target_r != i {
          let tidx = target_r * @types.grid_size + c
          if game.tiles[tidx].value == game.tiles[idx].value &&
            game.tiles[tidx].value != 0 {
            game.tiles[tidx].value = game.tiles[tidx].value * 2
            game.tiles[tidx].is_merged = true
            merge_score = merge_score + game.tiles[tidx].value
            game.tiles[idx].value = 0
          } else {
            game.tiles[tidx].value = game.tiles[idx].value
            game.tiles[idx].value = 0
          }
          game.tiles[tidx].anim_x = @types.cell_screen_x(c)
          game.tiles[tidx].anim_y = @types.cell_screen_y(i)
          game.tiles[tidx].target_x = @types.cell_screen_x(c)
          game.tiles[tidx].target_y = @types.cell_screen_y(target_r)
          moved = true
        }
      }
    }
  }
  if not(moved) {
    game.can_undo = old_can_undo
    game.prev_score = old_prev_score
    for i in 0..<@types.cell_count {
      game.prev_values[i] = old_prev[i]
    }
    return false
  }
  {
    game.score = game.score + merge_score
    if game.score > game.best_score {
      game.best_score = game.score
    }
    for i in 0..<@types.cell_count {
      if game.tiles[i].is_merged {
        game.tiles[i].scale = @types.anim_pop_scale
      }
    }
    game.animating = true
    game.spawn_tile()
    if not(game.keep_playing) {
      for i in 0..<@types.cell_count {
        if game.tiles[i].value >= 2048 {
          game.state = Won
          break
        }
      }
    }
    if !(game.has_moves()) && !(game.state is Won) {
      game.state = Over
    }
  }
  true
}

///|
fn @types.Game::has_moves(game : @types.Game) -> Bool {
  for i in 0..<@types.cell_count {
    if game.tiles[i].value == 0 {
      return true
    }
  }
  for r in 0..<@types.grid_size {
    for c in 0..<@types.grid_size {
      let v = game.tiles[r * @types.grid_size + c].value
      if c + 1 < @types.grid_size &&
        game.tiles[r * @types.grid_size + c + 1].value == v {
        return true
      }
      if r + 1 < @types.grid_size &&
        game.tiles[(r + 1) * @types.grid_size + c].value == v {
        return true
      }
    }
  }
  false
}

///|
/// Drives the per-frame animation that makes tiles slide and pop visually.
///
/// **How the animation system works:**
/// `try_move` sets each tile's starting position (`anim_x/y`) and destination
/// (`target_x/y`), plus an initial `scale` (0.0 for spawns, 1.15 for merges).
/// This function is called every frame to lerp those values a little closer to
/// their targets. `draw_board` then reads `anim_x/y` and `scale` to render
/// each tile, so repeating this over many frames produces smooth motion.
///
/// **Two independent animations per tile:**
///
/// 1. **Slide** — `anim_x/y` lerp toward `target_x/y` at rate
///    `anim_slide_speed * dt` (clamped to 0..1). Snaps when within 0.5 px.
///
/// 2. **Scale pop** — `scale` lerps toward 1.0 at rate `anim_pop_speed * dt`.
///    Snaps and clears `is_new`/`is_merged` when within 0.02 of 1.0.
///
/// **Mutated state per tile:**
/// - `tile.anim_x`, `tile.anim_y` — lerped toward `target_x/y` (slide)
/// - `tile.scale` — lerped toward 1.0 (pop)
/// - `tile.is_new` — cleared when scale settles
/// - `tile.is_merged` — cleared when scale settles
///
/// **Mutated state on Game:**
/// - `game.animating` — true while any tile still moving/scaling,
///   blocks player input in `handle_play_input`
/// - `game.msg_t` — decremented by `dt` each frame
/// - `game.msg` — cleared when `msg_t` reaches zero
fn @types.Game::update_animations(game : @types.Game, dt : Float) -> Unit {
  let mut all_done = true
  for i in 0..<@types.cell_count {
    let tile = game.tiles[i]
    let dx = tile.target_x - tile.anim_x
    let dy = tile.target_y - tile.anim_y
    if @types.absf(dx) > 0.5 || @types.absf(dy) > 0.5 {
      tile.anim_x = @types.lerpf(
        tile.anim_x,
        tile.target_x,
        @types.clampf(@types.anim_slide_speed * dt, 0.0, 1.0),
      )
      tile.anim_y = @types.lerpf(
        tile.anim_y,
        tile.target_y,
        @types.clampf(@types.anim_slide_speed * dt, 0.0, 1.0),
      )
      all_done = false
    } else {
      tile.anim_x = tile.target_x
      tile.anim_y = tile.target_y
    }
    if tile.is_new {
      tile.scale = @types.lerpf(
        tile.scale,
        1.0,
        @types.clampf(@types.anim_pop_speed * dt, 0.0, 1.0),
      )
      if @types.absf(tile.scale - 1.0) < 0.02 {
        tile.scale = 1.0
        tile.is_new = false
      } else {
        all_done = false
      }
    }
    if tile.is_merged {
      tile.scale = @types.lerpf(
        tile.scale,
        1.0,
        @types.clampf(@types.anim_pop_speed * dt, 0.0, 1.0),
      )
      if @types.absf(tile.scale - 1.0) < 0.02 {
        tile.scale = 1.0
        tile.is_merged = false
      } else {
        all_done = false
      }
    }
  }
  game.animating = not(all_done)
  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
    if game.msg_t <= 0.0 {
      game.msg = ""
    }
  }
}
