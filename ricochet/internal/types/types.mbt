///|
pub(all) struct Vec2 {
  mut x : Float
  mut y : Float
} derive(Eq, Debug)

///|
pub extend Vec2 with Eq::{not_equal, equal}

///|
pub extend Vec2 with Debug::{to_repr}

///|
pub(all) struct Ball {
  mut pos : Vec2
  mut vel : Vec2
  mut active : Bool
  mut bounce_count : Int
  trail : Array[Vec2]
}

///|
pub(all) struct Wall {
  p1 : Vec2
  p2 : Vec2
}

///|
pub(all) struct Target {
  pos : Vec2
  radius : Float
  mut hit : Bool
  mut hit_timer : Float
}

///|
pub(all) struct Splitter {
  pos : Vec2
  radius : Float
  mut pulse_timer : Float
}

///|
pub(all) struct Gate {
  p1 : Vec2
  p2 : Vec2
  direction : Vec2
}

///|
pub(all) struct Bumper {
  pos : Vec2
  radius : Float
  mut hit_timer : Float
}

///|
pub(all) struct LevelPickup {
  pos : Vec2
  radius : Float
  mut collected : Bool
}

///|
pub(all) struct Level {
  walls : Array[Wall]
  targets : Array[Target]
  splitters : Array[Splitter]
  gates : Array[Gate]
  bumpers : Array[Bumper]
  pickups : Array[LevelPickup]
  start_pos : Vec2
  par_bounces : Int
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_bounces : Int
}

///|
pub(all) struct PreviewPoint {
  pos : Vec2
  is_bounce : Bool
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut world : Int
  mut level_index : Int
  mut aim_angle : Float
  mut ball_state : BallState
  balls : Array[Ball]
  mut current_level : Level?
  scores : Array[LevelScore]
  mut total_bounces : Int
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut rng : Int
  preview_points : Array[PreviewPoint]
  mut anim_timer : Float
  mut result_timer : Float
  mut title_pulse : Float
}
