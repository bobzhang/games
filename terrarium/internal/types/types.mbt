///|
pub(all) struct Resources {
  mut o2 : Float
  mut co2 : Float
  mut water : Float
  mut nutrients : Float
} derive(Show, ToJson)

///|
pub(all) struct OrganismState {
  kind : OrganismKind
  row : Int
  col : Int
  mut alive : Bool
  mut health : Float
} derive(Show, ToJson)

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
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_turns_survived : Int
  mut stars : Int
} derive(Show)

///|
pub(all) struct SimTurnLog {
  turn : Int
  events : Array[String]
  resources_after : Resources
  organisms_alive : Int
} derive(Show)

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
} derive(Show)
