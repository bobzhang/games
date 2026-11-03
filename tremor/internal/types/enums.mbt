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
pub(all) enum SensorKind {
  Broad
  Precise
  Directional
}

///|
pub extend SensorKind with Eq::{not_equal, equal}

///|
pub extend SensorKind with Debug::{to_repr}

///|
pub impl Show for SensorKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SensorKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum TileKind {
  Empty
  Blocked
  Town
  Noisy
}

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
#derive(Eq, Debug)
pub(all) enum PlayState {
  Placing
  Guessing
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
  Detection
  Precision
  Crisis
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

///|
#derive(Eq, Debug)
pub(all) enum CompassDir {
  North
  East
  South
  West
}

///|
pub extend CompassDir with Eq::{not_equal, equal}

///|
pub extend CompassDir with Debug::{to_repr}

///|
pub impl Show for CompassDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CompassDir with Show::{to_string, output}
