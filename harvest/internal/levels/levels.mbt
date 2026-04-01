///|
/// Load a level by index (0-19)
pub fn load_level(index : Int) -> @types.LevelGoal {
  match index {
    0 => level_01()
    1 => level_02()
    2 => level_03()
    3 => level_04()
    4 => level_05()
    5 => level_06()
    6 => level_07()
    7 => level_08()
    8 => level_09()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    _ => level_01()
  }
}

///|
pub fn level_name(index : Int) -> String {
  match index {
    0 => "First Furrow"
    1 => "Spring Meadow"
    2 => "Double Crop"
    3 => "Rotation Basics"
    4 => "Clover Rest"
    5 => "Summer Harvest"
    6 => "Full Calendar"
    7 => "Depleted Fields"
    8 => "Corn Country"
    9 => "Nutrient Balance"
    10 => "Pumpkin Patch"
    11 => "Winter Prep"
    12 => "Mixed Farm"
    13 => "Soil Recovery"
    14 => "Dense Planting"
    15 => "Expert Rotation"
    16 => "Barren Start"
    17 => "Maximum Yield"
    18 => "Master Planner"
    19 => "Grand Harvest"
    _ => "Unknown"
  }
}

///|
pub fn level_tier(index : Int) -> String {
  if index < 7 {
    "Beginner"
  } else if index < 14 {
    "Intermediate"
  } else {
    "Expert"
  }
}

///|
fn uniform_soil(n : Int, p : Int, k : Int) -> Array[Array[(Int, Int, Int)]] {
  let data : Array[Array[(Int, Int, Int)]] = Array::new(
    capacity=@types.grid_rows,
  )
  for _r in 0..<@types.grid_rows {
    let row : Array[(Int, Int, Int)] = Array::new(capacity=@types.grid_cols)
    for _c in 0..<@types.grid_cols {
      row.push((n, p, k))
    }
    data.push(row)
  }
  data
}

///|
fn varied_soil(
  base_n : Int,
  base_p : Int,
  base_k : Int,
  variation : Int
) -> Array[Array[(Int, Int, Int)]] {
  let data : Array[Array[(Int, Int, Int)]] = Array::new(
    capacity=@types.grid_rows,
  )
  for r in 0..<@types.grid_rows {
    let row : Array[(Int, Int, Int)] = Array::new(capacity=@types.grid_cols)
    for c in 0..<@types.grid_cols {
      let offset = ((r + c) % 3 - 1) * variation
      let n = @types.clampi(base_n + offset, 0, 100)
      let p = @types.clampi(base_p - offset, 0, 100)
      let k = @types.clampi(base_k + offset * 2 / 3, 0, 100)
      row.push((n, p, k))
    }
    data.push(row)
  }
  data
}

// ============================================================
// Tier 1: Beginner (Levels 1-7)
// ============================================================

///|
fn level_01() -> @types.LevelGoal {
  // Just plant wheat in spring, harvest in summer
  {
    target_value: 10,
    bronze_threshold: 10,
    silver_threshold: 16,
    gold_threshold: 24,
    hint: "Plant wheat in spring. It grows fast!",
    locked_plots: [],
    initial_soil: uniform_soil(90, 90, 90),
  }
}

///|
fn level_02() -> @types.LevelGoal {
  // Plant multiple wheat, introduce potato
  {
    target_value: 20,
    bronze_threshold: 20,
    silver_threshold: 32,
    gold_threshold: 48,
    hint: "Try wheat and potatoes in spring.",
    locked_plots: [],
    initial_soil: uniform_soil(85, 85, 85),
  }
}

///|
fn level_03() -> @types.LevelGoal {
  // Plant spring crops, then summer crops
  {
    target_value: 30,
    bronze_threshold: 30,
    silver_threshold: 45,
    gold_threshold: 60,
    hint: "Plant in spring AND summer for more harvests.",
    locked_plots: [],
    initial_soil: uniform_soil(80, 80, 80),
  }
}

///|
fn level_04() -> @types.LevelGoal {
  // Introduce crop rotation concept
  {
    target_value: 40,
    bronze_threshold: 40,
    silver_threshold: 55,
    gold_threshold: 70,
    hint: "Different crops drain different nutrients. Rotate!",
    locked_plots: [],
    initial_soil: uniform_soil(75, 75, 75),
  }
}

///|
fn level_05() -> @types.LevelGoal {
  // Introduce clover for restoration
  {
    target_value: 35,
    bronze_threshold: 35,
    silver_threshold: 50,
    gold_threshold: 65,
    hint: "Clover restores soil nutrients. Use it wisely.",
    locked_plots: [],
    initial_soil: uniform_soil(50, 50, 50),
  }
}

///|
fn level_06() -> @types.LevelGoal {
  // Summer-focused: tomatoes and pumpkins
  {
    target_value: 45,
    bronze_threshold: 45,
    silver_threshold: 60,
    gold_threshold: 80,
    hint: "Tomatoes and pumpkins plant in summer.",
    locked_plots: [],
    initial_soil: uniform_soil(80, 80, 80),
  }
}

///|
fn level_07() -> @types.LevelGoal {
  // Use all four seasons
  {
    target_value: 55,
    bronze_threshold: 55,
    silver_threshold: 75,
    gold_threshold: 95,
    hint: "Plan all four seasons for maximum yield.",
    locked_plots: [],
    initial_soil: uniform_soil(80, 80, 80),
  }
}

// ============================================================
// Tier 2: Intermediate (Levels 8-14)
// ============================================================

///|
fn level_08() -> @types.LevelGoal {
  // Start with depleted soil
  {
    target_value: 40,
    bronze_threshold: 40,
    silver_threshold: 55,
    gold_threshold: 70,
    hint: "Soil is depleted. Fallow and clover help recover.",
    locked_plots: [],
    initial_soil: uniform_soil(30, 30, 30),
  }
}

///|
fn level_09() -> @types.LevelGoal {
  // Corn is high-value but uses 2 seasons
  {
    target_value: 60,
    bronze_threshold: 60,
    silver_threshold: 80,
    gold_threshold: 100,
    hint: "Corn takes two seasons but earns more.",
    locked_plots: [],
    initial_soil: uniform_soil(80, 85, 80),
  }
}

///|
fn level_10() -> @types.LevelGoal {
  // Nutrient-specific challenge
  {
    target_value: 50,
    bronze_threshold: 50,
    silver_threshold: 70,
    gold_threshold: 90,
    hint: "Watch each nutrient (N/P/K) separately!",
    locked_plots: [],
    initial_soil: varied_soil(80, 40, 60, 15),
  }
}

///|
fn level_11() -> @types.LevelGoal {
  // Pumpkin patch: heavy pumpkin focus
  {
    target_value: 55,
    bronze_threshold: 55,
    silver_threshold: 72,
    gold_threshold: 90,
    hint: "Pumpkins need good soil. Prepare in spring.",
    locked_plots: [],
    initial_soil: uniform_soil(75, 75, 75),
  }
}

///|
fn level_12() -> @types.LevelGoal {
  // Winter planning with carrots
  {
    target_value: 50,
    bronze_threshold: 50,
    silver_threshold: 65,
    gold_threshold: 85,
    hint: "Plant carrots in fall for winter harvest.",
    locked_plots: [],
    initial_soil: uniform_soil(70, 70, 70),
  }
}

///|
fn level_13() -> @types.LevelGoal {
  // Mixed farm with locked plots
  {
    target_value: 55,
    bronze_threshold: 55,
    silver_threshold: 75,
    gold_threshold: 95,
    hint: "Some plots are rocky. Work around them.",
    locked_plots: [(0, 0), (2, 1), (4, 2), (1, 3)],
    initial_soil: uniform_soil(70, 70, 70),
  }
}

///|
fn level_14() -> @types.LevelGoal {
  // Soil recovery challenge
  {
    target_value: 45,
    bronze_threshold: 45,
    silver_threshold: 65,
    gold_threshold: 85,
    hint: "Restore soil first, then maximize late harvests.",
    locked_plots: [],
    initial_soil: uniform_soil(20, 20, 20),
  }
}

// ============================================================
// Tier 3: Expert (Levels 15-20)
// ============================================================

///|
fn level_15() -> @types.LevelGoal {
  // Dense planting, careful rotation needed
  {
    target_value: 80,
    bronze_threshold: 80,
    silver_threshold: 105,
    gold_threshold: 130,
    hint: "Plant every plot every season if you can.",
    locked_plots: [],
    initial_soil: uniform_soil(80, 80, 80),
  }
}

///|
fn level_16() -> @types.LevelGoal {
  // Expert rotation: plan ahead
  {
    target_value: 90,
    bronze_threshold: 90,
    silver_threshold: 115,
    gold_threshold: 140,
    hint: "Think about what each season needs BEFORE planting.",
    locked_plots: [],
    initial_soil: varied_soil(70, 70, 70, 20),
  }
}

///|
fn level_17() -> @types.LevelGoal {
  // Barren start: almost no nutrients
  {
    target_value: 50,
    bronze_threshold: 50,
    silver_threshold: 70,
    gold_threshold: 90,
    hint: "Start with clover, build soil, then harvest.",
    locked_plots: [(5, 0), (5, 1)],
    initial_soil: uniform_soil(10, 10, 10),
  }
}

///|
fn level_18() -> @types.LevelGoal {
  // Maximum yield challenge
  {
    target_value: 100,
    bronze_threshold: 100,
    silver_threshold: 130,
    gold_threshold: 160,
    hint: "Every plot, every season. Perfect rotation.",
    locked_plots: [],
    initial_soil: uniform_soil(85, 85, 85),
  }
}

///|
fn level_19() -> @types.LevelGoal {
  // Master planner
  {
    target_value: 110,
    bronze_threshold: 110,
    silver_threshold: 140,
    gold_threshold: 175,
    hint: "Balance corn's long growth with quick crops.",
    locked_plots: [(0, 0), (5, 3)],
    initial_soil: varied_soil(65, 65, 65, 25),
  }
}

///|
fn level_20() -> @types.LevelGoal {
  // Grand harvest: everything matters
  {
    target_value: 120,
    bronze_threshold: 120,
    silver_threshold: 155,
    gold_threshold: 195,
    hint: "The ultimate challenge. Use every tool available.",
    locked_plots: [(2, 0), (3, 3), (0, 2)],
    initial_soil: varied_soil(55, 55, 55, 30),
  }
}
