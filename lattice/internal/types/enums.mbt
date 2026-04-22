///|
pub(all) enum Screen {
  Title
  ModeSelect
  DifficultySelect
  Playing
  PuzzleSelect
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Player {
  Black
  White
} derive(Eq, Debug)

///|
pub impl Show for Player with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CellState {
  Empty
  Occupied(Player)
} derive(Eq, Debug)

///|
pub impl Show for CellState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PatternKind {
  Bridge
  Chain
  Triangle
  Diamond
  Fortress
  Ring
  Star
  Wall
} derive(Eq, Debug)

///|
pub impl Show for PatternKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Difficulty {
  Easy
  Normal
  Hard
} derive(Eq, Debug)

///|
pub impl Show for Difficulty with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GameMode {
  VsAI
  Puzzle
  Local2P
} derive(Eq, Debug)

///|
pub impl Show for GameMode with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  WaitingForMove
  AIThinking
  Animating
  GameOver
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
