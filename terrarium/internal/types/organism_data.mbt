///|
pub(all) struct OrganismProfile {
  kind : OrganismKind
  name : String
  category : String
  o2_delta : Float
  co2_delta : Float
  water_delta : Float
  nutrient_delta : Float
  min_water : Float
  min_o2 : Float
  min_co2 : Float
  min_nutrients : Float
} derive(Debug)

///|
pub extend OrganismProfile with Debug::{to_repr}

///|
pub fn get_profile(kind : OrganismKind) -> OrganismProfile {
  match kind {
    Moss =>
      {
        kind: Moss,
        name: "Moss",
        category: "Plant",
        o2_delta: 8.0,
        co2_delta: -4.0,
        water_delta: -3.0,
        nutrient_delta: -1.0,
        min_water: 5.0,
        min_o2: 0.0,
        min_co2: 2.0,
        min_nutrients: 2.0,
      }
    Fern =>
      {
        kind: Fern,
        name: "Fern",
        category: "Plant",
        o2_delta: 10.0,
        co2_delta: -6.0,
        water_delta: -6.0,
        nutrient_delta: 2.0,
        min_water: 10.0,
        min_o2: 0.0,
        min_co2: 3.0,
        min_nutrients: 3.0,
      }
    Beetle =>
      {
        kind: Beetle,
        name: "Beetle",
        category: "Herbivore",
        o2_delta: -5.0,
        co2_delta: 6.0,
        water_delta: -2.0,
        nutrient_delta: -1.0,
        min_water: 3.0,
        min_o2: 5.0,
        min_co2: 0.0,
        min_nutrients: 0.0,
      }
    Snail =>
      {
        kind: Snail,
        name: "Snail",
        category: "Herbivore",
        o2_delta: -3.0,
        co2_delta: 4.0,
        water_delta: -1.0,
        nutrient_delta: 3.0,
        min_water: 2.0,
        min_o2: 3.0,
        min_co2: 0.0,
        min_nutrients: 0.0,
      }
    Fungus =>
      {
        kind: Fungus,
        name: "Fungus",
        category: "Decomposer",
        o2_delta: -2.0,
        co2_delta: 3.0,
        water_delta: -2.0,
        nutrient_delta: 8.0,
        min_water: 4.0,
        min_o2: 2.0,
        min_co2: 0.0,
        min_nutrients: 0.0,
      }
    Worm =>
      {
        kind: Worm,
        name: "Worm",
        category: "Decomposer",
        o2_delta: -1.0,
        co2_delta: 2.0,
        water_delta: 3.0,
        nutrient_delta: 5.0,
        min_water: 2.0,
        min_o2: 2.0,
        min_co2: 0.0,
        min_nutrients: 0.0,
      }
  }
}

///|
pub fn organism_color(kind : OrganismKind) -> @raylib.Color {
  match kind {
    Moss => color_moss
    Fern => color_fern
    Beetle => color_beetle
    Snail => color_snail
    Fungus => color_fungus
    Worm => color_worm
  }
}

///|
pub fn organism_index(kind : OrganismKind) -> Int {
  match kind {
    Moss => 0
    Fern => 1
    Beetle => 2
    Snail => 3
    Fungus => 4
    Worm => 5
  }
}

///|
pub fn organism_from_index(idx : Int) -> OrganismKind {
  match idx {
    0 => Moss
    1 => Fern
    2 => Beetle
    3 => Snail
    4 => Fungus
    _ => Worm
  }
}

///|
pub fn organism_symbol(kind : OrganismKind) -> String {
  match kind {
    Moss => "M"
    Fern => "F"
    Beetle => "B"
    Snail => "S"
    Fungus => "G"
    Worm => "W"
  }
}

///|
pub fn resource_name(kind : ResourceKind) -> String {
  match kind {
    O2 => "O2"
    CO2 => "CO2"
    Water => "Water"
    Nutrients => "Nutrients"
  }
}

///|
pub fn resource_color(kind : ResourceKind) -> @raylib.Color {
  match kind {
    O2 => color_o2
    CO2 => color_co2
    Water => color_water
    Nutrients => color_nutrients
  }
}
