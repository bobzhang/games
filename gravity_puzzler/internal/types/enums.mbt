///|
pub(all) enum Screen {
  Title
  Playing
  LevelComplete
  WorldSelect
  LevelSelect
  Paused
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
} derive(Eq, Show)

///|
pub(all) enum EntityKind {
  Player
  Box
  Boulder
  Key
  Gem
} derive(Eq, Show)

///|
pub(all) enum WorldTheme {
  Stone
  Crystal
  Void
  Magma
  Sky
} derive(Eq, Show)
