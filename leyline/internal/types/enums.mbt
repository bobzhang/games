///|
pub(all) enum CellKind {
  Empty
  Source
  Temple(Float)
  Waystone
  Amplifier
  Void
} derive(Debug, Eq)

///|
pub impl Show for CellKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  LevelComplete
  LevelFailed
} derive(Debug, Eq)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tool {
  PlaceWaystone
  RemoveWaystone
  DrawLine
  EraseLine
} derive(Debug, Eq)

///|
pub impl Show for Tool with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum StarRating {
  None
  Bronze
  Silver
  Gold
} derive(Debug, Eq)

///|
pub impl Show for StarRating with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Debug, Eq)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
