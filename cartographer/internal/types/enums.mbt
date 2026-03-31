///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum FeatureKind {
  Mountain
  River
  Forest
  Town
  Lake
  Desert
  Road
} derive(Eq, Show)

///|
pub(all) enum ClueKind {
  Distance
  Direction
  Adjacent
  Count
  Between
  Not
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Complete
  Checking
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Surveyor
  Explorer
  Master
} derive(Eq, Show)

///|
pub(all) enum CompassDir {
  N
  S
  E
  W
  NE
  NW
  SE
  SW
} derive(Eq, Show)

///|
pub(all) enum ClueStatus {
  Pending
  Satisfied
  Violated
} derive(Eq, Show)
