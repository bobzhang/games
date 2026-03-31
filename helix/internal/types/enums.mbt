///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum CellKind {
  Path
  Switch
  Gate
  SyncPoint
  OneShotSwitch
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Moving
  Blocked
  Won
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Coil
  Twist
  DoubleHelix
} derive(Eq, Show)

///|
pub(all) enum TokenKind {
  CW
  CCW
} derive(Eq, Show)
