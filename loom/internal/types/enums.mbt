///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Weaving
  Complete
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Apprentice
  Journeyman
  Master
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum WeaveType {
  Plain
  Twill
  Satin
  Herringbone
  Diamond
  Custom
} derive(Eq, Debug)

///|
pub impl Show for WeaveType with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CellState {
  WarpOver
  WeftOver
} derive(Eq, Debug)

///|
pub impl Show for CellState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
