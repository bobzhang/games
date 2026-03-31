///|
pub(all) struct Cell {
  kind : CellKind
  mut gate_open : Bool
  switch_link_id : Int
  arrow_offset : Int
  has_pickup : Bool
} derive(Eq, Show)

///|
pub(all) struct Spiral {
  cells : Array[Cell]
} derive(Eq, Show)

///|
pub(all) struct SwitchLink {
  switch_cell_cw : Int
  switch_cell_ccw : Int
  gate_cells_cw : Array[Int]
  gate_cells_ccw : Array[Int]
} derive(Eq, Show)

///|
pub(all) struct Level {
  cw_spiral : Spiral
  ccw_spiral : Spiral
  switch_links : Array[SwitchLink]
  par_steps : Int
  pickups_total : Int
  name : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut steps : Int
  mut stars : Int
  mut pickups : Int
} derive(Show)

///|
pub(all) struct HistoryEntry {
  cw_pos : Int
  ccw_pos : Int
  gate_states_cw : Array[Bool]
  gate_states_ccw : Array[Bool]
  oneshot_used : Array[Bool]
  pickups_collected : Array[Bool]
  pickups_count : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut cw_pos : Int
  mut ccw_pos : Int
  mut steps : Int
  mut play_state : PlayState
  mut pickups_collected : Array[Bool]
  mut pickups_count : Int
  mut oneshot_used : Array[Bool]
  mut current_level : Level?
  mut history : Array[HistoryEntry]
  mut level_scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
} derive(Show)
