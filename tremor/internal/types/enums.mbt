///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum SensorKind {
  Broad
  Precise
  Directional
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Empty
  Blocked
  Town
  Noisy
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Guessing
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Detection
  Precision
  Crisis
} derive(Eq, Show)

///|
pub(all) enum CompassDir {
  North
  East
  South
  West
} derive(Eq, Show)
