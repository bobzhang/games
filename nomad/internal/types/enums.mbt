///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Sand
  Dunes
  Oasis
  TradePost
  Ruins
  Sandstorm
  Destination
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Planning
  Executing
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  OasisTrail
  DuneSea
  LostCity
} derive(Eq, Show)
