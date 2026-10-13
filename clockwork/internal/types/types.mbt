///|
pub(all) struct Vec2 {
  mut x : Float
  mut y : Float
} derive(Eq, Debug)

///|
pub extend Vec2 with Eq::{not_equal, equal}

///|
pub extend Vec2 with Debug::{to_repr}

///|
pub(all) struct Component {
  mut active : Bool
  mut kind : ComponentKind
  mut col : Int32
  mut row : Int32
  mut rotation : Float
  mut rotation_speed : Float
  mut clockwise : Bool
  mut cam_dir : CamDirection
  mut cam_offset : Float
  mut spring_energy : Float
  mut spring_released : Bool
  mut escapement_phase : Float
  mut escapement_locked : Bool
  mut bell_target_tick : Int32
  mut bell_rung : Bool
  mut bell_ring_timer : Float
  mut connected_to : Array[Int32]
  mut fixed : Bool
  mut dragging : Bool
} derive(Debug)

///|
pub extend Component with Debug::{to_repr}

///|
pub(all) struct Palette {
  mut available : Array[ComponentKind]
  mut counts : Array[Int32]
} derive(Debug)

///|
pub extend Palette with Debug::{to_repr}

///|
pub(all) struct LevelDef {
  mut id : Int32
  mut name : String
  mut tier : Tier
  mut fixed_components : Array[Component]
  mut palette : Palette
  mut bell_targets : Array[Int32]
  mut par_components : Int32
  mut description : String
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct Simulation {
  mut state : SimState
  mut tick : Int32
  mut tick_timer : Float
  mut tick_interval : Float
  mut bells_rung : Array[Int32]
  mut bells_order : Array[Int32]
  mut total_bells : Int32
  mut speed_mult : Float
} derive(Debug)

///|
pub extend Simulation with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut grid : Array[Array[Int32]]
  mut components : Array[Component]
  mut selected_palette : Int32
  mut dragging_component : Int32
  mut hover_col : Int32
  mut hover_row : Int32
  mut current_level : Int32
  mut level_def : LevelDef
  sim : Simulation
  mut level_stars : Array[Int32]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut tier_scroll : Int32
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
