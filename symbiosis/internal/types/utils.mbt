///|
pub fn mirror_direction(dir : Direction) -> Direction {
  match dir {
    Left => Right
    Right => Left
    Up => Up
    Down => Down
  }
}

///|
pub fn direction_delta(dir : Direction) -> Vec2i {
  match dir {
    Up => { x: 0, y: -1 }
    Down => { x: 0, y: 1 }
    Left => { x: -1, y: 0 }
    Right => { x: 1, y: 0 }
  }
}

///|
pub fn vec2i_add(a : Vec2i, b : Vec2i) -> Vec2i {
  { x: a.x + b.x, y: a.y + b.y }
}

///|
pub fn in_bounds(pos : Vec2i) -> Bool {
  pos.x >= 0 && pos.x < grid_width && pos.y >= 0 && pos.y < grid_height
}

///|
pub fn tile_at(grid : Array[Array[TileKind]], pos : Vec2i) -> TileKind {
  if in_bounds(pos) {
    grid[pos.y][pos.x]
  } else {
    Wall
  }
}

///|
pub fn is_walkable(tile : TileKind, door_states : Array[Bool]) -> Bool {
  match tile {
    Wall => false
    Door(id) =>
      if id >= 0 && id < door_states.length() {
        door_states[id]
      } else {
        false
      }
    _ => true
  }
}

///|
pub fn new_character(pos : Vec2i) -> Character {
  { pos, on_anchor: false, reached_exit: false, alive: true }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, best_moves: 9999, stars: 0, gem_collected: false }
}

///|
pub fn make_snapshot(game : Game) -> Snapshot {
  let ds : Array[Bool] = Array::new(capacity=game.door_states.length())
  for i in 0..<game.door_states.length() {
    ds.push(game.door_states[i])
  }
  let fg : Array[Bool] = Array::new(capacity=game.floor_gems_collected.length())
  for i in 0..<game.floor_gems_collected.length() {
    fg.push(game.floor_gems_collected[i])
  }
  let cg : Array[Bool] = Array::new(
    capacity=game.ceiling_gems_collected.length(),
  )
  for i in 0..<game.ceiling_gems_collected.length() {
    cg.push(game.ceiling_gems_collected[i])
  }
  {
    luna_pos: game.luna.pos,
    sol_pos: game.sol.pos,
    door_states: ds,
    floor_gems_collected: fg,
    ceiling_gems_collected: cg,
    luna_on_anchor: game.luna.on_anchor,
    sol_on_anchor: game.sol.on_anchor,
    luna_reached_exit: game.luna.reached_exit,
    sol_reached_exit: game.sol.reached_exit,
  }
}

///|
pub fn restore_snapshot(game : Game, snap : Snapshot) -> Unit {
  game.luna.pos = snap.luna_pos
  game.sol.pos = snap.sol_pos
  game.luna.on_anchor = snap.luna_on_anchor
  game.sol.on_anchor = snap.sol_on_anchor
  game.luna.reached_exit = snap.luna_reached_exit
  game.sol.reached_exit = snap.sol_reached_exit
  game.door_states = snap.door_states
  game.floor_gems_collected = snap.floor_gems_collected
  game.ceiling_gems_collected = snap.ceiling_gems_collected
}

///|
pub fn new_game() -> Game {
  let scores : Array[Array[LevelScore]] = []
  for _w in 0..<num_worlds {
    let world_scores : Array[LevelScore] = []
    for _l in 0..<levels_per_world {
      world_scores.push(new_level_score())
    }
    scores.push(world_scores)
  }
  {
    screen: Title,
    selected_world: 0,
    selected_level: 0,
    current_level: None,
    luna: new_character({ x: 0, y: 0 }),
    sol: new_character({ x: 0, y: 0 }),
    door_states: [],
    floor_gems_collected: [],
    ceiling_gems_collected: [],
    move_count: 0,
    play_state: Active,
    history: [],
    scores,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
  }
}

///|
pub fn init_level(game : Game, level : Level) -> Unit {
  game.current_level = Some(level)
  game.luna.pos = level.floor_start
  game.luna.on_anchor = false
  game.luna.reached_exit = false
  game.luna.alive = true
  game.sol.pos = level.ceiling_start
  game.sol.on_anchor = false
  game.sol.reached_exit = false
  game.sol.alive = true
  let ds : Array[Bool] = Array::new(capacity=max_door_ids)
  for _i in 0..<max_door_ids {
    ds.push(false)
  }
  game.door_states = ds
  let fg : Array[Bool] = Array::new(capacity=level.gems.length())
  for _i in 0..<level.gems.length() {
    fg.push(false)
  }
  game.floor_gems_collected = fg
  let cg : Array[Bool] = Array::new(capacity=level.ceiling_gems.length())
  for _i in 0..<level.ceiling_gems.length() {
    cg.push(false)
  }
  game.ceiling_gems_collected = cg
  game.move_count = 0
  game.play_state = Active
  game.history = []
  game.message = ""
  game.message_timer = 0.0
}

///|
pub fn all_floor_gems_collected(game : Game) -> Bool {
  for i in 0..<game.floor_gems_collected.length() {
    if !game.floor_gems_collected[i] {
      return false
    }
  }
  true
}

///|
pub fn all_ceiling_gems_collected(game : Game) -> Bool {
  for i in 0..<game.ceiling_gems_collected.length() {
    if !game.ceiling_gems_collected[i] {
      return false
    }
  }
  true
}

///|
pub fn all_gems_collected(game : Game) -> Bool {
  all_floor_gems_collected(game) && all_ceiling_gems_collected(game)
}

///|
pub fn compute_stars(game : Game) -> Int {
  match game.current_level {
    None => 0
    Some(level) => {
      let mut stars = 1
      if game.move_count <= level.par_moves {
        stars = 2
      }
      if game.move_count <= level.par_moves && all_gems_collected(game) {
        stars = 3
      }
      stars
    }
  }
}

///|
pub fn world_name(w : Int) -> String {
  match w {
    0 => "Mirror"
    1 => "Switches"
    2 => "Anchors"
    3 => "Mastery"
    _ => "Unknown"
  }
}

///|
pub fn is_on_switch(grid : Array[Array[TileKind]], pos : Vec2i) -> Bool {
  match tile_at(grid, pos) {
    Switch(_) => true
    _ => false
  }
}
