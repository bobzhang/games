///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct WaveFront {
  mut amplitude : Float
  mut phase : Int
  mut direction : Int // 0=up,1=right,2=down,3=left, -1=omnidirectional
} derive(Show)

///|
pub(all) struct WaveTile {
  mut amplitude : Float
  mut phase : Int
  mut has_wall : Bool
  mut object : TileKind
  // target fields
  mut is_target : Bool
  mut target_min : Float
  mut target_max : Float
  mut target_phase : Int // -1 = any
  mut target_satisfied : Bool
  // wave fronts arriving this tick
  mut wave_fronts : Array[WaveFront]
} derive(Show)

///|
pub(all) struct WaveGrid {
  width : Int
  height : Int
  tiles : Array[WaveTile]
} derive(Show)

///|
pub(all) struct PlaceableBudget {
  mut kind : PlaceableKind
  mut total : Int
  mut used : Int
} derive(Show)

///|
pub(all) struct Level {
  tier : Int
  index : Int // within tier
  name : String
  grid_template : Array[Int] // encoded: 0=empty,1=wall,2+=special
  targets : Array[TargetDef]
  pre_placed : Array[PrePlaced]
  budget : Array[PlaceableBudget]
  par_objects : Int
  par_ticks : Int
} derive(Show)

///|
pub(all) struct TargetDef {
  x : Int
  y : Int
  min_amp : Float
  max_amp : Float
  phase : Int // -1 = any
} derive(Show)

///|
pub(all) struct PrePlaced {
  x : Int
  y : Int
  kind : TileKind
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut objects_used : Int
  mut ticks_used : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut grid : WaveGrid
  mut edit_grid : WaveGrid // snapshot for reset
  mut current_level : Int // index into all_levels
  mut current_tier : Int
  mut play_state : PlayState
  mut sim_tick : Int
  mut sim_timer : Float
  mut selected_slot : Int // index into budget array
  mut cursor_x : Int
  mut cursor_y : Int
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut objects_placed : Int
  mut emitter_phase : Int // phase for next emitter placement
  mut message : String
  mut message_timer : Float
  mut sim_speed : Float
} derive(Show)
