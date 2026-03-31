///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Programming
  Results
  Sandbox
} derive(Eq, Show)

///|
pub(all) enum CommandKind {
  Move
  TurnLeft
  TurnRight
  Jump
  Push
  If(Condition)
  Loop(Int)
} derive(Eq, Show)

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Floor
  Wall
  Gap
  Goal
  ColorTile(TileColor)
  Block
  Start
} derive(Eq, Show)

///|
pub(all) enum TileColor {
  Red
  Blue
  Green
} derive(Eq, Show)

///|
pub(all) enum Condition {
  PathAhead
  WallAhead
  AtGoal
  OnColor(TileColor)
} derive(Eq, Show)

///|
pub(all) enum RunState {
  Editing
  Running
  Stepping
  Complete
  Failed(String)
} derive(Eq, Show)

///|
pub(all) enum Medal {
  None_
  Bronze
  Silver
  Gold
} derive(Eq, Show)
