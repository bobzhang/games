///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug, Compare, Hash)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub extend Vec2i with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Vec2i with Hash::{hash, hash_combine}

///|
pub(all) struct Grid {
  width : Int32
  height : Int32
  tiles : Array[TileKind]
}

///|
pub(all) struct House {
  pos : Vec2i
  color_id : Int32
  required_area : Int32
}

///|
pub(all) struct FenceEdge {
  row : Int32
  col : Int32
  orient : Orientation
} derive(Eq, Debug)

///|
pub extend FenceEdge with Eq::{not_equal, equal}

///|
pub extend FenceEdge with Debug::{to_repr}

///|
pub(all) struct Region {
  tiles : Array[Vec2i]
  houses : Array[House]
  has_road : Bool
  area : Int32
}

///|
pub(all) struct LevelConstraint {
  must_be_rectangular : Bool
  must_not_touch_water : Bool
}

///|
pub(all) struct LevelDef {
  grid : Grid
  houses : Array[House]
  constraints : LevelConstraint
  par_fences : Int32
  par_length : Int32
  tier : Tier
  name : String
}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut fence_count : Int32
}

///|
pub(all) struct ConstraintStatus {
  house_idx : Int32
  mut one_house : ConstraintResult
  mut correct_area : ConstraintResult
  mut road_access : ConstraintResult
  mut shape_ok : ConstraintResult
}

///|
pub(all) struct UndoEntry {
  fences : Array[FenceEdge]
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level_idx : Int32
  mut current_level : LevelDef?
  mut fences : Array[FenceEdge]
  mut regions : Array[Region]
  mut constraint_status : Array[ConstraintStatus]
  mut undo_stack : Array[UndoEntry]
  mut hover_fence : FenceEdge?
  mut level_scores : Array[LevelScore]
  mut result_stars : Int32
  mut result_fence_count : Int32
  mut frame_count : Int32
  mut transition_timer : Float
  mut message : String
  mut message_timer : Float
}
