///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum Element {
  Fire
  Water
  Earth
  Air
  Light
  Shadow
  Steam
  Mud
  Magma
  Ice
  Lightning
  Dust
  Void
  Storm
  Obsidian
  Clay
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Idle
  Adding
  Reacting
  Success
  Destroyed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Apprentice
  Journeyman
  Master
} derive(Eq, Show)

///|
pub(all) enum ReactionResult {
  Transform(Element)
  Destroy
  NoReaction
} derive(Eq, Show)
