///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
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
pub(all) enum ObjectKind {
  Wall
  Target
  Splitter
  OneWayGate
  Bumper
  Pickup
} derive(Eq, Debug)

///|
pub extend ObjectKind with Eq::{not_equal, equal}

///|
pub extend ObjectKind with Debug::{to_repr}

///|
pub impl Show for ObjectKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ObjectKind with Show::{to_string, output}

///|
pub(all) enum BallState {
  Aiming
  Moving
  Complete
  Failed
} derive(Eq, Debug)

///|
pub extend BallState with Eq::{not_equal, equal}

///|
pub extend BallState with Debug::{to_repr}

///|
pub impl Show for BallState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend BallState with Show::{to_string, output}
