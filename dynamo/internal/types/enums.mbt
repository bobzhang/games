///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Simulating
  LevelComplete
  LevelFailed
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
pub(all) enum Polarity {
  North
  South
}

///|
pub extend Polarity with Eq::{not_equal, equal}

///|
pub extend Polarity with Debug::{to_repr}

///|
pub impl Show for Polarity with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Polarity with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum ComponentKind {
  Empty
  Magnet(Polarity)
  Coil
  Wire
  Device(Float)
}

///|
pub extend ComponentKind with Eq::{not_equal, equal}

///|
pub extend ComponentKind with Debug::{to_repr}

///|
pub impl Show for ComponentKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ComponentKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Direction {
  Up
  Down
  Left
  Right
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
pub(all) enum ToolMode {
  PlaceMagnetN
  PlaceMagnetS
  PlaceCoil
  PlaceWire
  Erase
}

///|
pub extend ToolMode with Eq::{not_equal, equal}

///|
pub extend ToolMode with Debug::{to_repr}

///|
pub impl Show for ToolMode with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ToolMode with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Tier {
  Foundations
  Generators
  PowerGrid
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
