///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum NodeKind {
  Pulley
  Anchor
  WeightHook
  CrateHook
  Ratchet
} derive(Eq, Show)

///|
pub(all) enum ComponentKind {
  WeightComp
  CrateComp
  BucketComp
  BreakableRopeComp
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Idle
  ConnectingRope(Int)
  Settling
  Won
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Basics
  Chains
  Workshop
} derive(Eq, Show)

///|
pub(all) enum RopeSide {
  LeftSide
  RightSide
} derive(Eq, Show)
