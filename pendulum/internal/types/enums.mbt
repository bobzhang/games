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
  Empty
  Anchor
  Peg
  Goal
  Wall
  Collectible
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
pub(all) enum SwingDir {
  Left
  Right
} derive(Eq, Debug)

///|
pub extend SwingDir with Eq::{not_equal, equal}

///|
pub extend SwingDir with Debug::{to_repr}

///|
pub impl Show for SwingDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SwingDir with Show::{to_string, output}

///|
pub(all) enum WeightState {
  Swinging
  Launched
  Stopped
  AtGoal
} derive(Eq, Debug)

///|
pub extend WeightState with Eq::{not_equal, equal}

///|
pub extend WeightState with Debug::{to_repr}

///|
pub impl Show for WeightState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend WeightState with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Ready
  Simulating
  Won
  Lost
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
  Swing
  Wrap
  Launch
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
