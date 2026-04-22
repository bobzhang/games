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
pub(all) enum DamageKind {
  Crack
  Stain
  Fade
  Flake
} derive(Eq, Debug)

///|
pub impl Show for DamageKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ToolKind {
  Clean
  Fill
  Retouch
  Seal
} derive(Eq, Debug)

///|
pub impl Show for ToolKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum RegionState {
  Pristine
  Damaged
  Treated
  Restored
  Worsened
  Sealed
} derive(Eq, Debug)

///|
pub impl Show for RegionState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Selecting
  Animating
  LevelComplete
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Sketches
  Paintings
  Masterworks
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
