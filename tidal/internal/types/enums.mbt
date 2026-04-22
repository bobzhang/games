///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Empty
  Wall
  Target
  Emitter(Int) // phase 0-3
  Reflector
  PhaseShifter
  Absorber
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Editing
  Simulating
  Stepping
  Complete
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlaceableKind {
  PlaceEmitter
  PlaceReflector
  PlacePhaseShifter
  PlaceAbsorber
} derive(Eq, Debug)

///|
pub impl Show for PlaceableKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
