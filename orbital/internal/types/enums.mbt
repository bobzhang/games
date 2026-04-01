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
  Aiming
  Flying
  Won
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Launch
  Slingshot
  Navigation
} derive(Eq, Show)
