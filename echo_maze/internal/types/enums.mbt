///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Planning
  Results
  Paused
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Floor
  Wall
  Start
  Exit
  Button(Int) // button_id
  Door(Int) // door_id
  TimedDoor(Int, Int) // door_id, duration in ticks
  Guard
  Collectible
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Recording
  Reviewing
  Complete
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GhostColor {
  Green
  Yellow
  Orange
} derive(Eq, Debug)

///|
pub impl Show for GhostColor with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GuardAlertState {
  Idle
  Alert
  Chasing
} derive(Eq, Debug)

///|
pub impl Show for GuardAlertState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
