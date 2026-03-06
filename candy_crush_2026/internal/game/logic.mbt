///|
/// Returns a random candy kind index in the range `[0, candy_kinds)`.
fn random_kind() -> Int {
  @raylib.get_random_value(0, @types.candy_kinds - 1)
}

///|
/// Deselects the currently selected board cell.
fn @types.Game::clear_selection(game : @types.Game) -> Unit {
  game.selected = false
}

///|
/// Sets the HUD message text and resets its display timer.
fn @types.Game::set_message(game : @types.Game, text : String) -> Unit {
  game.message = text
  game.message_t = @types.message_ttl_max
}

///|
/// Clears all match marks and pending special-spawn flags across the board.
fn @types.Game::clear_marks(game : @types.Game) -> Unit {
  for i in 0..<@types.board_cells {
    game.marks[i] = false
    game.spawn_special[i] = None
  }
}

///|
/// Resets all cell flash timers to zero.
fn @types.Game::clear_effects(game : @types.Game) -> Unit {
  for i in 0..<@types.board_cells {
    game.flash[i] = 0.0
  }
}

///|
/// Merges two special-candy markers, preferring bomb when types differ.
fn merge_special(a : @types.Special, b : @types.Special) -> @types.Special {
  match (a, b) {
    (Bomb, _) | (_, Bomb) => Bomb
    (None, _) => b
    (_, None) => a
    _ => if a != b { Bomb } else { a }
  }
}

///|
/// Marks a horizontal run of `len` cells starting at `(start_x, y)` and queues a special spawn for runs of 4 or 5+.
fn @types.Game::mark_horizontal_run(
  game : @types.Game,
  y : Int,
  start_x : Int,
  len : Int,
) -> Unit {
  for k in 0..<len {
    game.marks[@types.idx(start_x + k, y)] = true
  }

  if len == 4 {
    let anchor = @types.idx(start_x + 1, y)
    game.spawn_special[anchor] = merge_special(game.spawn_special[anchor], Row)
  } else if len >= 5 {
    let anchor = @types.idx(start_x + len / 2, y)
    game.spawn_special[anchor] = Bomb
  }
}

///|
/// Marks a vertical run of `len` cells starting at `(x, start_y)` and queues a special spawn for runs of 4 or 5+.
fn @types.Game::mark_vertical_run(
  game : @types.Game,
  x : Int,
  start_y : Int,
  len : Int,
) -> Unit {
  for k in 0..<len {
    game.marks[@types.idx(x, start_y + k)] = true
  }

  if len == 4 {
    let anchor = @types.idx(x, start_y + 1)
    game.spawn_special[anchor] = merge_special(game.spawn_special[anchor], Col)
  } else if len >= 5 {
    let anchor = @types.idx(x, start_y + len / 2)
    game.spawn_special[anchor] = Bomb
  }
}

///|
/// Scans all rows and columns for runs of 3+ matching candies, marks them, and returns the total count of marked cells.
fn @types.Game::scan_and_mark_matches(game : @types.Game) -> Int {
  game.clear_marks()

  for y in 0..<@types.board_rows {
    let mut x = 0
    while x < @types.board_cols {
      let t = game.kinds[@types.idx(x, y)]
      if t < 0 {
        x = x + 1
        continue
      }

      let mut len = 1
      while x + len < @types.board_cols &&
            game.kinds[@types.idx(x + len, y)] == t {
        len = len + 1
      }

      if len >= 3 {
        game.mark_horizontal_run(y, x, len)
      }
      x = x + len
    }
  }

  for x in 0..<@types.board_cols {
    let mut y = 0
    while y < @types.board_rows {
      let t = game.kinds[@types.idx(x, y)]
      if t < 0 {
        y = y + 1
        continue
      }

      let mut len = 1
      while y + len < @types.board_rows &&
            game.kinds[@types.idx(x, y + len)] == t {
        len = len + 1
      }

      if len >= 3 {
        game.mark_vertical_run(x, y, len)
      }
      y = y + len
    }
  }

  let mut n = 0
  for i in 0..<@types.board_cells {
    if game.marks[i] {
      n = n + 1
    }
  }
  n
}

///|
/// Expands marks through any triggered special candies (row, column, or bomb) until no new cells are added.
fn @types.Game::expand_special_marks(game : @types.Game) -> Unit {
  let mut changed = true

  while changed {
    changed = false

    for i in 0..<@types.board_cells {
      if !game.marks[i] {
        continue
      }

      let sp = game.specials[i]
      if sp == None {
        continue
      }

      let cx = i % @types.board_cols
      let cy = i / @types.board_cols

      match sp {
        None => ()
        Row =>
          for x in 0..<@types.board_cols {
            let j = @types.idx(x, cy)
            if !game.marks[j] {
              game.marks[j] = true
              changed = true
            }
          }
        Col =>
          for y in 0..<@types.board_rows {
            let j = @types.idx(cx, y)
            if !game.marks[j] {
              game.marks[j] = true
              changed = true
            }
          }
        Bomb =>
          for dy in -1..<=1 {
            for dx in -1..<=1 {
              let x = cx + dx
              let y = cy + dy
              if @types.in_board(x, y) {
                let j = @types.idx(x, y)
                if !game.marks[j] {
                  game.marks[j] = true
                  changed = true
                }
              }
            }
          }
      }
    }
  }
}

///|
/// Removes all marked cells from the board, decrementing jelly counters, and returns the count of removed candies.
fn @types.Game::remove_marked_cells(game : @types.Game) -> Int {
  let mut removed = 0

  for i in 0..<@types.board_cells {
    if !game.marks[i] {
      continue
    }

    let spawn = game.spawn_special[i]
    if spawn != None {
      if game.kinds[i] < 0 {
        game.kinds[i] = random_kind()
      }
      game.specials[i] = spawn
      game.flash[i] = 1.0
      continue
    }

    if game.kinds[i] >= 0 || game.specials[i] != None {
      removed = removed + 1
      if game.jelly[i] > 0 {
        game.jelly[i] = game.jelly[i] - 1
        if game.jelly[i] == 0 {
          game.jelly_left = game.jelly_left - 1
        }
      }
      game.kinds[i] = -1
      game.specials[i] = None
      game.flash[i] = 1.0
    }
  }

  removed
}

///|
/// Drops existing candies downward to fill gaps in each column and spawns new random candies at the top.
fn @types.Game::collapse_and_refill(game : @types.Game) -> Unit {
  let col_kind : Array[Int] = Array::make(@types.board_rows, -1)
  let col_special : Array[@types.Special] = Array::make(@types.board_rows, None)

  for x in 0..<@types.board_cols {
    for y in 0..<@types.board_rows {
      col_kind[y] = -1
      col_special[y] = None
    }

    let mut write = @types.board_rows - 1
    for y = @types.board_rows - 1; y >= 0; y = y - 1 {
      let i = @types.idx(x, y)
      if game.kinds[i] >= 0 {
        col_kind[write] = game.kinds[i]
        col_special[write] = game.specials[i]
        write = write - 1
      }
    }

    while write >= 0 {
      col_kind[write] = random_kind()
      col_special[write] = None
      write = write - 1
    }

    for y in 0..<@types.board_rows {
      let i = @types.idx(x, y)
      game.kinds[i] = col_kind[y]
      game.specials[i] = col_special[y]
    }
  }
}

///|
/// Returns true if the given kinds array contains any horizontal or vertical run of 3+ matching candies.
fn has_any_match(kinds : Array[Int]) -> Bool {
  for y in 0..<@types.board_rows {
    let mut x = 0
    while x < @types.board_cols {
      let t = kinds[@types.idx(x, y)]
      if t < 0 {
        x = x + 1
        continue
      }

      let mut len = 1
      while x + len < @types.board_cols && kinds[@types.idx(x + len, y)] == t {
        len = len + 1
      }
      if len >= 3 {
        return true
      }
      x = x + len
    }
  }

  for x in 0..<@types.board_cols {
    let mut y = 0
    while y < @types.board_rows {
      let t = kinds[@types.idx(x, y)]
      if t < 0 {
        y = y + 1
        continue
      }

      let mut len = 1
      while y + len < @types.board_rows && kinds[@types.idx(x, y + len)] == t {
        len = len + 1
      }
      if len >= 3 {
        return true
      }
      y = y + len
    }
  }

  false
}

///|
/// Returns true if swapping two board cells would produce at least one match.
fn would_swap_match(
  kinds : Array[Int],
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Bool {
  let a = @types.idx(x0, y0)
  let b = @types.idx(x1, y1)
  @types.swapi(kinds, a, b)
  let ok = has_any_match(kinds)
  @types.swapi(kinds, a, b)
  ok
}

///|
/// Returns true if any adjacent pair of cells can be swapped to produce a match.
fn has_possible_swap(kinds : Array[Int]) -> Bool {
  for y in 0..<@types.board_rows {
    for x in 0..<@types.board_cols {
      if x + 1 < @types.board_cols && would_swap_match(kinds, x, y, x + 1, y) {
        return true
      }
      if y + 1 < @types.board_rows && would_swap_match(kinds, x, y, x, y + 1) {
        return true
      }
    }
  }
  false
}

///|
/// Randomly shuffles board candies until a valid board with no initial matches but at least one possible swap is found, returning true on success.
fn @types.Game::shuffle_board(game : @types.Game) -> Bool {
  let bucket : Array[Int] = Array::make(@types.board_cells, 0)

  let mut tries = 0
  while tries < 160 {
    tries = tries + 1

    for i in 0..<@types.board_cells {
      bucket[i] = game.kinds[i]
    }

    for i = @types.board_cells - 1; i > 0; i = i - 1 {
      let j = @raylib.get_random_value(0, i)
      @types.swapi(bucket, i, j)
    }

    for i in 0..<@types.board_cells {
      game.kinds[i] = bucket[i]
      game.specials[i] = None
    }

    if !has_any_match(game.kinds) && has_possible_swap(game.kinds) {
      return true
    }
  }

  false
}

///|
/// Randomly assigns jelly markers to cells according to the level's target count.
fn @types.Game::assign_jelly_targets(game : @types.Game) -> Unit {
  for i in 0..<@types.board_cells {
    game.jelly[i] = 0
  }

  let mut target = @types.base_jelly +
    (game.level - 1) * @types.jelly_level_bonus
  if target > @types.board_cells {
    target = @types.board_cells
  }

  let mut placed = 0
  while placed < target {
    let p = @raylib.get_random_value(0, @types.board_cells - 1)
    if game.jelly[p] == 0 {
      game.jelly[p] = 1
      placed = placed + 1
    }
  }

  game.jelly_left = target
}

///|
/// Fills the board with random candies while avoiding pre-existing runs of 3+ in any direction.
fn @types.Game::fill_board_without_initial_matches(game : @types.Game) -> Unit {
  for y in 0..<@types.board_rows {
    for x in 0..<@types.board_cols {
      let mut t = random_kind()
      let mut retries = 0

      while retries < 40 {
        let mut bad = false

        if x >= 2 {
          let a = game.kinds[@types.idx(x - 1, y)]
          let b = game.kinds[@types.idx(x - 2, y)]
          if a == t && b == t {
            bad = true
          }
        }

        if y >= 2 {
          let a = game.kinds[@types.idx(x, y - 1)]
          let b = game.kinds[@types.idx(x, y - 2)]
          if a == t && b == t {
            bad = true
          }
        }

        if !bad {
          break
        }

        t = random_kind()
        retries = retries + 1
      }

      let i = @types.idx(x, y)
      game.kinds[i] = t
      game.specials[i] = None
    }
  }
}

///|
/// Resets jelly targets and fills the board with a valid starting layout that has at least one possible swap.
fn @types.Game::prepare_level_board(game : @types.Game) -> Unit {
  game.assign_jelly_targets()
  game.clear_effects()

  let mut tries = 0
  while tries < 120 {
    tries = tries + 1
    game.fill_board_without_initial_matches()

    if has_possible_swap(game.kinds) {
      return
    }
  }

  ignore(game.shuffle_board())
}

///|
/// Resets all run-wide state back to level 1 and starts a new board.
fn @types.Game::restart_run(game : @types.Game) -> Unit {
  game.level = 1
  game.score = 0
  game.chain_best = 0
  game.moves_left = @types.moves_base
  game.cursor_x = 0
  game.cursor_y = 0
  game.selected = false
  game.hint_active = false
  game.swap_flash_t = 0.0
  game.prepare_level_board()
  game.state = Play
  game.set_message("Crush all jelly tiles before moves run out.")
}

///|
/// Advances to the next level, restores the move budget, and prepares a fresh board.
fn @types.Game::start_next_level(game : @types.Game) -> Unit {
  game.level = game.level + 1
  game.moves_left = @types.moves_base +
    (game.level - 1) * @types.moves_level_bonus
  game.cursor_x = 0
  game.cursor_y = 0
  game.selected = false
  game.hint_active = false
  game.swap_flash_t = 0.0
  game.prepare_level_board()
  game.state = Play
  game.set_message("Level " + game.level.to_string() + " begins.")
}

///|
/// Restarts the current level, resetting moves and regenerating the board without changing the score.
fn @types.Game::restart_level(game : @types.Game) -> Unit {
  game.moves_left = @types.moves_base +
    (game.level - 1) * @types.moves_level_bonus
  game.cursor_x = 0
  game.cursor_y = 0
  game.selected = false
  game.hint_active = false
  game.swap_flash_t = 0.0
  game.prepare_level_board()
  game.state = Play
  game.set_message("Level reset.")
}

///|
/// Transitions to the LevelClear state and updates the best score if needed.
fn @types.Game::begin_level_clear(game : @types.Game) -> Unit {
  game.state = LevelClear
  if game.score > game.best_score {
    game.best_score = game.score
  }
  game.set_message("Sweet! Level cleared.")
}

///|
/// Transitions to the GameOver state and updates the best score if needed.
fn @types.Game::begin_game_over(game : @types.Game) -> Unit {
  game.state = GameOver
  if game.score > game.best_score {
    game.best_score = game.score
  }
  game.set_message("Out of moves. Try again.")
}

///|
/// Finds the first valid swap that produces a match and stores it as the active hint, returning true if found.
fn @types.Game::find_hint(game : @types.Game) -> Bool {
  for y in 0..<@types.board_rows {
    for x in 0..<@types.board_cols {
      if x + 1 < @types.board_cols &&
        would_swap_match(game.kinds, x, y, x + 1, y) {
        game.hint_active = true
        game.hint_x0 = x
        game.hint_y0 = y
        game.hint_x1 = x + 1
        game.hint_y1 = y
        game.hint_t = @types.hint_ttl_max
        return true
      }
      if y + 1 < @types.board_rows &&
        would_swap_match(game.kinds, x, y, x, y + 1) {
        game.hint_active = true
        game.hint_x0 = x
        game.hint_y0 = y
        game.hint_x1 = x
        game.hint_y1 = y + 1
        game.hint_t = @types.hint_ttl_max
        return true
      }
    }
  }

  game.hint_active = false
  false
}

///|
/// Records the two cells involved in the last successful swap and starts their flash animation timer.
fn @types.Game::set_swap_flash(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Unit {
  game.swap_flash_t = 0.42
  game.swap_x0 = x0
  game.swap_y0 = y0
  game.swap_x1 = x1
  game.swap_y1 = y1
}

///|
/// Repeatedly scans, expands, removes, and refills until no more matches exist, accumulating score per chain step.
fn @types.Game::run_cascade(game : @types.Game) -> Int {
  let mut chain = 0

  while true {
    let matched = game.scan_and_mark_matches()
    if matched <= 0 {
      break
    }

    game.expand_special_marks()

    let removed = game.remove_marked_cells()
    if removed <= 0 {
      break
    }

    chain = chain + 1
    game.score = game.score + @types.score_for_removed(removed, chain)
    if chain > game.chain_best {
      game.chain_best = chain
    }

    game.collapse_and_refill()
  }

  chain
}

///|
/// Attempts to swap two adjacent cells; runs the cascade if the swap creates a match, returns true on success.
fn @types.Game::attempt_swap(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Bool {
  if !@types.in_board(x0, y0) || !@types.in_board(x1, y1) {
    return false
  }

  if !@types.is_adjacent(x0, y0, x1, y1) {
    return false
  }

  let a = @types.idx(x0, y0)
  let b = @types.idx(x1, y1)

  @types.swapi(game.kinds, a, b)
  @types.swap_special(game.specials, a, b)

  if !has_any_match(game.kinds) {
    @types.swapi(game.kinds, a, b)
    @types.swap_special(game.specials, a, b)
    game.set_message("Swap did not make a match.")
    return false
  }

  game.moves_left = game.moves_left - 1
  game.clear_selection()
  game.hint_active = false
  game.set_swap_flash(x0, y0, x1, y1)

  ignore(game.run_cascade())

  if game.jelly_left <= 0 {
    game.begin_level_clear()
    return true
  }

  if game.moves_left <= 0 {
    game.begin_game_over()
    return true
  }

  if !has_possible_swap(game.kinds) {
    if game.shuffle_board() {
      game.set_message("No possible swaps. Board shuffled.")
    } else {
      game.begin_game_over()
    }
  }

  true
}

///|
/// Selects a cell on first tap or attempts a swap if an adjacent cell is already selected.
fn @types.Game::select_or_swap(game : @types.Game, x : Int, y : Int) -> Unit {
  if !@types.in_board(x, y) {
    return
  }

  game.cursor_x = x
  game.cursor_y = y
  game.hint_active = false

  if !game.selected {
    game.selected = true
    game.sel_x = x
    game.sel_y = y
    return
  }

  if game.sel_x == x && game.sel_y == y {
    game.clear_selection()
    return
  }

  if @types.is_adjacent(game.sel_x, game.sel_y, x, y) {
    ignore(game.attempt_swap(game.sel_x, game.sel_y, x, y))
    game.clear_selection()
    return
  }

  game.sel_x = x
  game.sel_y = y
}

///|
/// Moves the keyboard cursor by `(dx, dy)`, clamped to valid board bounds.
fn @types.Game::move_cursor(game : @types.Game, dx : Int, dy : Int) -> Unit {
  game.cursor_x = (game.cursor_x + dx).clamp(min=0, max=@types.board_cols - 1)
  game.cursor_y = (game.cursor_y + dy).clamp(min=0, max=@types.board_rows - 1)
}

///|
/// Activates the next hint or shuffles the board if no valid hint exists.
fn @types.Game::use_hint(game : @types.Game) -> Unit {
  if game.find_hint() {
    game.set_message("Try this swap.")
  } else {
    game.set_message("No hints found. Shuffling board...")
    ignore(game.shuffle_board())
  }
}

///|
/// Shuffles the board on player request, deducting one move; triggers game over if no valid arrangement is found.
fn @types.Game::try_manual_shuffle(game : @types.Game) -> Unit {
  if game.shuffle_board() {
    game.moves_left = (game.moves_left - 1).clamp(min=0, max=9999)
    game.set_message("Board shuffled (-1 move).")
    if game.moves_left <= 0 {
      game.begin_game_over()
    }
  } else {
    game.begin_game_over()
  }
}

///|
/// Advances all per-frame timers including flash, hint, message, touch cooldown, and swap flash.
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<@types.board_cells {
    game.flash[i] = @types.maxf(0.0, game.flash[i] - dt * 1.4)
  }

  if game.hint_active {
    game.hint_t = game.hint_t - dt
    if game.hint_t <= 0.0 {
      game.hint_active = false
    }
  }

  if game.message_t > 0.0 {
    game.message_t = game.message_t - dt
  }

  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  if game.swap_flash_t > 0.0 {
    game.swap_flash_t = game.swap_flash_t - dt
  }
}

///|
/// Advances one frame of game timers and state-specific input handling.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.update_timers(dt)
  match game.state {
    Title => game.update_title_input()
    Play => game.update_play_input()
    LevelClear | GameOver => game.update_result_input()
  }
}
