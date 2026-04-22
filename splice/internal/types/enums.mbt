///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Base {
  A
  T
  G
  C
} derive(Eq, Debug)

///|
pub impl Show for Base with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for Trait with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum OpKind {
  Cut
  Insert
  Duplicate
  Invert
  Delete
} derive(Eq, Debug)

///|
pub impl Show for OpKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Editing
  Verified
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  LabBasics
  GeneEditing
  Mastery
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
