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
  row : Int
  col : Int
  mut alive : Bool
  mut health : Float
} derive(Debug, ToJson)

///|
pub extend OrganismState with Debug::{to_repr}

///|
pub extend OrganismState with ToJson::{to_json}

///|
pub(all) struct LevelDef {
  id : Int
  name : String
  tier : Tier
  description : String
  initial_resources : Resources
  available_organisms : Array[OrganismKind]
  organism_counts : Array[Int]
  par_turns : Int
  locked_cells : Array[(Int, Int)]
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_turns_survived : Int
  mut stars : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct SimTurnLog {
  turn : Int
  events : Array[String]
  resources_after : Resources
  organisms_alive : Int
} derive(Debug)

///|
pub extend SimTurnLog with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_level : Int
  grid : Array[Array[CellContent]]
  mut resources : Resources
  mut organisms : Array[OrganismState]
  mut current_turn : Int
  mut play_result : PlayResult
  mut selected_organism : OrganismKind?
  mut hover_row : Int
  mut hover_col : Int
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut scores : Array[LevelScore]
  mut current_level : LevelDef?
  mut sim_log : Array[SimTurnLog]
  mut sim_speed_timer : Float
  mut organisms_placed : Array[Int]
  mut anim_timer : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
