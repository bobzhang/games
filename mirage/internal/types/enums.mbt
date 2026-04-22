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
} derive(Eq, Debug)

///|
pub impl Show for Tile with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Screen {
  Title
  Playing
  LevelSelect
  LevelComplete
  GameComplete
  Paused
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Layer {
  Foreground
  Background
} derive(Eq, Debug)

///|
pub impl Show for Layer with output(self, logger) {
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
pub(all) enum Tier {
  Reflection
  Overlap
  Illusion
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum MergeState {
  Split
  Merged
} derive(Eq, Debug)

///|
pub impl Show for MergeState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AnimKind {
  LayerSwap
  Merge
  PlayerMove
  SwitchToggle
  LevelClear
  GemCollect
} derive(Eq, Debug)

///|
pub impl Show for AnimKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
