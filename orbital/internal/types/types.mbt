///|
pub(all) struct Vec2f {
  mut x : Float
  mut y : Float
} derive(Eq, Show)

///|
pub(all) struct Planet {
  pos : Vec2f
  mass : Float
  radius : Float
} derive(Show)

///|
pub(all) struct Station {
  pos : Vec2f
  radius : Float
} derive(Show)

///|
pub(all) struct Waypoint {
  pos : Vec2f
  radius : Float
  mut collected : Bool
} derive(Show)

///|
pub(all) struct Probe {
  mut pos : Vec2f
  mut vel : Vec2f
  mut active : Bool
} derive(Show)

///|
pub(all) struct Level {
  planets : Array[Planet]
  station : Station
  waypoints : Array[Waypoint]
  launch_pos : Vec2f
  par_ticks : Int
  name : String
  tier : Tier
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_ticks : Int
  mut stars : Int
} derive(Show)

///|
pub(all) struct Star {
  x : Float
  y : Float
  brightness : Int
  size : Float
} derive(Show)

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
} derive(Show)
