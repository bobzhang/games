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
pub(all) enum RockKind {
  Sandstone
  Limestone
  Shale
  Granite
  Basalt
  Coal
  Chalk
  Slate
} derive(Eq, Debug)

///|
pub impl Show for RockKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ClueKind {
  FossilAge
  Superposition
  Dating
  Intrusion
  Unconformity
} derive(Eq, Debug)

///|
pub impl Show for ClueKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Arranging
  Checking
  Solved
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Surface
  Bedrock
  DeepCore
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
