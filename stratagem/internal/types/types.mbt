///|
pub(all) struct HexCoord {
  col : Int32
  row : Int32
} derive(Eq, Debug)

///|
pub extend HexCoord with Eq::{not_equal, equal}

///|
pub extend HexCoord with Debug::{to_repr}

///|
pub(all) struct GameUnit {
  mut id : Int32
  mut pos : HexCoord
  mut kind : UnitKind
  mut team : Team
  mut hp : Int32
  mut max_hp : Int32
  mut atk : Int32
  mut def : Int32
  mut move_range : Int32
  mut attack_range : Int32
  mut sight_range : Int32
  mut moved : Bool
  mut attacked : Bool
  mut active : Bool
}

///|
pub(all) struct HexTile {
  mut terrain : Terrain
  mut fog_player : FogState
  mut unit_id : Int32
  mut has_flag : Bool
}

///|
pub(all) struct HexMap {
  width : Int32
  height : Int32
  tiles : Array[HexTile]
}

///|
pub(all) struct LevelDef {
  name : String
  width : Int32
  height : Int32
  terrain : Array[Int32]
  player_units : Array[(UnitKind, Int32, Int32)]
  enemy_units : Array[(UnitKind, Int32, Int32)]
  victory : VictoryCondition
  description : String
}

///|
pub(all) struct Battle {
  map : HexMap
  mut units : Array[GameUnit]
  mut phase : Phase
  mut selected_unit : Int32
  mut turn : Int32
  mut result : GameResult
  mut victory_condition : VictoryCondition
  mut move_targets : Array[HexCoord]
  mut attack_targets : Array[HexCoord]
  mut player_done_count : Int32
  mut anim_timer : Float
  mut anim_message : String
  mut next_unit_id : Int32
  // Visual feedback state
  mut attack_flash_timer : Float
  mut attack_flash_pos : HexCoord?
  mut hit_shake_timer : Float
  mut hit_shake_target : HexCoord?
  mut damage_popup_timer : Float
  mut damage_popup_pos : HexCoord?
  mut damage_popup_value : Int32
  mut turn_banner_timer : Float
}

///|
pub(all) struct CampaignState {
  mut current_level : Int32
  mut levels_unlocked : Int32
  mut total_score : Int32
  mut level_scores : Array[Int32]
}

///|
pub(all) struct SkirmishSetup {
  mut map_index : Int32
  mut army_size : Int32
  mut difficulty : Difficulty
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut battle : Battle?
  mut campaign : CampaignState
  mut skirmish : SkirmishSetup
  mut last_score : Int32
  mut last_turns : Int32
  mut last_units_remaining : Int32
  mut last_was_victory : Bool
  mut frame_count : Int32
  mut rng : Int32
  mut hover_hex : HexCoord?
  mut scroll_y : Float
  mut difficulty : Difficulty
}
