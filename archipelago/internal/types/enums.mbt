///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Active
  Solved
  Checking
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Shores
  Straits
  Ocean
} derive(Eq, Show)

///|
pub(all) enum BridgeDir {
  Horizontal
  Vertical
} derive(Eq, Show)
