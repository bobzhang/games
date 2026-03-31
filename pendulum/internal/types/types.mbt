///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Vec2f {
  mut x : Float
  mut y : Float
} derive(Eq, Show)

///|
pub(all) struct ArcPoint {
  gx : Int
  gy : Int
  angle : Float
} derive(Eq, Show)

///|
pub(all) struct Rope {
  mut anchor : Vec2i
  mut length : Int
  mut wrapped_pegs : Array[Vec2i]
} derive(Show)

///|
pub(all) struct Weight {
  mut pos : Vec2i
  mut state : WeightState
  mut swing_dir : SwingDir
  mut arc_index : Int
  mut launch_vel : Vec2f
  mut launch_pos : Vec2f
} derive(Show)

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
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut best_ticks : Int
  mut collectibles_got : Int
} derive(Show)

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
} derive(Show)

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
} derive(Show)
