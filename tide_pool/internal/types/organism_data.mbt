///|
pub(all) struct OrganismProfile {
  kind : OrganismKind
  name : String
  symbol : String
  preferred_zone : Zone
  needs_submersion : Bool
  needs_exposure : Bool
  is_mobile : Bool
  is_predator : Bool
  prey : OrganismKind?
  health_decay_submerged : Float
  health_decay_exposed : Float
  health_regen : Float
} derive(Debug)

///|
pub extend OrganismProfile with Debug::{to_repr}

///|
pub fn get_profile(kind : OrganismKind) -> OrganismProfile {
  match kind {
    Barnacle =>
      {
        kind: Barnacle,
        name: "Barnacle",
        symbol: "B",
        preferred_zone: HighZone,
        needs_submersion: true,
        needs_exposure: false,
        is_mobile: false,
        is_predator: false,
        prey: None,
        health_decay_submerged: 0.0,
        health_decay_exposed: 15.0,
        health_regen: 20.0,
      }
    Anemone =>
      {
        kind: Anemone,
        name: "Anemone",
        symbol: "A",
        preferred_zone: LowZone,
        needs_submersion: true,
        needs_exposure: false,
        is_mobile: false,
        is_predator: false,
        prey: None,
        health_decay_submerged: 0.0,
        health_decay_exposed: 25.0,
        health_regen: 15.0,
      }
    Crab =>
      {
        kind: Crab,
        name: "Crab",
        symbol: "C",
        preferred_zone: MidZone,
        needs_submersion: false,
        needs_exposure: false,
        is_mobile: true,
        is_predator: false,
        prey: Some(Algae),
        health_decay_submerged: 5.0,
        health_decay_exposed: 5.0,
        health_regen: 10.0,
      }
    Starfish =>
      {
        kind: Starfish,
        name: "Starfish",
        symbol: "S",
        preferred_zone: LowZone,
        needs_submersion: true,
        needs_exposure: false,
        is_mobile: true,
        is_predator: true,
        prey: Some(Barnacle),
        health_decay_submerged: 0.0,
        health_decay_exposed: 20.0,
        health_regen: 12.0,
      }
    Algae =>
      {
        kind: Algae,
        name: "Algae",
        symbol: "G",
        preferred_zone: MidZone,
        needs_submersion: false,
        needs_exposure: true,
        is_mobile: false,
        is_predator: false,
        prey: None,
        health_decay_submerged: 12.0,
        health_decay_exposed: 0.0,
        health_regen: 18.0,
      }
    Urchin =>
      {
        kind: Urchin,
        name: "Urchin",
        symbol: "U",
        preferred_zone: LowZone,
        needs_submersion: true,
        needs_exposure: false,
        is_mobile: true,
        is_predator: false,
        prey: Some(Algae),
        health_decay_submerged: 0.0,
        health_decay_exposed: 18.0,
        health_regen: 10.0,
      }
  }
}

///|
pub fn organism_color(kind : OrganismKind) -> @raylib.Color {
  match kind {
    Barnacle => color_barnacle
    Anemone => color_anemone
    Crab => color_crab
    Starfish => color_starfish
    Algae => color_algae
    Urchin => color_urchin
  }
}

///|
pub fn organism_index(kind : OrganismKind) -> Int {
  match kind {
    Barnacle => 0
    Anemone => 1
    Crab => 2
    Starfish => 3
    Algae => 4
    Urchin => 5
  }
}

///|
pub fn organism_from_index(idx : Int) -> OrganismKind {
  match idx {
    0 => Barnacle
    1 => Anemone
    2 => Crab
    3 => Starfish
    4 => Algae
    _ => Urchin
  }
}

///|
pub fn zone_name(zone : Zone) -> String {
  match zone {
    HighZone => "High"
    MidZone => "Mid"
    LowZone => "Low"
  }
}
