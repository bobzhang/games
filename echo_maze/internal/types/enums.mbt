///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Planning
  Results
  Paused
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Floor
  Wall
  Start
  Exit
  Button(Int) // button_id
  Door(Int) // door_id
  TimedDoor(Int, Int) // door_id, duration in ticks
  Guard
  Collectible
} derive(Eq, Show)

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Recording
  Reviewing
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum GhostColor {
  Green
  Yellow
  Orange
} derive(Eq, Show)

///|
pub(all) enum GuardAlertState {
  Idle
  Alert
  Chasing
} derive(Eq, Show)
