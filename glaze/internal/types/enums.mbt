///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Firing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GlazeColor {
  Red
  Blue
  Green
  Gold
  White
  Black
  Empty
} derive(Eq, Debug, ToJson)

///|
pub impl Show for GlazeColor with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
} derive(Eq, Debug, ToJson)

///|
pub impl Show for FiredColor with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  ReadyToFire
  LevelComplete
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Beginner
  Intermediate
  Advanced
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
