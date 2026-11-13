///|
#derive(Eq, Debug, ToJson)
pub(all) enum OrganismKind {
  Barnacle
  Anemone
  Crab
  Starfish
  Algae
  Urchin
}

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
#derive(Eq, Debug, ToJson)
pub(all) enum TidePhase {
  Low
  Mid
  High
}

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
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Simulating
  Results
}

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
#derive(Eq, Debug)
pub(all) enum PlayResult {
  None
  Victory
  Failure(String)
}

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
#derive(Eq, Debug, ToJson)
pub(all) enum CellContent {
  Empty
  Rock
  Organism(OrganismKind)
}

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
#derive(Eq, Debug)
pub(all) enum Tier {
  Shallow
  Middle
  Deep
}

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
#derive(Eq, Debug, ToJson)
pub(all) enum Zone {
  HighZone
  MidZone
  LowZone
}

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
