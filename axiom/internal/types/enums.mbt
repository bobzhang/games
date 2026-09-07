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
pub extend Screen with Eq::{not_equal, equal}

///|
pub extend Screen with Debug::{to_repr}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

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
pub extend CommandKind with Eq::{not_equal, equal}

///|
pub extend CommandKind with Debug::{to_repr}

///|
pub impl Show for CommandKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CommandKind with Show::{to_string, output}

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Debug)

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub extend Direction with Debug::{to_repr}

///|
pub impl Show for Direction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Direction with Show::{to_string, output}

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
pub extend TileKind with Eq::{not_equal, equal}

///|
pub extend TileKind with Debug::{to_repr}

///|
pub impl Show for TileKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileKind with Show::{to_string, output}

///|
pub(all) enum TileColor {
  Red
  Blue
  Green
} derive(Eq, Debug)

///|
pub extend TileColor with Eq::{not_equal, equal}

///|
pub extend TileColor with Debug::{to_repr}

///|
pub impl Show for TileColor with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileColor with Show::{to_string, output}

///|
pub(all) enum Condition {
  PathAhead
  WallAhead
  AtGoal
  OnColor(TileColor)
} derive(Eq, Debug)

///|
pub extend Condition with Eq::{not_equal, equal}

///|
pub extend Condition with Debug::{to_repr}

///|
pub impl Show for Condition with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Condition with Show::{to_string, output}

///|
pub(all) enum RunState {
  Editing
  Running
  Stepping
  Complete
  Failed(String)
} derive(Eq, Debug)

///|
pub extend RunState with Eq::{not_equal, equal}

///|
pub extend RunState with Debug::{to_repr}

///|
pub impl Show for RunState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend RunState with Show::{to_string, output}

///|
pub(all) enum Medal {
  None_
  Bronze
  Silver
  Gold
} derive(Eq, Debug)

///|
pub extend Medal with Eq::{not_equal, equal}

///|
pub extend Medal with Debug::{to_repr}

///|
pub impl Show for Medal with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Medal with Show::{to_string, output}
