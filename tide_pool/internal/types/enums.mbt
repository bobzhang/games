///|
pub(all) enum OrganismKind {
  Barnacle
  Anemone
  Crab
  Starfish
  Algae
  Urchin
} derive(Eq, Debug, ToJson)

///|
pub impl Show for OrganismKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TidePhase {
  Low
  Mid
  High
} derive(Eq, Debug, ToJson)

///|
pub impl Show for TidePhase with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Simulating
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayResult {
  None
  Victory
  Failure(String)
} derive(Eq, Debug)

///|
pub impl Show for PlayResult with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CellContent {
  Empty
  Rock
  Organism(OrganismKind)
} derive(Eq, Debug, ToJson)

///|
pub impl Show for CellContent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Shallow
  Middle
  Deep
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Zone {
  HighZone
  MidZone
  LowZone
} derive(Eq, Debug, ToJson)

///|
pub impl Show for Zone with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
