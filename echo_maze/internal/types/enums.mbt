///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Planning
  Results
  Paused
} derive(Eq, Debug)

///|
pub extend Screen with Eq::{not_equal, equal}

///|
pub extend Screen with Debug::{to_repr}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

///|
pub(all) enum TileKind {
  Floor
  Wall
  Start
  Exit
  Button(Int) // button_id
  Door(Int) // door_id
  TimedDoor(Int, Int) // door_id, duration in ticks
  Guard
  Collectible
} derive(Eq, Debug)

///|
pub extend TileKind with Eq::{not_equal, equal}

///|
pub extend TileKind with Debug::{to_repr}

///|
pub impl Show for TileKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileKind with Show::{to_string, output}

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Debug)

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub extend Direction with Debug::{to_repr}

///|
pub impl Show for Direction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Direction with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Recording
  Reviewing
  Complete
  Failed
} derive(Eq, Debug)

///|
pub extend PlayState with Eq::{not_equal, equal}

///|
pub extend PlayState with Debug::{to_repr}

///|
pub impl Show for PlayState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayState with Show::{to_string, output}

///|
pub(all) enum GhostColor {
  Green
  Yellow
  Orange
} derive(Eq, Debug)

///|
pub extend GhostColor with Eq::{not_equal, equal}

///|
pub extend GhostColor with Debug::{to_repr}

///|
pub impl Show for GhostColor with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GhostColor with Show::{to_string, output}

///|
pub(all) enum GuardAlertState {
  Idle
  Alert
  Chasing
} derive(Eq, Debug)

///|
pub extend GuardAlertState with Eq::{not_equal, equal}

///|
pub extend GuardAlertState with Debug::{to_repr}

///|
pub impl Show for GuardAlertState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GuardAlertState with Show::{to_string, output}
