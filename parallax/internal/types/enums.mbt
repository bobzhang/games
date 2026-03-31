///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum ViewKind {
  Top
  Front
  Side
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Editing
  Complete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Shapes
  Structures
  Sculptures
} derive(Eq, Show)
