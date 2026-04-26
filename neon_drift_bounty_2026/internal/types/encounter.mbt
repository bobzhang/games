///|
/// Enumerates scripted enemy formation patterns used by the encounter director.
pub(all) enum Formation {
  VShape
  ColumnRush
  FlankingPairs
  Random
} derive(Eq, Debug)

///|
pub impl Show for Formation with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
/// Enumerates themed road zone types that affect gameplay feel.
pub(all) enum RoadZone {
  NeonAlley
  IndustrialStrip
  HighwayOverpass
} derive(Eq, Debug)

///|
pub impl Show for RoadZone with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
/// Enumerates weapon upgrade paths the player can obtain.
pub(all) enum WeaponUpgrade {
  Spread
  Piercing
  Homing
} derive(Eq, Debug)

///|
pub impl Show for WeaponUpgrade with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
/// Enumerates road hazard types that appear on the road surface.
pub(all) enum HazardKind {
  OilSlick
  BarrierGate
  BlastZone
} derive(Eq, Debug)

///|
pub impl Show for HazardKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
/// Stores runtime data for a road hazard.
pub(all) struct Hazard {
  mut active : Bool
  mut kind : HazardKind
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut timer : Float
  mut warn_t : Float
} derive(Debug)

///|
pub impl Show for Hazard with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
/// Maximum number of active road hazards.
pub let max_hazards : Int = 40

///|
/// Creates a default inactive Hazard.
pub fn Hazard::new() -> Hazard {
  {
    active: false,
    kind: OilSlick,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    timer: 0.0,
    warn_t: 0.0,
  }
}

///|
/// Returns the road zone for a given stage number.
pub fn road_zone_for_stage(stage : Int) -> RoadZone {
  match stage % 3 {
    1 => NeonAlley
    2 => IndustrialStrip
    _ => HighwayOverpass
  }
}

///|
/// Returns true if the given stage number is a boss stage (every 3rd).
pub fn is_boss_stage(stage : Int) -> Bool {
  stage >= 3 && stage % 3 == 0
}

///|
/// Selects a formation based on stage progression and a roll value 0..99.
pub fn select_formation(stage : Int, roll : Int) -> Formation {
  if stage <= 2 {
    // Early stages: mostly random, occasional V-shape
    if roll < 70 {
      Random
    } else {
      VShape
    }
  } else if stage <= 5 {
    // Midgame: formation-heavy
    if roll < 25 {
      Random
    } else if roll < 50 {
      VShape
    } else if roll < 75 {
      ColumnRush
    } else {
      FlankingPairs
    }
    // Late game: all formations
  } else if roll < 15 {
    Random
  } else if roll < 40 {
    VShape
  } else if roll < 65 {
    ColumnRush
  } else {
    FlankingPairs
  }
}
