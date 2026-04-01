///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Dirt
  Rock
  WaterSource
  River
  Goal
} derive(Eq, Show)

///|
pub(all) enum CropKind {
  Wheat
  Corn
  Berry
  Flower
} derive(Eq, Show)

///|
pub(all) enum CropState {
  Seed
  Growing
  Mature
  Harvested
} derive(Eq, Show)

///|
pub(all) enum Direction {
  NE
  E
  SE
  SW
  W
  NW
} derive(Eq, Show)

///|
pub(all) enum PlaceMode {
  CropPlace(CropKind)
  ChannelPlace
} derive(Eq, Show)

///|
pub(all) enum TurnPhase {
  Idle
  Placing
  Flowing
  Growing
  Harvesting
} derive(Eq, Show)
