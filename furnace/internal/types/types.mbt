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
  size : Int
}

///|
pub(all) struct LevelDef {
  id : Int
  name : String
  tier : Int
  par_materials : Int
  par_turns : Int
  sources : Array[(Int, Int, Float)]
  targets : Array[(Int, Int, Float, Float)]
  locked_tiles : Array[(Int, Int, Material)]
  available_materials : Array[Material]
}

///|
pub(all) struct LevelResult {
  mut stars : StarRating
  mut materials_used : Int
  mut turns_taken : Int
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
  mut current_level : Int
  mut tool_mode : ToolMode
  mut sim_turn : Int
  mut sim_timer : Float
  mut sim_running : Bool
  level_progress : Array[LevelProgress]
  mut result : LevelResult
  mut frame_count : Int
  mut hover_row : Int
  mut hover_col : Int
  mut message : String
  mut message_timer : Float
  mut total_stars : Int
}
