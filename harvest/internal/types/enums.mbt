///|
pub(all) enum Season {
  Spring
  Summer
  Fall
  Winter
} derive(Eq, Debug)

///|
pub impl Show for Season with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CropKind {
  Wheat
  Corn
  Tomato
  Potato
  Carrot
  Pumpkin
  Clover
  Fallow
} derive(Eq, Debug)

///|
pub impl Show for CropKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CropState {
  Empty
  Planted
  Growing
  Mature
  Harvested
  Withered
} derive(Eq, Debug)

///|
pub impl Show for CropState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Planning
  Simulate
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Nutrient {
  Nitrogen
  Phosphorus
  Potassium
} derive(Eq, Debug)

///|
pub impl Show for Nutrient with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Bronze
  Silver
  Gold
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
