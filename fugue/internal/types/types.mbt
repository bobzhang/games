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
  cols : Int
  rows : Int
  cells : Array[Array[NoteCell]]
} derive(Debug)

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct TargetPos {
  col : Int
  row : Int
} derive(Eq, Debug)

///|
pub extend TargetPos with Eq::{not_equal, equal}

///|
pub extend TargetPos with Debug::{to_repr}

///|
pub(all) struct Level {
  id : Int
  name : String
  tier : Tier
  grid_cols : Int
  grid_rows : Int
  targets : Array[TargetPos]
  note_budget : Int
  harmony_threshold_2star : Int
  harmony_threshold_3star : Int
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut harmony_score : Int
  mut targets_matched : Int
  mut total_targets : Int
  mut completed : Bool
}

///|
pub(all) struct UndoEntry {
  col : Int
  row : Int
  was_note : Bool
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut grid : Grid
  mut current_level : Level
  mut playback_col : Int
  mut play_state : PlayState
  mut play_timer : Float
  mut harmony_score : Int
  mut notes_placed : Int
  mut targets_matched : Int
  mut stars : Int
  mut level_scores : Array[LevelScore]
  mut undo_stack : Array[UndoEntry]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
}
