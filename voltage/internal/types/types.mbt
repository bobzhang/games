///|
pub(all) struct Cell {
  mut component : ComponentKind
  mut fixed : Bool
  mut powered : Bool
  mut voltage : Float
  mut current : Float
  mut connections : Array[Bool]
}

///|
pub(all) struct LevelDef {
  id : Int32
  name : String
  tier : Tier
  description : String
  battery_budget : Int32
  par_batteries : Int32
  fixed_cells : Array[CellPlacement]
  fuse_budget : Int32
  switch_budget : Int32
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
  mut batteries_used : Int32
  mut battery_budget : Int32
  mut fuses_used : Int32
  mut fuse_budget : Int32
  mut switches_used : Int32
  mut switch_budget : Int32
  mut par_batteries : Int32
  mut devices_total : Int32
  mut devices_satisfied : Int32
  mut any_fuse_blown : Bool
  mut simulated : Bool
}

///|
pub(all) struct LevelResult {
  mut stars : Int32
  mut completed : Bool
  mut devices_powered : Int32
  mut devices_total : Int32
  mut batteries_used : Int32
  mut fuses_blown : Int32
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
