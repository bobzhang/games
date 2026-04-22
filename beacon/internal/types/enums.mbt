///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Won
  Failed
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Empty
  Mountain
  Transmitter
  Receiver
  Tower
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum StarRating {
  None
  One
  Two
  Three
} derive(Eq, Debug)

///|
pub impl Show for StarRating with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
