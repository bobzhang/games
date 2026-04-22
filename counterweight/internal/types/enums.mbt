///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum NodeKind {
  Pulley
  Anchor
  WeightHook
  CrateHook
  Ratchet
} derive(Eq, Debug)

///|
pub impl Show for NodeKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ComponentKind {
  WeightComp
  CrateComp
  BucketComp
  BreakableRopeComp
} derive(Eq, Debug)

///|
pub impl Show for ComponentKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Idle
  ConnectingRope(Int)
  Settling
  Won
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Basics
  Chains
  Workshop
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum RopeSide {
  LeftSide
  RightSide
} derive(Eq, Debug)

///|
pub impl Show for RopeSide with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
