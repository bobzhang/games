///|
pub(all) enum Tile {
  Empty
  Floor
  Wall
  Gap
  Exit
  Switch(Int)
  Platform
  Gem
} derive(Eq, Show)

///|
pub(all) enum Screen {
  Title
  Playing
  LevelSelect
  LevelComplete
  GameComplete
  Paused
} derive(Eq, Show)

///|
pub(all) enum Layer {
  Foreground
  Background
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Reflection
  Overlap
  Illusion
} derive(Eq, Show)

///|
pub(all) enum MergeState {
  Split
  Merged
} derive(Eq, Show)

///|
pub(all) enum AnimKind {
  LayerSwap
  Merge
  PlayerMove
  SwitchToggle
  LevelClear
  GemCollect
} derive(Eq, Show)
