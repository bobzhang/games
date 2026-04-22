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
pub(all) enum CellKind {
  Empty
  Trunk
  Branch
  Leaf
  Pruned
} derive(Eq, Debug)

///|
pub impl Show for CellKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GrowthDir {
  Up
  UpLeft
  UpRight
  Left
  Right
} derive(Eq, Debug)

///|
pub impl Show for GrowthDir with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Species {
  Pine
  Maple
  Cherry
} derive(Eq, Debug)

///|
pub impl Show for Species with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Waiting
  Growing
  Won
  Lost
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Tier1
  Tier2
  Tier3
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ZoneKind {
  Required
  Forbidden
  TipTarget
} derive(Eq, Debug)

///|
pub impl Show for ZoneKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
