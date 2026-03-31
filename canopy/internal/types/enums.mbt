///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum CellKind {
  Empty
  Trunk
  Branch
  Leaf
  Shadow
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Idle
  Animating
  Won
  Lost
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Seedling
  Grove
  Forest
} derive(Eq, Show)
