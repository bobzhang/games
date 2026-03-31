///|
pub(all) struct CodonResult {
  trait_ : Trait
  bases : Array[Base]
} derive(Eq, Show)

///|
pub(all) struct ReadResult {
  traits : Array[Trait]
  valid : Bool
} derive(Eq, Show)

///|
pub(all) struct EditOp {
  kind : OpKind
  position : Int
  range_start : Int
  range_end : Int
  insert_base : Base
  removed : Array[Base]
} derive(Eq, Show)

///|
pub(all) struct Level {
  start_sequence : Array[Base]
  target_traits : Array[Trait]
  edit_budget : Int
  par_edits : Int
  min_edits : Int
  available_ops : Array[OpKind]
  name : String
  description : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut best_edits : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_sequence : Array[Base]
  mut original_sequence : Array[Base]
  mut cursor : Int
  mut selection_start : Int
  mut selection_end : Int
  mut edit_count : Int
  mut ops_history : Array[EditOp]
  mut current_tier : Int
  mut current_level : Int
  mut insert_base : Base
  mut selected_op : OpKind
  mut level_scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
  mut show_help : Bool
  mut confirm_verify : Bool
}
