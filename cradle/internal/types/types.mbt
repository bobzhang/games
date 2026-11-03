///|
#derive(Eq, Debug)
pub(all) struct Vec2f {
  x : Float
  y : Float
}

///|
pub extend Vec2f with Eq::{not_equal, equal}

///|
pub extend Vec2f with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Peg {
  index : Int32
  pos : Vec2f
}

///|
pub extend Peg with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct StringLine {
  peg_a : Int32
  peg_b : Int32
}

///|
pub extend StringLine with Eq::{not_equal, equal}

///|
pub extend StringLine with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Intersection {
  pos : Vec2f
  mut matched_target : Int32
}

///|
pub extend Intersection with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct TargetDot {
  pos : Vec2f
  mut hit : Bool
}

///|
pub extend TargetDot with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  peg_count : Int32
  targets : Array[Vec2f]
  par_strings : Int32
  tier : Tier
  name : String
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut strings_used : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut selected_tier : Tier
  mut selected_level : Int32
  mut current_level : Int32
  pegs : Array[Peg]
  mut strings : Array[StringLine]
  mut intersections : Array[Intersection]
  mut targets : Array[TargetDot]
  mut selected_peg : Int32
  mut hovered_peg : Int32
  mut level_data : Array[Level]
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
}
