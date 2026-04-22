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
pub(all) enum GearKind {
  Small
  Medium
  Large
  Belt
  Ratchet
} derive(Eq, Debug)

///|
pub impl Show for GearKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum RotDir {
  CW
  CCW
} derive(Eq, Debug)

///|
pub impl Show for RotDir with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Solved
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Gears
  Trains
  Workshop
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
