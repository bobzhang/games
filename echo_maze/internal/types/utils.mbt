///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn vec2i_add(a : Vec2i, b : Vec2i) -> Vec2i {
  { x: a.x + b.x, y: a.y + b.y }
}

///|
pub fn vec2i_eq(a : Vec2i, b : Vec2i) -> Bool {
  a.x == b.x && a.y == b.y
}

///|
pub fn dir_to_delta(dir : Direction) -> Vec2i {
  match dir {
    North => { x: 0, y: -1 }
    South => { x: 0, y: 1 }
    East => { x: 1, y: 0 }
    West => { x: -1, y: 0 }
  }
}

///|
pub fn in_bounds(pos : Vec2i, width : Int, height : Int) -> Bool {
  pos.x >= 0 && pos.x < width && pos.y >= 0 && pos.y < height
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn ghost_color_value(gc : GhostColor) -> @raylib.Color {
  match gc {
    Green => color_ghost_green
    Yellow => color_ghost_yellow
    Orange => color_ghost_orange
  }
}

///|
pub fn ghost_color_for_index(idx : Int) -> GhostColor {
  match idx % 3 {
    0 => Green
    1 => Yellow
    _ => Orange
  }
}

///|
pub fn tile_to_screen_x(gx : Int) -> Int {
  grid_offset_x + gx * tile_size
}

///|
pub fn tile_to_screen_y(gy : Int) -> Int {
  grid_offset_y + gy * tile_size
}

///|
pub fn new_player(start : Vec2i) -> Player {
  { pos: start, dir: South, alive: true }
}

///|
pub fn new_ghost(
  rec : Array[Direction?],
  color : GhostColor,
  start : Vec2i,
) -> Ghost {
  { recording: rec, color, pos: start, active: true, trail_positions: [start] }
}

///|
pub fn new_maze_state(maze : Maze) -> MazeState {
  let door_ids : Array[Int] = []
  for row in maze.tiles {
    for tile in row {
      match tile.kind {
        Door(id) | TimedDoor(id, _) => {
          let mut found = false
          for did in door_ids {
            if did == id {
              found = true
              break
            }
          }
          if !found {
            door_ids.push(id)
          }
        }
        _ => ()
      }
    }
  }
  let door_states : Array[DoorState] = []
  for did in door_ids {
    door_states.push({
      door_id: did,
      open: false,
      timer: 0,
      anim_progress: 0.0,
      prev_open: false,
    })
  }
  let button_pressed : Array[Bool] = Array::make(
    maze.button_links.length(),
    false,
  )
  let guard_states : Array[GuardState] = []
  for gd in maze.guard_defs {
    guard_states.push({
      pos: gd.patrol[0],
      patrol_index: 0,
      forward: true,
      alert: Idle,
      alert_timer: 0.0,
    })
  }
  let collectibles_collected : Array[Bool] = Array::make(
    maze.collectible_positions.length(),
    false,
  )
  { door_states, button_pressed, guard_states, collectibles_collected }
}

///|
pub fn new_level_score() -> LevelScore {
  {
    completed: false,
    best_loops: 99,
    stars: 0,
    collectibles_got: 0,
    collectibles_total: 0,
  }
}

///|
pub fn new_game() -> Game {
  let level_scores : Array[Array[LevelScore]] = []
  for _w in 0..<num_worlds {
    let world_scores : Array[LevelScore] = []
    for _l in 0..<levels_per_world {
      world_scores.push(new_level_score())
    }
    level_scores.push(world_scores)
  }
  {
    screen: Title,
    play_state: Recording,
    current_world: 0,
    current_level: 0,
    maze: None,
    maze_state: None,
    player: { pos: vec2i(0, 0), dir: South, alive: true },
    ghosts: [],
    current_recording: [],
    recordings: [],
    tick: 0,
    max_ticks: max_ticks_per_loop,
    loop_count: 0,
    timeline: [],
    level_scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    tick_timer: 0.0,
    planning_tick: 0,
    selected_world: 0,
    selected_level: 0,
    result_loops: 0,
    result_stars: 0,
    result_collectibles: 0,
    result_total_collectibles: 0,
    restart_flash_timer: 0.0,
    ghost_button_feedback: [],
    planning_paused: false,
    loop_transition_timer: 0.0,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn world_stars(game : Game, world : Int) -> Int {
  let mut total = 0
  if world < game.level_scores.length() {
    let scores = game.level_scores[world]
    for i in 0..<scores.length() {
      total = total + scores[i].stars
    }
  }
  total
}

///|
pub fn is_world_unlocked(game : Game, world : Int) -> Bool {
  if world == 0 {
    return true
  }
  // Need at least 6 stars from previous world to unlock next
  world_stars(game, world - 1) >= 6
}

///|
pub fn manhattan_dist(a : Vec2i, b : Vec2i) -> Int {
  let dx = a.x - b.x
  let dy = a.y - b.y
  (if dx < 0 { -dx } else { dx }) + (if dy < 0 { -dy } else { dy })
}

///|
pub fn update_door_animations(maze_state : MazeState, dt : Float) -> Unit {
  let speed : Float = 5.0
  for ds in maze_state.door_states {
    let target : Float = if ds.open { 1.0 } else { 0.0 }
    if ds.anim_progress < target {
      ds.anim_progress = minf(ds.anim_progress + dt * speed, 1.0)
    } else if ds.anim_progress > target {
      ds.anim_progress = maxf(ds.anim_progress - dt * speed, 0.0)
    }
    ds.prev_open = ds.open
  }
}

///|
pub fn is_level_unlocked(game : Game, world : Int, level : Int) -> Bool {
  if level == 0 {
    return is_world_unlocked(game, world)
  }
  // Previous level must be completed
  if world < game.level_scores.length() &&
    level - 1 < game.level_scores[world].length() {
    return game.level_scores[world][level - 1].completed
  }
  false
}
