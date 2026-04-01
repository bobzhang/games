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
pub(all) enum ComponentKind {
  Empty
  Battery
  Device(Float)
  Wire
  Fuse(Float)
  Switch(Bool)
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
  PlaceBattery
  PlaceWire
  PlaceFuse
  PlaceSwitch
  Erase
  ToggleSwitch
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Basics
  Parallel
  Networks
} derive(Eq, Show)
