///|
pub(all) struct NoteCell {
  mut has_note : Bool
  mut is_target : Bool
  mut is_locked : Bool
} derive(Debug)

///|
pub extend NoteCell with Debug::{to_repr}

///|
pub(all) struct Grid {
  cols : Int32
  rows : Int32
  cells : Array[Array[NoteCell]]
} derive(Debug)

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct TargetPos {
  col : Int32
  row : Int32
} derive(Eq, Debug)

///|
pub extend TargetPos with Eq::{not_equal, equal}

///|
pub extend TargetPos with Debug::{to_repr}

///|
pub(all) struct Level {
  id : Int32
  name : String
  tier : Tier
  grid_cols : Int32
  grid_rows : Int32
  targets : Array[TargetPos]
  note_budget : Int32
  harmony_threshold_2star : Int32
  harmony_threshold_3star : Int32
}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut harmony_score : Int32
  mut targets_matched : Int32
  mut total_targets : Int32
  mut completed : Bool
}

///|
pub(all) struct UndoEntry {
  col : Int32
  row : Int32
  was_note : Bool
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
  mut grid : Grid
  mut current_level : Level
  mut playback_col : Int32
  mut play_state : PlayState
  mut play_timer : Float
  mut harmony_score : Int32
  mut notes_placed : Int32
  mut targets_matched : Int32
  mut stars : Int32
  mut level_scores : Array[LevelScore]
  mut undo_stack : Array[UndoEntry]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut anim_timer : Float
}
