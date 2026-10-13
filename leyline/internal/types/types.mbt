///|
pub(all) struct Cell {
  mut kind : CellKind
  mut energy_received : Float
  mut glow_anim : Float
}

///|
pub(all) struct Connection {
  from_col : Int32
  from_row : Int32
  to_col : Int32
  to_row : Int32
  mut energy_flow : Float
  mut flow_anim : Float
} derive(Debug, Eq)

///|
pub extend Connection with Debug::{to_repr}

///|
pub extend Connection with Eq::{not_equal, equal}

///|
pub(all) struct LevelDef {
  id : Int32
  name : String
  tier : Int32
  waystone_budget : Int32
  grid : Array[Array[CellKind]]
  par_waystones : Int32
  gold_threshold : Float
  silver_threshold : Float
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct LevelState {
  mut grid : Array[Array[Cell]]
  mut connections : Array[Connection]
  mut waystones_placed : Int32
  mut waystone_budget : Int32
  mut all_temples_powered : Bool
  mut total_energy_delivered : Float
  mut cursor_col : Int32
  mut cursor_row : Int32
  mut hover_valid : Bool
  mut draw_start_col : Int32
  mut draw_start_row : Int32
  mut is_drawing_line : Bool
}

///|
pub(all) struct LevelProgress {
  mut completed : Bool
  mut stars : StarRating
  mut best_waystones : Int32
  mut best_energy : Float
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_level : Int32
  mut level_def : LevelDef?
  mut level_state : LevelState?
  mut progress : Array[LevelProgress]
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut scroll_offset : Int32
  mut frame_count : Int32
  mut tool : Tool
  mut energy_phase : Float
}
