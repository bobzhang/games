///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum DominoKind {
  Normal
  Heavy
  Splitter
  Delay
} derive(Eq, Show)

///|
pub(all) enum Orientation {
  N
  NE
  E
  SE
  S
  SW
  W
  NW
} derive(Eq, Show)

///|
pub(all) enum DominoState {
  Standing
  Toppling
  Fallen
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Editing
  Running
  Stepping
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Chains
  Splits
  Timing
} derive(Eq, Show)
