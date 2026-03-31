///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum CellKind {
  Empty
  Trunk
  Branch
  Leaf
  Pruned
} derive(Eq, Show)

///|
pub(all) enum GrowthDir {
  Up
  UpLeft
  UpRight
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum Species {
  Pine
  Maple
  Cherry
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Waiting
  Growing
  Won
  Lost
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Tier1
  Tier2
  Tier3
} derive(Eq, Show)

///|
pub(all) enum ZoneKind {
  Required
  Forbidden
  TipTarget
} derive(Eq, Show)
