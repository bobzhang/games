///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Simulating
  LevelComplete
  LevelFailed
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ComponentKind {
  Empty
  Battery
  Device(Float)
  Wire
  Fuse(Float)
  Switch(Bool)
} derive(Eq, Debug)

///|
pub impl Show for ComponentKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ToolMode {
  PlaceBattery
  PlaceWire
  PlaceFuse
  PlaceSwitch
  Erase
  ToggleSwitch
} derive(Eq, Debug)

///|
pub impl Show for ToolMode with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Basics
  Parallel
  Networks
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
