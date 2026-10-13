///|
pub(all) struct Patch {
  edges : Array[EdgePattern]
  wildcard_edges : Array[Bool]
  pinned : Bool
} derive(Eq, Debug)

///|
pub extend Patch with Eq::{not_equal, equal}

///|
pub extend Patch with Debug::{to_repr}

///|
pub(all) struct Board {
  size : Int32
  cells : Array[Patch?]
} derive(Debug)

///|
pub extend Board with Debug::{to_repr}

///|
pub(all) struct Level {
  board_size : Int32
  patches : Array[Patch]
  pinned_positions : Array[Int32]
  pinned_patches : Array[Patch]
  par_rotations : Int32
  par_swaps : Int32
  tier : Tier
  level_num : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut best_rotations : Int32
  mut best_swaps : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut board : Board
  mut tray : Array[Patch]
  mut selected_tray : Int32
  mut selected_board : Int32
  mut play_state : PlayState
  mut rotations : Int32
  mut swaps : Int32
  mut current_level : Int32
  mut current_tier : Tier
  mut level_scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut daily_seed : Int32
  mut is_daily : Bool
  mut daily_score : LevelScore
  mut anim_timer : Float
  mut tier_select_index : Int32
}
