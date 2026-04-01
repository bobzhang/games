///|
pub(all) struct HexCoord {
  col : Int
  row : Int
} derive(Eq, Show)

///|
pub(all) struct GameUnit {
  mut id : Int
  mut pos : HexCoord
  mut kind : UnitKind
  mut team : Team
  mut hp : Int
  mut max_hp : Int
  mut atk : Int
  mut def : Int
  mut move_range : Int
  mut attack_range : Int
  mut sight_range : Int
  mut moved : Bool
  mut attacked : Bool
  mut active : Bool
}

///|
pub(all) struct HexTile {
  mut terrain : Terrain
  mut fog_player : FogState
  mut unit_id : Int
  mut has_flag : Bool
}

///|
pub(all) struct HexMap {
  width : Int
  height : Int
  tiles : Array[HexTile]
}

///|
pub(all) struct LevelDef {
  name : String
  width : Int
  height : Int
  terrain : Array[Int]
  player_units : Array[(UnitKind, Int, Int)]
  enemy_units : Array[(UnitKind, Int, Int)]
  victory : VictoryCondition
  description : String
}

///|
pub(all) struct Battle {
  map : HexMap
  mut units : Array[GameUnit]
  mut phase : Phase
  mut selected_unit : Int
  mut turn : Int
  mut result : GameResult
  mut victory_condition : VictoryCondition
  mut move_targets : Array[HexCoord]
  mut attack_targets : Array[HexCoord]
  mut player_done_count : Int
  mut anim_timer : Float
  mut anim_message : String
  mut next_unit_id : Int
  // Visual feedback state
  mut attack_flash_timer : Float
  mut attack_flash_pos : HexCoord?
  mut hit_shake_timer : Float
  mut hit_shake_target : HexCoord?
  mut damage_popup_timer : Float
  mut damage_popup_pos : HexCoord?
  mut damage_popup_value : Int
  mut turn_banner_timer : Float
}

///|
pub(all) struct CampaignState {
  mut current_level : Int
  mut levels_unlocked : Int
  mut total_score : Int
  mut level_scores : Array[Int]
}

///|
pub(all) struct SkirmishSetup {
  mut map_index : Int
  mut army_size : Int
  mut difficulty : Difficulty
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut battle : Battle?
  mut campaign : CampaignState
  mut skirmish : SkirmishSetup
  mut last_score : Int
  mut last_turns : Int
  mut last_units_remaining : Int
  mut last_was_victory : Bool
  mut frame_count : Int
  mut rng : Int
  mut hover_hex : HexCoord?
  mut scroll_y : Float
  mut difficulty : Difficulty
}
