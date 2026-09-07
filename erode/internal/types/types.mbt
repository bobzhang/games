///|
pub(all) struct Grid {
  size : Int
  cells : Array[Bool]
} derive(Eq, Debug)

///|
pub extend Grid with Eq::{not_equal, equal}

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct ForceBudget {
  mut water : Int
  mut wind : Int
  mut frost : Int
  mut heat : Int
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
  par_forces : Int
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut forces_used : Int
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
  matching : Int
  over_eroded : Int
  under_eroded : Int
  total_target_empty : Int
  total_target_solid : Int
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
  mut current_level : Int
  mut current_tier : Tier
  mut play_state : PlayState
  mut forces_used : Int
  mut par_forces : Int
  mut level_scores : Array[LevelScore]
  mut preview_cells : Array[Bool]
  mut anim_timer : Float
  mut selected_force : ForceKind
  mut frame_count : Int
}
