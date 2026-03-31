///|
pub(all) enum Screen {
  Title
  TierSelect
  CaseSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum ClueKind {
  Before
  After
  Because
  During
  NotAdjacent
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Arranging
  Linking
  Validated
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Reports
  Investigations
  ColdCases
} derive(Eq, Show)
