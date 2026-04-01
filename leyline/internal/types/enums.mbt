///|
pub(all) enum CellKind {
  Empty
  Source
  Temple(Float)
  Waystone
  Amplifier
  Void
} derive(Show, Eq)

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  LevelComplete
  LevelFailed
} derive(Show, Eq)

///|
pub(all) enum Tool {
  PlaceWaystone
  RemoveWaystone
  DrawLine
  EraseLine
} derive(Show, Eq)

///|
pub(all) enum StarRating {
  None
  Bronze
  Silver
  Gold
} derive(Show, Eq)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Show, Eq)
