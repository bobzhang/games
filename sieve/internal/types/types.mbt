///|
pub(all) struct Cell {
  mut value : Int32
  mut locked : Bool
} derive(Eq, Debug)

///|
pub extend Cell with Eq::{not_equal, equal}

///|
pub extend Cell with Debug::{to_repr}

///|
pub(all) struct Grid {
  size : Int32
  cells : Array[Cell]
} derive(Eq, Debug)

///|
pub extend Grid with Eq::{not_equal, equal}

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct Constraint {
  kind : ConstraintKind
  params : Array[Int32]
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
  level_index : Int32
} derive(Eq, Debug)

///|
pub extend Level with Eq::{not_equal, equal}

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut best_time : Float
  mut completed : Bool
} derive(Eq, Debug)

///|
pub extend LevelScore with Eq::{not_equal, equal}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  row : Int32
  col : Int32
  old_value : Int32
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
  mut current_level_index : Int32
  mut current_level : Level?
  mut selected_row : Int32
  mut selected_col : Int32
  mut timer : Float
  mut incorrect_placements : Int32
  mut undo_stack : Array[UndoEntry]
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut checking_timer : Float
  mut tier_scroll : Int32
} derive(Eq, Debug)

///|
pub extend Game with Eq::{not_equal, equal}

///|
pub extend Game with Debug::{to_repr}
