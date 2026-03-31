///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Placement {
  pos : Vec2i
  feature : FeatureKind
} derive(Eq, Show)

///|
pub(all) struct Clue {
  kind : ClueKind
  feature_a : FeatureKind
  feature_b : FeatureKind
  distance : Int
  direction : CompassDir
  row_col : Int
  count : Int
  text : String
  mut status : ClueStatus
} derive(Show)

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_size : Int
  features_to_place : Array[FeatureKind]
  clues : Array[Clue]
  par_placements : Int
  description : String
}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut best_placements : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut grid : Array[FeatureKind?]
  mut placements : Array[Placement]
  mut incorrect_count : Int
  mut total_placements : Int
  mut selected_feature : FeatureKind?
  mut current_level : Int
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
  mut frame_count : Int
}
