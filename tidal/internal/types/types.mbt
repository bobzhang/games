///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct WaveFront {
  mut amplitude : Float
  mut phase : Int32
  mut direction : Int32 // 0=up,1=right,2=down,3=left, -1=omnidirectional
} derive(Debug)

///|
pub extend WaveFront with Debug::{to_repr}

///|
pub(all) struct WaveTile {
  mut amplitude : Float
  mut phase : Int32
  mut has_wall : Bool
  mut object : TileKind
  // target fields
  mut is_target : Bool
  mut target_min : Float
  mut target_max : Float
  mut target_phase : Int32 // -1 = any
  mut target_satisfied : Bool
  // wave fronts arriving this tick
  mut wave_fronts : Array[WaveFront]
} derive(Debug)

///|
pub extend WaveTile with Debug::{to_repr}

///|
pub(all) struct WaveGrid {
  width : Int32
  height : Int32
  tiles : Array[WaveTile]
} derive(Debug)

///|
pub extend WaveGrid with Debug::{to_repr}

///|
pub(all) struct PlaceableBudget {
  mut kind : PlaceableKind
  mut total : Int32
  mut used : Int32
} derive(Debug)

///|
pub extend PlaceableBudget with Debug::{to_repr}

///|
pub(all) struct Level {
  tier : Int32
  index : Int32 // within tier
  name : String
  grid_template : Array[Int32] // encoded: 0=empty,1=wall,2+=special
  targets : Array[TargetDef]
  pre_placed : Array[PrePlaced]
  budget : Array[PlaceableBudget]
  par_objects : Int32
  par_ticks : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct TargetDef {
  x : Int32
  y : Int32
  min_amp : Float
  max_amp : Float
  phase : Int32 // -1 = any
} derive(Debug)

///|
pub extend TargetDef with Debug::{to_repr}

///|
pub(all) struct PrePlaced {
  x : Int32
  y : Int32
  kind : TileKind
} derive(Debug)

///|
pub extend PrePlaced with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut objects_used : Int32
  mut ticks_used : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut grid : WaveGrid
  mut edit_grid : WaveGrid // snapshot for reset
  mut current_level : Int32 // index into all_levels
  mut current_tier : Int32
  mut play_state : PlayState
  mut sim_tick : Int32
  mut sim_timer : Float
  mut selected_slot : Int32 // index into budget array
  mut cursor_x : Int32
  mut cursor_y : Int32
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut objects_placed : Int32
  mut emitter_phase : Int32 // phase for next emitter placement
  mut message : String
  mut message_timer : Float
  mut sim_speed : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
