///|
pub(all) enum Screen {
  Title
  WorldSelect
  LevelSelect
  Playing
  Results
  Paused
} derive(Eq, Show)

///|
pub(all) enum ObjectKind {
  Wall
  Target
  Splitter
  OneWayGate
  Bumper
  Pickup
} derive(Eq, Show)

///|
pub(all) enum BallState {
  Aiming
  Moving
  Complete
  Failed
} derive(Eq, Show)
