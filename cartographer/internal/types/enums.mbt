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
pub(all) enum FeatureKind {
  Mountain
  River
  Forest
  Town
  Lake
  Desert
  Road
}

///|
pub extend FeatureKind with Eq::{not_equal, equal}

///|
pub extend FeatureKind with Debug::{to_repr}

///|
pub impl Show for FeatureKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend FeatureKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum ClueKind {
  Distance
  Direction
  Adjacent
  Count
  Between
  Not
}

///|
pub extend ClueKind with Eq::{not_equal, equal}

///|
pub extend ClueKind with Debug::{to_repr}

///|
pub impl Show for ClueKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ClueKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlayState {
  Placing
  Complete
  Checking
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
  Surveyor
  Explorer
  Master
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
pub(all) enum CompassDir {
  N
  S
  E
  W
  NE
  NW
  SE
  SW
}

///|
pub extend CompassDir with Eq::{not_equal, equal}

///|
pub extend CompassDir with Debug::{to_repr}

///|
pub impl Show for CompassDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CompassDir with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum ClueStatus {
  Pending
  Satisfied
  Violated
}

///|
pub extend ClueStatus with Eq::{not_equal, equal}

///|
pub extend ClueStatus with Debug::{to_repr}

///|
pub impl Show for ClueStatus with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ClueStatus with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum HintLevel {
  None
  Narrow // First hint: highlight possible cells for a feature
  Reveal // Second hint: highlight a specific cell
  Answer // Third hint: auto-place the answer
}

///|
pub extend HintLevel with Eq::{not_equal, equal}

///|
pub extend HintLevel with Debug::{to_repr}

///|
pub impl Show for HintLevel with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend HintLevel with Show::{to_string, output}
