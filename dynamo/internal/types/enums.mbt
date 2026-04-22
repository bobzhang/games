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
pub(all) enum Polarity {
  North
  South
} derive(Eq, Debug)

///|
pub impl Show for Polarity with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ComponentKind {
  Empty
  Magnet(Polarity)
  Coil
  Wire
  Device(Float)
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
  PlaceMagnetN
  PlaceMagnetS
  PlaceCoil
  PlaceWire
  Erase
} derive(Eq, Debug)

///|
pub impl Show for ToolMode with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Foundations
  Generators
  PowerGrid
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
