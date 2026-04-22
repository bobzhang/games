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
pub(all) enum InkChannel {
  Cyan
  Magenta
  Yellow
} derive(Eq, Debug)

///|
pub impl Show for InkChannel with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Paper
  Barrier
  Target
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  Spreading
  Won
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Watercolor
  Pigment
  Palette
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Debug)

///|
pub impl Show for StarRating with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
