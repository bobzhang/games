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
pub(all) enum TileColor {
  Red
  Blue
  Green
  Gold
  Purple
  White
} derive(Eq, Debug)

///|
pub impl Show for TileColor with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileShape {
  Square
  Triangle
  Arrow
  Diamond
  Circle
  Cross
} derive(Eq, Debug)

///|
pub impl Show for TileShape with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Orientation {
  N
  E
  S
  W
} derive(Eq, Debug)

///|
pub impl Show for Orientation with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum SymmetryKind {
  MirrorH
  MirrorV
  MirrorD
  Rotate2
  Rotate4
  Glide
} derive(Eq, Debug)

///|
pub impl Show for SymmetryKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  GuessSymmetry
  Complete
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Repair
  Restore
  Master
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
