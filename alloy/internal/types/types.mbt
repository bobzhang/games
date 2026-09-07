///|
/// Base properties of a metal
pub(all) struct MetalProps {
  hardness : Float
  flexibility : Float
  conductivity : Float
} derive(Debug, Eq)

///|
pub extend MetalProps with Debug::{to_repr}

///|
pub extend MetalProps with Eq::{not_equal, equal}

///|
/// An ingredient added to the crucible
pub(all) struct Ingredient {
  metal : MetalKind
  mut amount : Int
} derive(Debug)

///|
pub extend Ingredient with Debug::{to_repr}

///|
/// A range for one property in a target alloy
pub(all) struct PropertyRange {
  min : Float
  max : Float
} derive(Debug)

///|
pub extend PropertyRange with Debug::{to_repr}

///|
/// Target alloy requirements
pub(all) struct TargetAlloy {
  hardness : PropertyRange
  flexibility : PropertyRange
  conductivity : PropertyRange
} derive(Debug)

///|
pub extend TargetAlloy with Debug::{to_repr}

///|
/// Result of blending
pub(all) struct BlendResult {
  hardness : Float
  flexibility : Float
  conductivity : Float
} derive(Debug, Eq)

///|
pub extend BlendResult with Debug::{to_repr}

///|
pub extend BlendResult with Eq::{not_equal, equal}

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
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
/// Scoring result
pub(all) struct LevelResult {
  mut stars : StarRating
  mut ingredients_used : Int
  mut blend : BlendResult
  mut all_in_range : Bool
} derive(Debug)

///|
pub extend LevelResult with Debug::{to_repr}

///|
/// Progress for a single level
pub(all) struct LevelProgress {
  mut best_stars : StarRating
  mut completed : Bool
} derive(Debug)

///|
pub extend LevelProgress with Debug::{to_repr}

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
