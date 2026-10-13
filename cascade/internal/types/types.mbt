///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct Domino {
  mut pos : Vec2i
  mut kind : DominoKind
  mut orientation : Orientation
  mut state : DominoState
  mut is_target : Bool
  mut is_starter : Bool
  mut topple_tick : Int32
  mut delay_remaining : Int32
  mut anim_progress : Float
} derive(Debug)

///|
pub extend Domino with Debug::{to_repr}

///|
pub(all) struct DominoBudget {
  mut normal : Int32
  mut heavy : Int32
  mut splitter : Int32
  mut delay : Int32
} derive(Debug)

///|
pub extend DominoBudget with Debug::{to_repr}

///|
pub(all) struct ToppleEvent {
  pos : Vec2i
  tick : Int32
  kind : DominoKind
} derive(Eq, Debug)

///|
pub extend ToppleEvent with Eq::{not_equal, equal}

///|
pub extend ToppleEvent with Debug::{to_repr}

///|
pub(all) struct Level {
  id : Int32
  tier : Tier
  name : String
  dominoes : Array[Domino]
  starter_pos : Vec2i
  budget : DominoBudget
  par_count : Int32
  par_ticks : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut dominoes_used : Int32
  mut ticks_taken : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut selected_tier : Tier
  mut selected_level : Int32
  mut current_level : Level?
  mut dominoes : Array[Domino]
  mut events : Array[ToppleEvent]
  mut current_tick : Int32
  mut max_tick : Int32
  mut tick_timer : Float
  mut tick_speed : Int32
  mut scores : Array[LevelScore]
  mut selected_kind : DominoKind
  mut hover_pos : Vec2i
  mut show_hover : Bool
  mut hover_orientation : Orientation
  mut message : String
  mut message_timer : Float
  mut replay_mode : Bool
  mut replay_tick : Int32
  mut replay_timer : Float
  mut frame_count : Int32
  mut dominoes_placed : Int32
  mut title_anim : Float
  mut result_anim : Float
}
