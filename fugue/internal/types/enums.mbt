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
pub(all) enum Note {
  C
  D
  E
  F
  G
  A
  B
}

///|
pub extend Note with Eq::{not_equal, equal}

///|
pub extend Note with Debug::{to_repr}

///|
pub impl Show for Note with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Note with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlayState {
  Idle
  Playing
  Finished
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
  Melody
  Harmony
  Counterpoint
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
pub(all) enum IntervalQuality {
  Unison
  Second
  Third
  Tritone
  Fifth
  Sixth
  Seventh
}

///|
pub extend IntervalQuality with Eq::{not_equal, equal}

///|
pub extend IntervalQuality with Debug::{to_repr}

///|
pub impl Show for IntervalQuality with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend IntervalQuality with Show::{to_string, output}
