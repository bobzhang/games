///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct Piece {
  cells : Array[Vec2i]
  color : @raylib.Color
}

///|
pub(all) struct PlacedPiece {
  piece_index : Int32
  position : Vec2i
  rotation : Int32
  flipped : Bool
} derive(Debug)

///|
pub extend PlacedPiece with Debug::{to_repr}

///|
pub(all) struct Region {
  width : Int32
  height : Int32
  active : Array[Array[Bool]]
} derive(Debug)

///|
pub extend Region with Debug::{to_repr}

///|
pub(all) struct Level {
  region : Region
  pieces : Array[Piece]
  par_time : Int32
  par_rotations : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut best_time : Int32
  mut best_rotations : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut selected_piece : Int32
  mut hover_x : Int32
  mut hover_y : Int32
  mut rotation : Int32
  mut flipped : Bool
  mut placed_pieces : Array[PlacedPiece]
  mut grid : Array[Array[Int32]]
  mut timer : Float
  mut rotation_count : Int32
  mut level_scores : Array[LevelScore]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut tier_page : Int32
}

///|
/// `@raylib.Color` has no `Debug` impl, so `Piece` cannot derive one.
/// Render the color as its `(r, g, b, a)` channels instead.
pub impl Debug for Piece with fn to_repr(self) {
  Repr((self.cells, (self.color.r, self.color.g, self.color.b, self.color.a)))
}

///|
pub extend Piece with Debug::{to_repr}
