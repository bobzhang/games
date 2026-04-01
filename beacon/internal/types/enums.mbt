///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Won
  Failed
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Empty
  Mountain
  Transmitter
  Receiver
  Tower
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum StarRating {
  None
  One
  Two
  Three
} derive(Eq, Show)
