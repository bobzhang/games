///|
let screen_w : Int = 1280

///|
let screen_h : Int = 860

///|
let grid_w : Int = 12

///|
let grid_h : Int = 8

///|
let cell : Int = 72

///|
let board_x : Int = 150

///|
let board_y : Int = 150

///|
let loop_len : Int = 9

///|
let max_ghosts : Int = 6

///|
let tile_empty : Int = 0

///|
let tile_wall : Int = 1

///|
let tile_vault : Int = 2

///|
let tile_exit : Int = 3

///|
let tile_key : Int = 4

///|
let action_wait : Int = 0

///|
let action_up : Int = 1

///|
let action_down : Int = 2

///|
let action_left : Int = 3

///|
let action_right : Int = 4

///|
let max_guards : Int = 4

///|
let max_doors : Int = 3

///|
struct Actor {
  mut x : Int
  mut y : Int
}

///|
struct Guard {
  mut active : Bool
  mut x : Int
  mut y : Int
  ax : Int
  ay : Int
  bx : Int
  by : Int
  mut to_b : Bool
  mut alert_x : Int
  mut alert_y : Int
  mut alert_t : Int
}

///|
struct Door {
  mut active : Bool
  x : Int
  y : Int
  plate_x : Int
  plate_y : Int
  title : String
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * grid_w + x
}

///|
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && y >= 0 && x < grid_w && y < grid_h
}

///|
fn cell_rect(x : Int, y : Int) -> (Int, Int, Int, Int) {
  (board_x + x * cell, board_y + y * cell, cell, cell)
}

///|
fn screen_center_x(x : Int) -> Int {
  board_x + x * cell + cell / 2
}

///|
fn screen_center_y(y : Int) -> Int {
  board_y + y * cell + cell / 2
}

///|
fn clear_level(
  tiles : Array[Int],
  guards : Array[Guard],
  doors : Array[Door],
) -> Unit {
  for i in 0..<tiles.length() {
    tiles[i] = tile_empty
  }
  for x in 0..<grid_w {
    tiles[idx(x, 0)] = tile_wall
    tiles[idx(x, grid_h - 1)] = tile_wall
  }
  for y in 0..<grid_h {
    tiles[idx(0, y)] = tile_wall
    tiles[idx(grid_w - 1, y)] = tile_wall
  }
  for guard_val in guards {
    guard_val.active = false
    guard_val.x = 0
    guard_val.y = 0
    guard_val.to_b = true
    guard_val.alert_x = 0
    guard_val.alert_y = 0
    guard_val.alert_t = 0
  }
  for door in doors {
    door.active = false
  }
}

///|
fn set_wall_row(tiles : Array[Int], y : Int, x0 : Int, x1 : Int) -> Unit {
  for x in x0..=x1 {
    tiles[idx(x, y)] = tile_wall
  }
}

///|
fn set_wall_col(tiles : Array[Int], x : Int, y0 : Int, y1 : Int) -> Unit {
  for y in y0..=y1 {
    tiles[idx(x, y)] = tile_wall
  }
}

///|
fn set_guard_patrol(guards : Array[Guard], i : Int, x : Int, y : Int, ax : Int, ay : Int, bx : Int, by : Int) -> Unit {
  guards[i] = {
    active: true,
    x,
    y,
    ax,
    ay,
    bx,
    by,
    to_b: true,
    alert_x: x,
    alert_y: y,
    alert_t: 0,
  }
}

///|
fn set_door(doors : Array[Door], i : Int, x : Int, y : Int, px : Int, py : Int, title : String) -> Unit {
  doors[i] = { active: true, x, y, plate_x: px, plate_y: py, title }
}

///|
fn setup_level(
  level : Int,
  tiles : Array[Int],
  guards : Array[Guard],
  doors : Array[Door],
) -> (Int, Int, Int, Int, Int, Int, String) {
  clear_level(tiles, guards, doors)

  if level == 1 {
    set_wall_col(tiles, 5, 1, 6)
    tiles[idx(5, 4)] = tile_empty
    tiles[idx(8, 2)] = tile_vault
    tiles[idx(2, 6)] = tile_key
    tiles[idx(10, 6)] = tile_exit
    set_door(doors, 0, 5, 4, 2, 2, "Ghost holds plate")
    set_guard_patrol(guards, 0, 8, 5, 8, 5, 10, 5)
    (1, 1, 8, 2, 10, 6, "Stand a ghost on the amber plate to open the breach door.")
  } else if level == 2 {
    set_wall_col(tiles, 4, 1, 6)
    set_wall_col(tiles, 8, 1, 6)
    tiles[idx(4, 2)] = tile_empty
    tiles[idx(8, 5)] = tile_empty
    tiles[idx(9, 2)] = tile_vault
    tiles[idx(2, 5)] = tile_key
    tiles[idx(10, 1)] = tile_exit
    set_door(doors, 0, 4, 2, 2, 1, "Loop 1 holds left gate")
    set_door(doors, 1, 8, 5, 6, 6, "Loop 2 opens extraction gate")
    set_guard_patrol(guards, 0, 6, 2, 6, 2, 7, 5)
    set_guard_patrol(guards, 1, 10, 4, 10, 4, 9, 6)
    (1, 6, 9, 2, 10, 1, "Collect the key, crack the vault, then extract through the north dock.")
  } else {
    set_wall_row(tiles, 3, 2, 9)
    set_wall_row(tiles, 5, 2, 9)
    tiles[idx(3, 3)] = tile_empty
    tiles[idx(8, 5)] = tile_empty
    tiles[idx(9, 1)] = tile_vault
    tiles[idx(1, 6)] = tile_key
    tiles[idx(10, 6)] = tile_exit
    set_door(doors, 0, 3, 3, 6, 6, "Ghost lures guard left")
    set_door(doors, 1, 8, 5, 2, 2, "Another ghost opens final gate")
    set_guard_patrol(guards, 0, 5, 2, 5, 2, 7, 2)
    set_guard_patrol(guards, 1, 7, 6, 7, 6, 9, 6)
    set_guard_patrol(guards, 2, 9, 3, 9, 3, 9, 4)
    (1, 1, 9, 1, 10, 6, "Final blueprint: chain two loops and use ghosts as decoys.")
  }
}

///|
fn action_dir(action : Int) -> (Int, Int) {
  if action == action_up {
    (0, -1)
  } else if action == action_down {
    (0, 1)
  } else if action == action_left {
    (-1, 0)
  } else if action == action_right {
    (1, 0)
  } else {
    (0, 0)
  }
}

///|
fn door_is_open(doors : Array[Door], door_i : Int, player : Actor, ghosts : Array[Actor], ghost_count : Int) -> Bool {
  if !doors[door_i].active {
    return false
  }
  if player.x == doors[door_i].plate_x && player.y == doors[door_i].plate_y {
    return true
  }
  for i in 0..<ghost_count {
    if ghosts[i].x == doors[door_i].plate_x && ghosts[i].y == doors[door_i].plate_y {
      return true
    }
  }
  false
}

///|
fn tile_blocked(tiles : Array[Int], doors : Array[Door], player : Actor, ghosts : Array[Actor], ghost_count : Int, x : Int, y : Int) -> Bool {
  if !in_bounds(x, y) {
    return true
  }
  if tiles[idx(x, y)] == tile_wall {
    return true
  }
  for i in 0..<doors.length() {
    if doors[i].active && doors[i].x == x && doors[i].y == y && !door_is_open(doors, i, player, ghosts, ghost_count) {
      return true
    }
  }
  false
}

///|
fn step_actor(actor : Actor, action : Int, tiles : Array[Int], doors : Array[Door], player : Actor, ghosts : Array[Actor], ghost_count : Int) -> Unit {
  let (dx, dy) = action_dir(action)
  let nx = actor.x + dx
  let ny = actor.y + dy
  if tile_blocked(tiles, doors, player, ghosts, ghost_count, nx, ny) {
    return
  }
  actor.x = nx
  actor.y = ny
}

///|
fn line_clear(tiles : Array[Int], doors : Array[Door], player : Actor, ghosts : Array[Actor], ghost_count : Int, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Bool {
  if x0 == x1 {
    let lo = if y0 < y1 { y0 + 1 } else { y1 + 1 }
    let hi = if y0 < y1 { y1 - 1 } else { y0 - 1 }
    for y in lo..=hi {
      if tile_blocked(tiles, doors, player, ghosts, ghost_count, x0, y) {
        return false
      }
    }
    true
  } else if y0 == y1 {
    let lo = if x0 < x1 { x0 + 1 } else { x1 + 1 }
    let hi = if x0 < x1 { x1 - 1 } else { x0 - 1 }
    for x in lo..=hi {
      if tile_blocked(tiles, doors, player, ghosts, ghost_count, x, y0) {
        return false
      }
    }
    true
  } else {
    false
  }
}

///|
fn nearest_seen_target(
  guard_val : Guard,
  player : Actor,
  ghosts : Array[Actor],
  ghost_count : Int,
  tiles : Array[Int],
  doors : Array[Door],
) -> (Bool, Int, Int) {
  let mut best_seen = false
  let mut best_x = 0
  let mut best_y = 0
  let mut best_d = 9999

  if (guard_val.x == player.x || guard_val.y == player.y) &&
    line_clear(tiles, doors, player, ghosts, ghost_count, guard_val.x, guard_val.y, player.x, player.y) {
    best_seen = true
    best_x = player.x
    best_y = player.y
    best_d = (guard_val.x - player.x).abs() + (guard_val.y - player.y).abs()
  }

  for i in 0..<ghost_count {
    let gx = ghosts[i].x
    let gy = ghosts[i].y
    if guard_val.x != gx && guard_val.y != gy {
      continue
    }
    if !line_clear(tiles, doors, player, ghosts, ghost_count, guard_val.x, guard_val.y, gx, gy) {
      continue
    }
    let d = (guard_val.x - gx).abs() + (guard_val.y - gy).abs()
    if d < best_d {
      best_seen = true
      best_x = gx
      best_y = gy
      best_d = d
    }
  }

  (best_seen, best_x, best_y)
}

///|
fn guard_target_cell(guard_val : Guard) -> (Int, Int) {
  if guard_val.alert_t > 0 {
    (guard_val.alert_x, guard_val.alert_y)
  } else if guard_val.to_b {
    (guard_val.bx, guard_val.by)
  } else {
    (guard_val.ax, guard_val.ay)
  }
}

///|
fn step_guard(guard_val : Guard, tiles : Array[Int], doors : Array[Door], player : Actor, ghosts : Array[Actor], ghost_count : Int) -> Unit {
  if !guard_val.active {
    return
  }

  let seen = nearest_seen_target(guard_val, player, ghosts, ghost_count, tiles, doors)
  if seen.0 {
    guard_val.alert_x = seen.1
    guard_val.alert_y = seen.2
    guard_val.alert_t = 2
  } else if guard_val.alert_t > 0 {
    guard_val.alert_t = guard_val.alert_t - 1
  }

  let target = guard_target_cell(guard_val)
  let dx = if target.0 > guard_val.x {
    1
  } else if target.0 < guard_val.x {
    -1
  } else {
    0
  }
  let dy = if target.1 > guard_val.y {
    1
  } else if target.1 < guard_val.y {
    -1
  } else {
    0
  }

  let first_x = guard_val.x + dx
  let first_y = guard_val.y
  if dx != 0 && !tile_blocked(tiles, doors, player, ghosts, ghost_count, first_x, first_y) {
    guard_val.x = first_x
  } else {
    let second_x = guard_val.x
    let second_y = guard_val.y + dy
    if dy != 0 && !tile_blocked(tiles, doors, player, ghosts, ghost_count, second_x, second_y) {
      guard_val.y = second_y
    }
  }

  if guard_val.alert_t <= 0 && guard_val.x == target.0 && guard_val.y == target.1 {
    guard_val.to_b = !guard_val.to_b
  }
}

///|
fn player_spotted(guards : Array[Guard], player : Actor, ghosts : Array[Actor], ghost_count : Int, tiles : Array[Int], doors : Array[Door]) -> Bool {
  for guard_val in guards {
    if !guard_val.active {
      continue
    }
    if guard_val.x == player.x && guard_val.y == player.y {
      return true
    }
    if (guard_val.x == player.x || guard_val.y == player.y) &&
      line_clear(tiles, doors, player, ghosts, ghost_count, guard_val.x, guard_val.y, player.x, player.y) {
      return true
    }
  }
  false
}

///|
fn draw_tile(x : Int, y : Int, col : @raylib.Color) -> Unit {
  let (rx, ry, rw, rh) = cell_rect(x, y)
  @raylib.draw_rectangle(rx + 2, ry + 2, rw - 4, rh - 4, col)
}

///|
fn main {
  @raylib.init_window(screen_w, screen_h, "Chrono Heist Blueprint 2026")
  @raylib.set_target_fps(60)
  @draw.init_font()

  let tiles : Array[Int] = Array::make(grid_w * grid_h, tile_empty)
  let guards : Array[Guard] = Array::makei(max_guards, fn(_i) {
    {
      active: false,
      x: 0,
      y: 0,
      ax: 0,
      ay: 0,
      bx: 0,
      by: 0,
      to_b: true,
      alert_x: 0,
      alert_y: 0,
      alert_t: 0,
    }
  })
  let doors : Array[Door] = Array::makei(max_doors, fn(_i) {
    { active: false, x: 0, y: 0, plate_x: 0, plate_y: 0, title: "" }
  })
  let ghosts : Array[Actor] = Array::makei(max_ghosts, fn(_i) { { x: 0, y: 0 } })
  let ghost_actions : Array[Array[Int]] = Array::makei(max_ghosts, fn(_i) {
    Array::makei(loop_len, fn(_j) { action_wait })
  })
  let current_actions : Array[Int] = Array::makei(loop_len, fn(_i) { action_wait })

  let mut level = 1
  let mut title = true
  let mut over = false
  let mut won = false
  let mut level_note = ""
  let mut intro_flash : Float = 0.0

  let player = { x: 1, y: 1 }
  let mut start_x = 1
  let mut start_y = 1
  let mut vault_x = 8
  let mut vault_y = 2
  let mut exit_x = 10
  let mut exit_y = 6
  let mut key_taken = false
  let mut vault_looted = false
  let mut ghost_count = 0
  let mut turn_in_loop = 0
  let mut loop_no = 1
  let mut message = ""

  let reset_level = fn() {
    let setup = setup_level(level, tiles, guards, doors)
    start_x = setup.0
    start_y = setup.1
    vault_x = setup.2
    vault_y = setup.3
    exit_x = setup.4
    exit_y = setup.5
    level_note = setup.6
    player.x = start_x
    player.y = start_y
    key_taken = false
    vault_looted = false
    ghost_count = 0
    turn_in_loop = 0
    loop_no = 1
    message = "Loop 1. Build the route."
    intro_flash = 1.0
    for i in 0..<loop_len {
      current_actions[i] = action_wait
    }
  }

  reset_level()

  while !@raylib.window_should_close() {
    let dt = @raylib.get_frame_time()
    if intro_flash > 0.0 {
      intro_flash = intro_flash - dt
    }

    if title {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        title = false
        over = false
        won = false
        level = 1
        reset_level()
      }
    } else if over {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        title = false
        over = false
        won = false
        level = 1
        reset_level()
      }
      if won && @raylib.is_key_pressed(@raylib.KeyEnter) {
        title = true
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        reset_level()
      }

      let action = if @raylib.is_key_pressed(@raylib.KeyW) || @raylib.is_key_pressed(@raylib.KeyUp) {
        action_up
      } else if @raylib.is_key_pressed(@raylib.KeyS) || @raylib.is_key_pressed(@raylib.KeyDown) {
        action_down
      } else if @raylib.is_key_pressed(@raylib.KeyA) || @raylib.is_key_pressed(@raylib.KeyLeft) {
        action_left
      } else if @raylib.is_key_pressed(@raylib.KeyD) || @raylib.is_key_pressed(@raylib.KeyRight) {
        action_right
      } else if @raylib.is_key_pressed(@raylib.KeySpace) {
        action_wait
      } else {
        -1
      }

      if action >= 0 {
        current_actions[turn_in_loop] = action
        step_actor(player, action, tiles, doors, player, ghosts, ghost_count)

        for i in 0..<ghost_count {
          ghosts[i].x = start_x
          ghosts[i].y = start_y
          for s in 0..=turn_in_loop {
            step_actor(ghosts[i], ghost_actions[i][s], tiles, doors, player, ghosts, ghost_count)
          }
        }

        let player_tile = tiles[idx(player.x, player.y)]
        if player_tile == tile_key && !key_taken {
          key_taken = true
          tiles[idx(player.x, player.y)] = tile_empty
          message = "Blueprint key secured."
        }
        if player.x == vault_x && player.y == vault_y && key_taken {
          vault_looted = true
          tiles[idx(vault_x, vault_y)] = tile_empty
          message = "Vault blueprint copied. Extract now."
        }

        for guard_val in guards {
          step_guard(guard_val, tiles, doors, player, ghosts, ghost_count)
        }

        if player_spotted(guards, player, ghosts, ghost_count, tiles, doors) {
          reset_level()
          message = "Guard lock. Level reset."
        } else if player.x == exit_x && player.y == exit_y && vault_looted {
          if level < 3 {
            level = level + 1
            reset_level()
            message = "Clean escape. Next blueprint cell."
          } else {
            over = true
            won = true
            message = "All three blueprints extracted."
          }
        } else {
          turn_in_loop = turn_in_loop + 1
          if turn_in_loop >= loop_len {
            if ghost_count < max_ghosts {
              for i in 0..<loop_len {
                ghost_actions[ghost_count][i] = current_actions[i]
                current_actions[i] = action_wait
              }
              ghost_count = ghost_count + 1
            }
            loop_no = loop_no + 1
            turn_in_loop = 0
            player.x = start_x
            player.y = start_y
            for i in 0..<ghost_count {
              ghosts[i].x = start_x
              ghosts[i].y = start_y
            }
            message = "Loop \{loop_no}. Past selves replay the breach."
          } else if action == action_wait {
            message = "Waited. Ghost timing can matter."
          } else {
            message = "Turn \{turn_in_loop}/\{loop_len}."
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(12, 18, 28, 255))

    if title {
      @raylib.draw_rectangle_gradient_v(0, 0, screen_w, screen_h, @raylib.Color::new(18, 28, 44, 255), @raylib.Color::new(6, 12, 20, 255))
      @draw.draw_text("CHRONO HEIST BLUEPRINT", 210, 170, 56, @raylib.Color::new(233, 245, 255, 255))
      @draw.draw_text("Top-down time-loop stealth puzzle", 360, 248, 28, @raylib.Color::new(126, 196, 255, 255))
      @draw.draw_text("Each loop records your route. On the next loop, your ghost replays it.", 210, 360, 28, @raylib.Color::new(220, 228, 236, 255))
      @draw.draw_text("Use ghosts to hold plates, lure guards, and chain the vault escape.", 220, 404, 28, @raylib.Color::new(220, 228, 236, 255))
      @draw.draw_text("WASD / Arrows move   Space waits   R restarts", 310, 520, 26, @raylib.Color::new(255, 211, 112, 255))
      @raylib.draw_rectangle(420, 620, 420, 82, @raylib.Color::new(46, 92, 132, 255))
      @draw.draw_text("PRESS ENTER TO BREACH", 458, 648, 30, @raylib.Color::new(245, 250, 255, 255))
    } else {
      @raylib.draw_rectangle(70, 56, 1140, 84, @raylib.Color::new(18, 28, 42, 255))
      @draw.draw_text("Loop \{loop_no}  Turns \{turn_in_loop}/\{loop_len}  Ghosts \{ghost_count}", 98, 82, 28, @raylib.Color::new(236, 243, 248, 255))
      @draw.draw_text("Level \{level}/3", 960, 82, 28, @raylib.Color::new(255, 210, 116, 255))
      @draw.draw_text(level_note, 96, 116, 22, @raylib.Color::new(163, 194, 224, 255))

      for y in 0..<grid_h {
        for x in 0..<grid_w {
          let tile = tiles[idx(x, y)]
          if tile == tile_wall {
            draw_tile(x, y, @raylib.Color::new(46, 58, 74, 255))
          } else {
            draw_tile(x, y, @raylib.Color::new(20, 30, 46, 255))
          }

          if tile == tile_vault {
            draw_tile(x, y, @raylib.Color::new(44, 112, 132, 255))
            @draw.draw_text("V", screen_center_x(x) - 10, screen_center_y(y) - 16, 28, @raylib.Color::new(234, 248, 255, 255))
          } else if tile == tile_exit {
            draw_tile(x, y, @raylib.Color::new(42, 114, 82, 255))
            @draw.draw_text("EX", screen_center_x(x) - 16, screen_center_y(y) - 14, 22, @raylib.Color::new(239, 252, 244, 255))
          } else if tile == tile_key {
            draw_tile(x, y, @raylib.Color::new(118, 94, 24, 255))
            @raylib.draw_circle(screen_center_x(x), screen_center_y(y), 10.0, @raylib.Color::new(255, 218, 110, 255))
          }
        }
      }

      for i, door in doors {
        if !door.active {
          continue
        }
        let open = door_is_open(doors, i, player, ghosts, ghost_count)
        let col = if open {
          @raylib.Color::new(78, 168, 110, 255)
        } else {
          @raylib.Color::new(168, 76, 76, 255)
        }
        draw_tile(door.x, door.y, col)
        draw_tile(door.plate_x, door.plate_y, @raylib.Color::new(176, 140, 62, 255))
        @raylib.draw_circle_lines(screen_center_x(door.plate_x), screen_center_y(door.plate_y), 20.0, @raylib.Color::new(255, 228, 148, 255))
        @draw.draw_text(door.title, board_x + grid_w * cell + 24, board_y + 150 + i * 30, 22, @raylib.Color::new(198, 214, 228, 255))
      }

      for i in 0..<ghost_count {
        @raylib.draw_circle(screen_center_x(ghosts[i].x), screen_center_y(ghosts[i].y), 18.0, @raylib.Color::new(136, 210, 255, 110))
        @raylib.draw_circle_lines(screen_center_x(ghosts[i].x), screen_center_y(ghosts[i].y), 20.0, @raylib.Color::new(188, 232, 255, 170))
      }

      for guard_val in guards {
        if !guard_val.active {
          continue
        }
        let gx = screen_center_x(guard_val.x)
        let gy = screen_center_y(guard_val.y)
        @raylib.draw_circle(gx, gy, 18.0, @raylib.Color::new(236, 92, 92, 255))
        let target = guard_target_cell(guard_val)
        @raylib.draw_line(gx, gy, screen_center_x(target.0), screen_center_y(target.1), @raylib.Color::new(255, 120, 120, 90))
      }

      @raylib.draw_circle(screen_center_x(player.x), screen_center_y(player.y), 18.0, @raylib.Color::new(86, 166, 255, 255))
      @raylib.draw_circle_lines(screen_center_x(player.x), screen_center_y(player.y), 20.0, @raylib.Color::new(240, 246, 255, 255))

      if intro_flash > 0.0 {
        @raylib.draw_rectangle(board_x - 8, board_y - 8, grid_w * cell + 16, grid_h * cell + 16, @raylib.fade(@raylib.Color::new(116, 210, 255, 255), intro_flash * 0.18))
      }

      @raylib.draw_rectangle(70, 748, 1140, 76, @raylib.Color::new(18, 28, 42, 255))
      @draw.draw_text(message, 96, 772, 28, @raylib.Color::new(236, 242, 248, 255))
      @draw.draw_text(if key_taken { "Key secured" } else { "Need vault key" }, 820, 772, 24, if key_taken { @raylib.Color::new(255, 218, 110, 255) } else { @raylib.Color::new(176, 190, 206, 255) })
      @draw.draw_text(if vault_looted { "Blueprint copied" } else { "Vault intact" }, 990, 772, 24, if vault_looted { @raylib.Color::new(130, 230, 178, 255) } else { @raylib.Color::new(176, 190, 206, 255) })

      if over {
        @raylib.draw_rectangle(0, 0, screen_w, screen_h, @raylib.fade(@raylib.black, 0.58))
        @draw.draw_text(if won { "HEIST COMPLETE" } else { "HEIST FAILED" }, 410, 250, 58, if won { @raylib.Color::new(140, 245, 190, 255) } else { @raylib.Color::new(255, 120, 120, 255) })
        @draw.draw_text(message, 360, 340, 32, @raylib.Color::new(238, 244, 248, 255))
        @draw.draw_text("R to restart from level 1   Enter for title", 300, 430, 28, @raylib.Color::new(255, 214, 118, 255))
      }
    }

    @fps.draw()
    @raylib.end_drawing()
  }

  @draw.cleanup()
  @raylib.close_window()
}
