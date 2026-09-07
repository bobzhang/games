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
pub(all) struct Piece {
  cells : Array[Vec2i]
  color : @raylib.Color
}

///|
pub(all) struct PlacedPiece {
  piece_index : Int
  position : Vec2i
  rotation : Int
  flipped : Bool
} derive(Debug)

///|
pub extend PlacedPiece with Debug::{to_repr}

///|
pub(all) struct Region {
  width : Int
  height : Int
  active : Array[Array[Bool]]
} derive(Debug)

///|
pub extend Region with Debug::{to_repr}

///|
pub(all) struct Level {
  region : Region
  pieces : Array[Piece]
  par_time : Int
  par_rotations : Int
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_time : Int
  mut best_rotations : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut selected_piece : Int
  mut hover_x : Int
  mut hover_y : Int
  mut rotation : Int
  mut flipped : Bool
  mut placed_pieces : Array[PlacedPiece]
  mut grid : Array[Array[Int]]
  mut timer : Float
  mut rotation_count : Int
  mut level_scores : Array[LevelScore]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut tier_page : Int
}

///|
/// `@raylib.Color` has no `Debug` impl, so `Piece` cannot derive one.
/// Render the color as its `(r, g, b, a)` channels instead.
pub impl Debug for Piece with fn to_repr(self) {
  Repr((self.cells, (self.color.r, self.color.g, self.color.b, self.color.a)))
}

///|
pub extend Piece with Debug::{to_repr}
