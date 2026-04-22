///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Programming
  Results
  Sandbox
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CommandKind {
  Move
  TurnLeft
  TurnRight
  Jump
  Push
  If(Condition)
  Loop(Int)
} derive(Eq, Debug)

///|
pub impl Show for CommandKind with output(self, logger) {
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
pub(all) enum TileKind {
  Floor
  Wall
  Gap
  Goal
  ColorTile(TileColor)
  Block
  Start
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileColor {
  Red
  Blue
  Green
} derive(Eq, Debug)

///|
pub impl Show for TileColor with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Condition {
  PathAhead
  WallAhead
  AtGoal
  OnColor(TileColor)
} derive(Eq, Debug)

///|
pub impl Show for Condition with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum RunState {
  Editing
  Running
  Stepping
  Complete
  Failed(String)
} derive(Eq, Debug)

///|
pub impl Show for RunState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Medal {
  None_
  Bronze
  Silver
  Gold
} derive(Eq, Debug)

///|
pub impl Show for Medal with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
