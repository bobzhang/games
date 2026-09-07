///|
pub(all) struct Vec2f {
  mut x : Float
  mut y : Float
} derive(Eq, Debug)

///|
pub extend Vec2f with Eq::{not_equal, equal}

///|
pub extend Vec2f with Debug::{to_repr}

///|
pub(all) struct Planet {
  pos : Vec2f
  mass : Float
  radius : Float
} derive(Debug)

///|
pub extend Planet with Debug::{to_repr}

///|
pub(all) struct Station {
  pos : Vec2f
  radius : Float
} derive(Debug)

///|
pub extend Station with Debug::{to_repr}

///|
pub(all) struct Waypoint {
  pos : Vec2f
  radius : Float
  mut collected : Bool
} derive(Debug)

///|
pub extend Waypoint with Debug::{to_repr}

///|
pub(all) struct Probe {
  mut pos : Vec2f
  mut vel : Vec2f
  mut active : Bool
} derive(Debug)

///|
pub extend Probe with Debug::{to_repr}

///|
pub(all) struct Level {
  planets : Array[Planet]
  station : Station
  waypoints : Array[Waypoint]
  launch_pos : Vec2f
  par_ticks : Int
  name : String
  tier : Tier
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_ticks : Int
  mut stars : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Star {
  x : Float
  y : Float
  brightness : Int
  size : Float
} derive(Debug)

///|
pub extend Star with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut launch_angle : Float
  probe : Probe
  mut tick_count : Int
  mut trail : Array[Vec2f]
  mut preview : Array[Vec2f]
  mut scores : Array[LevelScore]
  mut frame_count : Int
  stars : Array[Star]
  mut message : String
  mut message_timer : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
