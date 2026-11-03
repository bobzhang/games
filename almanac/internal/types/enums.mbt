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
pub(all) enum WeatherState {
  Clear
  Sunny
  Rainy
  Cloudy
  Windy
  Stormy
}

///|
pub extend WeatherState with Eq::{not_equal, equal}

///|
pub extend WeatherState with Debug::{to_repr}

///|
pub impl Show for WeatherState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend WeatherState with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum SourceKind {
  Sun
  Rain
  Wind
}

///|
pub extend SourceKind with Eq::{not_equal, equal}

///|
pub extend SourceKind with Debug::{to_repr}

///|
pub impl Show for SourceKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SourceKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlayState {
  Placing
  Simulating
  Won
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
  Spring
  Summer
  Monsoon
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
pub(all) enum WindDir {
  North
  East
  South
  West
}

///|
pub extend WindDir with Eq::{not_equal, equal}

///|
pub extend WindDir with Debug::{to_repr}

///|
pub impl Show for WindDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend WindDir with Show::{to_string, output}
