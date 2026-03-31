///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Paused
  Hacking
  Results
  Victory
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Floor
  Wall
  Shadow
  Terminal
  HighTerminal
  Door
  LaserGrid
  PowerNode
  Exit
  CameraTile
  Start
} derive(Eq, Show)

///|
pub(all) enum GuardKind {
  Patrol
  Sentinel
  Hunter
} derive(Eq, Show)

///|
pub(all) enum AlertState {
  Patrolling
  Suspicious
  Alert
} derive(Eq, Show)

///|
pub(all) enum HackState {
  None
  Instant
  Sequencing
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum SoundEvent {
  Footstep
  Run
  Hack
  DoorOpen
  LaserOff
  AlertTriggered
  CoinToss
  LevelComplete
} derive(Eq, Show)

///|
pub(all) enum ScoreGrade {
  S
  A
  B
  C
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Corporate
  Military
} derive(Eq, Show)
