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
pub(all) struct Vec2f {
  mut x : Float
  mut y : Float
} derive(Eq, Debug)

///|
pub extend Vec2f with Eq::{not_equal, equal}

///|
pub extend Vec2f with Debug::{to_repr}

///|
pub(all) struct ArcPoint {
  gx : Int
  gy : Int
  angle : Float
} derive(Eq, Debug)

///|
pub extend ArcPoint with Eq::{not_equal, equal}

///|
pub extend ArcPoint with Debug::{to_repr}

///|
pub(all) struct Rope {
  mut anchor : Vec2i
  mut length : Int
  mut wrapped_pegs : Array[Vec2i]
} derive(Debug)

///|
pub extend Rope with Debug::{to_repr}

///|
pub(all) struct Weight {
  mut pos : Vec2i
  mut state : WeightState
  mut swing_dir : SwingDir
  mut arc_index : Int
  mut launch_vel : Vec2f
  mut launch_pos : Vec2f
} derive(Debug)

///|
pub extend Weight with Debug::{to_repr}

///|
pub(all) struct Level {
  id : Int
  tier : Tier
  name : String
  grid : Array[Array[CellKind]]
  anchor_pos : Vec2i
  goal_pos : Vec2i
  pegs : Array[Vec2i]
  walls : Array[Vec2i]
  collectibles : Array[Vec2i]
  par_ticks : Int
  rope_length : Int
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut best_ticks : Int
  mut collectibles_got : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut current_level : Level?
  mut play_state : PlayState
  weight : Weight
  rope : Rope
  mut arc_points : Array[ArcPoint]
  mut tick_count : Int
  mut collected : Array[Bool]
  mut history : Array[HistoryEntry]
  mut scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
  mut title_angle : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}

///|
pub(all) struct HistoryEntry {
  weight_pos : Vec2i
  weight_state : WeightState
  swing_dir : SwingDir
  arc_index : Int
  anchor : Vec2i
  rope_length : Int
  wrapped_pegs : Array[Vec2i]
  tick_count : Int
  collected : Array[Bool]
  launch_vel : Vec2f
  launch_pos : Vec2f
} derive(Debug)

///|
pub extend HistoryEntry with Debug::{to_repr}
