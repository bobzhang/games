///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  ModeSelect
  DifficultySelect
  Playing
  PuzzleSelect
  Results
}

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
#derive(Eq, Debug)
pub(all) enum Player {
  Black
  White
}

///|
pub extend Player with Eq::{not_equal, equal}

///|
pub extend Player with Debug::{to_repr}

///|
pub impl Show for Player with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Player with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum CellState {
  Empty
  Occupied(Player)
}

///|
pub extend CellState with Eq::{not_equal, equal}

///|
pub extend CellState with Debug::{to_repr}

///|
pub impl Show for CellState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CellState with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PatternKind {
  Bridge
  Chain
  Triangle
  Diamond
  Fortress
  Ring
  Star
  Wall
}

///|
pub extend PatternKind with Eq::{not_equal, equal}

///|
pub extend PatternKind with Debug::{to_repr}

///|
pub impl Show for PatternKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PatternKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Difficulty {
  Easy
  Normal
  Hard
}

///|
pub extend Difficulty with Eq::{not_equal, equal}

///|
pub extend Difficulty with Debug::{to_repr}

///|
pub impl Show for Difficulty with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Difficulty with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum GameMode {
  VsAI
  Puzzle
  Local2P
}

///|
pub extend GameMode with Eq::{not_equal, equal}

///|
pub extend GameMode with Debug::{to_repr}

///|
pub impl Show for GameMode with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GameMode with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlayState {
  WaitingForMove
  AIThinking
  Animating
  GameOver
}

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
