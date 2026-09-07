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
pub(all) enum ComponentKind {
  Empty
  Battery
  Device(Float)
  Wire
  Fuse(Float)
  Switch(Bool)
} derive(Eq, Debug)

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
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Debug)

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
pub(all) enum ToolMode {
  PlaceBattery
  PlaceWire
  PlaceFuse
  PlaceSwitch
  Erase
  ToggleSwitch
} derive(Eq, Debug)

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
pub(all) enum Tier {
  Basics
  Parallel
  Networks
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
