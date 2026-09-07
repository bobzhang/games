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
pub(all) enum DamageKind {
  Crack
  Stain
  Fade
  Flake
} derive(Eq, Debug)

///|
pub extend DamageKind with Eq::{not_equal, equal}

///|
pub extend DamageKind with Debug::{to_repr}

///|
pub impl Show for DamageKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend DamageKind with Show::{to_string, output}

///|
pub(all) enum ToolKind {
  Clean
  Fill
  Retouch
  Seal
} derive(Eq, Debug)

///|
pub extend ToolKind with Eq::{not_equal, equal}

///|
pub extend ToolKind with Debug::{to_repr}

///|
pub impl Show for ToolKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ToolKind with Show::{to_string, output}

///|
pub(all) enum RegionState {
  Pristine
  Damaged
  Treated
  Restored
  Worsened
  Sealed
} derive(Eq, Debug)

///|
pub extend RegionState with Eq::{not_equal, equal}

///|
pub extend RegionState with Debug::{to_repr}

///|
pub impl Show for RegionState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend RegionState with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Selecting
  Animating
  LevelComplete
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
  Sketches
  Paintings
  Masterworks
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
