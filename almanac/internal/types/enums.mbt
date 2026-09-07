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
pub(all) enum WeatherState {
  Clear
  Sunny
  Rainy
  Cloudy
  Windy
  Stormy
} derive(Eq, Debug)

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
pub(all) enum SourceKind {
  Sun
  Rain
  Wind
} derive(Eq, Debug)

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
pub(all) enum PlayState {
  Placing
  Simulating
  Won
  Failed
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
  Spring
  Summer
  Monsoon
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
pub(all) enum WindDir {
  North
  East
  South
  West
} derive(Eq, Debug)

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
