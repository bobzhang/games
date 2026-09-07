///|
pub(all) struct HexCoord {
  col : Int
  row : Int
} derive(Eq, Debug)

///|
pub extend HexCoord with Eq::{not_equal, equal}

///|
pub extend HexCoord with Debug::{to_repr}

///|
pub(all) struct HexTile {
  mut biome : BiomeKind
  locked : Bool
} derive(Eq, Debug)

///|
pub extend HexTile with Eq::{not_equal, equal}

///|
pub extend HexTile with Debug::{to_repr}

///|
pub(all) struct HexGrid {
  width : Int
  height : Int
  tiles : Array[HexTile]
  wraps_horizontal : Bool
} derive(Debug)

///|
pub extend HexGrid with Debug::{to_repr}

///|
pub(all) struct PaintBudget {
  mut forest : Int
  mut ocean : Int
  mut desert : Int
} derive(Debug)

///|
pub extend PaintBudget with Debug::{to_repr}

///|
pub(all) struct TargetRatio {
  forest_min : Float
  forest_max : Float
  ocean_min : Float
  ocean_max : Float
  desert_min : Float
  desert_max : Float
} derive(Debug)

///|
pub extend TargetRatio with Debug::{to_repr}

///|
pub(all) struct Level {
  tier : Tier
  tier_index : Int
  width : Int
  height : Int
  starting_tiles : Array[(Int, Int, BiomeKind, Bool)]
  budget : PaintBudget
  targets : TargetRatio
  par_turns : Int
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_turns : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  col : Int
  row : Int
  prev_biome : BiomeKind
  biome_used : BiomeKind
} derive(Debug)

///|
pub extend UndoEntry with Debug::{to_repr}

///|
/// Full grid snapshot for undoing ecosystem resolution steps.
pub(all) struct ResolveSnapshot {
  biomes : Array[BiomeKind]
  budget_forest : Int
  budget_ocean : Int
  budget_desert : Int
  turn : Int
} derive(Debug)

///|
pub extend ResolveSnapshot with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut grid : HexGrid
  mut budget : PaintBudget
  mut targets : TargetRatio
  mut par_turns : Int
  mut current_turn : Int
  mut selected_biome : BiomeKind
  mut hover_col : Int
  mut hover_row : Int
  mut current_level : Int
  mut current_tier : Tier
  mut tier_page : Int
  mut level_scores : Array[LevelScore]
  mut undo_stack : Array[UndoEntry]
  mut resolve_timer : Float
  mut resolve_step : Int
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut prev_snapshot : Array[BiomeKind]
  mut changed_tiles : Array[Bool]
  // Ecosystem undo stack: snapshots taken before each resolve cycle
  mut resolve_undo_stack : Array[ResolveSnapshot]
  // Spread animation: tiles animate one-by-one during resolve
  mut spread_queue : Array[Int]
  mut spread_index : Int
  mut spread_timer : Float
  // Preview overlay: show which tiles will change before committing
  mut show_preview : Bool
  mut preview_tiles : Array[(Int, BiomeKind)]
  // Transition indicators: track recently changed tiles for fade effect
  mut transition_tiles : Array[Int]
  mut transition_timer : Float
  // Target ratio pulse feedback
  mut ratio_pulse_timer : Float
  mut ratio_just_entered : Array[Bool]
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
