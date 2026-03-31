///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum BiomeKind {
  Barren
  Forest
  Ocean
  Desert
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Painting
  Resolving
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Seeds
  Balance
  Harmony
} derive(Eq, Show)
