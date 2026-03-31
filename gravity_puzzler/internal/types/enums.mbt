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
} derive(Eq, Show)

///|
pub(all) enum GravityDir {
  Down
  Up
  Left
  Right
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum EntityKind {
  Player
  Box
  Boulder
  Key
  Gem
  Enemy
} derive(Eq, Show)

///|
pub(all) enum WorldTheme {
  Stone
  Crystal
  Void
  Magma
  Sky
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum AccessibilityMode {
  Normal
  HighContrast
  LargeText
} derive(Eq, Show)
