///|
#derive(Eq, Debug)
pub(all) struct Vec3i {
  x : Int32
  y : Int32
  z : Int32
}

///|
pub extend Vec3i with Eq::{not_equal, equal}

///|
pub extend Vec3i with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct VoxelGrid {
  size : Int32
  cells : Array[Bool]
}

///|
pub extend VoxelGrid with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Silhouette {
  width : Int32
  height : Int32
  cells : Array[Bool]
}

///|
pub extend Silhouette with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct TargetSet {
  top : Silhouette
  front : Silhouette
  side : Silhouette
}

///|
pub extend TargetSet with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  size : Int32
  targets : TargetSet
  voxel_budget : Int32
  requires_connected : Bool
  par_moves : Int32
  par_voxels : Int32
  tier : Tier
  name : String
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut best_moves : Int32
  mut best_voxels : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct UndoEntry {
  x : Int32
  y : Int32
  z : Int32
  was_filled : Bool
}

///|
pub extend UndoEntry with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct HoverInfo {
  mut active : Bool
  mut vx : Int32
  mut vy : Int32
  mut vz : Int32
  mut view : ViewKind
}

///|
pub extend HoverInfo with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Int32
  mut current_level : Int32
  mut grid : VoxelGrid
  mut moves : Int32
  mut undo_stack : Array[UndoEntry]
  mut hover : HoverInfo
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut result_stars : Int32
}
