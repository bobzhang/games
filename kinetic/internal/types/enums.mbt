///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
}

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
#derive(Eq, Debug)
pub(all) enum GearKind {
  Small
  Medium
  Large
  Belt
  Ratchet
}

///|
pub extend GearKind with Eq::{not_equal, equal}

///|
pub extend GearKind with Debug::{to_repr}

///|
pub impl Show for GearKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GearKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum RotDir {
  CW
  CCW
}

///|
pub extend RotDir with Eq::{not_equal, equal}

///|
pub extend RotDir with Debug::{to_repr}

///|
pub impl Show for RotDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend RotDir with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlayState {
  Placing
  Simulating
  Solved
}

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
#derive(Eq, Debug)
pub(all) enum Tier {
  Gears
  Trains
  Workshop
}

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
