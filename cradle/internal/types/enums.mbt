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
  Complete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Lines
  Weave
  Art
} derive(Eq, Show)
