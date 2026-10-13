///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct TreeCell {
  mut kind : CellKind
  mut growth_dir : GrowthDir
  mut age : Int32
  mut stagnant_turns : Int32
} derive(Debug)

///|
pub extend TreeCell with Debug::{to_repr}

///|
pub(all) struct TreeGrid {
  width : Int32
  height : Int32
  cells : Array[TreeCell]
} derive(Debug)

///|
pub extend TreeGrid with Debug::{to_repr}

///|
pub(all) struct Zone {
  positions : Array[Vec2i]
  kind : ZoneKind
} derive(Debug)

///|
pub extend Zone with Debug::{to_repr}

///|
pub(all) struct Level {
  species : Species
  initial_branches : Array[BranchSeed]
  zones : Array[Zone]
  max_turns : Int32
  prune_budget_per_turn : Int32
  par_prunes : Int32
  tier : Tier
  level_index : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct BranchSeed {
  x : Int32
  y : Int32
  dir : GrowthDir
} derive(Debug)

///|
pub extend BranchSeed with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct PruneAction {
  pos : Vec2i
  turn : Int32
} derive(Debug)

///|
pub extend PruneAction with Debug::{to_repr}

///|
pub(all) struct GridSnapshot {
  cells : Array[TreeCell]
} derive(Debug)

///|
pub extend GridSnapshot with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut tree : TreeGrid
  mut turn : Int32
  mut prunes_this_turn : Int32
  mut total_prunes : Int32
  mut history : Array[GridSnapshot]
  mut current_level : Level?
  mut current_tier : Tier
  mut selected_level : Int32
  mut play_state : PlayState
  mut show_ghost : Bool
  mut ghost_tree : TreeGrid?
  mut hover_cell : Vec2i?
  mut scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut anim_timer : Float
  mut title_seed_angle : Float
}
