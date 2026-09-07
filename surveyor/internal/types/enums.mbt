///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub extend Screen with Eq::{not_equal, equal}

///|
pub extend Screen with Debug::{to_repr}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

///|
pub(all) enum TileKind {
  Empty
  House(Int) // color_id
  Road
  Water
} derive(Eq, Debug)

///|
pub extend TileKind with Eq::{not_equal, equal}

///|
pub extend TileKind with Debug::{to_repr}

///|
pub impl Show for TileKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileKind with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Drawing
  Checking
  Complete
} derive(Eq, Debug)

///|
pub extend PlayState with Eq::{not_equal, equal}

///|
pub extend PlayState with Debug::{to_repr}

///|
pub impl Show for PlayState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayState with Show::{to_string, output}

///|
pub(all) enum Tier {
  Plots
  Districts
  Zoning
} derive(Eq, Debug)

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}

///|
pub(all) enum Orientation {
  Horizontal // fence on top/bottom edge of cell
  Vertical // fence on left/right edge of cell
} derive(Eq, Debug)

///|
pub extend Orientation with Eq::{not_equal, equal}

///|
pub extend Orientation with Debug::{to_repr}

///|
pub impl Show for Orientation with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Orientation with Show::{to_string, output}

///|
pub(all) enum ConstraintResult {
  Satisfied
  Violated
  Unchecked
} derive(Eq, Debug)

///|
pub extend ConstraintResult with Eq::{not_equal, equal}

///|
pub extend ConstraintResult with Debug::{to_repr}

///|
pub impl Show for ConstraintResult with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ConstraintResult with Show::{to_string, output}
