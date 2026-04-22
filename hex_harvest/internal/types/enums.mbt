///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Dirt
  Rock
  WaterSource
  River
  Goal
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CropKind {
  Wheat
  Corn
  Berry
  Flower
} derive(Eq, Debug)

///|
pub impl Show for CropKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CropState {
  Seed
  Growing
  Mature
  Harvested
} derive(Eq, Debug)

///|
pub impl Show for CropState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  NE
  E
  SE
  SW
  W
  NW
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlaceMode {
  CropPlace(CropKind)
  ChannelPlace
} derive(Eq, Debug)

///|
pub impl Show for PlaceMode with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TurnPhase {
  Idle
  Placing
  Flowing
  Growing
  Harvesting
} derive(Eq, Debug)

///|
pub impl Show for TurnPhase with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
