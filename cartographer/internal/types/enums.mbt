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
pub(all) enum FeatureKind {
  Mountain
  River
  Forest
  Town
  Lake
  Desert
  Road
} derive(Eq, Debug)

///|
pub impl Show for FeatureKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ClueKind {
  Distance
  Direction
  Adjacent
  Count
  Between
  Not
} derive(Eq, Debug)

///|
pub impl Show for ClueKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  Complete
  Checking
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Surveyor
  Explorer
  Master
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CompassDir {
  N
  S
  E
  W
  NE
  NW
  SE
  SW
} derive(Eq, Debug)

///|
pub impl Show for CompassDir with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ClueStatus {
  Pending
  Satisfied
  Violated
} derive(Eq, Debug)

///|
pub impl Show for ClueStatus with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum HintLevel {
  None
  Narrow // First hint: highlight possible cells for a feature
  Reveal // Second hint: highlight a specific cell
  Answer // Third hint: auto-place the answer
} derive(Eq, Debug)

///|
pub impl Show for HintLevel with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
