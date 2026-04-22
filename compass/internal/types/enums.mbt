///|
pub(all) enum Tile {
  Ocean
  Land
  Lighthouse
  Reef
  Landmark
  Current(Direction)
} derive(Debug, Eq, ToJson)

///|
pub impl Show for Tile with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Debug, Eq, ToJson)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GamePhase {
  Menu
  Playing
  LevelComplete
  GameOver
  LevelSelect
} derive(Debug, Eq, ToJson)

///|
pub impl Show for GamePhase with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum StarRating {
  None
  One
  Two
  Three
} derive(Debug, Eq, ToJson)

///|
pub impl Show for StarRating with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
