///|
pub(all) enum OrganismKind {
  Moss
  Fern
  Beetle
  Snail
  Fungus
  Worm
} derive(Eq, Debug, ToJson)

///|
pub impl Show for OrganismKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ResourceKind {
  O2
  CO2
  Water
  Nutrients
} derive(Eq, Debug, ToJson)

///|
pub impl Show for ResourceKind with output(self, logger) {
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
  Organism(OrganismKind)
} derive(Eq, Debug, ToJson)

///|
pub impl Show for CellContent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Beginner
  Intermediate
  Advanced
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
