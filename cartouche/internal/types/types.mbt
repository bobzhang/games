///|
pub(all) struct Mapping {
  mut values : Array[Int32]
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
  mut par_guesses : Int32
  mut tier : Tier
}

///|
pub(all) struct TabletScore {
  mut solved : Bool
  mut stars : Int32
  mut guesses_used : Int32
  mut wrong_count : Int32
}

///|
pub(all) struct UndoEntry {
  mut symbol_index : Int32
  mut old_value : Int32
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_tablet_index : Int32
  mut current_mapping : Mapping
  mut guesses : Int32
  mut wrong_count : Int32
  mut selected_symbol : Symbol?
  mut undo_stack : Array[UndoEntry]
  mut scores : Array[TabletScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut anim_timer : Float
  mut hint_symbol : Symbol?
  mut hint_timer : Float
}
