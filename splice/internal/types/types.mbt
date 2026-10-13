///|
pub(all) struct CodonResult {
  trait_ : Trait
  bases : Array[Base]
} derive(Eq, Debug)

///|
pub extend CodonResult with Eq::{not_equal, equal}

///|
pub extend CodonResult with Debug::{to_repr}

///|
pub(all) struct ReadResult {
  traits : Array[Trait]
  valid : Bool
} derive(Eq, Debug)

///|
pub extend ReadResult with Eq::{not_equal, equal}

///|
pub extend ReadResult with Debug::{to_repr}

///|
pub(all) struct EditOp {
  kind : OpKind
  position : Int32
  range_start : Int32
  range_end : Int32
  insert_base : Base
  removed : Array[Base]
} derive(Eq, Debug)

///|
pub extend EditOp with Eq::{not_equal, equal}

///|
pub extend EditOp with Debug::{to_repr}

///|
pub(all) struct Level {
  start_sequence : Array[Base]
  target_traits : Array[Trait]
  edit_budget : Int32
  par_edits : Int32
  min_edits : Int32
  available_ops : Array[OpKind]
  name : String
  description : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut best_edits : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_sequence : Array[Base]
  mut original_sequence : Array[Base]
  mut cursor : Int32
  mut selection_start : Int32
  mut selection_end : Int32
  mut edit_count : Int32
  mut ops_history : Array[EditOp]
  mut current_tier : Int32
  mut current_level : Int32
  mut insert_base : Base
  mut selected_op : OpKind
  mut level_scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut anim_timer : Float
  mut show_help : Bool
  mut confirm_verify : Bool
}
