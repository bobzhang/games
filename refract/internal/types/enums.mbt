///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum ComponentKind {
  Source
  Mirror
  Prism
  Filter
  Combiner
  Receiver
} derive(Eq, Show)

///|
pub(all) enum Direction {
  N
  E
  S
  W
} derive(Eq, Show)

///|
pub(all) enum FilterColor {
  Red
  Green
  Blue
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Solved
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Spectrum
  Prisms
  Synthesis
} derive(Eq, Show)
