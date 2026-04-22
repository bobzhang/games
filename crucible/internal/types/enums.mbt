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
} derive(Eq, Debug)

///|
pub impl Show for Element with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Idle
  Adding
  Reacting
  Success
  Destroyed
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
pub(all) enum ReactionResult {
  Transform(Element)
  Destroy
  NoReaction
} derive(Eq, Debug)

///|
pub impl Show for ReactionResult with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
