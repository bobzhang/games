///|
pub(all) enum Terrain {
  Grass
  Water
  Sand
  Rock
  Trees
} derive(Eq, Debug, Compare)

///|
pub impl Show for Terrain with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for Species with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  LevelComplete
  Paused
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tool {
  TerrainBrush(Terrain)
  FenceTool
  EraserTool
  AnimalPlacer(Species)
} derive(Eq, Debug)

///|
pub impl Show for Tool with output(self, logger) {
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
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Debug)

///|
pub impl Show for StarRating with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
