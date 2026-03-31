///|
pub(all) struct Reaction {
  input_element : Element
  current_substance : Element
  result : ReactionResult
} derive(Eq, Show)

///|
pub(all) struct Recipe {
  mut discovered : Bool
  input : Element
  substance : Element
  output : ReactionResult
} derive(Eq, Show)

///|
pub(all) struct ElementBudget {
  mut fire : Int
  mut water : Int
  mut earth : Int
  mut air : Int
  mut light : Int
  mut shadow : Int
} derive(Eq, Show)

///|
pub(all) struct Level {
  tier : Tier
  target : Element
  budget : ElementBudget
  par_steps : Int
  hint : String
} derive(Eq, Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut best_steps : Int
} derive(Eq, Show)

///|
pub(all) struct AnimState {
  mut timer : Float
  mut active : Bool
  mut kind : AnimKind
} derive(Eq, Show)

///|
pub(all) enum AnimKind {
  None
  AddElement
  Destruction
  SuccessGlow
  Bubbling
} derive(Eq, Show)

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
} derive(Show)
