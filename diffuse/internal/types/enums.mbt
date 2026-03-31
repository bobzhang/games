///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum InkChannel {
  Cyan
  Magenta
  Yellow
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Paper
  Barrier
  Target
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Spreading
  Won
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Watercolor
  Pigment
  Palette
} derive(Eq, Show)

///|
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Show)
