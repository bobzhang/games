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
  Trunk
  Branch
  Leaf
  Pruned
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
pub(all) enum GrowthDir {
  Up
  UpLeft
  UpRight
  Left
  Right
} derive(Eq, Debug)

///|
pub extend GrowthDir with Eq::{not_equal, equal}

///|
pub extend GrowthDir with Debug::{to_repr}

///|
pub impl Show for GrowthDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GrowthDir with Show::{to_string, output}

///|
pub(all) enum Species {
  Pine
  Maple
  Cherry
} derive(Eq, Debug)

///|
pub extend Species with Eq::{not_equal, equal}

///|
pub extend Species with Debug::{to_repr}

///|
pub impl Show for Species with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Species with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Waiting
  Growing
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
  Tier1
  Tier2
  Tier3
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
pub(all) enum ZoneKind {
  Required
  Forbidden
  TipTarget
} derive(Eq, Debug)

///|
pub extend ZoneKind with Eq::{not_equal, equal}

///|
pub extend ZoneKind with Debug::{to_repr}

///|
pub impl Show for ZoneKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ZoneKind with Show::{to_string, output}
