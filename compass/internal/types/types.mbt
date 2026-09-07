///|
pub(all) struct Pos {
  x : Int
  y : Int
} derive(Debug, Eq, ToJson, Hash, Compare)

///|
pub extend Pos with Debug::{to_repr}

///|
pub extend Pos with Eq::{not_equal, equal}

///|
pub extend Pos with ToJson::{to_json}

///|
pub extend Pos with Hash::{hash, hash_combine}

///|
pub extend Pos with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub(all) struct LevelData {
  grid : Array[Array[Tile]]
  start : Pos
  lighthouse : Pos
  par_steps : Int
  landmark_count : Int
  tier : Int
} derive(Debug, ToJson)

///|
pub extend LevelData with Debug::{to_repr}

///|
pub extend LevelData with ToJson::{to_json}

///|
pub(all) struct Ship {
  mut pos : Pos
  mut hp : Int
  mut steps : Int
  mut heading : Float
  mut landmarks_found : Int
} derive(Debug, ToJson)

///|
pub extend Ship with Debug::{to_repr}

///|
pub extend Ship with ToJson::{to_json}

///|
pub(all) struct LevelState {
  data : LevelData
  mut revealed : Array[Array[Bool]]
  ship : Ship
  mut phase : GamePhase
  mut message : String
  mut message_timer : Float
  mut compass_beep : Bool
  mut near_land_dir : Direction
} derive(Debug, ToJson)

///|
pub extend LevelState with Debug::{to_repr}

///|
pub extend LevelState with ToJson::{to_json}

///|
pub(all) struct GameState {
  mut current_level : Int
  mut phase : GamePhase
  mut level_state : LevelState?
  mut stars : Array[StarRating]
  mut anim_timer : Float
  mut frame_count : Int
} derive(Debug, ToJson)

///|
pub extend GameState with Debug::{to_repr}

///|
pub extend GameState with ToJson::{to_json}

///|
pub fn new_ship(start : Pos) -> Ship {
  { pos: start, hp: max_hp, steps: 0, heading: 0.0, landmarks_found: 0, }
}

///|
pub fn new_game() -> GameState {
  let stars : Array[StarRating] = Array::make(total_levels, None)
  {
    current_level: 0,
    phase: Menu,
    level_state: None,
    stars,
    anim_timer: 0.0,
    frame_count: 0,
  }
}

///|
pub fn direction_dx(dir : Direction) -> Int {
  match dir {
    North => 0
    South => 0
    East => 1
    West => -1
  }
}

///|
pub fn direction_dy(dir : Direction) -> Int {
  match dir {
    North => -1
    South => 1
    East => 0
    West => 0
  }
}

///|
pub fn direction_name(dir : Direction) -> String {
  match dir {
    North => "N"
    South => "S"
    East => "E"
    West => "W"
  }
}

///|
pub fn heading_to_compass(heading : Float) -> String {
  let pi : Float = Float::from_double(@math.PI)
  let h = if heading < 0.0 { heading + 2.0 * pi } else { heading }
  let eighth = pi / 4.0
  if h < eighth || h >= 7.0 * eighth {
    "N"
  } else if h < 3.0 * eighth {
    "NE"
  } else if h < 5.0 * eighth {
    "E"
  } else if h < 7.0 * eighth {
    "SE"
  } else {
    "S"
  }
}

///|
pub fn compute_bearing(from : Pos, to : Pos) -> Float {
  let dx : Float = Float::from_int(to.x - from.x)
  let dy : Float = Float::from_int(to.y - from.y)
  @math.atan2f(dx, -dy)
}

///|
pub fn bearing_to_degrees(rad : Float) -> Float {
  let deg = rad * 180.0 / Float::from_double(@math.PI)
  if deg < 0.0 {
    deg + 360.0
  } else {
    deg
  }
}

///|
pub fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < grid_cols && y >= 0 && y < grid_rows
}

///|
pub fn star_rating_value(star : StarRating) -> Int {
  match star {
    None => 0
    One => 1
    Two => 2
    Three => 3
  }
}
