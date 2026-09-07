///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct Tile {
  mut color : TileColor
  mut shape : TileShape
  mut orientation : Orientation
} derive(Eq, Debug)

///|
pub extend Tile with Eq::{not_equal, equal}

///|
pub extend Tile with Debug::{to_repr}

///|
pub(all) struct MosaicGrid {
  width : Int
  height : Int
  tiles : Array[Tile?]
  holes : Array[Vec2i]
} derive(Debug)

///|
pub extend MosaicGrid with Debug::{to_repr}

///|
pub(all) struct Level {
  grid : MosaicGrid
  symmetry : SymmetryKind
  par_errors : Int
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut errors : Int
  mut guessed_symmetry : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  pos : Vec2i
  prev_tile : Tile?
} derive(Debug)

///|
pub extend UndoEntry with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut selected_color : TileColor
  mut selected_shape : TileShape
  mut selected_orientation : Orientation
  mut hover_cell : Vec2i?
  mut errors : Int
  mut no_errors : Bool
  mut guessed_symmetry : Bool
  mut symmetry_guess : SymmetryKind?
  levels : Array[Level]
  scores : Array[LevelScore]
  mut placed_tiles : Array[(Vec2i, Tile)]
  mut undo_stack : Array[UndoEntry]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut show_symmetry_hint : Bool
  mut anim_timer : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
