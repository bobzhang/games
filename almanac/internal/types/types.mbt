///|
pub(all) struct Tile {
  mut weather : WeatherState
  height : Int
  is_target : Bool
  target_weather : WeatherState
}

///|
pub(all) struct Grid {
  width : Int
  height : Int
  tiles : Array[Tile]
}

///|
pub(all) struct Source {
  kind : SourceKind
  mut col : Int
  mut row : Int
  wind_dir : WindDir
}

///|
pub(all) struct Level {
  grid_width : Int
  grid_height : Int
  heights : Array[Int]
  targets : Array[(Int, Int, WeatherState)]
  source_budget : Array[(SourceKind, Int)]
  par_sources : Int
  par_turns : Int
  tier : Tier
  name : String
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut sources_used : Int
  mut turns_taken : Int
}

///|
pub(all) struct HistoryEntry {
  tiles : Array[WeatherState]
  sources : Array[Source]
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut grid : Grid
  mut placed_sources : Array[Source]
  mut available_sources : Array[(SourceKind, Int)]
  mut selected_source : Int
  mut wind_dir : WindDir
  mut turn_count : Int
  mut cursor_col : Int
  mut cursor_row : Int
  mut level_scores : Array[LevelScore]
  mut history : Array[HistoryEntry]
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut stable : Bool
  mut prev_weather : Array[WeatherState]
}
