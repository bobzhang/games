///|
pub(all) enum OrganismKind {
  Barnacle
  Anemone
  Crab
  Starfish
  Algae
  Urchin
} derive(Eq, Show, ToJson)

///|
pub(all) enum TidePhase {
  Low
  Mid
  High
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
  Rock
  Organism(OrganismKind)
} derive(Eq, Show, ToJson)

///|
pub(all) enum Tier {
  Shallow
  Middle
  Deep
} derive(Eq, Show)

///|
pub(all) enum Zone {
  HighZone
  MidZone
  LowZone
} derive(Eq, Show, ToJson)
