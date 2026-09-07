///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Debug, Compare)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub extend Vec2i with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub(all) struct Shape {
  mut cells : Array[Vec2i]
} derive(Debug)

///|
pub extend Shape with Debug::{to_repr}

///|
pub(all) struct Level {
  initial_shape : Shape
  target_shape : Shape
  par_cost : Int
  min_cost : Int
  available_ops : Array[OpKind]
  tier : Tier
  name : String
}

///|
pub(all) struct OpRecord {
  kind : OpKind
  cost : Int
}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_cost : Int
  mut stars : StarRating
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_shape : Shape
  mut target_shape : Shape
  mut ops_history : Array[OpRecord]
  mut shape_history : Array[Shape]
  mut total_cost : Int
  mut play_state : PlayState
  mut selected_op : OpKind?
  mut current_level_idx : Int
  mut current_tier : Tier
  mut level_scores : Array[LevelScore]
  mut hover_cell : Vec2i?
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
  mut anim_shape_before : Shape?
}
