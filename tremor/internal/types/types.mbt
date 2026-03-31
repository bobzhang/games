///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Sensor {
  pos : Vec2i
  kind : SensorKind
  direction : CompassDir
} derive(Eq, Show)

///|
pub(all) struct SensorReading {
  center : Vec2i
  min_dist : Float
  max_dist : Float
  direction : CompassDir
  angle : Float
  kind : SensorKind
} derive(Show)

///|
pub(all) struct Epicenter {
  pos : Vec2i
  mut found : Bool
} derive(Show)

///|
pub(all) struct TileInfo {
  kind : TileKind
} derive(Show)

///|
pub(all) struct Level {
  grid : Array[Array[TileInfo]]
  epicenters : Array[Epicenter]
  sensor_budget : Int
  par_budget : Int
  par_guesses : Int
  tier : Tier
  towns : Array[Vec2i]
  level_index : Int
  name : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_budget_used : Int
  mut best_guesses : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level_index : Int
  mut level : Level?
  mut sensors : Array[Sensor]
  mut readings : Array[SensorReading]
  mut selected_sensor : SensorKind
  mut selected_direction : CompassDir
  mut budget_used : Int
  mut guess_pos : Vec2i?
  mut guess_count : Int
  mut sensor_place_count : Int
  mut hover_tile : Vec2i?
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut level_scores : Array[LevelScore]
  mut anim_timer : Float
  mut show_overlap : Bool
  mut rng : Int
}
