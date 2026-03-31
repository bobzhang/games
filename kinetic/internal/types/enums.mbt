///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum GearKind {
  Small
  Medium
  Large
  Belt
  Ratchet
} derive(Eq, Show)

///|
pub(all) enum RotDir {
  CW
  CCW
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Solved
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Gears
  Trains
  Workshop
} derive(Eq, Show)
