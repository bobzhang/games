///|
pub(all) struct Tile {
  mut weather : WeatherState
  height : Int32
  is_target : Bool
  target_weather : WeatherState
}

///|
pub(all) struct Grid {
  width : Int32
  height : Int32
  tiles : Array[Tile]
}

///|
pub(all) struct Source {
  kind : SourceKind
  mut col : Int32
  mut row : Int32
  wind_dir : WindDir
}

///|
pub(all) struct Level {
  grid_width : Int32
  grid_height : Int32
  heights : Array[Int32]
  targets : Array[(Int32, Int32, WeatherState)]
  source_budget : Array[(SourceKind, Int32)]
  par_sources : Int32
  par_turns : Int32
  tier : Tier
  name : String
}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut sources_used : Int32
  mut turns_taken : Int32
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
  mut current_level : Int32
  mut grid : Grid
  mut placed_sources : Array[Source]
  mut available_sources : Array[(SourceKind, Int32)]
  mut selected_source : Int32
  mut wind_dir : WindDir
  mut turn_count : Int32
  mut cursor_col : Int32
  mut cursor_row : Int32
  mut level_scores : Array[LevelScore]
  mut history : Array[HistoryEntry]
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut stable : Bool
  mut prev_weather : Array[WeatherState]
}
