///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct Branch {
  mut row : Int32
  mut col_offset : Int32
  mut pruned : Bool
} derive(Debug)

///|
pub extend Branch with Debug::{to_repr}

///|
pub(all) struct Tree {
  mut col : Int32
  mut height : Int32
  branches : Array[Branch]
  mut growth_timer : Int32
  mut shadowed : Bool
} derive(Debug)

///|
pub extend Tree with Debug::{to_repr}

///|
pub(all) struct GroundTile {
  mut water : Int32
  mut has_seed : Bool
} derive(Debug)

///|
pub extend GroundTile with Debug::{to_repr}

///|
pub(all) struct Grid {
  width : Int32
  height : Int32
  cells : Array[Array[CellKind]]
} derive(Debug)

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct Target {
  tree_index : Int32
  required_height : Int32
} derive(Debug)

///|
pub extend Target with Debug::{to_repr}

///|
pub(all) struct Level {
  seed_columns : Array[Int32]
  targets : Array[Target]
  turn_limit : Int32
  prune_budget : Int32
  par_prunes : Int32
  par_turns : Int32
  tier : Tier
  water_levels : Array[Int32]
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut turns_used : Int32
  mut prunes_used : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoState {
  trees : Array[Tree]
  turn : Int32
  prunes_used : Int32
  ground : Array[GroundTile]
} derive(Debug)

///|
pub extend UndoState with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut grid : Grid
  mut trees : Array[Tree]
  mut ground : Array[GroundTile]
  mut turn : Int32
  mut prunes_used : Int32
  mut targets : Array[Target]
  mut turn_limit : Int32
  mut prune_budget : Int32
  mut par_prunes : Int32
  mut par_turns : Int32
  mut level_scores : Array[LevelScore]
  mut undo_stack : Array[UndoState]
  mut frame_count : Int32
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut hover_col : Int32
  mut hover_row : Int32
  mut selected_tier : Int32
}
