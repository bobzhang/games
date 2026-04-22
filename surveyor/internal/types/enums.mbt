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
pub(all) enum TileKind {
  Empty
  House(Int) // color_id
  Road
  Water
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Drawing
  Checking
  Complete
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Plots
  Districts
  Zoning
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Orientation {
  Horizontal // fence on top/bottom edge of cell
  Vertical // fence on left/right edge of cell
} derive(Eq, Debug)

///|
pub impl Show for Orientation with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ConstraintResult {
  Satisfied
  Violated
  Unchecked
} derive(Eq, Debug)

///|
pub impl Show for ConstraintResult with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
