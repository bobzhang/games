///|
pub(all) struct OrganismState {
  kind : OrganismKind
  row : Int
  col : Int
  mut alive : Bool
  mut health : Float
  mut submerged : Bool
} derive(Show, ToJson)

///|
pub(all) struct LevelDef {
  id : Int
  name : String
  tier : Tier
  description : String
  depth_profile : Array[Int]
  available_organisms : Array[OrganismKind]
  organism_counts : Array[Int]
  target_species : Array[OrganismKind]
  rock_cells : Array[(Int, Int)]
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_cycles_survived : Int
  mut stars : Int
} derive(Show)

///|
pub(all) struct TurnLog {
  turn : Int
  tide_level : Int
  phase : TidePhase
  events : Array[String]
  organisms_alive : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_level : Int
  grid : Array[Array[CellContent]]
  mut organisms : Array[OrganismState]
  mut current_turn : Int
  mut current_cycle : Int
  mut tide_level : Int
  mut tide_phase : TidePhase
  mut play_result : PlayResult
  mut selected_organism : OrganismKind?
  mut hover_row : Int
  mut hover_col : Int
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut scores : Array[LevelScore]
  mut current_level : LevelDef?
  mut sim_log : Array[TurnLog]
  mut sim_speed_timer : Float
  mut organisms_placed : Array[Int]
  mut anim_timer : Float
} derive(Show)
