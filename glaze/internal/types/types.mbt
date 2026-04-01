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
  max_moves : Int
  par_moves : Int
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut matched_cells : Int
  mut cracked_cells : Int
  mut total_cells : Int
  mut moves_used : Int
}

///|
pub(all) struct UndoEntry {
  row : Int
  col : Int
  prev_glaze : GlazeColor
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut current_level : Level?
  grid : Grid
  mut target_grid : Array[FiredColor]
  mut play_state : PlayState
  mut selected_glaze : GlazeColor
  mut hover_row : Int
  mut hover_col : Int
  mut moves_used : Int
  mut max_moves : Int
  mut score : LevelScore?
  mut level_scores : Array[Int]
  mut undo_stack : Array[UndoEntry]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut fire_timer : Float
  mut fire_phase : Int
  mut title_anim_timer : Float
  mut allowed_glazes : Array[GlazeColor]
}
