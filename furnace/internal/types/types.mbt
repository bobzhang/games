///|
pub(all) struct Tile {
  mut material : Material
  mut kind : TileKind
  mut temperature : Float
  mut locked : Bool
}

///|
pub(all) struct Grid {
  tiles : Array[Array[Tile]]
  size : Int32
}

///|
pub(all) struct LevelDef {
  id : Int32
  name : String
  tier : Int32
  par_materials : Int32
  par_turns : Int32
  sources : Array[(Int32, Int32, Float)]
  targets : Array[(Int32, Int32, Float, Float)]
  locked_tiles : Array[(Int32, Int32, Material)]
  available_materials : Array[Material]
}

///|
pub(all) struct LevelResult {
  mut stars : StarRating
  mut materials_used : Int32
  mut turns_taken : Int32
  mut all_targets_met : Bool
}

///|
pub(all) struct LevelProgress {
  mut best_stars : StarRating
  mut completed : Bool
}

///|
pub(all) struct Game {
  mut screen : Screen
  grid : Grid
  mut current_level : Int32
  mut tool_mode : ToolMode
  mut sim_turn : Int32
  mut sim_timer : Float
  mut sim_running : Bool
  level_progress : Array[LevelProgress]
  mut result : LevelResult
  mut frame_count : Int32
  mut hover_row : Int32
  mut hover_col : Int32
  mut message : String
  mut message_timer : Float
  mut total_stars : Int32
}
