///|
pub(all) struct Cell {
  mut value : Int
  mut locked : Bool
} derive(Eq, Debug)

///|
pub extend Cell with Eq::{not_equal, equal}

///|
pub extend Cell with Debug::{to_repr}

///|
pub(all) struct Grid {
  size : Int
  cells : Array[Cell]
} derive(Eq, Debug)

///|
pub extend Grid with Eq::{not_equal, equal}

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct Constraint {
  kind : ConstraintKind
  params : Array[Int]
  mut satisfied : Bool
} derive(Eq, Debug)

///|
pub extend Constraint with Eq::{not_equal, equal}

///|
pub extend Constraint with Debug::{to_repr}

///|
pub(all) struct Level {
  tier : Tier
  grid : Grid
  constraints : Array[Constraint]
  par_time : Float
  level_index : Int
} derive(Eq, Debug)

///|
pub extend Level with Eq::{not_equal, equal}

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut best_time : Float
  mut completed : Bool
} derive(Eq, Debug)

///|
pub extend LevelScore with Eq::{not_equal, equal}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  row : Int
  col : Int
  old_value : Int
} derive(Eq, Debug)

///|
pub extend UndoEntry with Eq::{not_equal, equal}

///|
pub extend UndoEntry with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level_index : Int
  mut current_level : Level?
  mut selected_row : Int
  mut selected_col : Int
  mut timer : Float
  mut incorrect_placements : Int
  mut undo_stack : Array[UndoEntry]
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut checking_timer : Float
  mut tier_scroll : Int
} derive(Eq, Debug)

///|
pub extend Game with Eq::{not_equal, equal}

///|
pub extend Game with Debug::{to_repr}
