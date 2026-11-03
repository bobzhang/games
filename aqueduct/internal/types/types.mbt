///|
#derive(Eq, Debug, Hash, Compare)
pub(all) struct Pos {
  x : Int32
  y : Int32
}

///|
pub extend Pos with Eq::{not_equal, equal}

///|
pub extend Pos with Debug::{to_repr}

///|
pub extend Pos with Hash::{hash, hash_combine}

///|
pub extend Pos with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
#derive(Debug)
pub(all) struct Tile {
  mut kind : TileKind
  elevation : Int32
  mut has_water : Bool
  mut water_level : Int32
  mut connections : Array[Direction]
}

///|
pub extend Tile with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  name : String
  tier : Tier
  grid_cols : Int32
  grid_rows : Int32
  elevations : Array[Int32]
  springs : Array[Pos]
  fountains : Array[Pos]
  reservoirs : Array[Pos]
  dams : Array[(Pos, Direction)]
  par_segments : Int32
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut segments_used : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct UndoEntry {
  pos : Pos
  prev_kind : TileKind
  prev_connections : Array[Direction]
}

///|
pub extend UndoEntry with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut hover_cell : Pos?
  mut selected_tool : TileKind
  levels : Array[Level]
  scores : Array[LevelScore]
  mut grid : Array[Tile]
  mut segments_placed : Int32
  mut undo_stack : Array[UndoEntry]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut sim_timer : Float
  mut sim_step : Int32
  mut fountains_filled : Int32
  mut total_fountains : Int32
  mut anim_timer : Float
  mut water_sources : Array[Pos]
}

///|
pub extend Game with Debug::{to_repr}
