///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Simulating
  LevelComplete
  LevelFailed
} derive(Eq, Show)

///|
pub(all) enum Polarity {
  North
  South
} derive(Eq, Show)

///|
pub(all) enum ComponentKind {
  Empty
  Magnet(Polarity)
  Coil
  Wire
  Device(Float)
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum ToolMode {
  PlaceMagnetN
  PlaceMagnetS
  PlaceCoil
  PlaceWire
  Erase
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Foundations
  Generators
  PowerGrid
} derive(Eq, Show)
