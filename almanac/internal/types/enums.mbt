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
pub(all) enum WeatherState {
  Clear
  Sunny
  Rainy
  Cloudy
  Windy
  Stormy
} derive(Eq, Debug)

///|
pub impl Show for WeatherState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum SourceKind {
  Sun
  Rain
  Wind
} derive(Eq, Debug)

///|
pub impl Show for SourceKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Won
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Spring
  Summer
  Monsoon
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum WindDir {
  North
  East
  South
  West
} derive(Eq, Debug)

///|
pub impl Show for WindDir with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
