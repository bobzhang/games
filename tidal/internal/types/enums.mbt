///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub extend Screen with Eq::{not_equal, equal}

///|
pub extend Screen with Debug::{to_repr}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

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
pub extend TileKind with Eq::{not_equal, equal}

///|
pub extend TileKind with Debug::{to_repr}

///|
pub impl Show for TileKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileKind with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Editing
  Simulating
  Stepping
  Complete
  Failed
} derive(Eq, Debug)

///|
pub extend PlayState with Eq::{not_equal, equal}

///|
pub extend PlayState with Debug::{to_repr}

///|
pub impl Show for PlayState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayState with Show::{to_string, output}

///|
pub(all) enum PlaceableKind {
  PlaceEmitter
  PlaceReflector
  PlacePhaseShifter
  PlaceAbsorber
} derive(Eq, Debug)

///|
pub extend PlaceableKind with Eq::{not_equal, equal}

///|
pub extend PlaceableKind with Debug::{to_repr}

///|
pub impl Show for PlaceableKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlaceableKind with Show::{to_string, output}
