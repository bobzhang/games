///|
pub(all) enum Terrain {
  Grass
  Water
  Sand
  Rock
  Trees
} derive(Eq, Show, Compare)

///|
pub(all) enum Species {
  Lion
  Penguin
  Elephant
  Snake
  Monkey
  Bear
} derive(Eq, Show, Compare)

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  LevelComplete
  Paused
} derive(Eq, Show)

///|
pub(all) enum Tool {
  TerrainBrush(Terrain)
  FenceTool
  EraserTool
  AnimalPlacer(Species)
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Show)
