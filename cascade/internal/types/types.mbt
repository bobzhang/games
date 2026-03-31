///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Domino {
  mut pos : Vec2i
  mut kind : DominoKind
  mut orientation : Orientation
  mut state : DominoState
  mut is_target : Bool
  mut is_starter : Bool
  mut topple_tick : Int
  mut delay_remaining : Int
  mut anim_progress : Float
} derive(Show)

///|
pub(all) struct DominoBudget {
  mut normal : Int
  mut heavy : Int
  mut splitter : Int
  mut delay : Int
} derive(Show)

///|
pub(all) struct ToppleEvent {
  pos : Vec2i
  tick : Int
  kind : DominoKind
} derive(Eq, Show)

///|
pub(all) struct Level {
  id : Int
  tier : Tier
  name : String
  dominoes : Array[Domino]
  starter_pos : Vec2i
  budget : DominoBudget
  par_count : Int
  par_ticks : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut dominoes_used : Int
  mut ticks_taken : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut selected_tier : Tier
  mut selected_level : Int
  mut current_level : Level?
  mut dominoes : Array[Domino]
  mut events : Array[ToppleEvent]
  mut current_tick : Int
  mut max_tick : Int
  mut tick_timer : Float
  mut tick_speed : Int
  mut scores : Array[LevelScore]
  mut selected_kind : DominoKind
  mut hover_pos : Vec2i
  mut show_hover : Bool
  mut hover_orientation : Orientation
  mut message : String
  mut message_timer : Float
  mut replay_mode : Bool
  mut replay_tick : Int
  mut replay_timer : Float
  mut frame_count : Int
  mut dominoes_placed : Int
  mut title_anim : Float
  mut result_anim : Float
}
