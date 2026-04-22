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
  Crystal
  Filter
  Mirror
  Target
} derive(Eq, Debug)

///|
pub impl Show for ComponentKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
/// Hex directions: 6 directions at 60-degree intervals for flat-top hexes.
/// E=0deg, NE=60deg, NW=120deg, W=180deg, SW=240deg, SE=300deg.
pub(all) enum HexDir {
  E
  NE
  NW
  W
  SW
  SE
} derive(Eq, Debug)

///|
pub impl Show for HexDir with output(self, logger) {
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
  Fundamentals
  Chromatics
  Mastery
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
/// Crystal refraction: beam turns 60 degrees left or right.
pub(all) enum CrystalFace {
  Left60
  Right60
} derive(Eq, Debug)

///|
pub impl Show for CrystalFace with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
