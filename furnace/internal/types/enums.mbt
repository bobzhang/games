///|
pub(all) enum Material {
  Empty
  Metal
  Stone
  Wood
  Insulator
  Glass
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Normal
  HeatSource(Float)
  Target(Float, Float)
} derive(Eq, Show)

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
pub(all) enum ToolMode {
  Place(Material)
  Erase
} derive(Eq, Show)

///|
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Show)
