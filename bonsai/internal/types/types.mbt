///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct TreeCell {
  mut kind : CellKind
  mut growth_dir : GrowthDir
  mut age : Int
  mut stagnant_turns : Int
} derive(Debug)

///|
pub extend TreeCell with Debug::{to_repr}

///|
pub(all) struct TreeGrid {
  width : Int
  height : Int
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
  max_turns : Int
  prune_budget_per_turn : Int
  par_prunes : Int
  tier : Tier
  level_index : Int
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct BranchSeed {
  x : Int
  y : Int
  dir : GrowthDir
} derive(Debug)

///|
pub extend BranchSeed with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct PruneAction {
  pos : Vec2i
  turn : Int
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
  mut turn : Int
  mut prunes_this_turn : Int
  mut total_prunes : Int
  mut history : Array[GridSnapshot]
  mut current_level : Level?
  mut current_tier : Tier
  mut selected_level : Int
  mut play_state : PlayState
  mut show_ghost : Bool
  mut ghost_tree : TreeGrid?
  mut hover_cell : Vec2i?
  mut scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
  mut title_seed_angle : Float
}
