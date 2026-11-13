///|
#derive(Eq, Debug)
pub(all) struct Vec2i {
  x : Int32
  y : Int32
}

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct Placement {
  pos : Vec2i
  feature : FeatureKind
}

///|
pub extend Placement with Eq::{not_equal, equal}

///|
pub extend Placement with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Clue {
  kind : ClueKind
  feature_a : FeatureKind
  feature_b : FeatureKind
  distance : Int32
  direction : CompassDir
  row_col : Int32
  count : Int32
  text : String
  mut status : ClueStatus
}

///|
pub extend Clue with Debug::{to_repr}

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_size : Int32
  features_to_place : Array[FeatureKind]
  clues : Array[Clue]
  par_placements : Int32
  description : String
}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut best_placements : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut grid : Array[FeatureKind?]
  mut placements : Array[Placement]
  mut incorrect_count : Int32
  mut total_placements : Int32
  mut selected_feature : FeatureKind?
  mut current_level : Int32
  mut current_tier : Tier
  mut levels : Array[Level]
  mut scores : Array[LevelScore]
  mut hover_cell : Vec2i?
  mut play_state : PlayState
  mut message : String
  mut message_timer : Float
  mut anim_timer : Float
  mut hint_cells : Array[Vec2i]
  mut show_hints : Bool
  mut frame_count : Int32
  // Graduated hints
  mut hint_level : HintLevel
  mut hint_narrow_cells : Array[Vec2i]
  mut hint_reveal_cell : Vec2i?
  mut hint_feature : FeatureKind?
  // Clue highlighting
  mut hover_clue_index : Int32
  mut highlighted_cells : Array[Vec2i]
  mut highlighted_clue_indices : Array[Int32]
  // Visual feedback
  mut flash_timer : Float
  mut flash_cell : Vec2i?
  mut flash_is_error : Bool
  mut clue_anim_indices : Array[Int32]
  mut clue_anim_timer : Float
  // Parchment texture noise seed
  mut parchment_seed : Int32
}
