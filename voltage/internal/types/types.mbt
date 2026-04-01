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
  id : Int
  name : String
  tier : Tier
  description : String
  battery_budget : Int
  par_batteries : Int
  fixed_cells : Array[CellPlacement]
  fuse_budget : Int
  switch_budget : Int
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
  mut batteries_used : Int
  mut battery_budget : Int
  mut fuses_used : Int
  mut fuse_budget : Int
  mut switches_used : Int
  mut switch_budget : Int
  mut par_batteries : Int
  mut devices_total : Int
  mut devices_satisfied : Int
  mut any_fuse_blown : Bool
  mut simulated : Bool
}

///|
pub(all) struct LevelResult {
  mut stars : Int
  mut completed : Bool
  mut devices_powered : Int
  mut devices_total : Int
  mut batteries_used : Int
  mut fuses_blown : Int
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
