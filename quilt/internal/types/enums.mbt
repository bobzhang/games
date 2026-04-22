///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
  Daily
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum EdgePattern {
  Zigzag
  Dots
  Stripes
  Waves
  Diamonds
  Stars
} derive(Eq, Debug)

///|
pub impl Show for EdgePattern with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  Selecting
  Swapping
  Complete
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Scraps
  Quilting
  Masterwork
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  North
  East
  South
  West
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
