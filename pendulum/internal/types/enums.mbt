///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum CellKind {
  Empty
  Anchor
  Peg
  Goal
  Wall
  Collectible
} derive(Eq, Show)

///|
pub(all) enum SwingDir {
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum WeightState {
  Swinging
  Launched
  Stopped
  AtGoal
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Ready
  Simulating
  Won
  Lost
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Swing
  Wrap
  Launch
} derive(Eq, Show)
