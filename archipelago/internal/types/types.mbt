///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct Island {
  pos : Vec2i
  required_count : Int
} derive(Eq, Debug)

///|
pub extend Island with Eq::{not_equal, equal}

///|
pub extend Island with Debug::{to_repr}

///|
pub(all) struct Bridge {
  island_a : Int
  island_b : Int
  mut count : Int
  direction : BridgeDir
} derive(Eq, Debug)

///|
pub extend Bridge with Eq::{not_equal, equal}

///|
pub extend Bridge with Debug::{to_repr}

///|
pub(all) struct Level {
  grid_size : Int
  islands : Array[Island]
  par_bridges : Int
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_bridges : Int
  mut best_no_removals : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut islands : Array[Island]
  mut bridges : Array[Bridge]
  mut selected_island : Int
  mut removal_count : Int
  mut grid_size : Int
  mut par_bridges : Int
  mut level_scores : Array[LevelScore]
  mut frame_count : Int
  mut hint_island_a : Int
  mut hint_island_b : Int
  mut hint_timer : Float
  mut undo_stack : Array[Array[Bridge]]
  mut message : String
  mut message_timer : Float
  // Per-island satisfaction pulse animation timers (0 = no pulse, >0 = pulsing)
  mut satisfaction_timers : Array[Float]
  // Track previous satisfaction state to detect changes
  mut prev_satisfied : Array[Bool]
}
