///|
pub(all) struct Cell {
  mut kind : CellKind
  mut energy_received : Float
  mut glow_anim : Float
}

///|
pub(all) struct Connection {
  from_col : Int
  from_row : Int
  to_col : Int
  to_row : Int
  mut energy_flow : Float
  mut flow_anim : Float
} derive(Show, Eq)

///|
pub(all) struct LevelDef {
  id : Int
  name : String
  tier : Int
  waystone_budget : Int
  grid : Array[Array[CellKind]]
  par_waystones : Int
  gold_threshold : Float
  silver_threshold : Float
} derive(Show)

///|
pub(all) struct LevelState {
  mut grid : Array[Array[Cell]]
  mut connections : Array[Connection]
  mut waystones_placed : Int
  mut waystone_budget : Int
  mut all_temples_powered : Bool
  mut total_energy_delivered : Float
  mut cursor_col : Int
  mut cursor_row : Int
  mut hover_valid : Bool
  mut draw_start_col : Int
  mut draw_start_row : Int
  mut is_drawing_line : Bool
}

///|
pub(all) struct LevelProgress {
  mut completed : Bool
  mut stars : StarRating
  mut best_waystones : Int
  mut best_energy : Float
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_level : Int
  mut level_def : LevelDef?
  mut level_state : LevelState?
  mut progress : Array[LevelProgress]
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut scroll_offset : Int
  mut frame_count : Int
  mut tool : Tool
  mut energy_phase : Float
}
