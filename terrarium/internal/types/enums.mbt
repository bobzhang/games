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
pub(all) enum ResourceKind {
  O2
  CO2
  Water
  Nutrients
} derive(Eq, Debug, ToJson)

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
  Beginner
  Intermediate
  Advanced
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
