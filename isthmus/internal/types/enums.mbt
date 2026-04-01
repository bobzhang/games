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
  Placing
  Rising
  Won
  Lost
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Shores
  Straits
  Archipelago
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Land
  Water
  Settlement
  Sand
} derive(Eq, Show)
