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
pub(all) enum ComponentKind {
  Source
  Mirror
  Prism
  Filter
  Combiner
  Receiver
} derive(Eq, Debug)

///|
pub impl Show for ComponentKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  N
  E
  S
  W
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum FilterColor {
  Red
  Green
  Blue
} derive(Eq, Debug)

///|
pub impl Show for FilterColor with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Solved
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Spectrum
  Prisms
  Synthesis
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
