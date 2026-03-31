///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show, Compare, Hash)

///|
pub(all) struct Grid {
  width : Int
  height : Int
  tiles : Array[TileKind]
}

///|
pub(all) struct House {
  pos : Vec2i
  color_id : Int
  required_area : Int
}

///|
pub(all) struct FenceEdge {
  row : Int
  col : Int
  orient : Orientation
} derive(Eq, Show)

///|
pub(all) struct Region {
  tiles : Array[Vec2i]
  houses : Array[House]
  has_road : Bool
  area : Int
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
  par_fences : Int
  par_length : Int
  tier : Tier
  name : String
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut fence_count : Int
}

///|
pub(all) struct ConstraintStatus {
  house_idx : Int
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
  mut current_level_idx : Int
  mut current_level : LevelDef?
  mut fences : Array[FenceEdge]
  mut regions : Array[Region]
  mut constraint_status : Array[ConstraintStatus]
  mut undo_stack : Array[UndoEntry]
  mut hover_fence : FenceEdge?
  mut level_scores : Array[LevelScore]
  mut result_stars : Int
  mut result_fence_count : Int
  mut frame_count : Int
  mut transition_timer : Float
  mut message : String
  mut message_timer : Float
}
