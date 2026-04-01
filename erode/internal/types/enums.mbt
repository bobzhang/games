///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum ForceKind {
  Water
  WindLeft
  WindRight
  Frost
  Heat
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Selecting
  Previewing(ForceKind)
  Animating
  Won
  Lost
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Clay
  Stone
  Crystal
} derive(Eq, Show)
