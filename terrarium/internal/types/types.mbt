///|
pub(all) struct Resources {
  mut o2 : Float
  mut co2 : Float
  mut water : Float
  mut nutrients : Float
} derive(Debug, ToJson)

///|
pub extend Resources with Debug::{to_repr}

///|
pub extend Resources with ToJson::{to_json}

///|
pub(all) struct OrganismState {
  kind : OrganismKind
  row : Int32
  col : Int32
  mut alive : Bool
  mut health : Float
} derive(Debug, ToJson)

///|
pub extend OrganismState with Debug::{to_repr}

///|
pub extend OrganismState with ToJson::{to_json}

///|
pub(all) struct LevelDef {
  id : Int32
  name : String
  tier : Tier
  description : String
  initial_resources : Resources
  available_organisms : Array[OrganismKind]
  organism_counts : Array[Int32]
  par_turns : Int32
  locked_cells : Array[(Int32, Int32)]
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_turns_survived : Int32
  mut stars : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct SimTurnLog {
  turn : Int32
  events : Array[String]
  resources_after : Resources
  organisms_alive : Int32
} derive(Debug)

///|
pub extend SimTurnLog with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_level : Int32
  grid : Array[Array[CellContent]]
  mut resources : Resources
  mut organisms : Array[OrganismState]
  mut current_turn : Int32
  mut play_result : PlayResult
  mut selected_organism : OrganismKind?
  mut hover_row : Int32
  mut hover_col : Int32
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut scores : Array[LevelScore]
  mut current_level : LevelDef?
  mut sim_log : Array[SimTurnLog]
  mut sim_speed_timer : Float
  mut organisms_placed : Array[Int32]
  mut anim_timer : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
