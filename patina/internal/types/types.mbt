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
  width : Int32
  height : Int32
  regions : Array[Region]
}

///|
pub(all) struct ToolBudget {
  mut clean : Int32
  mut fill : Int32
  mut retouch : Int32
  mut seal : Int32
}

///|
pub(all) struct Level {
  tier : Tier
  name : String
  artwork : Artwork
  budget : ToolBudget
  par_tools : Int32
}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut restored_count : Int32
  mut worsened_count : Int32
  mut sealed_count : Int32
  mut total_tools_used : Int32
}

///|
pub(all) struct UndoEntry {
  region_index : Int32
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
  mut selected_level : Int32
  mut current_level : Level?
  mut current_budget : ToolBudget?
  mut selected_tool : ToolKind
  mut play_state : PlayState
  mut anim_timer : Float
  mut anim_region : Int32
  mut hover_region : Int32
  mut score : LevelScore?
  mut level_scores : Array[Int32]
  mut undo_stack : Array[UndoEntry]
  mut total_tools_used : Int32
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut title_anim_timer : Float
}
