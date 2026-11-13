///|
pub(all) struct Tile {
  mut kind : TileKind
  mut elevation : Int32
  mut has_signal : Bool
  mut signal_anim : Float
}

///|
pub(all) struct SignalPath {
  mut from_col : Int32
  mut from_row : Int32
  mut to_col : Int32
  mut to_row : Int32
  mut progress : Float
  mut active : Bool
}

///|
pub(all) struct LevelData {
  id : Int32
  name : String
  tier : Int32
  par_towers : Int32
  par_chain : Int32
  budget : Int32
  grid : Array[Array[TileKind]]
  elevations : Array[Array[Int32]]
}

///|
pub(all) struct LevelState {
  mut grid : Array[Array[Tile]]
  mut towers_placed : Int32
  mut budget : Int32
  mut all_receivers_lit : Bool
  mut relay_chain_length : Int32
  mut signal_paths : Array[SignalPath]
  mut cursor_col : Int32
  mut cursor_row : Int32
  mut hover_valid : Bool
}

///|
pub(all) struct LevelProgress {
  mut completed : Bool
  mut stars : StarRating
  mut best_towers : Int32
  mut best_chain : Int32
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_level : Int32
  mut level_data : LevelData?
  mut level_state : LevelState?
  mut progress : Array[LevelProgress]
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut scroll_offset : Int32
  mut frame_count : Int32
  mut signal_phase : Float
}
