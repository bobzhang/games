///|
pub(all) struct Cell {
  mut component : ComponentKind
  mut fixed : Bool
  mut powered : Bool
  mut field_lines : Int32
  mut wattage : Float
  mut connections : Array[Bool]
}

///|
pub(all) struct FieldLine {
  mut start_col : Int32
  mut start_row : Int32
  mut end_col : Int32
  mut end_row : Int32
  mut strength : Float
  mut captured : Bool
}

///|
pub(all) struct LevelDef {
  id : Int32
  name : String
  tier : Tier
  description : String
  magnet_budget : Int32
  coil_budget : Int32
  par_magnets : Int32
  fixed_cells : Array[CellPlacement]
}

///|
pub(all) struct CellPlacement {
  col : Int32
  row : Int32
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
  mut magnets_used : Int32
  mut magnet_budget : Int32
  mut coils_used : Int32
  mut coil_budget : Int32
  mut par_magnets : Int32
  mut devices_total : Int32
  mut devices_satisfied : Int32
  mut field_lines : Array[FieldLine]
  mut total_power : Float
  mut simulated : Bool
}

///|
pub(all) struct LevelResult {
  mut stars : Int32
  mut completed : Bool
  mut devices_powered : Int32
  mut devices_total : Int32
  mut magnets_used : Int32
  mut total_watts : Float
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_level : Int32
  mut level_state : LevelState?
  mut level_results : Array[LevelResult]
  mut cursor_col : Int32
  mut cursor_row : Int32
  mut tool : ToolMode
  mut sparks : Array[Spark]
  mut animation_timer : Float
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut level_select_scroll : Int32
  mut show_help : Bool
}
