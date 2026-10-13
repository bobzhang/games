///|
pub(all) struct Grid {
  size : Int32
  cells : Array[Bool]
} derive(Eq, Debug)

///|
pub extend Grid with Eq::{not_equal, equal}

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct ForceBudget {
  mut water : Int32
  mut wind : Int32
  mut frost : Int32
  mut heat : Int32
} derive(Eq, Debug)

///|
pub extend ForceBudget with Eq::{not_equal, equal}

///|
pub extend ForceBudget with Debug::{to_repr}

///|
pub(all) struct Level {
  tier : Tier
  name : String
  initial_block : Grid
  target_shape : Grid
  budget : ForceBudget
  par_forces : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut forces_used : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct ForceAction {
  kind : ForceKind
} derive(Debug)

///|
pub extend ForceAction with Debug::{to_repr}

///|
pub(all) struct MatchResult {
  matching : Int32
  over_eroded : Int32
  under_eroded : Int32
  total_target_empty : Int32
  total_target_solid : Int32
} derive(Debug)

///|
pub extend MatchResult with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut grid : Grid
  mut target : Grid
  mut budget : ForceBudget
  mut history : Array[Grid]
  mut current_level : Int32
  mut current_tier : Tier
  mut play_state : PlayState
  mut forces_used : Int32
  mut par_forces : Int32
  mut level_scores : Array[LevelScore]
  mut preview_cells : Array[Bool]
  mut anim_timer : Float
  mut selected_force : ForceKind
  mut frame_count : Int32
}
