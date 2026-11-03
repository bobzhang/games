///|
#derive(Eq, Debug)
pub(all) struct Vec2i {
  x : Int32
  y : Int32
}

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct Sensor {
  pos : Vec2i
  kind : SensorKind
  direction : CompassDir
}

///|
pub extend Sensor with Eq::{not_equal, equal}

///|
pub extend Sensor with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct SensorReading {
  center : Vec2i
  min_dist : Float
  max_dist : Float
  direction : CompassDir
  angle : Float
  kind : SensorKind
}

///|
pub extend SensorReading with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Epicenter {
  pos : Vec2i
  mut found : Bool
}

///|
pub extend Epicenter with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct TileInfo {
  kind : TileKind
}

///|
pub extend TileInfo with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  grid : Array[Array[TileInfo]]
  epicenters : Array[Epicenter]
  sensor_budget : Int32
  par_budget : Int32
  par_guesses : Int32
  tier : Tier
  towns : Array[Vec2i]
  level_index : Int32
  name : String
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut best_budget_used : Int32
  mut best_guesses : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level_index : Int32
  mut level : Level?
  mut sensors : Array[Sensor]
  mut readings : Array[SensorReading]
  mut selected_sensor : SensorKind
  mut selected_direction : CompassDir
  mut budget_used : Int32
  mut guess_pos : Vec2i?
  mut guess_count : Int32
  mut sensor_place_count : Int32
  mut hover_tile : Vec2i?
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut level_scores : Array[LevelScore]
  mut anim_timer : Float
  mut show_overlap : Bool
  mut rng : Int32
}
