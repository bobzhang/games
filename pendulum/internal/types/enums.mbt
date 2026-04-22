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
  Anchor
  Peg
  Goal
  Wall
  Collectible
} derive(Eq, Debug)

///|
pub impl Show for CellKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum SwingDir {
  Left
  Right
} derive(Eq, Debug)

///|
pub impl Show for SwingDir with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum WeightState {
  Swinging
  Launched
  Stopped
  AtGoal
} derive(Eq, Debug)

///|
pub impl Show for WeightState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Ready
  Simulating
  Won
  Lost
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Swing
  Wrap
  Launch
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
