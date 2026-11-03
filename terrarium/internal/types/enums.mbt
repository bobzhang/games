///|
#derive(Eq, Debug, ToJson)
pub(all) enum OrganismKind {
  Moss
  Fern
  Beetle
  Snail
  Fungus
  Worm
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
pub(all) enum ResourceKind {
  O2
  CO2
  Water
  Nutrients
}

///|
pub extend ResourceKind with Eq::{not_equal, equal}

///|
pub extend ResourceKind with Debug::{to_repr}

///|
pub extend ResourceKind with ToJson::{to_json}

///|
pub impl Show for ResourceKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ResourceKind with Show::{to_string, output}

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
  Beginner
  Intermediate
  Advanced
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
