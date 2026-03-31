///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum CipherKind {
  Caesar
  Substitution
  Vigenere
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Solving
  Solved
  GaveUp
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Recruit
  Agent
  Cryptographer
} derive(Eq, Show)

///|
pub(all) enum Tool {
  FrequencyChart
  LetterSwap
  PatternFinder
} derive(Eq, Show)
