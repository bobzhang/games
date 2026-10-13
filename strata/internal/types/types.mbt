///|
pub(all) struct Clue {
  kind : ClueKind
  param_a : Int32
  param_b : Int32
  text : String
  mut satisfied : Bool
} derive(Eq, Debug)

///|
pub extend Clue with Eq::{not_equal, equal}

///|
pub extend Clue with Debug::{to_repr}

///|
pub(all) struct Level {
  tier : Tier
  name : String
  rocks : Array[RockKind]
  clues : Array[Clue]
  par_moves : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut best_moves : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  slots : Array[RockKind?]
  tray : Array[RockKind]
} derive(Debug)

///|
pub extend UndoEntry with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_tier : Tier
  mut current_level : Int32
  mut slots : Array[RockKind?]
  mut tray : Array[RockKind]
  mut play_state : PlayState
  mut moves : Int32
  mut selected_tray : Int32
  mut selected_slot : Int32
  mut any_incorrect : Bool
  mut scores : Array[LevelScore]
  mut undo_stack : Array[UndoEntry]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut anim_timer : Float
  mut tier_page : Int32
}
