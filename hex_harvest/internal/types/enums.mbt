///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
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
pub(all) enum TileKind {
  Dirt
  Rock
  WaterSource
  River
  Goal
}

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
#derive(Eq, Debug)
pub(all) enum CropKind {
  Wheat
  Corn
  Berry
  Flower
}

///|
pub extend CropKind with Eq::{not_equal, equal}

///|
pub extend CropKind with Debug::{to_repr}

///|
pub impl Show for CropKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CropKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum CropState {
  Seed
  Growing
  Mature
  Harvested
}

///|
pub extend CropState with Eq::{not_equal, equal}

///|
pub extend CropState with Debug::{to_repr}

///|
pub impl Show for CropState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CropState with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Direction {
  NE
  E
  SE
  SW
  W
  NW
}

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub extend Direction with Debug::{to_repr}

///|
pub impl Show for Direction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Direction with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PlaceMode {
  CropPlace(CropKind)
  ChannelPlace
}

///|
pub extend PlaceMode with Eq::{not_equal, equal}

///|
pub extend PlaceMode with Debug::{to_repr}

///|
pub impl Show for PlaceMode with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlaceMode with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum TurnPhase {
  Idle
  Placing
  Flowing
  Growing
  Harvesting
}

///|
pub extend TurnPhase with Eq::{not_equal, equal}

///|
pub extend TurnPhase with Debug::{to_repr}

///|
pub impl Show for TurnPhase with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TurnPhase with Show::{to_string, output}
