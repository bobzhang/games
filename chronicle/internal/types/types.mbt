///|
pub(all) struct EventCard {
  id : Int
  text : String
  actor : String
  action : String
  time_hint : String
  fixed_slot : Int // -1 means not fixed
} derive(Eq, Show)

///|
pub(all) struct CauseLink {
  from_id : Int
  to_id : Int
} derive(Eq, Show)

///|
pub(all) struct Clue {
  kind : ClueKind
  card_a : Int
  card_b : Int
  text : String
} derive(Eq, Show)

///|
pub(all) struct Case {
  cards : Array[EventCard]
  solution_order : Array[Int]
  solution_links : Array[CauseLink]
  clues : Array[Clue]
  anchors : Array[Int] // card ids with fixed positions
  tier : Tier
  title : String
  theme : String
} derive(Show)

///|
pub(all) struct CaseScore {
  mut order_correct : Bool
  mut links_correct : Bool
  mut no_rewinds : Bool
  mut stars : Int
  mut order_count : Int
  mut link_count : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_case_index : Int
  mut timeline_slots : Array[Int] // card ids in slots, -1 = empty
  mut placed_links : Array[CauseLink]
  mut rewinds : Int
  mut selected_card : Int // -1 = none
  mut link_from : Int // -1 = none, card id for linking
  mut dragging : Bool
  mut drag_card_id : Int // card id being dragged
  mut drag_x : Float
  mut drag_y : Float
  mut hover_slot : Int // -1 = none
  mut hover_card : Int // -1 = none
  mut scroll_offset : Float
  mut anim_timer : Float
  mut result_score : CaseScore
  mut case_scores : Array[Array[CaseScore]] // per tier, per case
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut title_pulse : Float
} derive(Show)
