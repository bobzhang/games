///|
/// Plant a crop on a plot if conditions are met
pub fn plant_crop(
  plot : @types.Plot,
  kind : @types.CropKind,
  season : @types.Season,
) -> Bool {
  if plot.state != Empty {
    return false
  }
  if !@types.can_plant_in_season(kind, season) {
    return false
  }
  match kind {
    Fallow => {
      plot.crop = Fallow
      plot.state = Planted
      plot.growth_turns = 0
      plot.season_planted = season
      true
    }
    _ => {
      if !@types.soil_has_nutrients(plot.soil, kind) {
        return false
      }
      plot.crop = kind
      plot.state = Planted
      plot.growth_turns = 0
      plot.season_planted = season
      true
    }
  }
}

///|
/// Advance one season: grow planted crops
pub fn advance_season(
  grid : Array[Array[@types.Plot]],
  current_season : @types.Season,
) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let plot = grid[r][c]
      advance_plot(plot, current_season)
    }
  }
}

///|
/// Advance a single plot through one season
fn advance_plot(plot : @types.Plot, current_season : @types.Season) -> Unit {
  match plot.state {
    Planted => {
      let info = @types.crop_info(plot.crop)
      plot.growth_turns += 1
      if plot.growth_turns >= info.growth_time {
        // Check if we're in the harvest season
        if current_season == info.harvest_season ||
          plot.crop == Fallow ||
          plot.crop == Clover {
          plot.state = Mature
        } else {
          plot.state = Growing
        }
      } else {
        plot.state = Growing
      }
    }
    Growing => {
      let info = @types.crop_info(plot.crop)
      plot.growth_turns += 1
      if plot.growth_turns >= info.growth_time {
        if current_season == info.harvest_season ||
          plot.crop == Fallow ||
          plot.crop == Clover {
          plot.state = Mature
        }
      }
    }
    Mature =>
      // Stay mature until harvested; if past harvest season, wither
      if plot.crop != Fallow && plot.crop != Clover {
        let info = @types.crop_info(plot.crop)
        if current_season != info.harvest_season {
          plot.state = Withered
        }
      }
    _ => ()
  }
}

///|
/// Harvest all mature crops, return total value
pub fn harvest_mature(
  grid : Array[Array[@types.Plot]],
  flash : Array[Array[Float]],
) -> Int {
  let mut total = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let plot = grid[r][c]
      if plot.state == Mature {
        let value = @types.crop_yield_value(plot.crop, plot.soil)
        total += value
        // Apply nutrient cost
        @types.apply_crop_cost(plot.soil, plot.crop)
        // Mark as harvested
        plot.state = Harvested
        flash[r][c] = 1.0
      }
    }
  }
  total
}

///|
/// Clear harvested and withered plots for next planting
pub fn clear_harvested(grid : Array[Array[@types.Plot]]) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let plot = grid[r][c]
      if plot.state == Harvested || plot.state == Withered {
        plot.crop = Fallow
        plot.state = Empty
        plot.growth_turns = 0
      }
    }
  }
}

///|
/// Apply seasonal plan to the grid
pub fn apply_plan(
  grid : Array[Array[@types.Plot]],
  plan : @types.SeasonPlan,
  season : @types.Season,
) -> Int {
  let mut planted = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let crop = plan.crops[r][c]
      if crop != Fallow {
        if plant_crop(grid[r][c], crop, season) {
          planted += 1
        }
      }
    }
  }
  planted
}

///|
/// Count how many plots have a specific state
pub fn count_state(
  grid : Array[Array[@types.Plot]],
  state : @types.CropState,
) -> Int {
  let mut count = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if grid[r][c].state == state {
        count += 1
      }
    }
  }
  count
}

///|
/// Calculate total potential value of current mature crops
pub fn total_mature_value(grid : Array[Array[@types.Plot]]) -> Int {
  let mut total = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let plot = grid[r][c]
      if plot.state == Mature {
        total += @types.crop_yield_value(plot.crop, plot.soil)
      }
    }
  }
  total
}

///|
/// Check if soil can still support any crops
pub fn soil_viable(soil : @types.Soil) -> Bool {
  @types.soil_quality(soil) >= 10
}

///|
/// Count plots with viable soil
pub fn count_viable_plots(grid : Array[Array[@types.Plot]]) -> Int {
  let mut count = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if soil_viable(grid[r][c].soil) {
        count += 1
      }
    }
  }
  count
}

///|
/// Average soil quality across the grid
pub fn average_soil_quality(grid : Array[Array[@types.Plot]]) -> Int {
  let mut total = 0
  let count = @types.grid_rows * @types.grid_cols
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      total += @types.soil_quality(grid[r][c].soil)
    }
  }
  total / count
}

///|
/// Simulate entire year from plans, return total value
pub fn simulate_year(
  grid : Array[Array[@types.Plot]],
  plans : Array[@types.SeasonPlan],
  flash : Array[Array[Float]],
) -> Int {
  let mut total = 0
  for s in 0..<4 {
    let season = @types.season_from_index(s)
    // Clear old harvested plots
    clear_harvested(grid)
    // Apply plan for this season
    let _planted = apply_plan(grid, plans[s], season)
    // Advance season (grow crops)
    advance_season(grid, season)
    // Harvest mature crops
    let value = harvest_mature(grid, flash)
    total += value
  }
  total
}

///|
/// Reset grid to initial state with given soil
pub fn reset_grid(
  grid : Array[Array[@types.Plot]],
  soil_data : Array[Array[(Int, Int, Int)]],
) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let plot = grid[r][c]
      plot.crop = Fallow
      plot.state = Empty
      plot.growth_turns = 0
      if r < soil_data.length() && c < soil_data[r].length() {
        let (n, p, k) = soil_data[r][c]
        plot.soil.nitrogen = n
        plot.soil.phosphorus = p
        plot.soil.potassium = k
      } else {
        plot.soil.nitrogen = 80
        plot.soil.phosphorus = 80
        plot.soil.potassium = 80
      }
    }
  }
}
