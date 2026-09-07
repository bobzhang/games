///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

// Grid coordinate helpers

///|
pub fn cell_x(col : Int) -> Int {
  grid_offset_x + col * cell_size
}

///|
pub fn cell_y(row : Int) -> Int {
  grid_offset_y + row * cell_size
}

///|
pub fn pixel_to_grid(px : Int, py : Int) -> (Int, Int) {
  let col = (px - grid_offset_x) / cell_size
  let row = (py - grid_offset_y) / cell_size
  (col, row)
}

///|
pub fn in_bounds(col : Int, row : Int) -> Bool {
  col >= 0 && col < grid_cols && row >= 0 && row < grid_rows
}

///|
pub fn in_grid_area(px : Int, py : Int) -> Bool {
  px >= grid_offset_x &&
  px < grid_offset_x + grid_cols * cell_size &&
  py >= grid_offset_y &&
  py < grid_offset_y + grid_rows * cell_size
}

// Season helpers

///|
pub fn season_name(s : Season) -> String {
  match s {
    Spring => "Spring"
    Summer => "Summer"
    Fall => "Fall"
    Winter => "Winter"
  }
}

///|
pub fn season_from_index(i : Int) -> Season {
  match i % 4 {
    0 => Spring
    1 => Summer
    2 => Fall
    _ => Winter
  }
}

///|
pub fn season_index(s : Season) -> Int {
  match s {
    Spring => 0
    Summer => 1
    Fall => 2
    Winter => 3
  }
}

///|
pub fn season_color(s : Season) -> @raylib.Color {
  match s {
    Spring => color_spring
    Summer => color_summer
    Fall => color_fall
    Winter => color_winter
  }
}

///|
pub fn next_season(s : Season) -> Season {
  match s {
    Spring => Summer
    Summer => Fall
    Fall => Winter
    Winter => Spring
  }
}

// Crop info table

///|
pub fn crop_info(kind : CropKind) -> CropInfo {
  match kind {
    Wheat =>
      {
        name: "Wheat",
        plant_season: Some(Spring),
        growth_time: 1,
        harvest_season: Summer,
        value: 8,
        n_cost: 20,
        p_cost: 10,
        k_cost: 10,
      }
    Corn =>
      {
        name: "Corn",
        plant_season: Some(Spring),
        growth_time: 2,
        harvest_season: Fall,
        value: 15,
        n_cost: 30,
        p_cost: 15,
        k_cost: 10,
      }
    Tomato =>
      {
        name: "Tomato",
        plant_season: Some(Summer),
        growth_time: 1,
        harvest_season: Fall,
        value: 12,
        n_cost: 15,
        p_cost: 25,
        k_cost: 15,
      }
    Potato =>
      {
        name: "Potato",
        plant_season: Some(Spring),
        growth_time: 1,
        harvest_season: Summer,
        value: 10,
        n_cost: 10,
        p_cost: 10,
        k_cost: 25,
      }
    Carrot =>
      {
        name: "Carrot",
        plant_season: Some(Fall),
        growth_time: 1,
        harvest_season: Winter,
        value: 9,
        n_cost: 10,
        p_cost: 20,
        k_cost: 10,
      }
    Pumpkin =>
      {
        name: "Pumpkin",
        plant_season: Some(Summer),
        growth_time: 1,
        harvest_season: Fall,
        value: 14,
        n_cost: 20,
        p_cost: 20,
        k_cost: 20,
      }
    Clover =>
      {
        name: "Clover",
        plant_season: None,
        growth_time: 1,
        harvest_season: Spring,
        value: 2,
        n_cost: -30,
        p_cost: -20,
        k_cost: -20,
      }
    Fallow =>
      {
        name: "Fallow",
        plant_season: None,
        growth_time: 0,
        harvest_season: Spring,
        value: 0,
        n_cost: -10,
        p_cost: -10,
        k_cost: -10,
      }
  }
}

///|
pub fn crop_color(kind : CropKind) -> @raylib.Color {
  match kind {
    Wheat => color_wheat
    Corn => color_corn
    Tomato => color_tomato
    Potato => color_potato
    Carrot => color_carrot
    Pumpkin => color_pumpkin
    Clover => color_clover
    Fallow => color_fallow
  }
}

///|
pub fn crop_name(kind : CropKind) -> String {
  crop_info(kind).name
}

///|
pub fn can_plant_in_season(kind : CropKind, season : Season) -> Bool {
  match kind {
    Clover | Fallow => true
    _ => {
      let info = crop_info(kind)
      match info.plant_season {
        Some(s) => s == season
        None => true
      }
    }
  }
}

// Soil helpers

///|
pub fn new_soil(n : Int, p : Int, k : Int) -> Soil {
  { nitrogen: n, phosphorus: p, potassium: k, }
}

///|
pub fn default_soil() -> Soil {
  new_soil(80, 80, 80)
}

///|
pub fn soil_quality(soil : Soil) -> Int {
  (soil.nitrogen + soil.phosphorus + soil.potassium) / 3
}

///|
pub fn soil_has_nutrients(soil : Soil, kind : CropKind) -> Bool {
  let info = crop_info(kind)
  // Negative costs mean restoration; always allowed
  if info.n_cost <= 0 && info.p_cost <= 0 && info.k_cost <= 0 {
    return true
  }
  soil.nitrogen >= maxi(info.n_cost, 0) &&
  soil.phosphorus >= maxi(info.p_cost, 0) &&
  soil.potassium >= maxi(info.k_cost, 0)
}

///|
pub fn apply_crop_cost(soil : Soil, kind : CropKind) -> Unit {
  let info = crop_info(kind)
  soil.nitrogen = clampi(soil.nitrogen - info.n_cost, 0, max_nutrient)
  soil.phosphorus = clampi(soil.phosphorus - info.p_cost, 0, max_nutrient)
  soil.potassium = clampi(soil.potassium - info.k_cost, 0, max_nutrient)
}

///|
pub fn soil_color(soil : Soil) -> @raylib.Color {
  let q = soil_quality(soil)
  if q >= 70 {
    color_soil_rich
  } else if q >= 45 {
    color_soil_medium
  } else if q >= 20 {
    color_soil_poor
  } else {
    color_soil_depleted
  }
}

// Crop yield calculation based on soil quality

///|
pub fn crop_yield_value(kind : CropKind, soil : Soil) -> Int {
  let info = crop_info(kind)
  let quality = soil_quality(soil)
  let base = info.value
  // Soil quality multiplier: 100% at q>=70, 75% at q>=45, 50% at q>=20, 25% below
  if quality >= 70 {
    base
  } else if quality >= 45 {
    maxi(base * 3 / 4, 1)
  } else if quality >= 20 {
    maxi(base / 2, 1)
  } else {
    maxi(base / 4, 1)
  }
}

// Plot helpers

///|
pub fn new_plot() -> Plot {
  {
    crop: Fallow,
    state: Empty,
    growth_turns: 0,
    soil: default_soil(),
    season_planted: Spring,
  }
}

///|
pub fn new_plot_with_soil(n : Int, p : Int, k : Int) -> Plot {
  {
    crop: Fallow,
    state: Empty,
    growth_turns: 0,
    soil: new_soil(n, p, k),
    season_planted: Spring,
  }
}

// Grid helpers

///|
pub fn new_grid() -> Array[Array[Plot]] {
  let grid : Array[Array[Plot]] = Array(capacity=grid_rows)
  for _r in 0..<grid_rows {
    let row : Array[Plot] = Array(capacity=grid_cols)
    for _c in 0..<grid_cols {
      row.push(new_plot())
    }
    grid.push(row)
  }
  grid
}

///|
pub fn new_grid_with_soil(
  soil_data : Array[Array[(Int, Int, Int)]],
) -> Array[Array[Plot]] {
  let grid : Array[Array[Plot]] = Array(capacity=grid_rows)
  for r in 0..<grid_rows {
    let row : Array[Plot] = Array(capacity=grid_cols)
    for c in 0..<grid_cols {
      if r < soil_data.length() && c < soil_data[r].length() {
        let (n, p, k) = soil_data[r][c]
        row.push(new_plot_with_soil(n, p, k))
      } else {
        row.push(new_plot())
      }
    }
    grid.push(row)
  }
  grid
}

///|
pub fn new_season_plan() -> SeasonPlan {
  let crops : Array[Array[CropKind]] = Array(capacity=grid_rows)
  for _r in 0..<grid_rows {
    let row : Array[CropKind] = Array(capacity=grid_cols)
    for _c in 0..<grid_cols {
      row.push(Fallow)
    }
    crops.push(row)
  }
  { crops, }
}

///|
pub fn new_anim_grid() -> Array[Array[Float]] {
  let grid : Array[Array[Float]] = Array(capacity=grid_rows)
  for _r in 0..<grid_rows {
    let row : Array[Float] = Array(capacity=grid_cols)
    for _c in 0..<grid_cols {
      row.push(0.0)
    }
    grid.push(row)
  }
  grid
}

// Constructors

///|
pub fn new_level_score() -> LevelScore {
  { value_earned: 0, target_value: 0, tier: None, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore?] = Array(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(None)
  }
  let plans : Array[SeasonPlan] = Array(capacity=seasons_per_year)
  for _i in 0..<seasons_per_year {
    plans.push(new_season_plan())
  }
  {
    screen: Title,
    level_index: 0,
    grid: new_grid(),
    season: Spring,
    season_index: 0,
    plans,
    planning_season: 0,
    selected_crop: Wheat,
    hover_col: -1,
    hover_row: -1,
    hover_valid: false,
    total_value: 0,
    season_value: 0,
    level_scores: scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    menu_selection: 0,
    sim_timer: 0.0,
    sim_season: 0,
    sim_step: 0,
    fade_timer: 0.0,
    scroll_offset: 0,
    anim_timer: 0.0,
    harvest_flash: new_anim_grid(),
    growth_anim: new_anim_grid(),
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Bronze => "Bronze"
    Silver => "Silver"
    Gold => "Gold"
  }
}

///|
pub fn tier_from_value(
  value : Int,
  bronze : Int,
  silver : Int,
  gold : Int,
) -> Tier? {
  if value >= gold {
    Some(Gold)
  } else if value >= silver {
    Some(Silver)
  } else if value >= bronze {
    Some(Bronze)
  } else {
    None
  }
}

///|
pub fn tier_stars(t : Tier?) -> Int {
  match t {
    Some(Gold) => 3
    Some(Silver) => 2
    Some(Bronze) => 1
    None => 0
  }
}

///|
pub fn all_crops() -> Array[CropKind] {
  [Wheat, Corn, Tomato, Potato, Carrot, Pumpkin, Clover, Fallow]
}
