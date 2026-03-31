///|
pub(all) enum Screen {
  Title
  ModeSelect
  DifficultySelect
  Playing
  PuzzleSelect
  Results
} derive(Eq, Show)

///|
pub(all) enum Player {
  Black
  White
} derive(Eq, Show)

///|
pub(all) enum CellState {
  Empty
  Occupied(Player)
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum Difficulty {
  Easy
  Normal
  Hard
} derive(Eq, Show)

///|
pub(all) enum GameMode {
  VsAI
  Puzzle
  Local2P
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  WaitingForMove
  AIThinking
  Animating
  GameOver
} derive(Eq, Show)
