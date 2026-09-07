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
pub(all) enum NodeKind {
  Pulley
  Anchor
  WeightHook
  CrateHook
  Ratchet
} derive(Eq, Debug)

///|
pub extend NodeKind with Eq::{not_equal, equal}

///|
pub extend NodeKind with Debug::{to_repr}

///|
pub impl Show for NodeKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend NodeKind with Show::{to_string, output}

///|
pub(all) enum ComponentKind {
  WeightComp
  CrateComp
  BucketComp
  BreakableRopeComp
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
pub(all) enum PlayState {
  Idle
  ConnectingRope(Int)
  Settling
  Won
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
pub(all) enum Tier {
  Basics
  Chains
  Workshop
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
pub(all) enum RopeSide {
  LeftSide
  RightSide
} derive(Eq, Debug)

///|
pub extend RopeSide with Eq::{not_equal, equal}

///|
pub extend RopeSide with Debug::{to_repr}

///|
pub impl Show for RopeSide with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend RopeSide with Show::{to_string, output}
