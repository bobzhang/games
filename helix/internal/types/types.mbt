///|
pub(all) struct Cell {
  kind : CellKind
  mut gate_open : Bool
  switch_link_id : Int32
  arrow_offset : Int32
  has_pickup : Bool
} derive(Eq, Debug)

///|
pub extend Cell with Eq::{not_equal, equal}

///|
pub extend Cell with Debug::{to_repr}

///|
pub(all) struct Spiral {
  cells : Array[Cell]
} derive(Eq, Debug)

///|
pub extend Spiral with Eq::{not_equal, equal}

///|
pub extend Spiral with Debug::{to_repr}

///|
pub(all) struct SwitchLink {
  switch_cell_cw : Int32
  switch_cell_ccw : Int32
  gate_cells_cw : Array[Int32]
  gate_cells_ccw : Array[Int32]
} derive(Eq, Debug)

///|
pub extend SwitchLink with Eq::{not_equal, equal}

///|
pub extend SwitchLink with Debug::{to_repr}

///|
pub(all) struct Level {
  cw_spiral : Spiral
  ccw_spiral : Spiral
  switch_links : Array[SwitchLink]
  par_steps : Int32
  pickups_total : Int32
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut steps : Int32
  mut stars : Int32
  mut pickups : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct HistoryEntry {
  cw_pos : Int32
  ccw_pos : Int32
  gate_states_cw : Array[Bool]
  gate_states_ccw : Array[Bool]
  oneshot_used : Array[Bool]
  pickups_collected : Array[Bool]
  pickups_count : Int32
} derive(Debug)

///|
pub extend HistoryEntry with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
  mut cw_pos : Int32
  mut ccw_pos : Int32
  mut steps : Int32
  mut play_state : PlayState
  mut pickups_collected : Array[Bool]
  mut pickups_count : Int32
  mut oneshot_used : Array[Bool]
  mut current_level : Level?
  mut history : Array[HistoryEntry]
  mut level_scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut anim_timer : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
