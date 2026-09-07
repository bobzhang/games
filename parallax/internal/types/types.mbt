///|
pub(all) struct Vec3i {
  x : Int
  y : Int
  z : Int
} derive(Eq, Debug)

///|
pub extend Vec3i with Eq::{not_equal, equal}

///|
pub extend Vec3i with Debug::{to_repr}

///|
pub(all) struct VoxelGrid {
  size : Int
  cells : Array[Bool]
} derive(Debug)

///|
pub extend VoxelGrid with Debug::{to_repr}

///|
pub(all) struct Silhouette {
  width : Int
  height : Int
  cells : Array[Bool]
} derive(Debug)

///|
pub extend Silhouette with Debug::{to_repr}

///|
pub(all) struct TargetSet {
  top : Silhouette
  front : Silhouette
  side : Silhouette
} derive(Debug)

///|
pub extend TargetSet with Debug::{to_repr}

///|
pub(all) struct Level {
  size : Int
  targets : TargetSet
  voxel_budget : Int
  requires_connected : Bool
  par_moves : Int
  par_voxels : Int
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_moves : Int
  mut best_voxels : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  x : Int
  y : Int
  z : Int
  was_filled : Bool
} derive(Debug)

///|
pub extend UndoEntry with Debug::{to_repr}

///|
pub(all) struct HoverInfo {
  mut active : Bool
  mut vx : Int
  mut vy : Int
  mut vz : Int
  mut view : ViewKind
} derive(Debug)

///|
pub extend HoverInfo with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Int
  mut current_level : Int
  mut grid : VoxelGrid
  mut moves : Int
  mut undo_stack : Array[UndoEntry]
  mut hover : HoverInfo
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut anim_timer : Float
  mut message : String
  mut message_timer : Float
  mut result_stars : Int
}
