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
pub extend CellKind with Debug::{to_repr}

///|
pub extend CellKind with Eq::{not_equal, equal}

///|
pub impl Show for CellKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CellKind with Show::{to_string, output}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  LevelComplete
  LevelFailed
} derive(Debug, Eq)

///|
pub extend Screen with Debug::{to_repr}

///|
pub extend Screen with Eq::{not_equal, equal}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

///|
pub(all) enum Tool {
  PlaceWaystone
  RemoveWaystone
  DrawLine
  EraseLine
} derive(Debug, Eq)

///|
pub extend Tool with Debug::{to_repr}

///|
pub extend Tool with Eq::{not_equal, equal}

///|
pub impl Show for Tool with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tool with Show::{to_string, output}

///|
pub(all) enum StarRating {
  None
  Bronze
  Silver
  Gold
} derive(Debug, Eq)

///|
pub extend StarRating with Debug::{to_repr}

///|
pub extend StarRating with Eq::{not_equal, equal}

///|
pub impl Show for StarRating with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StarRating with Show::{to_string, output}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Debug, Eq)

///|
pub extend Direction with Debug::{to_repr}

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub impl Show for Direction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Direction with Show::{to_string, output}
