///|
pub fn parse_maze(level_def : @types.LevelDef) -> @types.Maze {
  let lines : Array[String] = split_lines(level_def.ascii)
  let height = lines.length()
  let mut width = 0
  for line in lines {
    let len = line.length()
    if len > width {
      width = len
    }
  }
  let tiles : Array[Array[@types.Tile]] = []
  let mut start = @types.vec2i(0, 0)
  let mut exit = @types.vec2i(0, 0)
  let collectible_positions : Array[@types.Vec2i] = []
  let mut button_count = 0
  let mut door_count = 0
  let guard_positions : Array[@types.Vec2i] = []
  // First pass: count buttons, doors, guards
  for y, line in lines {
    for x = 0; x < line.length(); x = x + 1 {
      let ch = line[x]
      match ch {
        'B' => button_count = button_count + 1
        'D' => door_count = door_count + 1
        'T' => door_count = door_count + 1
        'G' => guard_positions.push(@types.vec2i(x, y))
        _ => ()
      }
    }
  }
  // Second pass: build tiles
  let mut cur_button = 0
  let mut cur_door = 0
  // Map timed door durations by door_id
  let timed_durations : Array[(Int, Int)] = level_def.timed_door_durations
  for y, line in lines {
    let row : Array[@types.Tile] = []
    for x = 0; x < width; x = x + 1 {
      let ch = if x < line.length() { line[x] } else { '#' }
      let kind : @types.TileKind = match ch {
        '#' => Wall
        '.' => Floor
        'S' => {
          start = @types.vec2i(x, y)
          Start
        }
        'X' => {
          exit = @types.vec2i(x, y)
          Exit
        }
        'B' => {
          let id = cur_button
          cur_button = cur_button + 1
          Button(id)
        }
        'D' => {
          let id = cur_door
          cur_door = cur_door + 1
          Door(id)
        }
        'T' => {
          let id = cur_door
          cur_door = cur_door + 1
          let dur = find_timed_duration(timed_durations, id)
          TimedDoor(id, dur)
        }
        'G' => {
          // Guard tile is floor underneath
          Floor
        }
        'C' => {
          collectible_positions.push(@types.vec2i(x, y))
          Collectible
        }
        _ => Floor
      }
      row.push({ kind, })
    }
    tiles.push(row)
  }
  // Build guard defs from patrols
  let guard_defs : Array[@types.GuardDef] = []
  for i, patrol in level_def.guard_patrols {
    ignore(i)
    guard_defs.push({ patrol, patrol_index: 0, forward: true })
  }
  {
    width,
    height,
    tiles,
    button_links: level_def.button_links,
    guard_defs,
    start,
    exit,
    collectible_positions,
  }
}

///|
fn find_timed_duration(durations : Array[(Int, Int)], door_id : Int) -> Int {
  for pair in durations {
    if pair.0 == door_id {
      return pair.1
    }
  }
  6 // default duration
}

///|
fn split_lines(s : String) -> Array[String] {
  let lines : Array[String] = []
  let mut start = 0
  for i = 0; i < s.length(); i = i + 1 {
    if s[i] == '\n' {
      lines.push(s[start:i].to_string())
      start = i + 1
    }
  }
  if start < s.length() {
    lines.push(s[start:s.length()].to_string())
  }
  lines
}

///|
pub fn validate_maze(maze : @types.Maze) -> Bool {
  // Check start is accessible (not a wall)
  let st = maze.start
  if st.y < maze.height && st.x < maze.width {
    match maze.tiles[st.y][st.x].kind {
      Start => ()
      _ => return false
    }
  } else {
    return false
  }
  // Check exit is accessible
  let ex = maze.exit
  if ex.y < maze.height && ex.x < maze.width {
    match maze.tiles[ex.y][ex.x].kind {
      Exit => ()
      _ => return false
    }
  } else {
    return false
  }
  true
}
