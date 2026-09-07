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
pub extend OrganismKind with Eq::{not_equal, equal}

///|
pub extend OrganismKind with Debug::{to_repr}

///|
pub extend OrganismKind with ToJson::{to_json}

///|
pub impl Show for OrganismKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend OrganismKind with Show::{to_string, output}

///|
pub(all) enum TidePhase {
  Low
  Mid
  High
} derive(Eq, Debug, ToJson)

///|
pub extend TidePhase with Eq::{not_equal, equal}

///|
pub extend TidePhase with Debug::{to_repr}

///|
pub extend TidePhase with ToJson::{to_json}

///|
pub impl Show for TidePhase with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TidePhase with Show::{to_string, output}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Simulating
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
pub(all) enum PlayResult {
  None
  Victory
  Failure(String)
} derive(Eq, Debug)

///|
pub extend PlayResult with Eq::{not_equal, equal}

///|
pub extend PlayResult with Debug::{to_repr}

///|
pub impl Show for PlayResult with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayResult with Show::{to_string, output}

///|
pub(all) enum CellContent {
  Empty
  Rock
  Organism(OrganismKind)
} derive(Eq, Debug, ToJson)

///|
pub extend CellContent with Eq::{not_equal, equal}

///|
pub extend CellContent with Debug::{to_repr}

///|
pub extend CellContent with ToJson::{to_json}

///|
pub impl Show for CellContent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CellContent with Show::{to_string, output}

///|
pub(all) enum Tier {
  Shallow
  Middle
  Deep
} derive(Eq, Debug)

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}

///|
pub(all) enum Zone {
  HighZone
  MidZone
  LowZone
} derive(Eq, Debug, ToJson)

///|
pub extend Zone with Eq::{not_equal, equal}

///|
pub extend Zone with Debug::{to_repr}

///|
pub extend Zone with ToJson::{to_json}

///|
pub impl Show for Zone with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Zone with Show::{to_string, output}
