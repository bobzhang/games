///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum Note {
  C
  D
  E
  F
  G
  A
  B
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Idle
  Playing
  Finished
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Melody
  Harmony
  Counterpoint
} derive(Eq, Show)

///|
pub(all) enum IntervalQuality {
  Unison
  Second
  Third
  Tritone
  Fifth
  Sixth
  Seventh
} derive(Eq, Show)
