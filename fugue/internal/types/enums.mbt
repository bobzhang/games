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
pub(all) enum Note {
  C
  D
  E
  F
  G
  A
  B
} derive(Eq, Debug)

///|
pub impl Show for Note with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Idle
  Playing
  Finished
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Melody
  Harmony
  Counterpoint
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum IntervalQuality {
  Unison
  Second
  Third
  Tritone
  Fifth
  Sixth
  Seventh
} derive(Eq, Debug)

///|
pub impl Show for IntervalQuality with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
