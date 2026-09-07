///|
pub(all) struct Point {
  mut x : Float
  mut y : Float
} derive(Eq, Debug)

///|
pub extend Point with Eq::{not_equal, equal}

///|
pub extend Point with Debug::{to_repr}

///|
pub(all) struct Polygon {
  vertices : Array[Point]
} derive(Debug)

///|
pub extend Polygon with Debug::{to_repr}

///|
pub(all) struct Level {
  target_polygon : Polygon
  pre_placed_points : Array[Point]
  par_points : Int
  min_points : Int
  tier : Tier
  name : String
}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut points_used : Int
}

///|
pub(all) struct UndoEntry {
  points : Array[Point]
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut selected_tier : Tier
  mut selected_level : Int
  mut placed_points : Array[Point]
  mut current_hull : Array[Point]
  mut target : Polygon
  mut match_pct : Float
  mut hull_matches : Bool
  mut level_index : Int
  mut undo_stack : Array[UndoEntry]
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut snap_preview : Point?
  mut hover_remove : Int
}
