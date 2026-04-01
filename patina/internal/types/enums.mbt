///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum DamageKind {
  Crack
  Stain
  Fade
  Flake
} derive(Eq, Show)

///|
pub(all) enum ToolKind {
  Clean
  Fill
  Retouch
  Seal
} derive(Eq, Show)

///|
pub(all) enum RegionState {
  Pristine
  Damaged
  Treated
  Restored
  Worsened
  Sealed
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Selecting
  Animating
  LevelComplete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Sketches
  Paintings
  Masterworks
} derive(Eq, Show)
