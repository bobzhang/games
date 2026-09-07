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
pub extend Screen with Eq::{not_equal, equal}

///|
pub extend Screen with Debug::{to_repr}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

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
pub extend GlazeColor with Eq::{not_equal, equal}

///|
pub extend GlazeColor with Debug::{to_repr}

///|
pub extend GlazeColor with ToJson::{to_json}

///|
pub impl Show for GlazeColor with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GlazeColor with Show::{to_string, output}

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
pub extend FiredColor with Eq::{not_equal, equal}

///|
pub extend FiredColor with Debug::{to_repr}

///|
pub extend FiredColor with ToJson::{to_json}

///|
pub impl Show for FiredColor with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend FiredColor with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Placing
  ReadyToFire
  LevelComplete
} derive(Eq, Debug)

///|
pub extend PlayState with Eq::{not_equal, equal}

///|
pub extend PlayState with Debug::{to_repr}

///|
pub impl Show for PlayState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayState with Show::{to_string, output}

///|
pub(all) enum Tier {
  Beginner
  Intermediate
  Advanced
} derive(Eq, Debug)

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}
