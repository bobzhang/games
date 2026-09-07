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
pub extend Tile with Debug::{to_repr}

///|
pub extend Tile with Eq::{not_equal, equal}

///|
pub extend Tile with ToJson::{to_json}

///|
pub impl Show for Tile with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tile with Show::{to_string, output}

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Debug, Eq, ToJson)

///|
pub extend Direction with Debug::{to_repr}

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub extend Direction with ToJson::{to_json}

///|
pub impl Show for Direction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Direction with Show::{to_string, output}

///|
pub(all) enum GamePhase {
  Menu
  Playing
  LevelComplete
  GameOver
  LevelSelect
} derive(Debug, Eq, ToJson)

///|
pub extend GamePhase with Debug::{to_repr}

///|
pub extend GamePhase with Eq::{not_equal, equal}

///|
pub extend GamePhase with ToJson::{to_json}

///|
pub impl Show for GamePhase with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GamePhase with Show::{to_string, output}

///|
pub(all) enum StarRating {
  None
  One
  Two
  Three
} derive(Debug, Eq, ToJson)

///|
pub extend StarRating with Debug::{to_repr}

///|
pub extend StarRating with Eq::{not_equal, equal}

///|
pub extend StarRating with ToJson::{to_json}

///|
pub impl Show for StarRating with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StarRating with Show::{to_string, output}
