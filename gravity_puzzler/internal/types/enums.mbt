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
pub(all) enum GravityDir {
  Down
  Up
  Left
  Right
} derive(Eq, Debug)

///|
pub extend GravityDir with Eq::{not_equal, equal}

///|
pub extend GravityDir with Debug::{to_repr}

///|
pub impl Show for GravityDir with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GravityDir with Show::{to_string, output}

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
pub(all) enum EntityKind {
  Player
  Box
  Boulder
  Key
  Gem
  Enemy
} derive(Eq, Debug)

///|
pub extend EntityKind with Eq::{not_equal, equal}

///|
pub extend EntityKind with Debug::{to_repr}

///|
pub impl Show for EntityKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EntityKind with Show::{to_string, output}

///|
pub(all) enum WorldTheme {
  Stone
  Crystal
  Void
  Magma
  Sky
} derive(Eq, Debug)

///|
pub extend WorldTheme with Eq::{not_equal, equal}

///|
pub extend WorldTheme with Debug::{to_repr}

///|
pub impl Show for WorldTheme with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend WorldTheme with Show::{to_string, output}

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
pub extend AchievementKind with Eq::{not_equal, equal}

///|
pub extend AchievementKind with Debug::{to_repr}

///|
pub impl Show for AchievementKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AchievementKind with Show::{to_string, output}

///|
pub(all) enum AccessibilityMode {
  Normal
  HighContrast
  LargeText
} derive(Eq, Debug)

///|
pub extend AccessibilityMode with Eq::{not_equal, equal}

///|
pub extend AccessibilityMode with Debug::{to_repr}

///|
pub impl Show for AccessibilityMode with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AccessibilityMode with Show::{to_string, output}
