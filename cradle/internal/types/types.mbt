///|
pub(all) struct Vec2f {
  x : Float
  y : Float
} derive(Eq, Debug)

///|
pub extend Vec2f with Eq::{not_equal, equal}

///|
pub extend Vec2f with Debug::{to_repr}

///|
pub(all) struct Peg {
  index : Int
  pos : Vec2f
} derive(Debug)

///|
pub extend Peg with Debug::{to_repr}

///|
pub(all) struct StringLine {
  peg_a : Int
  peg_b : Int
} derive(Eq, Debug)

///|
pub extend StringLine with Eq::{not_equal, equal}

///|
pub extend StringLine with Debug::{to_repr}

///|
pub(all) struct Intersection {
  pos : Vec2f
  mut matched_target : Int
} derive(Debug)

///|
pub extend Intersection with Debug::{to_repr}

///|
pub(all) struct TargetDot {
  pos : Vec2f
  mut hit : Bool
} derive(Debug)

///|
pub extend TargetDot with Debug::{to_repr}

///|
pub(all) struct Level {
  peg_count : Int
  targets : Array[Vec2f]
  par_strings : Int
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut strings_used : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut selected_tier : Tier
  mut selected_level : Int
  mut current_level : Int
  pegs : Array[Peg]
  mut strings : Array[StringLine]
  mut intersections : Array[Intersection]
  mut targets : Array[TargetDot]
  mut selected_peg : Int
  mut hovered_peg : Int
  mut level_data : Array[Level]
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
}
