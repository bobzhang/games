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
pub(all) enum TileColor {
  Red
  Blue
  Green
  Gold
  Purple
  White
} derive(Eq, Debug)

///|
pub extend TileColor with Eq::{not_equal, equal}

///|
pub extend TileColor with Debug::{to_repr}

///|
pub impl Show for TileColor with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileColor with Show::{to_string, output}

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
pub extend TileShape with Eq::{not_equal, equal}

///|
pub extend TileShape with Debug::{to_repr}

///|
pub impl Show for TileShape with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileShape with Show::{to_string, output}

///|
pub(all) enum Orientation {
  N
  E
  S
  W
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
pub(all) enum SymmetryKind {
  MirrorH
  MirrorV
  MirrorD
  Rotate2
  Rotate4
  Glide
} derive(Eq, Debug)

///|
pub extend SymmetryKind with Eq::{not_equal, equal}

///|
pub extend SymmetryKind with Debug::{to_repr}

///|
pub impl Show for SymmetryKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SymmetryKind with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Placing
  GuessSymmetry
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
  Repair
  Restore
  Master
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
