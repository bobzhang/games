///|
pub(all) struct Cell {
  mut glaze : GlazeColor
  mut fired : FiredColor
}

///|
pub(all) struct Grid {
  cells : Array[Cell]
}

///|
pub(all) struct Level {
  tier : Tier
  name : String
  target : Array[FiredColor]
  allowed_glazes : Array[GlazeColor]
  max_moves : Int32
  par_moves : Int32
}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut matched_cells : Int32
  mut cracked_cells : Int32
  mut total_cells : Int32
  mut moves_used : Int32
}

///|
pub(all) struct UndoEntry {
  row : Int32
  col : Int32
  prev_glaze : GlazeColor
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
  mut current_level : Level?
  grid : Grid
  mut target_grid : Array[FiredColor]
  mut play_state : PlayState
  mut selected_glaze : GlazeColor
  mut hover_row : Int32
  mut hover_col : Int32
  mut moves_used : Int32
  mut max_moves : Int32
  mut score : LevelScore?
  mut level_scores : Array[Int32]
  mut undo_stack : Array[UndoEntry]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut fire_timer : Float
  mut fire_phase : Int32
  mut title_anim_timer : Float
  mut allowed_glazes : Array[GlazeColor]
}
