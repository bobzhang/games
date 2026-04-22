///|
pub(all) enum MetalKind {
  Iron
  Copper
  Tin
  Gold
  Carbon
  Zinc
} derive(Eq, Debug)

///|
pub impl Show for MetalKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Temperature {
  Low
  Medium
  High
} derive(Eq, Debug)

///|
pub impl Show for Temperature with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Blending
  LevelComplete
  LevelFailed
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
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
