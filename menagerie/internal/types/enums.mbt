///|
pub(all) enum Terrain {
  Grass
  Water
  Sand
  Rock
  Trees
} derive(Eq, Debug, Compare)

///|
pub extend Terrain with Eq::{not_equal, equal}

///|
pub extend Terrain with Debug::{to_repr}

///|
pub extend Terrain with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub impl Show for Terrain with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Terrain with Show::{to_string, output}

///|
pub(all) enum Species {
  Lion
  Penguin
  Elephant
  Snake
  Monkey
  Bear
} derive(Eq, Debug, Compare)

///|
pub extend Species with Eq::{not_equal, equal}

///|
pub extend Species with Debug::{to_repr}

///|
pub extend Species with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub impl Show for Species with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Species with Show::{to_string, output}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  LevelComplete
  Paused
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
pub(all) enum Tool {
  TerrainBrush(Terrain)
  FenceTool
  EraserTool
  AnimalPlacer(Species)
} derive(Eq, Debug)

///|
pub extend Tool with Eq::{not_equal, equal}

///|
pub extend Tool with Debug::{to_repr}

///|
pub impl Show for Tool with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tool with Show::{to_string, output}

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
