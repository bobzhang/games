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
  index : Int32
  pos : Vec2f
} derive(Debug)

///|
pub extend Peg with Debug::{to_repr}

///|
pub(all) struct StringLine {
  peg_a : Int32
  peg_b : Int32
} derive(Eq, Debug)

///|
pub extend StringLine with Eq::{not_equal, equal}

///|
pub extend StringLine with Debug::{to_repr}

///|
pub(all) struct Intersection {
  pos : Vec2f
  mut matched_target : Int32
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
  peg_count : Int32
  targets : Array[Vec2f]
  par_strings : Int32
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut strings_used : Int32
} derive(Debug)

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
