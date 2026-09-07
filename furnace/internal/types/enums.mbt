///|
pub(all) enum Material {
  Empty
  Metal
  Stone
  Wood
  Insulator
  Glass
} derive(Eq, Debug)

///|
pub extend Material with Eq::{not_equal, equal}

///|
pub extend Material with Debug::{to_repr}

///|
pub impl Show for Material with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Material with Show::{to_string, output}

///|
pub(all) enum TileKind {
  Normal
  HeatSource(Float)
  Target(Float, Float)
} derive(Eq, Debug)

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
pub(all) enum ToolMode {
  Place(Material)
  Erase
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
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Debug)

///|
pub extend StarRating with Eq::{not_equal, equal}

///|
pub extend StarRating with Debug::{to_repr}

///|
pub impl Show for StarRating with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StarRating with Show::{to_string, output}
