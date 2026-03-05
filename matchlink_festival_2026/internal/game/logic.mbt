///|
/// Fills the board with shuffled paired tile kinds and sets the remaining count to the total cell count.
fn @types.Game::build_level_board(game : @types.Game) -> Unit {
  let total : Int = game.board_w * game.board_h
  let pair_count : Int = total / 2

  let vals : Array[Int] = []
  for i in 0..<pair_count {
    let kind : Int = i % game.kind_count + 1
    vals.push(kind)
    vals.push(kind)
  }

  @types.shuffle_ints(vals)

  @types.clear_board(game)
  let mut p : Int = 0
  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      @types.set_cell(game, x, y, vals[p])
      p = p + 1
    }
  }

  game.remaining = total
}

///|
/// Appends (x, y) to the path coordinate arrays, skipping the push if it duplicates the last point.
fn push_point(xs : Array[Int], ys : Array[Int], x : Int, y : Int) -> Unit {
  if xs.length() > 0 {
    let last : Int = xs.length() - 1
    if xs[last] == x && ys[last] == y {
      return
    }
  }

  xs.push(x)
  ys.push(y)
}

///|
/// Constructs a `LinkPath` struct from coordinate arrays, returning an empty path when fewer than two points are present.
fn make_path(xs : Array[Int], ys : Array[Int]) -> @types.LinkPath {
  let n : Int = xs.length()
  if n < 2 {
    return @types.empty_path()
  }

  {
    found: true,
    points: n,
    x0: xs[0],
    y0: ys[0],
    x1: if n > 1 {
      xs[1]
    } else {
      xs[0]
    },
    y1: if n > 1 {
      ys[1]
    } else {
      ys[0]
    },
    x2: if n > 2 {
      xs[2]
    } else {
      xs[0]
    },
    y2: if n > 2 {
      ys[2]
    } else {
      ys[0]
    },
    x3: if n > 3 {
      xs[3]
    } else {
      xs[0]
    },
    y3: if n > 3 {
      ys[3]
    } else {
      ys[0]
    },
  }
}

///|
/// Returns true when the axis-aligned segment from (x1, y1) to (x2, y2) contains no non-empty cells between the endpoints.
fn @types.Game::line_clear(
  game : @types.Game,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Bool {
  if x1 == x2 && y1 == y2 {
    return true
  }

  if x1 != x2 && y1 != y2 {
    return false
  }

  if x1 == x2 {
    let step : Int = if y2 > y1 { 1 } else { -1 }
    let mut y : Int = y1 + step
    while y != y2 {
      if @types.cell_at(game, x1, y) != 0 {
        return false
      }
      y = y + step
    }
    return true
  }

  let step : Int = if x2 > x1 { 1 } else { -1 }
  let mut x : Int = x1 + step
  while x != x2 {
    if @types.cell_at(game, x, y1) != 0 {
      return false
    }
    x = x + step
  }

  true
}

///|
/// Returns true when cell (x, y) is the target tile or is empty, used to validate corner waypoints.
fn @types.Game::empty_or_target(
  game : @types.Game,
  x : Int,
  y : Int,
  tx : Int,
  ty : Int,
) -> Bool {
  (x == tx && y == ty) || @types.cell_at(game, x, y) == 0
}

///|
/// Tries to connect anchor (ax, ay) to (bx, by) via a straight line or a single L-shaped turn, returning the path if found.
fn @types.Game::direct_or_one_turn_from_anchor(
  game : @types.Game,
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
) -> @types.LinkPath {
  if game.line_clear(ax, ay, bx, by) {
    let xs : Array[Int] = []
    let ys : Array[Int] = []
    push_point(xs, ys, ax, ay)
    push_point(xs, ys, bx, by)
    return make_path(xs, ys)
  }

  let c1x : Int = ax
  let c1y : Int = by
  if game.empty_or_target(c1x, c1y, bx, by) &&
    game.line_clear(ax, ay, c1x, c1y) &&
    game.line_clear(c1x, c1y, bx, by) {
    let xs : Array[Int] = []
    let ys : Array[Int] = []
    push_point(xs, ys, ax, ay)
    push_point(xs, ys, c1x, c1y)
    push_point(xs, ys, bx, by)
    return make_path(xs, ys)
  }

  let c2x : Int = bx
  let c2y : Int = ay
  if game.empty_or_target(c2x, c2y, bx, by) &&
    game.line_clear(ax, ay, c2x, c2y) &&
    game.line_clear(c2x, c2y, bx, by) {
    let xs : Array[Int] = []
    let ys : Array[Int] = []
    push_point(xs, ys, ax, ay)
    push_point(xs, ys, c2x, c2y)
    push_point(xs, ys, bx, by)
    return make_path(xs, ys)
  }

  @types.empty_path()
}

///|
/// Prepends point (ax, ay) to a tail path, building a combined polyline.
fn compose_with_start(
  ax : Int,
  ay : Int,
  tail : @types.LinkPath,
) -> @types.LinkPath {
  if not(tail.found) {
    return @types.empty_path()
  }

  let xs : Array[Int] = []
  let ys : Array[Int] = []
  push_point(xs, ys, ax, ay)

  for i in 0..<tail.points {
    let (x, y) = @types.path_point(tail, i)
    push_point(xs, ys, x, y)
  }

  make_path(xs, ys)
}

///|
/// Searches for a valid link path between (ax, ay) and (bx, by) using direct, one-turn, and two-turn routes, returning the path if found.
fn @types.Game::find_link_path(
  game : @types.Game,
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
) -> @types.LinkPath {
  if ax == bx && ay == by {
    return @types.empty_path()
  }

  let a : Int = @types.cell_at(game, ax, ay)
  let b : Int = @types.cell_at(game, bx, by)
  if a <= 0 || a != b {
    return @types.empty_path()
  }

  let direct_or_corner : @types.LinkPath = game.direct_or_one_turn_from_anchor(
    ax, ay, bx, by,
  )
  if direct_or_corner.found {
    return direct_or_corner
  }

  for x in 0..<=(game.board_w + 1) {
    if x == bx && ay == by {
      continue
    }

    if x != ax && not(game.empty_or_target(x, ay, bx, by)) {
      continue
    }

    if not(game.line_clear(ax, ay, x, ay)) {
      continue
    }

    let tail : @types.LinkPath = game.direct_or_one_turn_from_anchor(
      x, ay, bx, by,
    )
    if tail.found {
      return compose_with_start(ax, ay, tail)
    }
  }

  for y in 0..<=(game.board_h + 1) {
    if ax == bx && y == by {
      continue
    }

    if y != ay && not(game.empty_or_target(ax, y, bx, by)) {
      continue
    }

    if not(game.line_clear(ax, ay, ax, y)) {
      continue
    }

    let tail : @types.LinkPath = game.direct_or_one_turn_from_anchor(
      ax, y, bx, by,
    )
    if tail.found {
      return compose_with_start(ax, ay, tail)
    }
  }

  @types.empty_path()
}

///|
/// Stores a link path into the game state for a brief flash animation, or clears it if the path was not found.
fn @types.Game::set_path_flash(
  game : @types.Game,
  path : @types.LinkPath,
) -> Unit {
  if not(path.found) {
    @types.clear_path_flash(game)
    return
  }

  game.path_active = true
  game.path_ttl = 0.23
  game.path_points = path.points
  game.path_x0 = path.x0
  game.path_y0 = path.y0
  game.path_x1 = path.x1
  game.path_y1 = path.y1
  game.path_x2 = path.x2
  game.path_y2 = path.y2
  game.path_x3 = path.x3
  game.path_y3 = path.y3
}

///|
/// Activates a hint highlight for the tile pair at (x0, y0) and (x1, y1) with a fixed display TTL.
fn @types.Game::set_hint_pair(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Unit {
  game.hint_active = true
  game.hint_ttl = 2.8
  game.hint_x0 = x0
  game.hint_y0 = y0
  game.hint_x1 = x1
  game.hint_y1 = y1
}

///|
/// Scans the entire board for any linkable matching tile pair, returning found status, the two coordinates, and the path.
fn @types.Game::find_any_move(
  game : @types.Game,
) -> (Bool, Int, Int, Int, Int, @types.LinkPath) {
  for y1 in 1..<=game.board_h {
    for x1 in 1..<=game.board_w {
      let k1 : Int = @types.cell_at(game, x1, y1)
      if k1 == 0 {
        continue
      }

      let mut y2 : Int = y1
      while y2 <= game.board_h {
        let start_x : Int = if y2 == y1 { x1 + 1 } else { 1 }
        let mut x2 : Int = start_x
        while x2 <= game.board_w {
          if @types.cell_at(game, x2, y2) == k1 {
            let p : @types.LinkPath = game.find_link_path(x1, y1, x2, y2)
            if p.found {
              return (true, x1, y1, x2, y2, p)
            }
          }
          x2 = x2 + 1
        }
        y2 = y2 + 1
      }
    }
  }

  (false, 0, 0, 0, 0, @types.empty_path())
}

///|
/// Repeatedly reshuffles remaining tile values until a valid move exists, optionally spending a shuffle ticket.
fn @types.Game::reshuffle_board(
  game : @types.Game,
  consume_ticket : Bool,
) -> Bool {
  if game.state != Play {
    return false
  }

  if consume_ticket && game.shuffles_left <= 0 {
    game.message = "No shuffle tickets"
    game.message_t = 0.9
    return false
  }

  let vals : Array[Int] = []
  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      let k : Int = @types.cell_at(game, x, y)
      if k > 0 {
        vals.push(k)
      }
    }
  }

  if vals.length() <= 1 {
    return false
  }

  let mut made : Bool = false
  for _t in 0..<28 {
    @types.shuffle_ints(vals)

    let mut p : Int = 0
    for y in 1..<=game.board_h {
      for x in 1..<=game.board_w {
        if @types.cell_at(game, x, y) > 0 {
          @types.set_cell(game, x, y, vals[p])
          p = p + 1
        }
      }
    }

    let probe = game.find_any_move()
    if probe.0 {
      made = true
      break
    }
  }

  if not(made) {
    game.message = "No valid shuffle"
    game.message_t = 0.9
    return false
  }

  if consume_ticket {
    game.shuffles_left = game.shuffles_left - 1
  }

  @types.clear_selection(game)
  @types.clear_path_flash(game)
  @types.clear_hint_flash(game)
  game.combo = 0
  game.message = "Board shuffled"
  game.message_t = 0.8
  game.shake_t = 0.14

  true
}

///|
/// Records level completion by incrementing the cleared level counter and accumulating elapsed time.
fn @types.Game::finalize_level_clear(game : @types.Game) -> Unit {
  game.total_levels = game.total_levels + 1
  game.total_time = game.total_time + (game.time_limit - game.timer)
}

///|
/// Finalises a cleared level and transitions to LevelClear or CampaignClear state depending on progress.
fn @types.Game::complete_level(game : @types.Game) -> Unit {
  if game.state != Play {
    return
  }

  game.finalize_level_clear()
  game.state = if game.level_index + 1 >= game.level_count {
    CampaignClear
  } else {
    LevelClear
  }

  game.message = "Board cleared"
  game.message_t = 1.4
  game.shake_t = 0.2
}

///|
/// Transitions to Fail state when time runs out, resetting combo and triggering a shake effect.
fn @types.Game::fail_level(game : @types.Game) -> Unit {
  if game.state != Play {
    return
  }

  game.state = Fail
  game.combo = 0
  game.message = "Time up"
  game.message_t = 1.2
  game.shake_t = 0.28
}

///|
/// Checks whether any valid move exists, and if not auto-shuffles or forces a shuffle; fails the level if no valid arrangement can be found.
fn @types.Game::ensure_move_exists(game : @types.Game) -> Unit {
  if game.state != Play || game.remaining <= 0 {
    return
  }

  let probe = game.find_any_move()
  if probe.0 {
    return
  }

  if game.reshuffle_board(true) {
    game.message = "No moves, auto-shuffled"
    game.message_t = 1.0
    return
  }

  if game.reshuffle_board(false) {
    game.message = "No moves, forced shuffle"
    game.message_t = 1.0
    return
  }

  game.fail_level()
}

///|
/// Removes the matched pair from the board, updates score and combo, grants bonus time, triggers sparks and path flash, and checks for level completion or a follow-up ensure_move_exists.
fn @types.Game::on_pair_matched(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
  kind : Int,
  path : @types.LinkPath,
) -> Unit {
  @types.set_cell(game, x0, y0, 0)
  @types.set_cell(game, x1, y1, 0)

  game.remaining = game.remaining - 2
  game.combo = game.combo + 1

  let gain : Int = 90 + game.combo * 20 + kind * 4
  game.score = game.score + gain

  game.timer = game.timer + 2.2 + Float::from_int(game.combo) * 0.18
  if game.timer > game.time_limit {
    game.timer = game.time_limit
  }

  game.set_path_flash(path)
  @types.clear_hint_flash(game)
  @types.clear_selection(game)

  game.message = "Combo x\{game.combo} +\{gain}"
  game.message_t = 0.95

  @types.burst_cell(game, x0, y0, 14, 0)
  @types.burst_cell(game, x1, y1, 14, 1)

  if game.remaining <= 0 {
    game.complete_level()
    return
  }

  game.ensure_move_exists()
}

///|
/// Resets the combo, shows a "Path blocked" message, and emits a shake and spark effect at the attempted cell.
fn @types.Game::on_pair_failed(game : @types.Game, x : Int, y : Int) -> Unit {
  game.combo = 0
  game.message = "Path blocked"
  game.message_t = 0.62
  game.shake_t = 0.08
  @types.burst_cell(game, x, y, 8, 2)
}

///|
/// Handles a tile pick at (x, y): selects the first tile, deselects on re-tap, switches selection to a different kind, or attempts to match the pair if kinds match.
fn @types.Game::pick_cell(game : @types.Game, x : Int, y : Int) -> Unit {
  if game.state != Play {
    return
  }

  let k : Int = @types.cell_at(game, x, y)
  if k <= 0 {
    return
  }

  game.cursor_x = x
  game.cursor_y = y

  if not(game.select_active) {
    game.select_active = true
    game.select_x = x
    game.select_y = y
    game.message = "Tile selected"
    game.message_t = 0.34
    return
  }

  if game.select_x == x && game.select_y == y {
    @types.clear_selection(game)
    game.message = "Selection cleared"
    game.message_t = 0.3
    return
  }

  let sx : Int = game.select_x
  let sy : Int = game.select_y
  let sk : Int = @types.cell_at(game, sx, sy)

  if sk <= 0 || sk != k {
    game.select_x = x
    game.select_y = y
    game.message = "Switched selection"
    game.message_t = 0.32
    return
  }

  let path : @types.LinkPath = game.find_link_path(sx, sy, x, y)
  if path.found {
    game.on_pair_matched(sx, sy, x, y, k, path)
  } else {
    game.select_x = x
    game.select_y = y
    game.on_pair_failed(x, y)
  }
}

///|
/// Picks the tile at the current cursor position.
fn @types.Game::pick_cursor_cell(game : @types.Game) -> Unit {
  game.pick_cell(game.cursor_x, game.cursor_y)
}

///|
/// Consumes one hint ticket to highlight the first available matching pair and moves the cursor to it; returns false if no hints remain or no pair is available.
fn @types.Game::use_hint(game : @types.Game) -> Bool {
  if game.state != Play || game.hints_left <= 0 {
    game.message = "No hints left"
    game.message_t = 0.8
    return false
  }

  let m = game.find_any_move()
  if not(m.0) {
    game.message = "No pair available"
    game.message_t = 0.9
    return false
  }

  game.hints_left = game.hints_left - 1
  game.set_hint_pair(m.1, m.2, m.3, m.4)
  game.cursor_x = m.1
  game.cursor_y = m.2
  game.message = "Hint highlighted"
  game.message_t = 0.9
  @types.burst_cell(game, m.1, m.2, 10, 3)
  @types.burst_cell(game, m.3, m.4, 10, 3)

  true
}

///|
/// Moves the cursor one step in the given direction, clamping to the board boundaries.
fn @types.Game::move_cursor_once(
  game : @types.Game,
  dir : @types.Direction,
) -> Unit {
  if game.state != Play {
    return
  }

  match dir {
    Left => game.cursor_x = (game.cursor_x - 1).clamp(min=1, max=game.board_w)
    Right => game.cursor_x = (game.cursor_x + 1).clamp(min=1, max=game.board_w)
    Up => game.cursor_y = (game.cursor_y - 1).clamp(min=1, max=game.board_h)
    Down => game.cursor_y = (game.cursor_y + 1).clamp(min=1, max=game.board_h)
    DirNone => ()
  }
}

///|
/// Handles directional key/button hold with initial delay and repeat rate to move the cursor smoothly while a direction is held.
fn @types.Game::update_cursor_hold(
  game : @types.Game,
  dt : Float,
  held_dir : @types.Direction,
) -> Unit {
  if game.state != Play {
    game.hold_dir = DirNone
    game.repeat_t = 0.0
    return
  }

  if held_dir == DirNone {
    game.hold_dir = DirNone
    game.repeat_t = 0.0
    return
  }

  if game.hold_dir != held_dir {
    game.hold_dir = held_dir
    game.repeat_t = 0.2
    game.move_cursor_once(held_dir)
  } else {
    game.repeat_t = game.repeat_t - dt
    if game.repeat_t <= 0.0 {
      game.repeat_t = 0.095
      game.move_cursor_once(held_dir)
    }
  }
}

///|
/// Advances all time-based game fields each frame: ui_t, message fade, shake, path flash, hint flash, touch cooldown, level countdown timer, and spark particles.
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

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

  if game.path_active {
    game.path_ttl = game.path_ttl - dt
    if game.path_ttl <= 0.0 {
      @types.clear_path_flash(game)
    }
  }

  if game.hint_active {
    game.hint_ttl = game.hint_ttl - dt
    if game.hint_ttl <= 0.0 {
      @types.clear_hint_flash(game)
    }
  }

  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  if game.state == Play {
    game.timer = game.timer - dt
    if game.timer <= 0.0 {
      game.timer = 0.0
      game.fail_level()
    }
  }

  @types.update_sparks(game, dt)
}

///|
/// Configures and initialises a campaign level by id: sets board dimensions, time limit, hint and shuffle counts, builds the board, and ensures at least one valid move exists before entering Play state.
fn @types.Game::load_level(game : @types.Game, level_id : Int) -> Unit {
  let mut id : Int = level_id
  if id < 0 {
    id = 0
  }
  if id >= game.level_count {
    id = game.level_count - 1
  }

  let (w, h, kinds, limit, hints, shuffles, name) = configure_level(id)

  game.level_index = id
  game.level_name = name
  game.board_w = w
  game.board_h = h
  game.kind_count = kinds.min((2).max(w * h / 2))

  game.time_limit = limit
  game.timer = limit
  game.hints_left = hints
  game.shuffles_left = shuffles

  game.combo = 0
  game.cursor_x = (1).max(w / 2)
  game.cursor_y = (1).max(h / 2)
  @types.clear_selection(game)
  @types.clear_path_flash(game)
  @types.clear_hint_flash(game)
  @types.clear_sparks(game)

  game.build_level_board()

  let mut ok : Bool = false
  for _k in 0..<28 {
    let m = game.find_any_move()
    if m.0 {
      ok = true
      break
    }
    ignore(game.reshuffle_board(false))
  }

  if not(ok) {
    game.message = "Generating board..."
    game.message_t = 0.8
  }

  game.state = Play
  game.message = "Level \{id + 1}: \{name}"
  game.message_t = 1.2
}

///|
/// Reloads the current level by index, resetting the board and all level state.
fn @types.Game::reload_level(game : @types.Game) -> Unit {
  game.load_level(game.level_index)
}

///|
/// Resets cumulative score and statistics then loads level 0 to start a fresh campaign run.
fn @types.Game::restart_campaign(game : @types.Game) -> Unit {
  game.score = 0
  game.total_levels = 0
  game.total_time = 0.0
  game.load_level(0)
}

///|
/// Advances to the next campaign level, or transitions to CampaignClear if the last level has already been completed.
fn @types.Game::next_level(game : @types.Game) -> Unit {
  if game.level_index + 1 >= game.level_count {
    game.state = CampaignClear
    return
  }
  game.load_level(game.level_index + 1)
}

///|
/// Advances one frame of input handling and state-specific game updates.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Read input state into game struct
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

  game.update_timers(dt)

  let start_press : Bool = game.detect_start_press()
  let next_press : Bool = game.detect_next_press()
  let reset_press : Bool = game.detect_reset_press()

  match game.state {
    Title => if start_press { game.restart_campaign() }
    Play => {
      let held_dir : @types.Direction = game.detect_held_dir()
      game.update_cursor_hold(dt, held_dir)

      let select_press : Bool = game.detect_select_press()
      let hint_press : Bool = game.detect_hint_press()
      let shuffle_press : Bool = game.detect_shuffle_press()
      let clear_press : Bool = game.detect_clear_press()
      let board_tap = game.detect_board_tap()

      if reset_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        game.reload_level()
      } else if clear_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.12
        @types.clear_selection(game)
        game.message = "Selection cleared"
        game.message_t = 0.5
      } else if hint_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.18
        ignore(game.use_hint())
      } else if shuffle_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        ignore(game.reshuffle_board(true))
      } else if board_tap.0 && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        game.pick_cell(board_tap.1, board_tap.2)
      } else if select_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        game.pick_cursor_cell()
      }
    }
    LevelClear => if next_press { game.next_level() }
    CampaignClear => if next_press { game.restart_campaign() }
    Fail => if reset_press || next_press { game.reload_level() }
  }
}
