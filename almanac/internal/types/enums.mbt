///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum WeatherState {
  Clear
  Sunny
  Rainy
  Cloudy
  Windy
  Stormy
} derive(Eq, Show)

///|
pub(all) enum SourceKind {
  Sun
  Rain
  Wind
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Won
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Spring
  Summer
  Monsoon
} derive(Eq, Show)

///|
pub(all) enum WindDir {
  North
  East
  South
  West
} derive(Eq, Show)
