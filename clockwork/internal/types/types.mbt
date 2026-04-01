///|
pub(all) struct Vec2 {
  mut x : Float
  mut y : Float
} derive(Eq, Show)

///|
pub(all) struct Component {
  mut active : Bool
  mut kind : ComponentKind
  mut col : Int
  mut row : Int
  mut rotation : Float
  mut rotation_speed : Float
  mut clockwise : Bool
  mut cam_dir : CamDirection
  mut cam_offset : Float
  mut spring_energy : Float
  mut spring_released : Bool
  mut escapement_phase : Float
  mut escapement_locked : Bool
  mut bell_target_tick : Int
  mut bell_rung : Bool
  mut bell_ring_timer : Float
  mut connected_to : Array[Int]
  mut fixed : Bool
  mut dragging : Bool
} derive(Show)

///|
pub(all) struct Palette {
  mut available : Array[ComponentKind]
  mut counts : Array[Int]
} derive(Show)

///|
pub(all) struct LevelDef {
  mut id : Int
  mut name : String
  mut tier : Tier
  mut fixed_components : Array[Component]
  mut palette : Palette
  mut bell_targets : Array[Int]
  mut par_components : Int
  mut description : String
} derive(Show)

///|
pub(all) struct Simulation {
  mut state : SimState
  mut tick : Int
  mut tick_timer : Float
  mut tick_interval : Float
  mut bells_rung : Array[Int]
  mut bells_order : Array[Int]
  mut total_bells : Int
  mut speed_mult : Float
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut grid : Array[Array[Int]]
  mut components : Array[Component]
  mut selected_palette : Int
  mut dragging_component : Int
  mut hover_col : Int
  mut hover_row : Int
  mut current_level : Int
  mut level_def : LevelDef
  sim : Simulation
  mut level_stars : Array[Int]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut tier_scroll : Int
} derive(Show)
