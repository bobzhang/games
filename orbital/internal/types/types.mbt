///|
#derive(Eq, Debug)
pub(all) struct Vec2f {
  mut x : Float
  mut y : Float
}

///|
pub extend Vec2f with Eq::{not_equal, equal}

///|
pub extend Vec2f with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Planet {
  pos : Vec2f
  mass : Float
  radius : Float
}

///|
pub extend Planet with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Station {
  pos : Vec2f
  radius : Float
}

///|
pub extend Station with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Waypoint {
  pos : Vec2f
  radius : Float
  mut collected : Bool
}

///|
pub extend Waypoint with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Probe {
  mut pos : Vec2f
  mut vel : Vec2f
  mut active : Bool
}

///|
pub extend Probe with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  planets : Array[Planet]
  station : Station
  waypoints : Array[Waypoint]
  launch_pos : Vec2f
  par_ticks : Int32
  name : String
  tier : Tier
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_ticks : Int32
  mut stars : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Star {
  x : Float
  y : Float
  brightness : Int32
  size : Float
}

///|
pub extend Star with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut launch_angle : Float
  probe : Probe
  mut tick_count : Int32
  mut trail : Array[Vec2f]
  mut preview : Array[Vec2f]
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  stars : Array[Star]
  mut message : String
  mut message_timer : Float
}

///|
pub extend Game with Debug::{to_repr}
