///|
pub(all) struct Reaction {
  input_element : Element
  current_substance : Element
  result : ReactionResult
} derive(Eq, Debug)

///|
pub extend Reaction with Eq::{not_equal, equal}

///|
pub extend Reaction with Debug::{to_repr}

///|
pub(all) struct Recipe {
  mut discovered : Bool
  input : Element
  substance : Element
  output : ReactionResult
} derive(Eq, Debug)

///|
pub extend Recipe with Eq::{not_equal, equal}

///|
pub extend Recipe with Debug::{to_repr}

///|
pub(all) struct ElementBudget {
  mut fire : Int
  mut water : Int
  mut earth : Int
  mut air : Int
  mut light : Int
  mut shadow : Int
} derive(Eq, Debug)

///|
pub extend ElementBudget with Eq::{not_equal, equal}

///|
pub extend ElementBudget with Debug::{to_repr}

///|
pub(all) struct Level {
  tier : Tier
  target : Element
  budget : ElementBudget
  par_steps : Int
  hint : String
} derive(Eq, Debug)

///|
pub extend Level with Eq::{not_equal, equal}

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut best_steps : Int
} derive(Eq, Debug)

///|
pub extend LevelScore with Eq::{not_equal, equal}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct AnimState {
  mut timer : Float
  mut active : Bool
  mut kind : AnimKind
} derive(Eq, Debug)

///|
pub extend AnimState with Eq::{not_equal, equal}

///|
pub extend AnimState with Debug::{to_repr}

///|
pub(all) enum AnimKind {
  None
  AddElement
  Destruction
  SuccessGlow
  Bubbling
} derive(Eq, Debug)

///|
pub extend AnimKind with Eq::{not_equal, equal}

///|
pub extend AnimKind with Debug::{to_repr}

///|
pub impl Show for AnimKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AnimKind with Show::{to_string, output}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut cauldron_substance : Element?
  mut cauldron_history : Array[Element]
  recipe_book : Array[Recipe]
  mut current_tier : Tier
  mut current_level_index : Int
  level_scores : Array[LevelScore]
  mut budget : ElementBudget
  mut steps_taken : Int
  mut failed_attempts : Int
  mut total_attempts : Int
  mut discovered_count : Int
  mut show_recipe_book : Bool
  mut message : String
  mut message_timer : Float
  mut anim : AnimState
  mut frame_count : Int
  mut selected_element : Element?
  mut add_anim_element : Element?
  mut add_anim_y : Float
  mut result_stars : Int
  mut result_steps : Int
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
