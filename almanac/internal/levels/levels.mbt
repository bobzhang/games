///|
fn flat_heights() -> Array[Int] {
  let h : Array[Int] = []
  for _i in 0..<80 {
    h.push(0)
  }
  h
}

///|
fn make_heights(data : Array[Int]) -> Array[Int] {
  let h : Array[Int] = []
  for i in 0..<80 {
    if i < data.length() {
      h.push(data[i])
    } else {
      h.push(0)
    }
  }
  h
}

///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    // === TIER 1: SPRING (levels 0-7) - Sun + Rain only, flat terrain ===
    0 =>
      // "First Light" - Place one sun to make a tile sunny
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(5, 4, Sunny)],
        source_budget: [(Sun, 1)],
        par_sources: 1,
        par_turns: 1,
        tier: Spring,
        name: "First Light",
      }
    1 =>
      // "Morning Dew" - Place one rain to make a tile rainy
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(3, 3, Rainy)],
        source_budget: [(Rain, 1)],
        par_sources: 1,
        par_turns: 1,
        tier: Spring,
        name: "Morning Dew",
      }
    2 =>
      // "Sunshine Spread" - Sun makes multiple adjacent tiles sunny
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(4, 3, Sunny), (6, 3, Sunny)],
        source_budget: [(Sun, 2)],
        par_sources: 2,
        par_turns: 1,
        tier: Spring,
        name: "Sunshine Spread",
      }
    3 =>
      // "Rain Garden" - Rain two separate spots
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(2, 5, Rainy), (7, 2, Rainy)],
        source_budget: [(Rain, 2)],
        par_sources: 2,
        par_turns: 1,
        tier: Spring,
        name: "Rain Garden",
      }
    4 =>
      // "Cancel Out" - Sun and Rain cancel each other; keep one clear
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(5, 4, Clear), (5, 2, Sunny)],
        source_budget: [(Sun, 1), (Rain, 1)],
        par_sources: 2,
        par_turns: 1,
        tier: Spring,
        name: "Cancel Out",
      }
    5 =>
      // "Downpour" - Rain flows to adjacent tiles
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(3, 4, Rainy), (5, 4, Rainy), (4, 5, Rainy)],
        source_budget: [(Rain, 2)],
        par_sources: 2,
        par_turns: 2,
        tier: Spring,
        name: "Downpour",
      }
    6 =>
      // "Sunny Corridors" - Multiple sun targets in a row
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(3, 4, Sunny), (5, 4, Sunny), (7, 4, Sunny)],
        source_budget: [(Sun, 3)],
        par_sources: 2,
        par_turns: 1,
        tier: Spring,
        name: "Sunny Corridors",
      }
    7 =>
      // "Equilibrium" - Balance sun and rain with cancellation
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(3, 3, Sunny), (7, 3, Rainy), (5, 3, Clear)],
        source_budget: [(Sun, 2), (Rain, 2)],
        par_sources: 3,
        par_turns: 1,
        tier: Spring,
        name: "Equilibrium",
      }
    // === TIER 2: SUMMER (levels 8-16) - + Wind + clouds, hills ===
    8 =>
      // "Breeze" - Place wind to make tiles windy
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(5, 4, Windy)],
        source_budget: [(Wind, 1)],
        par_sources: 1,
        par_turns: 1,
        tier: Summer,
        name: "Breeze",
      }
    9 =>
      // "Cloud Cover" - Rain creates cloud above, target that cloud
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(4, 3, Cloudy)],
        source_budget: [(Rain, 1)],
        par_sources: 1,
        par_turns: 1,
        tier: Summer,
        name: "Cloud Cover",
      }
    10 =>
      // "Hill Rain" - Rain flows downhill from height 2 to 0
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [(4, 4, Rainy), (5, 4, Rainy)],
        source_budget: [(Rain, 1)],
        par_sources: 1,
        par_turns: 2,
        tier: Summer,
        name: "Hill Rain",
      }
    11 =>
      // "Storm Front" - Combine rain + wind for storm
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(5, 4, Stormy)],
        source_budget: [(Rain, 1), (Wind, 1)],
        par_sources: 2,
        par_turns: 1,
        tier: Summer,
        name: "Storm Front",
      }
    12 =>
      // "Cloud Blocker" - Use cloud to block sun
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(5, 3, Cloudy), (5, 5, Sunny)],
        source_budget: [(Sun, 1), (Rain, 1)],
        par_sources: 2,
        par_turns: 1,
        tier: Summer,
        name: "Cloud Blocker",
      }
    13 =>
      // "Wind Corridor" - Wind pushes clouds across the field
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(6, 3, Cloudy)],
        source_budget: [(Rain, 1), (Wind, 1)],
        par_sources: 2,
        par_turns: 2,
        tier: Summer,
        name: "Wind Corridor",
      }
    14 =>
      // "Hillside" - Terrain with height variation
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0,
            1, 2, 2, 2, 1, 0, 0, 0, 0, 0, 1, 2, 2, 2, 1, 0, 0, 0, 0, 0, 0, 1,
            1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [(3, 5, Rainy), (6, 5, Rainy)],
        source_budget: [(Rain, 1)],
        par_sources: 1,
        par_turns: 3,
        tier: Summer,
        name: "Hillside",
      }
    15 =>
      // "Sun Shield" - Use clouds to protect rainy tiles from sun
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(4, 4, Rainy), (6, 3, Cloudy), (6, 5, Sunny)],
        source_budget: [(Sun, 1), (Rain, 2)],
        par_sources: 3,
        par_turns: 1,
        tier: Summer,
        name: "Sun Shield",
      }
    16 =>
      // "Weather Mix" - Multiple weather types required
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [(2, 3, Sunny), (5, 3, Windy), (8, 3, Rainy)],
        source_budget: [(Sun, 1), (Rain, 1), (Wind, 1)],
        par_sources: 3,
        par_turns: 1,
        tier: Summer,
        name: "Weather Mix",
      }
    // === TIER 3: MONSOON (levels 17-24) - All weather, complex terrain, storms ===
    17 =>
      // "Monsoon Rising" - Multiple storms needed
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(3, 4, Stormy), (7, 4, Stormy)],
        source_budget: [(Rain, 2), (Wind, 2)],
        par_sources: 4,
        par_turns: 1,
        tier: Monsoon,
        name: "Monsoon Rising",
      }
    18 =>
      // "Mountain Pass" - Complex terrain with rain flow
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0,
            2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 2, 2,
            2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [(4, 3, Rainy), (5, 3, Rainy)],
        source_budget: [(Rain, 1)],
        par_sources: 1,
        par_turns: 2,
        tier: Monsoon,
        name: "Mountain Pass",
      }
    19 =>
      // "Eye of Storm" - Storm surrounding a clear center
      {
        grid_width: 10,
        grid_height: 8,
        heights: flat_heights(),
        targets: [(5, 4, Clear), (4, 4, Stormy), (6, 4, Stormy)],
        source_budget: [(Sun, 1), (Rain, 2), (Wind, 2)],
        par_sources: 4,
        par_turns: 1,
        tier: Monsoon,
        name: "Eye of Storm",
      }
    20 =>
      // "Cascade Falls" - Rain flows through multiple height levels
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0,
            0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [(3, 5, Rainy), (4, 5, Rainy), (3, 6, Rainy), (4, 6, Rainy)],
        source_budget: [(Rain, 1)],
        par_sources: 1,
        par_turns: 3,
        tier: Monsoon,
        name: "Cascade Falls",
      }
    21 =>
      // "Weather Wall" - Use terrain and clouds to create barriers
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [(3, 3, Sunny), (5, 3, Rainy), (7, 3, Windy)],
        source_budget: [(Sun, 1), (Rain, 1), (Wind, 1)],
        par_sources: 3,
        par_turns: 1,
        tier: Monsoon,
        name: "Weather Wall",
      }
    22 =>
      // "Thunder Valley" - Storms in a valley between hills
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 0, 0,
            1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
            0, 0, 1, 1, 0, 0, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [
          (4, 3, Stormy),
          (5, 3, Stormy),
          (4, 4, Rainy),
          (5, 4, Rainy),
        ],
        source_budget: [(Rain, 2), (Wind, 2)],
        par_sources: 3,
        par_turns: 2,
        tier: Monsoon,
        name: "Thunder Valley",
      }
    23 =>
      // "Pressure System" - Complex multi-weather with interactions
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0, 1,
            1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [
          (2, 3, Sunny),
          (4, 3, Cloudy),
          (7, 3, Stormy),
          (5, 5, Rainy),
        ],
        source_budget: [(Sun, 2), (Rain, 2), (Wind, 1)],
        par_sources: 4,
        par_turns: 2,
        tier: Monsoon,
        name: "Pressure System",
      }
    // 24 - Final level
    _ =>
      // "Perfect Storm" - Grand finale
      {
        grid_width: 10,
        grid_height: 8,
        heights: make_heights(
          [
            1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
            0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0, 1,
            1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0,
            0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ],
        ),
        targets: [
          (2, 2, Sunny),
          (4, 3, Stormy),
          (5, 3, Stormy),
          (7, 2, Rainy),
          (4, 5, Cloudy),
          (5, 5, Windy),
        ],
        source_budget: [(Sun, 2), (Rain, 3), (Wind, 2)],
        par_sources: 5,
        par_turns: 3,
        tier: Monsoon,
        name: "Perfect Storm",
      }
  }
}

///|
pub fn level_tier(index : Int) -> @types.Tier {
  if index < 8 {
    Spring
  } else if index < 17 {
    Summer
  } else {
    Monsoon
  }
}

///|
pub fn tier_levels(tier : @types.Tier) -> (Int, Int) {
  match tier {
    Spring => (0, 8)
    Summer => (8, 17)
    Monsoon => (17, 25)
  }
}
