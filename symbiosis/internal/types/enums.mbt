///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum GoalKind {
  BothExit
  BothSwitch
  ExitInMoves(Int)
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Active
  Won
  Failed
  Paused
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum MoveInput {
  DirInput(Direction)
  Wait
} derive(Eq, Show)
