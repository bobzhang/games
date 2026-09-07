///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Paused
  LevelComplete
  LevelFailed
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
pub(all) enum ComponentKind {
  Gear(GearSize)
  Cam
  Spring
  Escapement
  Bell
} derive(Eq, Debug)

///|
pub extend ComponentKind with Eq::{not_equal, equal}

///|
pub extend ComponentKind with Debug::{to_repr}

///|
pub impl Show for ComponentKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ComponentKind with Show::{to_string, output}

///|
pub(all) enum GearSize {
  Small
  Medium
  Large
} derive(Eq, Debug)

///|
pub extend GearSize with Eq::{not_equal, equal}

///|
pub extend GearSize with Debug::{to_repr}

///|
pub impl Show for GearSize with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GearSize with Show::{to_string, output}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
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
pub(all) enum CamDirection {
  PushUp
  PushDown
  PushLeft
  PushRight
} derive(Eq, Debug)

///|
pub extend CamDirection with Eq::{not_equal, equal}

///|
pub extend CamDirection with Debug::{to_repr}

///|
pub impl Show for CamDirection with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CamDirection with Show::{to_string, output}

///|
pub(all) enum Tier {
  Ticks
  Timing
  Clockwork
} derive(Eq, Debug)

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}

///|
pub(all) enum SimState {
  Idle
  Running
  Paused
  Complete
  Failed
} derive(Eq, Debug)

///|
pub extend SimState with Eq::{not_equal, equal}

///|
pub extend SimState with Debug::{to_repr}

///|
pub impl Show for SimState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SimState with Show::{to_string, output}
