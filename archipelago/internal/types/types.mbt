///|
#derive(Eq, Debug)
pub(all) struct Vec2i {
  x : Int32
  y : Int32
}

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct Island {
  pos : Vec2i
  required_count : Int32
}

///|
pub extend Island with Eq::{not_equal, equal}

///|
pub extend Island with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct Bridge {
  island_a : Int32
  island_b : Int32
  mut count : Int32
  direction : BridgeDir
}

///|
pub extend Bridge with Eq::{not_equal, equal}

///|
pub extend Bridge with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  grid_size : Int32
  islands : Array[Island]
  par_bridges : Int32
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut best_bridges : Int32
  mut best_no_removals : Bool
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut islands : Array[Island]
  mut bridges : Array[Bridge]
  mut selected_island : Int32
  mut removal_count : Int32
  mut grid_size : Int32
  mut par_bridges : Int32
  mut level_scores : Array[LevelScore]
  mut frame_count : Int32
  mut hint_island_a : Int32
  mut hint_island_b : Int32
  mut hint_timer : Float
  mut undo_stack : Array[Array[Bridge]]
  mut message : String
  mut message_timer : Float
  // Per-island satisfaction pulse animation timers (0 = no pulse, >0 = pulsing)
  mut satisfaction_timers : Array[Float]
  // Track previous satisfaction state to detect changes
  mut prev_satisfied : Array[Bool]
}
