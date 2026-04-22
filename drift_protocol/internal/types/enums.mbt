///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Paused
  Hacking
  Results
  Victory
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GuardKind {
  Patrol
  Sentinel
  Hunter
} derive(Eq, Debug)

///|
pub impl Show for GuardKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AlertState {
  Patrolling
  Suspicious
  Alert
} derive(Eq, Debug)

///|
pub impl Show for AlertState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum HackState {
  None
  Instant
  Sequencing
  Complete
  Failed
} derive(Eq, Debug)

///|
pub impl Show for HackState with output(self, logger) {
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
pub(all) enum SoundEvent {
  Footstep
  Run
  Hack
  DoorOpen
  LaserOff
  AlertTriggered
  CoinToss
  LevelComplete
} derive(Eq, Debug)

///|
pub impl Show for SoundEvent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ScoreGrade {
  S
  A
  B
  C
} derive(Eq, Debug)

///|
pub impl Show for ScoreGrade with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Corporate
  Military
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
