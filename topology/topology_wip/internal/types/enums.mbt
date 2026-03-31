///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum OpKind {
  Shift
  Rotate
  Flip
  Grow
  Shrink
} derive(Eq, Show)

///|
pub(all) enum Direction {
  N
  E
  S
  W
} derive(Eq, Show)

///|
pub(all) enum FlipAxis {
  Horizontal
  Vertical
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Idle
  SelectingDirection
  SelectingFlipAxis
  SelectingGrowCell
  SelectingShrinkCell
  AnimatingOp
  Won
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Morph
  Sculpt
  Transform
} derive(Eq, Show)

///|
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Show)
