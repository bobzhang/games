///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Piece {
  cells : Array[Vec2i]
  color : @raylib.Color
} derive(Show)

///|
pub(all) struct PlacedPiece {
  piece_index : Int
  position : Vec2i
  rotation : Int
  flipped : Bool
} derive(Show)

///|
pub(all) struct Region {
  width : Int
  height : Int
  active : Array[Array[Bool]]
} derive(Show)

///|
pub(all) struct Level {
  region : Region
  pieces : Array[Piece]
  par_time : Int
  par_rotations : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_time : Int
  mut best_rotations : Int
} derive(Show)

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
