///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Firing
  Results
} derive(Eq, Show)

///|
pub(all) enum GlazeColor {
  Red
  Blue
  Green
  Gold
  White
  Black
  Empty
} derive(Eq, Show, ToJson)

///|
pub(all) enum FiredColor {
  FRed
  FBlue
  FGreen
  FGold
  FWhite
  FBlack
  FPurple
  FDeepRed
  FDeepBlue
  FDeepGreen
  FDeepGold
  FDeepWhite
  FDeepBlack
  FCracked
  FEmpty
} derive(Eq, Show, ToJson)

///|
pub(all) enum PlayState {
  Placing
  ReadyToFire
  LevelComplete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Beginner
  Intermediate
  Advanced
} derive(Eq, Show)
