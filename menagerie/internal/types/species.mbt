///|
pub(all) struct SpeciesNeeds {
  name : String
  terrain_primary : Terrain
  terrain_primary_count : Int
  terrain_secondary : Terrain?
  terrain_secondary_count : Int
  water_adjacent : Bool
  water_adjacent_count : Int
  min_space : Int
  is_predator : Bool
  fears_predators : Bool
} derive(Show)

///|
pub fn species_needs(species : Species) -> SpeciesNeeds {
  match species {
    Lion =>
      {
        name: "Lion",
        terrain_primary: Grass,
        terrain_primary_count: 4,
        terrain_secondary: None,
        terrain_secondary_count: 0,
        water_adjacent: true,
        water_adjacent_count: 1,
        min_space: 6,
        is_predator: true,
        fears_predators: false,
      }
    Penguin =>
      {
        name: "Penguin",
        terrain_primary: Water,
        terrain_primary_count: 3,
        terrain_secondary: Some(Rock),
        terrain_secondary_count: 2,
        water_adjacent: false,
        water_adjacent_count: 0,
        min_space: 5,
        is_predator: false,
        fears_predators: true,
      }
    Elephant =>
      {
        name: "Elephant",
        terrain_primary: Grass,
        terrain_primary_count: 5,
        terrain_secondary: None,
        terrain_secondary_count: 0,
        water_adjacent: true,
        water_adjacent_count: 2,
        min_space: 8,
        is_predator: false,
        fears_predators: false,
      }
    Snake =>
      {
        name: "Snake",
        terrain_primary: Sand,
        terrain_primary_count: 3,
        terrain_secondary: Some(Rock),
        terrain_secondary_count: 1,
        water_adjacent: false,
        water_adjacent_count: 0,
        min_space: 4,
        is_predator: false,
        fears_predators: false,
      }
    Monkey =>
      {
        name: "Monkey",
        terrain_primary: Trees,
        terrain_primary_count: 4,
        terrain_secondary: None,
        terrain_secondary_count: 0,
        water_adjacent: true,
        water_adjacent_count: 1,
        min_space: 5,
        is_predator: false,
        fears_predators: false,
      }
    Bear =>
      {
        name: "Bear",
        terrain_primary: Trees,
        terrain_primary_count: 3,
        terrain_secondary: Some(Grass),
        terrain_secondary_count: 2,
        water_adjacent: false,
        water_adjacent_count: 0,
        min_space: 6,
        is_predator: true,
        fears_predators: false,
      }
  }
}

///|
pub fn species_color(species : Species) -> @raylib.Color {
  match species {
    Lion => color_lion
    Penguin => color_penguin
    Elephant => color_elephant
    Snake => color_snake
    Monkey => color_monkey
    Bear => color_bear
  }
}

///|
pub fn species_icon(species : Species) -> String {
  match species {
    Lion => "L"
    Penguin => "P"
    Elephant => "E"
    Snake => "S"
    Monkey => "M"
    Bear => "B"
  }
}

///|
pub fn terrain_color(terrain : Terrain) -> @raylib.Color {
  match terrain {
    Grass => color_grass
    Water => color_water
    Sand => color_sand
    Rock => color_rock
    Trees => color_trees
  }
}

///|
pub fn terrain_label(terrain : Terrain) -> String {
  match terrain {
    Grass => "Grass"
    Water => "Water"
    Sand => "Sand"
    Rock => "Rock"
    Trees => "Trees"
  }
}
