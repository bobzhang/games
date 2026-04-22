///|
pub(all) enum Screen {
  Title
  TierSelect
  CaseSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ClueKind {
  Before
  After
  Because
  During
  NotAdjacent
} derive(Eq, Debug)

///|
pub impl Show for ClueKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Arranging
  Linking
  Validated
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Reports
  Investigations
  ColdCases
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
