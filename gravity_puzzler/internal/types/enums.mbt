///|
pub(all) enum Screen {
  Title
  Playing
  LevelComplete
  WorldSelect
  LevelSelect
  Paused
  Editor
  Statistics
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GravityDir {
  Down
  Up
  Left
  Right
} derive(Eq, Debug)

///|
pub impl Show for GravityDir with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Empty
  Wall
  Exit
  Spike
  Ice
  Portal(Int)
  Switch(Int)
  Gate(Int)
  Crumble
  Conveyor(GravityDir)
  PressurePlate(Int)
  Mirror(Int)
  GravityWell
  TimedLava
  WindGust(GravityDir)
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum EntityKind {
  Player
  Box
  Boulder
  Key
  Gem
  Enemy
} derive(Eq, Debug)

///|
pub impl Show for EntityKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum WorldTheme {
  Stone
  Crystal
  Void
  Magma
  Sky
} derive(Eq, Debug)

///|
pub impl Show for WorldTheme with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AchievementKind {
  FirstStep
  WorldMaster(Int)
  Speedster
  Perfectionist
  NoHints
  GemCollector
  KeyMaster
  Minimalist
  Explorer
  GhostRacer
  UndoFree
  AllWorlds
  GravitySpinner
  IceSlider
  Completionist
} derive(Eq, Debug)

///|
pub impl Show for AchievementKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AccessibilityMode {
  Normal
  HighContrast
  LargeText
} derive(Eq, Debug)

///|
pub impl Show for AccessibilityMode with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
