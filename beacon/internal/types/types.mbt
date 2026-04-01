///|
pub(all) struct Tile {
  mut kind : TileKind
  mut elevation : Int
  mut has_signal : Bool
  mut signal_anim : Float
}

///|
pub(all) struct SignalPath {
  mut from_col : Int
  mut from_row : Int
  mut to_col : Int
  mut to_row : Int
  mut progress : Float
  mut active : Bool
}

///|
pub(all) struct LevelData {
  id : Int
  name : String
  tier : Int
  par_towers : Int
  par_chain : Int
  budget : Int
  grid : Array[Array[TileKind]]
  elevations : Array[Array[Int]]
}

///|
pub(all) struct LevelState {
  mut grid : Array[Array[Tile]]
  mut towers_placed : Int
  mut budget : Int
  mut all_receivers_lit : Bool
  mut relay_chain_length : Int
  mut signal_paths : Array[SignalPath]
  mut cursor_col : Int
  mut cursor_row : Int
  mut hover_valid : Bool
}

///|
pub(all) struct LevelProgress {
  mut completed : Bool
  mut stars : StarRating
  mut best_towers : Int
  mut best_chain : Int
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_level : Int
  mut level_data : LevelData?
  mut level_state : LevelState?
  mut progress : Array[LevelProgress]
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut scroll_offset : Int
  mut frame_count : Int
  mut signal_phase : Float
}
