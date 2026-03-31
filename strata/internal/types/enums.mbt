///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum ClueKind {
  FossilAge
  Superposition
  Dating
  Intrusion
  Unconformity
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Arranging
  Checking
  Solved
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Surface
  Bedrock
  DeepCore
} derive(Eq, Show)
