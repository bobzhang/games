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
pub(all) enum Base {
  A
  T
  G
  C
} derive(Eq, Debug)

///|
pub extend Base with Eq::{not_equal, equal}

///|
pub extend Base with Debug::{to_repr}

///|
pub impl Show for Base with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Base with Show::{to_string, output}

///|
pub(all) enum Trait {
  Start
  Stop
  Strength
  Speed
  Shield
  Stealth
  Heal
  Poison
  Armor
  Vision
  Neutral
} derive(Eq, Debug)

///|
pub extend Trait with Eq::{not_equal, equal}

///|
pub extend Trait with Debug::{to_repr}

///|
pub impl Show for Trait with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Trait with Show::{to_string, output}

///|
pub(all) enum OpKind {
  Cut
  Insert
  Duplicate
  Invert
  Delete
} derive(Eq, Debug)

///|
pub extend OpKind with Eq::{not_equal, equal}

///|
pub extend OpKind with Debug::{to_repr}

///|
pub impl Show for OpKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend OpKind with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Editing
  Verified
  Failed
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
  LabBasics
  GeneEditing
  Mastery
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
