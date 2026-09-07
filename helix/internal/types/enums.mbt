///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
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
pub(all) enum CellKind {
  Path
  Switch
  Gate
  SyncPoint
  OneShotSwitch
} derive(Eq, Debug)

///|
pub extend CellKind with Eq::{not_equal, equal}

///|
pub extend CellKind with Debug::{to_repr}

///|
pub impl Show for CellKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CellKind with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Moving
  Blocked
  Won
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
pub(all) enum Tier {
  Coil
  Twist
  DoubleHelix
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
pub(all) enum TokenKind {
  CW
  CCW
} derive(Eq, Debug)

///|
pub extend TokenKind with Eq::{not_equal, equal}

///|
pub extend TokenKind with Debug::{to_repr}

///|
pub impl Show for TokenKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TokenKind with Show::{to_string, output}
