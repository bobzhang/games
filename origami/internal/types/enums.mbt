///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum FoldDir {
  Left
  Right
  Up
  Down
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Selecting
  Animating
  Complete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Folds
  Layers
  Craft
} derive(Eq, Show)

///|
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Show)
