///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum ComponentKind {
  Source
  Crystal
  Filter
  Mirror
  Target
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum FilterColor {
  Red
  Green
  Blue
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Solved
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Fundamentals
  Chromatics
  Mastery
} derive(Eq, Show)

///|
/// Crystal refraction: beam turns 60 degrees left or right.
pub(all) enum CrystalFace {
  Left60
  Right60
} derive(Eq, Show)
