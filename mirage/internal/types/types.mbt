///|
pub(all) struct GridData {
  fg : Array[Tile]
  bg : Array[Tile]
}

///|
pub(all) struct LevelDef {
  tier : Tier
  index : Int
  name : String
  par_swaps : Int
  fg : Array[Tile]
  bg : Array[Tile]
  player_start_x : Int
  player_start_y : Int
  player_start_layer : Layer
}

///|
pub(all) struct LevelResult {
  mut completed : Bool
  mut stars : Int
  mut best_swaps : Int
}

///|
pub(all) struct Animation {
  mut kind : AnimKind
  mut timer : Float
  mut duration : Float
  mut active : Bool
}

///|
pub(all) struct Player {
  mut grid_x : Int
  mut grid_y : Int
  mut pixel_x : Float
  mut pixel_y : Float
  mut target_x : Float
  mut target_y : Float
  mut moving : Bool
  mut active_layer : Layer
  mut move_timer : Float
}

///|
pub(all) struct Game {
  mut screen : Screen
  player : Player
  mut fg_tiles : Array[Tile]
  mut bg_tiles : Array[Tile]
  mut merge_state : MergeState
  mut current_level : Int
  mut swap_count : Int
  mut gem_collected : Bool
  mut level_results : Array[LevelResult]
  anim : Animation
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut input_cooldown : Float
  mut switch_states : Array[Bool]
  mut level_select_cursor : Int
}
