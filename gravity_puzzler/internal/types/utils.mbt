///|
pub fn gravity_vector(dir : GravityDir) -> (Int, Int) {
  match dir {
    Down => (0, 1)
    Up => (0, -1)
    Left => (-1, 0)
    Right => (1, 0)
  }
}

///|
pub fn gravity_perp_vectors(dir : GravityDir) -> ((Int, Int), (Int, Int)) {
  match dir {
    Down | Up => ((-1, 0), (1, 0))
    Left | Right => ((0, -1), (0, 1))
  }
}

///|
pub fn rotate_gravity_cw(dir : GravityDir) -> GravityDir {
  match dir {
    Down => Left
    Left => Up
    Up => Right
    Right => Down
  }
}

///|
pub fn rotate_gravity_ccw(dir : GravityDir) -> GravityDir {
  match dir {
    Down => Right
    Right => Up
    Up => Left
    Left => Down
  }
}

///|
pub fn get_tile(level : Level, x : Int, y : Int) -> TileKind {
  if x < 0 || x >= level.width || y < 0 || y >= level.height {
    Wall
  } else {
    level.tiles[y * level.width + x]
  }
}

///|
pub fn set_tile(level : Level, x : Int, y : Int, tile : TileKind) -> Unit {
  if x >= 0 && x < level.width && y >= 0 && y < level.height {
    level.tiles[y * level.width + x] = tile
  }
}

///|
pub fn is_solid(tile : TileKind) -> Bool {
  match tile {
    Wall | Gate(_) => true
    TimedLava => true
    _ => false
  }
}

///|
pub fn gravity_dir_to_angle(dir : GravityDir) -> Float {
  match dir {
    Down => 0.0
    Left => 90.0
    Up => 180.0
    Right => 270.0
  }
}

///|
pub fn mirror_reflect(dir : GravityDir, mirror_id : Int) -> GravityDir {
  // mirror_id 1 = "/" diagonal, mirror_id 2 = "\" diagonal
  match (dir, mirror_id) {
    (Down, 1) => Left
    (Up, 1) => Right
    (Left, 1) => Down
    (Right, 1) => Up
    (Down, 2) => Right
    (Up, 2) => Left
    (Left, 2) => Up
    (Right, 2) => Down
    (_, _) => dir
  }
}

///|
pub fn tile_kind_index(tile : TileKind) -> Int {
  match tile {
    Empty => 0
    Wall => 1
    Exit => 2
    Spike => 3
    Ice => 4
    Portal(_) => 5
    Switch(_) => 7
    Gate(_) => 8
    Crumble => 9
    Conveyor(_) => 10
    PressurePlate(_) => 11
    Mirror(_) => 12
    GravityWell => 13
    TimedLava => 14
    WindGust(_) => 15
  }
}

///|
pub fn tile_from_index(idx : Int) -> TileKind {
  match idx {
    0 => Empty
    1 => Wall
    2 => Exit
    3 => Spike
    4 => Ice
    5 => Portal(1)
    6 => Portal(2)
    7 => Switch(1)
    8 => Gate(1)
    9 => Crumble
    10 => Conveyor(Right)
    11 => PressurePlate(1)
    12 => Mirror(1)
    13 => GravityWell
    14 => TimedLava
    15 => WindGust(Right)
    _ => Empty
  }
}

///|
pub fn entity_kind_from_index(idx : Int) -> EntityKind {
  match idx {
    0 => Player
    1 => Box
    2 => Boulder
    3 => Key
    4 => Gem
    _ => Enemy
  }
}

///|
pub fn is_blocking(level : Level, x : Int, y : Int) -> Bool {
  let tile = get_tile(level, x, y)
  if is_solid(tile) {
    return true
  }
  false
}

///|
pub fn entity_at(level : Level, x : Int, y : Int) -> Entity? {
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && e.x == x && e.y == y {
      return Some(e)
    }
  }
  None
}

///|
pub fn entity_at_except(
  level : Level,
  x : Int,
  y : Int,
  exclude_id : Int
) -> Entity? {
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && e.x == x && e.y == y && e.id != exclude_id {
      return Some(e)
    }
  }
  None
}

///|
pub fn find_player(level : Level) -> Entity? {
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && e.kind == Player {
      return Some(e)
    }
  }
  None
}

///|
pub fn find_enemies(level : Level) -> Array[Entity] {
  let result : Array[Entity] = []
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && e.kind == Enemy {
      result.push(e)
    }
  }
  result
}

///|
pub fn count_active_enemies(level : Level) -> Int {
  let mut count = 0
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && e.kind == Enemy {
      count = count + 1
    }
  }
  count
}

///|
pub fn save_snapshot(level : Level) -> LevelSnapshot {
  let states : Array[(Int, Bool, Int, Int)] = []
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    states.push((e.id, e.active, e.x, e.y))
  }
  let tiles_copy : Array[TileKind] = Array::make(level.tiles.length(), Empty)
  for i in 0..<level.tiles.length() {
    tiles_copy[i] = level.tiles[i]
  }
  {
    gravity: level.gravity,
    moves: level.moves,
    gems_collected: level.gems_collected,
    keys_collected: level.keys_collected,
    entity_states: states,
    tile_states: tiles_copy,
  }
}

///|
pub fn restore_snapshot(level : Level, snap : LevelSnapshot) -> Unit {
  level.gravity = snap.gravity
  level.moves = snap.moves
  level.gems_collected = snap.gems_collected
  level.keys_collected = snap.keys_collected
  for i in 0..<snap.entity_states.length() {
    if i < level.entities.length() {
      let (id, active, x, y) = snap.entity_states[i]
      let e = level.entities[i]
      e.id = id
      e.active = active
      e.x = x
      e.y = y
      e.from_x = x
      e.from_y = y
      e.falling = false
      e.slide_timer = 0.0
    }
  }
  for i in 0..<snap.tile_states.length() {
    if i < level.tiles.length() {
      level.tiles[i] = snap.tile_states[i]
    }
  }
  level.player_dead = false
  level.completed = false
}

///|
pub fn calc_stars(moves : Int, par : Int) -> Int {
  if moves <= par {
    3
  } else if moves <= par + 3 {
    2
  } else if moves <= par + 7 {
    1
  } else {
    0
  }
}

///|
pub fn tile_to_pixel_x(tx : Int) -> Float {
  Float::from_int(grid_offset_x + tx * tile_size)
}

///|
pub fn tile_to_pixel_y(ty : Int) -> Float {
  Float::from_int(grid_offset_y + ty * tile_size)
}

///|
pub fn lerp(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn rand_next(game : Game) -> UInt {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  game.rng_state = x
  x
}

///|
pub fn find_matching_portal(level : Level, id : Int, ex : Int, ey : Int) -> (Int, Int) {
  for y in 0..<level.height {
    for x in 0..<level.width {
      if (x != ex || y != ey) && get_tile(level, x, y) == Portal(id) {
        return (x, y)
      }
    }
  }
  (ex, ey)
}

///|
pub fn count_gates(level : Level, id : Int) -> Int {
  let mut count = 0
  for i in 0..<level.tiles.length() {
    if level.tiles[i] == Gate(id) {
      count = count + 1
    }
  }
  count
}

///|
pub fn toggle_gates(level : Level, id : Int) -> Unit {
  for i in 0..<level.tiles.length() {
    if level.tiles[i] == Gate(id) {
      level.tiles[i] = Empty
    } else if level.tiles[i] == Empty {
      // We don't toggle empty back to gate; switches are one-way open
      ()
    }
  }
}

///|
pub fn open_gates(level : Level, id : Int) -> Unit {
  for i in 0..<level.tiles.length() {
    if level.tiles[i] == Gate(id) {
      level.tiles[i] = Empty
    }
  }
}
