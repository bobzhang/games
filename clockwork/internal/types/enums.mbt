///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Paused
  LevelComplete
  LevelFailed
} derive(Eq, Show)

///|
pub(all) enum ComponentKind {
  Gear(GearSize)
  Cam
  Spring
  Escapement
  Bell
} derive(Eq, Show)

///|
pub(all) enum GearSize {
  Small
  Medium
  Large
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum CamDirection {
  PushUp
  PushDown
  PushLeft
  PushRight
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Ticks
  Timing
  Clockwork
} derive(Eq, Show)

///|
pub(all) enum SimState {
  Idle
  Running
  Paused
  Complete
  Failed
} derive(Eq, Show)
