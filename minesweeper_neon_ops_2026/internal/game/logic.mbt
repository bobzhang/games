///|
/// Deactivates and zeroes all spark particle slots in the game state.
fn @types.Game::clear_effects(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
/// Activates the first inactive spark in the pool with the given position, velocity, lifetime, size, and visual kind.
fn @types.Game::spawn_spark(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for spark in game.sparks {
    if spark.active {
      continue
    }

    spark.active = true
    spark.x = x
    spark.y = y
    spark.vx = vx
    spark.vy = vy
    spark.life = life
    spark.size = size
    spark.kind = kind
    break
  }
}

///|
/// Spawns `n` sparks in a burst at (`x`, `y`) with random velocities and the given kind.
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    game.spawn_spark(
      x + @types.randf(-8.0, 8.0),
      y + @types.randf(-8.0, 8.0),
      @types.randf(-200.0, 200.0),
      @types.randf(-230.0, 120.0),
      @types.randf(0.2, 1.0),
      @types.randf(1.4, 4.8),
      kind,
    )
  }
}

///|
/// Advances all active sparks by `dt` seconds, applying drag and gravity, deactivating expired ones.
fn @types.Game::update_sparks(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 2.3)
    spark.vy = spark.vy * (1.0 - dt * 2.1) + dt * 170.0
  }
}

///|
/// Resets every cell on the board to the unrevealed, non-mined, unflagged state.
fn @types.Game::clear_board(game : @types.Game) -> Unit {
  for cell in game.cells {
    cell.mine = false
    cell.revealed = false
    cell.flagged = false
    cell.exploded = false
    cell.around = 0
  }
}

///|
/// Counts the number of mines in the eight neighbours of cell (`x`, `y`).
fn @types.Game::adjacent_mines(game : @types.Game, x : Int, y : Int) -> Int {
  let mut n : Int = 0

  for oy in -1..<=1 {
    for ox in -1..<=1 {
      if ox == 0 && oy == 0 {
        continue
      }
      let nx : Int = x + ox
      let ny : Int = y + oy
      if not(@types.in_board(nx, ny)) {
        continue
      }
      if game.cells[@types.idx(nx, ny)].mine {
        n = n + 1
      }
    }
  }

  n
}

///|
/// Recalculates the `around` field for every cell after mines have been placed.
fn @types.Game::recompute_around(game : @types.Game) -> Unit {
  for y in 0..<@types.board_h {
    for x in 0..<@types.board_w {
      let i : Int = @types.idx(x, y)
      if game.cells[i].mine {
        game.cells[i].around = -1
      } else {
        game.cells[i].around = game.adjacent_mines(x, y)
      }
    }
  }
}

///|
/// Returns true if (`x`, `y`) is within the 3x3 safe zone around the first-click seed cell.
fn is_safe_seed_cell(seed_x : Int, seed_y : Int, x : Int, y : Int) -> Bool {
  Float::from_int(seed_x - x).abs() <= 1.0 &&
  Float::from_int(seed_y - y).abs() <= 1.0
}

///|
/// Randomly places the required number of mines, guaranteeing the 3x3 area around (`safe_x`, `safe_y`) is mine-free.
fn @types.Game::place_mines(
  game : @types.Game,
  safe_x : Int,
  safe_y : Int,
) -> Unit {
  let mut placed : Int = 0

  while placed < game.mine_count {
    let x : Int = @raylib.get_random_value(0, @types.board_w - 1)
    let y : Int = @raylib.get_random_value(0, @types.board_h - 1)

    if is_safe_seed_cell(safe_x, safe_y, x, y) {
      continue
    }

    let i : Int = @types.idx(x, y)
    if game.cells[i].mine {
      continue
    }

    game.cells[i].mine = true
    placed = placed + 1
  }

  game.recompute_around()
}

///|
/// Resets all game counters, clears the board and effects, and transitions to the Play state.
fn @types.Game::start_match(game : @types.Game) -> Unit {
  game.clear_board()
  game.clear_effects()

  game.state = Play
  game.mode = Reveal
  game.first_move = true
  game.frame_seed = game.frame_seed + 1

  game.mine_count = @types.mine_count_default
  game.revealed_safe = 0
  game.flagged_count = 0

  game.cursor_x = @types.board_w / 2
  game.cursor_y = @types.board_h / 2
  game.last_reveal_x = -1
  game.last_reveal_y = -1

  game.lives = @types.lives_default
  game.hints = @types.hints_default
  game.mistakes = 0
  game.combo = 0
  game.combo_best = 0
  game.score = 0
  game.game_t = 0.0
  game.ui_t = 0.0
  game.combo_t = 0.0
  game.shake_t = 0.0

  game.grade = GradeD
  game.win = false
  game.touch_cd = 0.0

  @types.set_msg(game, "Sweep the grid. First reveal is always safe.", 2.4)
}

///|
/// Reveals every mine cell on the board, used when the game ends.
fn @types.Game::reveal_all_mines(game : @types.Game) -> Unit {
  for cell in game.cells {
    if cell.mine {
      cell.revealed = true
    }
  }
}

///|
/// Calculates the score awarded for revealing a safe cell, scaled by adjacency count and current combo.
fn score_for_reveal(around : Int, combo : Int) -> Int {
  let base : Int = if around <= 0 { 18 } else { 12 + around * 8 }
  base + combo * 5
}

///|
/// Increments the combo counter, updates the best combo record, and refreshes the combo display timer.
fn @types.Game::award_combo(game : @types.Game) -> Unit {
  game.combo = game.combo + 1
  if game.combo > game.combo_best {
    game.combo_best = game.combo
  }
  game.combo_t = 1.2
}

///|
/// Resets the combo counter and its display timer to zero.
fn @types.Game::reset_combo(game : @types.Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
/// Returns the pixel centre of cell (`x`, `y`) in world coordinates, using the current board metrics.
fn @types.Game::cell_world_center(
  game : @types.Game,
  x : Int,
  y : Int,
) -> (Float, Float) {
  let (bx, by, tile) = @types.board_metrics(game)
  (
    Float::from_int(bx + x * tile + tile / 2),
    Float::from_int(by + y * tile + tile / 2),
  )
}

///|
/// Reveals a single cell at (`x`, `y`): awards score or deducts a life on mine hit, emits particles, and may trigger game over.
fn @types.Game::reveal_single(game : @types.Game, x : Int, y : Int) -> Bool {
  if not(@types.in_board(x, y)) {
    return false
  }

  let i : Int = @types.idx(x, y)
  if game.cells[i].revealed || game.cells[i].flagged {
    return false
  }

  game.cells[i].revealed = true
  game.last_reveal_x = x
  game.last_reveal_y = y

  let (wx, wy) = game.cell_world_center(x, y)

  if game.cells[i].mine {
    game.cells[i].exploded = true
    game.mistakes = game.mistakes + 1
    game.lives = game.lives - 1
    game.reset_combo()

    game.burst(wx, wy, 28, 2)
    game.shake_t = @types.maxf(game.shake_t, 0.18)

    @types.set_msg(game, "Mine hit!", 1.0)

    if game.lives <= 0 {
      game.win = false
      game.grade = @types.compute_grade(
        game.score,
        game.game_t.to_int(),
        game.mistakes,
        game.lives,
      )
      game.reveal_all_mines()
      game.state = Result
      @types.set_msg(game, "Mission failed.", 2.0)
    }

    return true
  }

  game.revealed_safe = game.revealed_safe + 1
  game.award_combo()

  let bonus : Int = score_for_reveal(game.cells[i].around, game.combo)
  game.score = game.score + bonus

  game.burst(wx, wy, if game.cells[i].around == 0 { 9 } else { 6 }, 0)
  true
}

///|
/// BFS flood-reveals all connected zero-adjacency cells starting from (`sx`, `sy`), stopping if the game ends mid-flood.
fn @types.Game::flood_reveal(game : @types.Game, sx : Int, sy : Int) -> Unit {
  let mut qh : Int = 0
  let mut qt : Int = 0

  game.queue_x[qt] = sx
  game.queue_y[qt] = sy
  qt = qt + 1

  while qh < qt {
    let x : Int = game.queue_x[qh]
    let y : Int = game.queue_y[qh]
    qh = qh + 1

    if not(@types.in_board(x, y)) {
      continue
    }

    let i : Int = @types.idx(x, y)
    if game.cells[i].revealed || game.cells[i].flagged {
      continue
    }

    if not(game.reveal_single(x, y)) {
      continue
    }

    if game.state != Play {
      return
    }

    if game.cells[i].around != 0 {
      continue
    }

    for oy in -1..<=1 {
      for ox in -1..<=1 {
        if ox == 0 && oy == 0 {
          continue
        }

        let nx : Int = x + ox
        let ny : Int = y + oy
        if not(@types.in_board(nx, ny)) {
          continue
        }

        if qt < game.queue_x.length() {
          game.queue_x[qt] = nx
          game.queue_y[qt] = ny
          qt = qt + 1
        }
      }
    }
  }
}

///|
/// Checks whether all safe cells have been revealed; if so, computes the final score and grade and transitions to Result state.
fn @types.Game::check_clear(game : @types.Game) -> Bool {
  if game.revealed_safe >= @types.safe_cells_total(game) {
    game.win = true
    game.state = Result

    // Bonus for remaining resources.
    game.score = game.score + game.lives * 180 + game.hints * 120
    game.grade = @types.compute_grade(
      game.score,
      game.game_t.to_int(),
      game.mistakes,
      game.lives,
    )

    if game.score > game.best_score {
      game.best_score = game.score
    }

    @types.set_msg(game, "Sector cleared!", 2.2)
    return true
  }

  false
}

///|
/// Attempts to reveal cell (`x`, `y`): places mines on first move, flood-reveals if around == 0, and checks for board clear.
fn @types.Game::reveal_cell(game : @types.Game, x : Int, y : Int) -> Bool {
  if game.state != Play {
    return false
  }

  if not(@types.in_board(x, y)) {
    return false
  }

  let i0 : Int = @types.idx(x, y)
  if game.cells[i0].flagged {
    @types.set_msg(game, "Flag removed first", 0.8)
    return false
  }

  if game.first_move {
    game.place_mines(x, y)
    game.first_move = false
  }

  if game.cells[i0].revealed {
    return false
  }

  if game.cells[i0].around == 0 && not(game.cells[i0].mine) {
    game.flood_reveal(x, y)
  } else {
    ignore(game.reveal_single(x, y))
  }

  if game.state == Play {
    ignore(game.check_clear())
  }

  true
}

///|
/// Toggles the flag on the unrevealed cell at (`x`, `y`), enforcing the mine count budget.
fn @types.Game::toggle_flag(game : @types.Game, x : Int, y : Int) -> Bool {
  if game.state != Play {
    return false
  }
  if not(@types.in_board(x, y)) {
    return false
  }

  let i : Int = @types.idx(x, y)
  if game.cells[i].revealed {
    return false
  }

  if game.cells[i].flagged {
    game.cells[i].flagged = false
    game.flagged_count = (0).max(game.flagged_count - 1)
    @types.set_msg(game, "Flag removed", 0.6)
    return true
  }

  if game.flagged_count >= game.mine_count {
    @types.set_msg(game, "No flags left", 0.8)
    return false
  }

  game.cells[i].flagged = true
  game.flagged_count = game.flagged_count + 1

  let (wx, wy) = game.cell_world_center(x, y)
  game.burst(wx, wy, 6, 1)

  @types.set_msg(game, "Flag set", 0.6)
  true
}

///|
/// Searches for a random unrevealed, unflagged, safe cell to use as a hint target; falls back to a sequential scan if random probing fails.
fn @types.Game::safe_hint_target(game : @types.Game) -> (Bool, Int, Int) {
  let mut tries : Int = 0

  while tries < 900 {
    let x : Int = @raylib.get_random_value(0, @types.board_w - 1)
    let y : Int = @raylib.get_random_value(0, @types.board_h - 1)
    let i : Int = @types.idx(x, y)

    if not(game.cells[i].mine) &&
      not(game.cells[i].revealed) &&
      not(game.cells[i].flagged) {
      return (true, x, y)
    }

    tries = tries + 1
  }

  for y in 0..<@types.board_h {
    for x in 0..<@types.board_w {
      let i : Int = @types.idx(x, y)
      if not(game.cells[i].mine) &&
        not(game.cells[i].revealed) &&
        not(game.cells[i].flagged) {
        return (true, x, y)
      }
    }
  }

  (false, 0, 0)
}

///|
/// Spends one hint to reveal a guaranteed safe cell, moving the cursor to it and deducting 60 points.
fn @types.Game::use_hint(game : @types.Game) -> Bool {
  if game.state != Play {
    return false
  }

  if game.hints <= 0 {
    @types.set_msg(game, "No hints", 0.8)
    return false
  }

  if game.first_move {
    game.place_mines(game.cursor_x, game.cursor_y)
    game.first_move = false
  }

  let pick = game.safe_hint_target()
  if not(pick.0) {
    return false
  }

  game.hints = game.hints - 1
  game.score = (0).max(game.score - 60)

  let x : Int = pick.1
  let y : Int = pick.2

  game.cursor_x = x
  game.cursor_y = y

  ignore(game.reveal_cell(x, y))
  @types.set_msg(game, "Hint used", 1.0)

  true
}

///|
/// Converts pixel mouse coordinates to board cell coordinates using the current board metrics.
fn @types.Game::click_to_cell(
  game : @types.Game,
  mx : Float,
  my : Float,
) -> (Bool, Int, Int) {
  let (bx, by, tile) = @types.board_metrics(game)

  let x : Int = (mx.to_int() - bx) / tile
  let y : Int = (my.to_int() - by) / tile

  if @types.in_board(x, y) {
    (true, x, y)
  } else {
    (false, 0, 0)
  }
}

///|
/// Ticks timers for elapsed time, message display, combo decay, screen shake, touch cooldown, and spark particles.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.game_t = game.game_t + dt
  game.ui_t = game.ui_t + dt

  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
  }
  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
  }
  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }
  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  if game.combo_t <= 0.0 {
    game.combo = (0).max(game.combo - 1)
    game.combo_t = if game.combo > 0 { 0.55 } else { 0.0 }
  }

  game.update_sparks(dt)
}
