///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Empty
  Wall
  Target
  Emitter(Int) // phase 0-3
  Reflector
  PhaseShifter
  Absorber
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Editing
  Simulating
  Stepping
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum PlaceableKind {
  PlaceEmitter
  PlaceReflector
  PlacePhaseShifter
  PlaceAbsorber
} derive(Eq, Show)
