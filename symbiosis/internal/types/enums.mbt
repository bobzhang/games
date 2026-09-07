///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Results
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
pub(all) enum GoalKind {
  BothExit
  BothSwitch
  ExitInMoves(Int)
} derive(Eq, Debug)

///|
pub extend GoalKind with Eq::{not_equal, equal}

///|
pub extend GoalKind with Debug::{to_repr}

///|
pub impl Show for GoalKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GoalKind with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Active
  Won
  Failed
  Paused
} derive(Eq, Debug)

///|
pub extend PlayState with Eq::{not_equal, equal}

///|
pub extend PlayState with Debug::{to_repr}

///|
pub impl Show for PlayState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayState with Show::{to_string, output}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
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
pub(all) enum MoveInput {
  DirInput(Direction)
  Wait
} derive(Eq, Debug)

///|
pub extend MoveInput with Eq::{not_equal, equal}

///|
pub extend MoveInput with Debug::{to_repr}

///|
pub impl Show for MoveInput with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend MoveInput with Show::{to_string, output}
