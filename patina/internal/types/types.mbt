///|
pub(all) struct Region {
  mut state : RegionState
  damage_types : Array[DamageKind]
  treatments_applied : Array[ToolKind]
  mut fragile : Bool
  mut stain_permanent : Bool
}

///|
pub(all) struct Artwork {
  width : Int
  height : Int
  regions : Array[Region]
}

///|
pub(all) struct ToolBudget {
  mut clean : Int
  mut fill : Int
  mut retouch : Int
  mut seal : Int
}

///|
pub(all) struct Level {
  tier : Tier
  name : String
  artwork : Artwork
  budget : ToolBudget
  par_tools : Int
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut restored_count : Int
  mut worsened_count : Int
  mut sealed_count : Int
  mut total_tools_used : Int
}

///|
pub(all) struct UndoEntry {
  region_index : Int
  prev_state : RegionState
  prev_treatments : Array[ToolKind]
  prev_fragile : Bool
  prev_stain_permanent : Bool
  tool_used : ToolKind
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut current_level : Level?
  mut current_budget : ToolBudget?
  mut selected_tool : ToolKind
  mut play_state : PlayState
  mut anim_timer : Float
  mut anim_region : Int
  mut hover_region : Int
  mut score : LevelScore?
  mut level_scores : Array[Int]
  mut undo_stack : Array[UndoEntry]
  mut total_tools_used : Int
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut title_anim_timer : Float
}
