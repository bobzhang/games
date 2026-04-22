///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Paused
  LevelComplete
  LevelFailed
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ComponentKind {
  Gear(GearSize)
  Cam
  Spring
  Escapement
  Bell
} derive(Eq, Debug)

///|
pub impl Show for ComponentKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GearSize {
  Small
  Medium
  Large
} derive(Eq, Debug)

///|
pub impl Show for GearSize with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CamDirection {
  PushUp
  PushDown
  PushLeft
  PushRight
} derive(Eq, Debug)

///|
pub impl Show for CamDirection with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Ticks
  Timing
  Clockwork
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum SimState {
  Idle
  Running
  Paused
  Complete
  Failed
} derive(Eq, Debug)

///|
pub impl Show for SimState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
