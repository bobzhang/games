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
pub(all) enum ComponentKind {
  Source
  Crystal
  Filter
  Mirror
  Target
} derive(Eq, Debug)

///|
pub extend ComponentKind with Eq::{not_equal, equal}

///|
pub extend ComponentKind with Debug::{to_repr}

///|
pub impl Show for ComponentKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ComponentKind with Show::{to_string, output}

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
pub extend HexDir with Eq::{not_equal, equal}

///|
pub extend HexDir with Debug::{to_repr}

///|
pub impl Show for HexDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend HexDir with Show::{to_string, output}

///|
pub(all) enum FilterColor {
  Red
  Green
  Blue
} derive(Eq, Debug)

///|
pub extend FilterColor with Eq::{not_equal, equal}

///|
pub extend FilterColor with Debug::{to_repr}

///|
pub impl Show for FilterColor with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend FilterColor with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Solved
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
  Fundamentals
  Chromatics
  Mastery
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
/// Crystal refraction: beam turns 60 degrees left or right.
pub(all) enum CrystalFace {
  Left60
  Right60
} derive(Eq, Debug)

///|
pub extend CrystalFace with Eq::{not_equal, equal}

///|
pub extend CrystalFace with Debug::{to_repr}

///|
pub impl Show for CrystalFace with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CrystalFace with Show::{to_string, output}
