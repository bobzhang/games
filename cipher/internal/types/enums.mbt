///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
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
pub(all) enum CipherKind {
  Caesar
  Substitution
  Vigenere
}

///|
pub extend CipherKind with Eq::{not_equal, equal}

///|
pub extend CipherKind with Debug::{to_repr}

///|
pub impl Show for CipherKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CipherKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlayState {
  Solving
  Solved
  GaveUp
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

///|
#derive(Eq, Debug)
pub(all) enum Tier {
  Recruit
  Agent
  Cryptographer
}

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Tool {
  FrequencyChart
  LetterSwap
  PatternFinder
}

///|
pub extend Tool with Eq::{not_equal, equal}

///|
pub extend Tool with Debug::{to_repr}

///|
pub impl Show for Tool with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tool with Show::{to_string, output}
