///|
#derive(Eq, Debug)
pub(all) struct Vec2i {
  x : Int32
  y : Int32
}

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct Tile {
  mut color : TileColor
  mut shape : TileShape
  mut orientation : Orientation
}

///|
pub extend Tile with Eq::{not_equal, equal}

///|
pub extend Tile with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct MosaicGrid {
  width : Int32
  height : Int32
  tiles : Array[Tile?]
  holes : Array[Vec2i]
}

///|
pub extend MosaicGrid with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  grid : MosaicGrid
  symmetry : SymmetryKind
  par_errors : Int32
  tier : Tier
  name : String
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut errors : Int32
  mut guessed_symmetry : Bool
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct UndoEntry {
  pos : Vec2i
  prev_tile : Tile?
}

///|
pub extend UndoEntry with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut selected_color : TileColor
  mut selected_shape : TileShape
  mut selected_orientation : Orientation
  mut hover_cell : Vec2i?
  mut errors : Int32
  mut no_errors : Bool
  mut guessed_symmetry : Bool
  mut symmetry_guess : SymmetryKind?
  levels : Array[Level]
  scores : Array[LevelScore]
  mut placed_tiles : Array[(Vec2i, Tile)]
  mut undo_stack : Array[UndoEntry]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut show_symmetry_hint : Bool
  mut anim_timer : Float
}

///|
pub extend Game with Debug::{to_repr}
