///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Island {
  pos : Vec2i
  required_count : Int
} derive(Eq, Show)

///|
pub(all) struct Bridge {
  island_a : Int
  island_b : Int
  mut count : Int
  direction : BridgeDir
} derive(Eq, Show)

///|
pub(all) struct Level {
  grid_size : Int
  islands : Array[Island]
  par_bridges : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_bridges : Int
  mut best_no_removals : Bool
} derive(Show)

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
}
