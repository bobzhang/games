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
  Path
  Switch
  Gate
  SyncPoint
  OneShotSwitch
} derive(Eq, Debug)

///|
pub impl Show for CellKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Moving
  Blocked
  Won
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Coil
  Twist
  DoubleHelix
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TokenKind {
  CW
  CCW
} derive(Eq, Debug)

///|
pub impl Show for TokenKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
