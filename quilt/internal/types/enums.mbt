///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
  Daily
} derive(Eq, Show)

///|
pub(all) enum EdgePattern {
  Zigzag
  Dots
  Stripes
  Waves
  Diamonds
  Stars
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Selecting
  Swapping
  Complete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Scraps
  Quilting
  Masterwork
} derive(Eq, Show)

///|
pub(all) enum Direction {
  North
  East
  South
  West
} derive(Eq, Show)
