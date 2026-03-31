///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Completed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Vertices
  Edges
  Sculpt
} derive(Eq, Show)
