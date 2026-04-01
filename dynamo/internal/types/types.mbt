///|
pub(all) struct Cell {
  mut component : ComponentKind
  mut fixed : Bool
  mut powered : Bool
  mut field_lines : Int
  mut wattage : Float
  mut connections : Array[Bool]
}

///|
pub(all) struct FieldLine {
  mut start_col : Int
  mut start_row : Int
  mut end_col : Int
  mut end_row : Int
  mut strength : Float
  mut captured : Bool
}

///|
pub(all) struct LevelDef {
  id : Int
  name : String
  tier : Tier
  description : String
  magnet_budget : Int
  coil_budget : Int
  par_magnets : Int
  fixed_cells : Array[CellPlacement]
}

///|
pub(all) struct CellPlacement {
  col : Int
  row : Int
  component : ComponentKind
  connections : Array[Bool]
}

///|
pub(all) struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut color : @raylib.Color
}

///|
pub(all) struct LevelState {
  mut cells : Array[Array[Cell]]
  mut magnets_used : Int
  mut magnet_budget : Int
  mut coils_used : Int
  mut coil_budget : Int
  mut par_magnets : Int
  mut devices_total : Int
  mut devices_satisfied : Int
  mut field_lines : Array[FieldLine]
  mut total_power : Float
  mut simulated : Bool
}

///|
pub(all) struct LevelResult {
  mut stars : Int
  mut completed : Bool
  mut devices_powered : Int
  mut devices_total : Int
  mut magnets_used : Int
  mut total_watts : Float
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_level : Int
  mut level_state : LevelState?
  mut level_results : Array[LevelResult]
  mut cursor_col : Int
  mut cursor_row : Int
  mut tool : ToolMode
  mut sparks : Array[Spark]
  mut animation_timer : Float
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut level_select_scroll : Int
  mut show_help : Bool
}
