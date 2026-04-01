///|
pub(all) struct Mapping {
  mut values : Array[Int]
  // 20 entries, one per symbol. -1 = unmapped, 0-19 = letter index (A=0..T=19)
}

///|
pub(all) struct InscriptionSymbol {
  mut symbol : Symbol?
  // None = space/word break
}

///|
pub(all) struct Inscription {
  mut symbols : Array[InscriptionSymbol]
}

///|
pub(all) struct Tablet {
  inscription : Inscription
  solution_mapping : Mapping
  given_mapping : Mapping
  mut theme_name : String
  mut par_guesses : Int
  mut tier : Tier
}

///|
pub(all) struct TabletScore {
  mut solved : Bool
  mut stars : Int
  mut guesses_used : Int
  mut wrong_count : Int
}

///|
pub(all) struct UndoEntry {
  mut symbol_index : Int
  mut old_value : Int
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_tablet_index : Int
  mut current_mapping : Mapping
  mut guesses : Int
  mut wrong_count : Int
  mut selected_symbol : Symbol?
  mut undo_stack : Array[UndoEntry]
  mut scores : Array[TabletScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
  mut hint_symbol : Symbol?
  mut hint_timer : Float
}
