///|
pub(all) enum OrganismKind {
  Moss
  Fern
  Beetle
  Snail
  Fungus
  Worm
} derive(Eq, Show, ToJson)

///|
pub(all) enum ResourceKind {
  O2
  CO2
  Water
  Nutrients
} derive(Eq, Show, ToJson)

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Simulating
  Results
} derive(Eq, Show)

///|
pub(all) enum PlayResult {
  None
  Victory
  Failure(String)
} derive(Eq, Show)

///|
pub(all) enum CellContent {
  Empty
  Organism(OrganismKind)
} derive(Eq, Show, ToJson)

///|
pub(all) enum Tier {
  Beginner
  Intermediate
  Advanced
} derive(Eq, Show)
