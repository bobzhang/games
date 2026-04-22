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
pub impl Show for Material with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Normal
  HeatSource(Float)
  Target(Float, Float)
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub(all) enum ToolMode {
  Place(Material)
  Erase
} derive(Eq, Debug)

///|
pub impl Show for ToolMode with output(self, logger) {
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
