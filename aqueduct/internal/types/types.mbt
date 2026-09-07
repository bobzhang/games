///|
pub(all) struct Pos {
  x : Int
  y : Int
} derive(Eq, Debug, Hash, Compare)

///|
pub extend Pos with Eq::{not_equal, equal}

///|
pub extend Pos with Debug::{to_repr}

///|
pub extend Pos with Hash::{hash, hash_combine}

///|
pub extend Pos with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub(all) struct Tile {
  mut kind : TileKind
  elevation : Int
  mut has_water : Bool
  mut water_level : Int
  mut connections : Array[Direction]
} derive(Debug)

///|
pub extend Tile with Debug::{to_repr}

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_cols : Int
  grid_rows : Int
  elevations : Array[Int]
  springs : Array[Pos]
  fountains : Array[Pos]
  reservoirs : Array[Pos]
  dams : Array[(Pos, Direction)]
  par_segments : Int
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut segments_used : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  pos : Pos
  prev_kind : TileKind
  prev_connections : Array[Direction]
} derive(Debug)

///|
pub extend UndoEntry with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut hover_cell : Pos?
  mut selected_tool : TileKind
  levels : Array[Level]
  scores : Array[LevelScore]
  mut grid : Array[Tile]
  mut segments_placed : Int
  mut undo_stack : Array[UndoEntry]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut sim_timer : Float
  mut sim_step : Int
  mut fountains_filled : Int
  mut total_fountains : Int
  mut anim_timer : Float
  mut water_sources : Array[Pos]
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
