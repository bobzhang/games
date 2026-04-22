///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CipherKind {
  Caesar
  Substitution
  Vigenere
} derive(Eq, Debug)

///|
pub impl Show for CipherKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Solving
  Solved
  GaveUp
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Recruit
  Agent
  Cryptographer
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tool {
  FrequencyChart
  LetterSwap
  PatternFinder
} derive(Eq, Debug)

///|
pub impl Show for Tool with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
