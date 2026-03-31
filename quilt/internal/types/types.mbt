///|
pub(all) struct Patch {
  edges : Array[EdgePattern]
  wildcard_edges : Array[Bool]
  pinned : Bool
} derive(Eq, Show)

///|
pub(all) struct Board {
  size : Int
  cells : Array[Patch?]
} derive(Show)

///|
pub(all) struct Level {
  board_size : Int
  patches : Array[Patch]
  pinned_positions : Array[Int]
  pinned_patches : Array[Patch]
  par_rotations : Int
  par_swaps : Int
  tier : Tier
  level_num : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_rotations : Int
  mut best_swaps : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut board : Board
  mut tray : Array[Patch]
  mut selected_tray : Int
  mut selected_board : Int
  mut play_state : PlayState
  mut rotations : Int
  mut swaps : Int
  mut current_level : Int
  mut current_tier : Tier
  mut level_scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut daily_seed : Int
  mut is_daily : Bool
  mut daily_score : LevelScore
  mut anim_timer : Float
  mut tier_select_index : Int
}
