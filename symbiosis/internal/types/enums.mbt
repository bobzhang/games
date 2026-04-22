///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Floor
  Wall
  Exit
  Switch(Int)
  Door(Int)
  Pit
  Ice
  Anchor
  Gem
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GoalKind {
  BothExit
  BothSwitch
  ExitInMoves(Int)
} derive(Eq, Debug)

///|
pub impl Show for GoalKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Active
  Won
  Failed
  Paused
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
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
pub(all) enum MoveInput {
  DirInput(Direction)
  Wait
} derive(Eq, Debug)

///|
pub impl Show for MoveInput with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
