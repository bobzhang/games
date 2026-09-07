///|
/// Record a gravity rotation move into the move history
pub fn record_gravity_rotate(
  game : @types.Game,
  dir : @types.GravityDir,
) -> Unit {
  let frame : @types.ReplayFrame = {
    direction: dir,
    move_type: 0,
    dx: 0,
    dy: 0,
  }
  game.move_history.push(frame)
}

///|
/// Record a player movement into the move history
pub fn record_player_move(game : @types.Game, dx : Int, dy : Int) -> Unit {
  let frame : @types.ReplayFrame = { direction: Down, move_type: 1, dx, dy, }
  game.move_history.push(frame)
}

///|
/// Called when a level is completed to save the replay as best if fewer moves
pub fn save_best_replay(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let ghost = game.ghost
  if level.moves < ghost.best_moves || ghost.best_moves >= 999 {
    ghost.best_moves = level.moves
    ghost.replay_frames = []
    for i in 0..<game.move_history.length() {
      ghost.replay_frames.push(game.move_history[i])
    }
  }
}

///|
/// Clear move history when starting/restarting a level
pub fn clear_history(game : @types.Game) -> Unit {
  game.move_history = []
}

///|
/// Start ghost replay playback
pub fn start_ghost_replay(game : @types.Game) -> Unit {
  let ghost = game.ghost
  if ghost.replay_frames.length() == 0 {
    return
  }
  ghost.active = true
  ghost.frame_index = 0
  ghost.ghost_timer = 0.0
  // Set initial ghost position to player start
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return
  }
  ghost.ghost_x = player.x
  ghost.ghost_y = player.y
}

///|
/// Stop ghost replay
pub fn stop_ghost_replay(game : @types.Game) -> Unit {
  game.ghost.active = false
  game.ghost.frame_index = 0
}

///|
/// Update ghost replay state each frame
pub fn update_ghost(game : @types.Game, dt : Float) -> Unit {
  let ghost = game.ghost
  if !ghost.active {
    return
  }
  if ghost.frame_index >= ghost.replay_frames.length() {
    ghost.active = false
    return
  }
  ghost.ghost_timer = ghost.ghost_timer + dt
  if ghost.ghost_timer >= @types.ghost_replay_speed {
    ghost.ghost_timer = ghost.ghost_timer - @types.ghost_replay_speed
    let frame = ghost.replay_frames[ghost.frame_index]
    match frame.move_type {
      0 => {
        // Gravity rotation - move ghost in gravity direction
        let (dx, dy) = @types.gravity_vector(frame.direction)
        ghost.ghost_x = ghost.ghost_x + dx
        ghost.ghost_y = ghost.ghost_y + dy
      }
      _ => {
        // Player movement
        ghost.ghost_x = ghost.ghost_x + frame.dx
        ghost.ghost_y = ghost.ghost_y + frame.dy
      }
    }
    ghost.frame_index = ghost.frame_index + 1
  }
}

///|
/// Draw the ghost entity on the grid
pub fn draw_ghost(game : @types.Game) -> Unit {
  let ghost = game.ghost
  if !ghost.active {
    return
  }
  let px = @types.tile_to_pixel_x(ghost.ghost_x) + @types.tile_sizef * 0.5
  let py = @types.tile_to_pixel_y(ghost.ghost_y) + @types.tile_sizef * 0.5
  // Ghost is a semi-transparent pulsing circle
  let pulse_d = @math.sin(game.frame_count.to_double() * 0.15)
  let pulse = Float::from_double(pulse_d.abs()) * 4.0 + 14.0
  let ghost_color = @raylib.Color::new(80, 200, 255, 80)
  @raylib.draw_circle(px.to_int(), py.to_int(), pulse, ghost_color)
  let inner_color = @raylib.Color::new(255, 255, 255, 40)
  @raylib.draw_circle(px.to_int(), py.to_int(), pulse * 0.5, inner_color)
}

///|
/// Draw ghost info in the HUD during replay
pub fn draw_ghost_hud(game : @types.Game) -> Unit {
  let ghost = game.ghost
  if ghost.best_moves < 999 {
    let text = "Best: " + ghost.best_moves.to_string() + " moves"
    @draw.draw_text(text, 660, 10, 16, @raylib.Color::new(180, 180, 255, 200))
  }
  if ghost.active {
    let prog = ghost.frame_index.to_string() +
      "/" +
      ghost.replay_frames.length().to_string()
    @draw.draw_text(
      "Ghost: " + prog,
      660,
      30,
      14,
      @raylib.Color::new(180, 180, 255, 160),
    )
  }
}

///|
/// Encode move history as a compact string for sharing/saving
pub fn encode_replay(game : @types.Game) -> String {
  let buf = StringBuilder()
  for i in 0..<game.move_history.length() {
    let frame = game.move_history[i]
    if i > 0 {
      buf.write_char(',')
    }
    match frame.move_type {
      0 => {
        let c = match frame.direction {
          Down => 'D'
          Up => 'U'
          Left => 'L'
          Right => 'R'
        }
        buf.write_char(c)
      }
      _ => {
        buf.write_char('M')
        buf.write_string(frame.dx.to_string())
        buf.write_char(':')
        buf.write_string(frame.dy.to_string())
      }
    }
  }
  buf.to_string()
}

///|
/// Decode a replay string back into frames
pub fn decode_replay(data : String) -> Array[@types.ReplayFrame] {
  let frames : Array[@types.ReplayFrame] = []
  if data.length() == 0 {
    return frames
  }
  let parts = split_by_comma(data)
  for i in 0..<parts.length() {
    let part = parts[i]
    if part.length() == 0 {
      continue
    }
    let first = part[0]
    let ch = Int::unsafe_to_char(first.to_int())
    match ch {
      'D' => frames.push({ direction: Down, move_type: 0, dx: 0, dy: 0, })
      'U' => frames.push({ direction: Up, move_type: 0, dx: 0, dy: 0, })
      'L' => frames.push({ direction: Left, move_type: 0, dx: 0, dy: 0, })
      'R' => frames.push({ direction: Right, move_type: 0, dx: 0, dy: 0, })
      'M' => {
        // Parse Mdx:dy
        let coords = parse_move_coords(part)
        frames.push({
          direction: Down,
          move_type: 1,
          dx: coords.0,
          dy: coords.1,
        })
      }
      _ => ()
    }
  }
  frames
}

///|
fn split_by_comma(s : String) -> Array[String] {
  let parts : Array[String] = []
  let buf = StringBuilder()
  for i in 0..<s.length() {
    let ch = Int::unsafe_to_char(s[i].to_int())
    if ch == ',' {
      parts.push(buf.to_string())
      buf.reset()
    } else {
      buf.write_char(ch)
    }
  }
  let last = buf.to_string()
  if last.length() > 0 {
    parts.push(last)
  }
  parts
}

///|
fn parse_move_coords(s : String) -> (Int, Int) {
  // Format: Mdx:dy
  let mut colon_pos = -1
  for i in 1..<s.length() {
    let ch = Int::unsafe_to_char(s[i].to_int())
    if ch == ':' {
      colon_pos = i
    }
  }
  if colon_pos < 0 {
    return (0, 0)
  }
  let dx_str = substring(s, 1, colon_pos)
  let dy_str = substring(s, colon_pos + 1, s.length())
  (parse_int_safe(dx_str), parse_int_safe(dy_str))
}

///|
fn substring(s : String, start : Int, end : Int) -> String {
  let buf = StringBuilder()
  for i in start..<end {
    if i < s.length() {
      buf.write_char(Int::unsafe_to_char(s[i].to_int()))
    }
  }
  buf.to_string()
}

///|
fn parse_int_safe(s : String) -> Int {
  let mut result = 0
  let mut negative = false
  for i in 0..<s.length() {
    let ch = Int::unsafe_to_char(s[i].to_int())
    if ch == '-' && i == 0 {
      negative = true
    } else if ch >= '0' && ch <= '9' {
      result = result * 10 + s[i].to_int() - 48
    }
  }
  if negative {
    -result
  } else {
    result
  }
}
