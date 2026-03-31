///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Branch {
  mut row : Int
  mut col_offset : Int
  mut pruned : Bool
} derive(Show)

///|
pub(all) struct Tree {
  mut col : Int
  mut height : Int
  branches : Array[Branch]
  mut growth_timer : Int
  mut shadowed : Bool
} derive(Show)

///|
pub(all) struct GroundTile {
  mut water : Int
  mut has_seed : Bool
} derive(Show)

///|
pub(all) struct Grid {
  width : Int
  height : Int
  cells : Array[Array[CellKind]]
} derive(Show)

///|
pub(all) struct Target {
  tree_index : Int
  required_height : Int
} derive(Show)

///|
pub(all) struct Level {
  seed_columns : Array[Int]
  targets : Array[Target]
  turn_limit : Int
  prune_budget : Int
  par_prunes : Int
  par_turns : Int
  tier : Tier
  water_levels : Array[Int]
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut turns_used : Int
  mut prunes_used : Int
} derive(Show)

///|
pub(all) struct UndoState {
  trees : Array[Tree]
  turn : Int
  prunes_used : Int
  ground : Array[GroundTile]
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut grid : Grid
  mut trees : Array[Tree]
  mut ground : Array[GroundTile]
  mut turn : Int
  mut prunes_used : Int
  mut targets : Array[Target]
  mut turn_limit : Int
  mut prune_budget : Int
  mut par_prunes : Int
  mut par_turns : Int
  mut level_scores : Array[LevelScore]
  mut undo_stack : Array[UndoState]
  mut frame_count : Int
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut hover_col : Int
  mut hover_row : Int
  mut selected_tier : Int
}
