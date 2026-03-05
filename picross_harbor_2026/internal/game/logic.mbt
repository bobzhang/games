///|
/// Zeroes the solution, cell, row-clue, and column-clue arrays along with their count arrays to prepare for a new level load.
fn @types.Game::clear_solution_and_cells(game : @types.Game) -> Unit {
  for i in 0..<@types.max_cells {
    game.solution[i] = false
    game.cells[i] = @types.cell_unknown
    game.row_clues[i] = 0
    game.col_clues[i] = 0
  }

  for i in 0..<@types.max_board {
    game.row_clue_counts[i] = 0
    game.col_clue_counts[i] = 0
  }
}

///|
/// Resets the undo stack length to zero and clears every undo slot to its invalid default state.
fn @types.Game::clear_undo(game : @types.Game) -> Unit {
  game.undo_len = 0
  for i in 0..<game.undo.length() {
    game.undo[i] = {
      valid: false,
      x: 0,
      y: 0,
      prev_state: @types.cell_unknown,
      prev_mistakes: 0,
      prev_filled_correct: 0,
      prev_filled_wrong: 0,
      prev_hints_left: 0,
      prev_hints_used: 0,
    }
  }
}

///|
/// Deactivates all spark particles and resets their position, velocity, life, size, and kind fields.
fn @types.Game::clear_sparks(game : @types.Game) -> Unit {
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
/// Returns 1 if the cell is filled and the solution requires it to be filled, otherwise 0.
fn contribution_correct(cell_state : Int, sol : Bool) -> Int {
  if cell_state == @types.cell_fill {
    if sol {
      1
    } else {
      0
    }
  } else {
    0
  }
}

///|
/// Returns 1 if the cell is filled but the solution requires it to be empty, otherwise 0.
fn contribution_wrong(cell_state : Int, sol : Bool) -> Int {
  if cell_state == @types.cell_fill {
    if not(sol) {
      1
    } else {
      0
    }
  } else {
    0
  }
}

///|
/// Computes the nonogram run-length clues for the given row and stores them in the row_clues array along with the clue count.
fn @types.Game::compute_row_clues(game : @types.Game, y : Int) -> Unit {
  let base : Int = y * @types.max_board

  for k in 0..<@types.max_board {
    game.row_clues[base + k] = 0
  }

  let mut run : Int = 0
  let mut cnt : Int = 0

  for x in 0..<game.grid_w {
    if @types.solution_at(game, x, y) {
      run = run + 1
    } else if run > 0 {
      game.row_clues[base + cnt] = run
      cnt = cnt + 1
      run = 0
    }
  }

  if run > 0 {
    game.row_clues[base + cnt] = run
    cnt = cnt + 1
  }

  if cnt == 0 {
    game.row_clues[base] = 0
    cnt = 1
  }

  game.row_clue_counts[y] = cnt
}

///|
/// Computes the nonogram run-length clues for the given column and stores them in the col_clues array along with the clue count.
fn @types.Game::compute_col_clues(game : @types.Game, x : Int) -> Unit {
  let base : Int = x * @types.max_board

  for k in 0..<@types.max_board {
    game.col_clues[base + k] = 0
  }

  let mut run : Int = 0
  let mut cnt : Int = 0

  for y in 0..<game.grid_h {
    if @types.solution_at(game, x, y) {
      run = run + 1
    } else if run > 0 {
      game.col_clues[base + cnt] = run
      cnt = cnt + 1
      run = 0
    }
  }

  if run > 0 {
    game.col_clues[base + cnt] = run
    cnt = cnt + 1
  }

  if cnt == 0 {
    game.col_clues[base] = 0
    cnt = 1
  }

  game.col_clue_counts[x] = cnt
}

///|
/// Recomputes clues for every row and every column of the current grid.
fn @types.Game::compute_all_clues(game : @types.Game) -> Unit {
  for y in 0..<game.grid_h {
    game.compute_row_clues(y)
  }

  for x in 0..<game.grid_w {
    game.compute_col_clues(x)
  }
}

///|
/// Loads a level from a row-major binary grid, computes all clues, places the cursor at the board center, and resets all per-level counters.
fn @types.Game::apply_level_rows(
  game : @types.Game,
  rows : Array[Array[Int]],
  title : String,
  par_time : Int,
  mistake_limit : Int,
  hints : Int,
) -> Unit {
  game.clear_solution_and_cells()
  game.clear_undo()
  game.clear_sparks()

  game.level_name = title
  game.level_par_time = par_time
  game.level_mistake_limit = mistake_limit

  game.grid_h = rows.length().min(@types.max_board)
  game.grid_w = 0
  for y in 0..<game.grid_h {
    if rows[y].length() > game.grid_w {
      game.grid_w = rows[y].length()
    }
  }
  game.grid_w = game.grid_w.min(@types.max_board)

  game.solution_total = 0
  for y in 0..<game.grid_h {
    let row = rows[y]
    for x in 0..<game.grid_w {
      let filled : Bool = x < row.length() && row[x] != 0
      @types.set_solution(game, x, y, filled)
      @types.set_cell(game, x, y, @types.cell_unknown)
      if filled {
        game.solution_total = game.solution_total + 1
      }
    }
  }

  game.compute_all_clues()

  game.cursor_x = game.grid_w / 2
  game.cursor_y = game.grid_h / 2
  game.tool_mode = @types.tool_fill

  game.level_time = 0.0
  game.mistakes = 0
  game.hints_left = hints
  game.hints_used = 0
  game.filled_correct = 0
  game.filled_wrong = 0
  game.last_level_stars = 0

  game.message = ""
  game.message_t = 0.0
  game.shake_t = 0.0
  game.hold_dir = @types.dir_none
  game.move_repeat_t = 0.0
  game.touch_action_cd = 0.0
}

///|
/// Activates the first available spark slot with the given position, velocity, lifetime, size, and visual kind.
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
/// Spawns a burst of spark particles centred on the world position of the given board cell.
fn @types.Game::burst_cell(
  game : @types.Game,
  x : Int,
  y : Int,
  amount : Int,
  kind : Int,
) -> Unit {
  let (cx, cy, tile_f) = @types.world_for_cell(game, x, y)

  for _i in 0..<amount {
    let spread : Float = @types.maxf(6.0, tile_f * 0.22)
    game.spawn_spark(
      cx + @types.randf(-spread, spread),
      cy + @types.randf(-spread, spread),
      @types.randf(-120.0, 120.0),
      @types.randf(-130.0, 125.0),
      @types.randf(0.22, 0.88),
      @types.randf(1.8, 5.2),
      kind,
    )
  }
}

///|
/// Advances all active spark particles by dt: integrates velocity, applies drag and gravity, and deactivates expired sparks.
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
    spark.vx = spark.vx * (1.0 - dt * 1.8)
    spark.vy = spark.vy * (1.0 - dt * 1.8) + dt * 22.0
  }
}

///|
/// Appends an undo step to the ring buffer, evicting the oldest entry if the buffer is full.
fn @types.Game::push_undo(game : @types.Game, step : @types.UndoStep) -> Unit {
  if game.undo_len >= game.undo.length() {
    for i in 1..<game.undo.length() {
      game.undo[i - 1] = game.undo[i]
    }
    game.undo_len = game.undo.length() - 1
  }

  game.undo[game.undo_len] = step
  game.undo_len = game.undo_len + 1
}

///|
/// Returns 1 to 3 stars based on whether the player beat the par time, made no mistakes, and used no hints.
fn @types.Game::score_stars(game : @types.Game) -> Int {
  let mut stars : Int = 3

  if game.level_time > Float::from_int(game.level_par_time) {
    stars = stars - 1
  }

  if game.mistakes > 0 {
    stars = stars - 1
  }

  if game.hints_used > 0 {
    stars = stars - 1
  }

  if stars < 1 {
    stars = 1
  }

  stars
}

///|
/// Scores the completed level, stores the star result, and accumulates campaign-wide totals for time, mistakes, hints, stars, and completed count.
fn @types.Game::finalize_level_success(game : @types.Game) -> Unit {
  let stars : Int = game.score_stars()
  game.last_level_stars = stars

  game.total_time = game.total_time + game.level_time
  game.total_mistakes = game.total_mistakes + game.mistakes
  game.total_hints = game.total_hints + game.hints_used
  game.total_stars = game.total_stars + stars
  game.total_completed = game.total_completed + 1
}

///|
/// Finalizes a solved puzzle: scores the run, triggers a spark burst on all filled cells, and transitions to the level-clear or campaign-clear state.
fn @types.Game::complete_level(game : @types.Game) -> Unit {
  if game.state != @types.state_play {
    return
  }

  game.finalize_level_success()
  game.message = "Board solved"
  game.message_t = 1.4
  game.shake_t = 0.24

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if @types.solution_at(game, x, y) {
        game.burst_cell(x, y, 12, 0)
      }
    }
  }

  if game.level_index + 1 >= game.level_count {
    game.state = @types.state_campaign_clear
  } else {
    game.state = @types.state_level_clear
  }
}

///|
/// Triggers a level failure: sets the fail state, shows a shake effect, and bursts sparks on every incorrectly filled cell.
fn @types.Game::fail_level(game : @types.Game) -> Unit {
  if game.state != @types.state_play {
    return
  }

  game.message = "Too many mistakes"
  game.message_t = 1.2
  game.shake_t = 0.3
  game.state = @types.state_level_fail

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if @types.cell_at(game, x, y) == @types.cell_fill &&
        not(@types.solution_at(game, x, y)) {
        game.burst_cell(x, y, 10, 2)
      }
    }
  }
}

///|
/// Applies a new cell state at (x, y), records an undo step, updates correct/wrong fill counts, optionally counts mistakes or consumes a hint, spawns a spark burst, and checks for puzzle completion or failure.
fn @types.Game::apply_cell_state(
  game : @types.Game,
  x : Int,
  y : Int,
  new_state : Int,
  count_mistake : Bool,
  consume_hint : Bool,
  spark_kind : Int,
) -> Bool {
  if game.state != @types.state_play {
    return false
  }

  if not(@types.in_grid(game, x, y)) {
    return false
  }

  let idx : Int = @types.board_index(x, y)
  let prev_state : Int = game.cells[idx]
  if prev_state == new_state {
    return false
  }

  let sol : Bool = game.solution[idx]

  let step : @types.UndoStep = {
    valid: true,
    x,
    y,
    prev_state,
    prev_mistakes: game.mistakes,
    prev_filled_correct: game.filled_correct,
    prev_filled_wrong: game.filled_wrong,
    prev_hints_left: game.hints_left,
    prev_hints_used: game.hints_used,
  }
  game.push_undo(step)

  game.filled_correct = game.filled_correct -
    contribution_correct(prev_state, sol)
  game.filled_wrong = game.filled_wrong - contribution_wrong(prev_state, sol)

  game.cells[idx] = new_state

  game.filled_correct = game.filled_correct +
    contribution_correct(new_state, sol)
  game.filled_wrong = game.filled_wrong + contribution_wrong(new_state, sol)

  if count_mistake {
    if new_state == @types.cell_fill &&
      not(sol) &&
      prev_state != @types.cell_fill {
      game.mistakes = game.mistakes + 1
      game.message = "Wrong fill"
      game.message_t = 0.8
      game.shake_t = 0.1
    } else if new_state == @types.cell_cross &&
      sol &&
      prev_state != @types.cell_cross {
      game.mistakes = game.mistakes + 1
      game.message = "Marked a required cell"
      game.message_t = 0.9
      game.shake_t = 0.12
    }
  }

  if consume_hint {
    game.hints_left = (0).max(game.hints_left - 1)
    game.hints_used = game.hints_used + 1
    game.message = "Hint used"
    game.message_t = 0.9
  }

  game.burst_cell(x, y, 10, spark_kind)

  if @types.puzzle_solved(game) {
    game.complete_level()
  } else if game.mistakes > game.level_mistake_limit {
    game.fail_level()
  }

  true
}

///|
/// Applies the fill or mark tool to the cell at (x, y): toggles the state between filled/unknown or crossed/unknown, moves the cursor, and returns whether the cell changed.
fn @types.Game::apply_tool_on_cell(game : @types.Game, x : Int, y : Int, tool : Int) -> Bool {
  if game.state != @types.state_play {
    return false
  }

  let prev : Int = @types.cell_at(game, x, y)

  let next_state : Int = if tool == @types.tool_fill {
    if prev == @types.cell_fill {
      @types.cell_unknown
    } else {
      @types.cell_fill
    }
  } else if prev == @types.cell_cross {
    @types.cell_unknown
  } else {
    @types.cell_cross
  }

  let spark_kind : Int = if tool == @types.tool_fill { 1 } else { 3 }
  let ok : Bool = game.apply_cell_state(
    x, y, next_state, true, false, spark_kind,
  )

  if ok {
    game.cursor_x = x
    game.cursor_y = y
  }

  ok
}

///|
/// Applies the given tool to the cell under the current cursor position.
fn @types.Game::apply_tool_at_cursor(game : @types.Game, tool : Int) -> Bool {
  game.apply_tool_on_cell(game.cursor_x, game.cursor_y, tool)
}

///|
/// Consumes one hint: reveals the first unfilled required cell, then the first incorrect fill, then the first unmarked empty cell; returns false if no hints remain.
fn @types.Game::use_hint(game : @types.Game) -> Bool {
  if game.state != @types.state_play {
    return false
  }
  if game.hints_left <= 0 {
    return false
  }

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if @types.solution_at(game, x, y) &&
        @types.cell_at(game, x, y) != @types.cell_fill {
        game.cursor_x = x
        game.cursor_y = y
        return game.apply_cell_state(x, y, @types.cell_fill, false, true, 0)
      }
    }
  }

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if not(@types.solution_at(game, x, y)) &&
        @types.cell_at(game, x, y) == @types.cell_fill {
        game.cursor_x = x
        game.cursor_y = y
        return game.apply_cell_state(x, y, @types.cell_cross, false, true, 0)
      }
    }
  }

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if not(@types.solution_at(game, x, y)) &&
        @types.cell_at(game, x, y) == @types.cell_unknown {
        game.cursor_x = x
        game.cursor_y = y
        return game.apply_cell_state(x, y, @types.cell_cross, false, true, 0)
      }
    }
  }

  false
}

///|
/// Pops the most recent undo step and restores the cell state, mistake count, fill counts, hint counts, and cursor position to their previous values.
fn @types.Game::undo_action(game : @types.Game) -> Bool {
  if game.undo_len <= 0 {
    return false
  }

  game.undo_len = game.undo_len - 1
  let step : @types.UndoStep = game.undo[game.undo_len]
  if not(step.valid) {
    return false
  }

  if @types.in_grid(game, step.x, step.y) {
    game.cells[@types.board_index(step.x, step.y)] = step.prev_state
  }

  game.mistakes = step.prev_mistakes
  game.filled_correct = step.prev_filled_correct
  game.filled_wrong = step.prev_filled_wrong
  game.hints_left = step.prev_hints_left
  game.hints_used = step.prev_hints_used

  game.cursor_x = step.x
  game.cursor_y = step.y
  game.state = @types.state_play
  game.message = "Undo"
  game.message_t = 0.45
  game.shake_t = 0.08
  game.burst_cell(step.x, step.y, 8, 2)

  true
}

///|
/// Advances the UI animation clock, level timer, message countdown, shake countdown, touch-action cooldown, and spark particle system by dt.
fn @types.Game::update_frame_timers(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == @types.state_play {
    game.level_time = game.level_time + dt
  }

  if game.message_t > 0.0 {
    game.message_t = game.message_t - dt
    if game.message_t < 0.0 {
      game.message_t = 0.0
    }
  }

  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
    if game.shake_t < 0.0 {
      game.shake_t = 0.0
    }
  }

  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  game.update_sparks(dt)
}

///|
/// Moves the cursor one step in the given direction, clamping it within the current grid bounds.
fn @types.Game::move_cursor_once(game : @types.Game, dir : Int) -> Unit {
  if game.state != @types.state_play {
    return
  }

  if dir == @types.dir_left {
    game.cursor_x = (game.cursor_x - 1).clamp(min=0, max=game.grid_w - 1)
  } else if dir == @types.dir_right {
    game.cursor_x = (game.cursor_x + 1).clamp(min=0, max=game.grid_w - 1)
  } else if dir == @types.dir_up {
    game.cursor_y = (game.cursor_y - 1).clamp(min=0, max=game.grid_h - 1)
  } else if dir == @types.dir_down {
    game.cursor_y = (game.cursor_y + 1).clamp(min=0, max=game.grid_h - 1)
  }
}

///|
/// Handles cursor auto-repeat movement: on first frame of a new held direction the cursor moves once, then repeats at a faster interval while the direction is held.
fn @types.Game::update_cursor_hold(game : @types.Game, dt : Float, held_dir : Int) -> Unit {
  if game.state != @types.state_play {
    game.hold_dir = @types.dir_none
    game.move_repeat_t = 0.0
    return
  }

  if held_dir == @types.dir_none {
    game.hold_dir = @types.dir_none
    game.move_repeat_t = 0.0
    return
  }

  if game.hold_dir != held_dir {
    game.hold_dir = held_dir
    game.move_repeat_t = 0.19
    game.move_cursor_once(held_dir)
  } else {
    game.move_repeat_t = game.move_repeat_t - dt
    if game.move_repeat_t <= 0.0 {
      game.move_repeat_t = 0.095
      game.move_cursor_once(held_dir)
    }
  }
}

///|
/// Toggles the active tool between fill and mark and shows a brief status message.
fn @types.Game::switch_tool(game : @types.Game) -> Unit {
  if game.tool_mode == @types.tool_fill {
    game.tool_mode = @types.tool_cross
    game.message = "Tool: Mark"
  } else {
    game.tool_mode = @types.tool_fill
    game.message = "Tool: Fill"
  }
  game.message_t = 0.5
}

///|
/// Loads the puzzle for the given level ID by calling apply_level_rows with the appropriate hardcoded grid, then transitions to the play state.
fn @types.Game::load_level(game : @types.Game, level_id : Int) -> Unit {
  let mut id : Int = level_id
  if id < 0 {
    id = 0
  }
  if id >= game.level_count {
    id = game.level_count - 1
  }

  if id == 0 {
    let rows : Array[Array[Int]] = [
      [0, 0, 1, 1, 0, 0, 0, 0],
      [0, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 0],
      [0, 1, 1, 1, 1, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 1, 1, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Lighthouse Watch", 70, 7, 3)
  } else if id == 1 {
    let rows : Array[Array[Int]] = [
      [0, 0, 0, 0, 1, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 0, 1, 1, 1, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 0, 0, 0, 1, 1, 0],
      [1, 1, 0, 0, 0, 0, 0, 1, 1],
    ]
    game.apply_level_rows(rows, "Tugboat Shift", 82, 8, 3)
  } else if id == 2 {
    let rows : Array[Array[Int]] = [
      [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 0, 0, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 0, 1, 1, 0, 1, 1, 0],
      [1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
    ]
    game.apply_level_rows(rows, "Anchor Draft", 96, 9, 3)
  } else if id == 3 {
    let rows : Array[Array[Int]] = [
      [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Crane Hook", 96, 8, 3)
  } else if id == 4 {
    let rows : Array[Array[Int]] = [
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 0, 0, 0, 0, 1, 1, 0],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 0, 1, 1, 1, 1, 0, 1, 1],
      [1, 1, 0, 1, 0, 0, 1, 0, 1, 1],
      [1, 1, 0, 1, 1, 1, 1, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [0, 1, 1, 0, 0, 0, 0, 1, 1, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Cargo Crate", 104, 9, 3)
  } else if id == 5 {
    let rows : Array[Array[Int]] = [
      [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0],
      [1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1],
      [0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0],
      [0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    ]
    game.apply_level_rows(rows, "Wave Beacon", 118, 10, 3)
  } else if id == 6 {
    let rows : Array[Array[Int]] = [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Harbor Bridge", 126, 10, 3)
  } else if id == 7 {
    let rows : Array[Array[Int]] = [
      [0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0],
      [0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0],
      [1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Seagull Pass", 132, 11, 3)
  } else if id == 8 {
    let rows : Array[Array[Int]] = [
      [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Submarine Echo", 142, 12, 2)
  } else if id == 9 {
    let rows : Array[Array[Int]] = [
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
      [0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
    ]
    game.apply_level_rows(rows, "Shipyard Gear", 152, 12, 2)
  } else if id == 10 {
    let rows : Array[Array[Int]] = [
      [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Fleet Signal", 160, 13, 2)
  } else {
    let rows : Array[Array[Int]] = [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
      [1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
      [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    ]
    game.apply_level_rows(rows, "Storm Port", 176, 14, 2)
  }

  game.level_index = id
  game.state = @types.state_play
  game.message = "Level \{id + 1}: \{game.level_name}"
  game.message_t = 1.4
}

///|
/// Reloads the current level from scratch, resetting all cell states and counters.
fn @types.Game::reload_level(game : @types.Game) -> Unit {
  game.load_level(game.level_index)
}

///|
/// Resets all campaign-wide totals and reloads the first level to begin a fresh playthrough.
fn @types.Game::restart_campaign(game : @types.Game) -> Unit {
  game.total_time = 0.0
  game.total_mistakes = 0
  game.total_hints = 0
  game.total_stars = 0
  game.total_completed = 0
  game.load_level(0)
}

///|
/// Loads the next level in the campaign, or transitions to the campaign-clear state if all levels have been completed.
fn @types.Game::advance_level(game : @types.Game) -> Unit {
  if game.level_index + 1 >= game.level_count {
    game.state = @types.state_campaign_clear
    return
  }
  game.load_level(game.level_index + 1)
}

///|
/// Capture input and advance one frame of puzzle/campaign state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  let mouse = @raylib.get_mouse_position()
  game.mouse_x = mouse.x
  game.mouse_y = mouse.y
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
  game.mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let mut tc : Int = @raylib.get_touch_point_count()
  if tc < 0 {
    tc = 0
  }
  game.touch_count = tc

  if @raylib.is_key_pressed(@raylib.KeyF11) {
    @raylib.toggle_borderless_windowed()
  }

  game.update_frame_timers(dt)

  let start_press : Bool = game.detect_start_press()
  let next_press : Bool = game.detect_next_press()
  let reset_press : Bool = game.detect_reset_press()

  if game.state == @types.state_title {
    if start_press {
      game.restart_campaign()
    }
  } else if game.state == @types.state_play {
    let held_dir : Int = game.detect_held_dir()
    game.update_cursor_hold(dt, held_dir)

    if detect_toggle_tool() {
      game.switch_tool()
    }

    let undo_press : Bool = game.detect_undo_press()
    let hint_press : Bool = game.detect_hint_press()
    let fill_press : Bool = game.detect_fill_press()
    let cross_press : Bool = game.detect_cross_press()
    let board_tap = game.detect_board_tap()

    if reset_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.2
      game.reload_level()
    } else if undo_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.16
      ignore(game.undo_action())
    } else if hint_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.2
      ignore(game.use_hint())
    } else if board_tap.0 && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.12
      ignore(game.apply_tool_on_cell(board_tap.1, board_tap.2, game.tool_mode))
    } else if fill_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.1
      ignore(game.apply_tool_at_cursor(@types.tool_fill))
    } else if cross_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.1
      ignore(game.apply_tool_at_cursor(@types.tool_cross))
    }
  } else if game.state == @types.state_level_clear {
    if next_press {
      game.advance_level()
    }
  } else if game.state == @types.state_campaign_clear {
    if next_press {
      game.restart_campaign()
    }
  } else if game.state == @types.state_level_fail {
    if reset_press || next_press {
      game.reload_level()
    }
  }
}
