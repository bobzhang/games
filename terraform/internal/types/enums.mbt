///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
}

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
#derive(Eq, Debug)
pub(all) enum BiomeKind {
  Barren
  Forest
  Ocean
  Desert
}

///|
pub extend BiomeKind with Eq::{not_equal, equal}

///|
pub extend BiomeKind with Debug::{to_repr}

///|
pub impl Show for BiomeKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend BiomeKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlayState {
  Painting
  Resolving
  Complete
  Failed
}

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
#derive(Eq, Debug)
pub(all) enum Tier {
  Seeds
  Balance
  Harmony
}

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
