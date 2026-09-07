///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
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
pub(all) enum Element {
  Fire
  Water
  Earth
  Air
  Light
  Shadow
  Steam
  Mud
  Magma
  Ice
  Lightning
  Dust
  Void
  Storm
  Obsidian
  Clay
} derive(Eq, Debug)

///|
pub extend Element with Eq::{not_equal, equal}

///|
pub extend Element with Debug::{to_repr}

///|
pub impl Show for Element with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Element with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Idle
  Adding
  Reacting
  Success
  Destroyed
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
  Apprentice
  Journeyman
  Master
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

///|
pub(all) enum ReactionResult {
  Transform(Element)
  Destroy
  NoReaction
} derive(Eq, Debug)

///|
pub extend ReactionResult with Eq::{not_equal, equal}

///|
pub extend ReactionResult with Debug::{to_repr}

///|
pub impl Show for ReactionResult with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ReactionResult with Show::{to_string, output}
