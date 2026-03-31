///|
pub(all) struct Clue {
  kind : ClueKind
  param_a : Int
  param_b : Int
  text : String
  mut satisfied : Bool
} derive(Eq, Show)

///|
pub(all) struct Level {
  tier : Tier
  name : String
  rocks : Array[RockKind]
  clues : Array[Clue]
  par_moves : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_moves : Int
} derive(Show)

///|
pub(all) struct UndoEntry {
  slots : Array[RockKind?]
  tray : Array[RockKind]
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_tier : Tier
  mut current_level : Int
  mut slots : Array[RockKind?]
  mut tray : Array[RockKind]
  mut play_state : PlayState
  mut moves : Int
  mut selected_tray : Int
  mut selected_slot : Int
  mut any_incorrect : Bool
  mut scores : Array[LevelScore]
  mut undo_stack : Array[UndoEntry]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut anim_timer : Float
  mut tier_page : Int
}
