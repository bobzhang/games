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
pub(all) enum DominoKind {
  Normal
  Heavy
  Splitter
  Delay
} derive(Eq, Debug)

///|
pub impl Show for DominoKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Orientation {
  N
  NE
  E
  SE
  S
  SW
  W
  NW
} derive(Eq, Debug)

///|
pub impl Show for Orientation with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum DominoState {
  Standing
  Toppling
  Fallen
} derive(Eq, Debug)

///|
pub impl Show for DominoState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Editing
  Running
  Stepping
  Complete
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Chains
  Splits
  Timing
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
