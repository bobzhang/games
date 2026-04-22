///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Results
  Paused
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ObjectKind {
  Wall
  Target
  Splitter
  OneWayGate
  Bumper
  Pickup
} derive(Eq, Debug)

///|
pub impl Show for ObjectKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum BallState {
  Aiming
  Moving
  Complete
  Failed
} derive(Eq, Debug)

///|
pub impl Show for BallState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
