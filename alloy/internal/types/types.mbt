///|
/// Base properties of a metal
pub(all) struct MetalProps {
  hardness : Float
  flexibility : Float
  conductivity : Float
} derive(Show, Eq)

///|
/// An ingredient added to the crucible
pub(all) struct Ingredient {
  metal : MetalKind
  mut amount : Int
} derive(Show)

///|
/// A range for one property in a target alloy
pub(all) struct PropertyRange {
  min : Float
  max : Float
} derive(Show)

///|
/// Target alloy requirements
pub(all) struct TargetAlloy {
  hardness : PropertyRange
  flexibility : PropertyRange
  conductivity : PropertyRange
} derive(Show)

///|
/// Result of blending
pub(all) struct BlendResult {
  hardness : Float
  flexibility : Float
  conductivity : Float
} derive(Show, Eq)

///|
/// A level definition
pub(all) struct LevelDef {
  id : Int
  name : String
  tier : Int
  available_metals : Array[MetalKind]
  target : TargetAlloy
  par_ingredients : Int
  hint : String
} derive(Show)

///|
/// Scoring result
pub(all) struct LevelResult {
  mut stars : StarRating
  mut ingredients_used : Int
  mut blend : BlendResult
  mut all_in_range : Bool
} derive(Show)

///|
/// Progress for a single level
pub(all) struct LevelProgress {
  mut best_stars : StarRating
  mut completed : Bool
} derive(Show)

///|
/// Main game state
pub(all) struct Game {
  mut screen : Screen
  mut current_level : Int
  crucible : Array[Ingredient]
  mut temperature : Temperature
  mut blend_result : BlendResult
  mut blend_timer : Float
  mut blend_animating : Bool
  level_progress : Array[LevelProgress]
  mut result : LevelResult
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut total_stars : Int
  mut hover_metal : Int
  mut hover_button : String
  mut selected_slot : Int
}
