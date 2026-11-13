///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Paused
  Hacking
  Results
  Victory
}

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
#derive(Eq, Debug)
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
}

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
#derive(Eq, Debug)
pub(all) enum GuardKind {
  Patrol
  Sentinel
  Hunter
}

///|
pub extend GuardKind with Eq::{not_equal, equal}

///|
pub extend GuardKind with Debug::{to_repr}

///|
pub impl Show for GuardKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GuardKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum AlertState {
  Patrolling
  Suspicious
  Alert
}

///|
pub extend AlertState with Eq::{not_equal, equal}

///|
pub extend AlertState with Debug::{to_repr}

///|
pub impl Show for AlertState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AlertState with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum HackState {
  None
  Instant
  Sequencing
  Complete
  Failed
}

///|
pub extend HackState with Eq::{not_equal, equal}

///|
pub extend HackState with Debug::{to_repr}

///|
pub impl Show for HackState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend HackState with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Direction {
  Up
  Down
  Left
  Right
}

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub extend Direction with Debug::{to_repr}

///|
pub impl Show for Direction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Direction with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum SoundEvent {
  Footstep
  Run
  Hack
  DoorOpen
  LaserOff
  AlertTriggered
  CoinToss
  LevelComplete
}

///|
pub extend SoundEvent with Eq::{not_equal, equal}

///|
pub extend SoundEvent with Debug::{to_repr}

///|
pub impl Show for SoundEvent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SoundEvent with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum ScoreGrade {
  S
  A
  B
  C
}

///|
pub extend ScoreGrade with Eq::{not_equal, equal}

///|
pub extend ScoreGrade with Debug::{to_repr}

///|
pub impl Show for ScoreGrade with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ScoreGrade with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Tier {
  Corporate
  Military
}

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}
