///|
pub(all) struct HexCoord {
  col : Int
  row : Int
} derive(Eq, Show)

///|
pub(all) struct HexTile {
  mut biome : BiomeKind
  locked : Bool
} derive(Eq, Show)

///|
pub(all) struct HexGrid {
  width : Int
  height : Int
  tiles : Array[HexTile]
  wraps_horizontal : Bool
} derive(Show)

///|
pub(all) struct PaintBudget {
  mut forest : Int
  mut ocean : Int
  mut desert : Int
} derive(Show)

///|
pub(all) struct TargetRatio {
  forest_min : Float
  forest_max : Float
  ocean_min : Float
  ocean_max : Float
  desert_min : Float
  desert_max : Float
} derive(Show)

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
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_turns : Int
} derive(Show)

///|
pub(all) struct UndoEntry {
  col : Int
  row : Int
  prev_biome : BiomeKind
  biome_used : BiomeKind
} derive(Show)

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
} derive(Show)
