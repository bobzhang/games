///|
test "plant_crop_basic" {
  let plot = @types.new_plot()
  let ok = plant_crop(plot, Wheat, Spring)
  assert_true(ok)
  assert_eq(plot.crop, Wheat)
  assert_eq(plot.state, Planted)
}

///|
test "plant_crop_wrong_season" {
  let plot = @types.new_plot()
  let ok = plant_crop(plot, Wheat, Summer)
  assert_false(ok)
  assert_eq(plot.state, Empty)
}

///|
test "plant_crop_poor_soil" {
  let plot = @types.new_plot_with_soil(5, 5, 5)
  let ok = plant_crop(plot, Corn, Spring)
  assert_false(ok)
}

///|
test "plant_clover_any_season" {
  let plot = @types.new_plot()
  assert_true(plant_crop(plot, Clover, Winter))
}

///|
test "plant_fallow_always" {
  let plot = @types.new_plot()
  assert_true(plant_crop(plot, Fallow, Summer))
}

///|
test "plant_on_occupied" {
  let plot = @types.new_plot()
  let _ = plant_crop(plot, Wheat, Spring)
  let ok = plant_crop(plot, Corn, Spring)
  assert_false(ok)
}

///|
test "advance_season_grows" {
  let grid = @types.new_grid()
  let _ = plant_crop(grid[0][0], Wheat, Spring)
  advance_season(grid, Summer)
  assert_eq(grid[0][0].state, Mature)
}

///|
test "corn_needs_two_seasons" {
  let grid = @types.new_grid()
  let _ = plant_crop(grid[0][0], Corn, Spring)
  advance_season(grid, Summer)
  assert_eq(grid[0][0].state, Growing)
  advance_season(grid, Fall)
  assert_eq(grid[0][0].state, Mature)
}

///|
test "harvest_mature_crops" {
  let grid = @types.new_grid()
  let flash = @types.new_anim_grid()
  let _ = plant_crop(grid[0][0], Wheat, Spring)
  advance_season(grid, Summer)
  assert_eq(grid[0][0].state, Mature)
  let value = harvest_mature(grid, flash)
  assert_true(value > 0)
  assert_eq(grid[0][0].state, Harvested)
}

///|
test "harvest_depletes_soil" {
  let grid = @types.new_grid()
  let flash = @types.new_anim_grid()
  let n_before = grid[0][0].soil.nitrogen
  let _ = plant_crop(grid[0][0], Wheat, Spring)
  advance_season(grid, Summer)
  let _ = harvest_mature(grid, flash)
  assert_true(grid[0][0].soil.nitrogen < n_before)
}

///|
test "clear_harvested_resets" {
  let grid = @types.new_grid()
  let flash = @types.new_anim_grid()
  let _ = plant_crop(grid[0][0], Wheat, Spring)
  advance_season(grid, Summer)
  let _ = harvest_mature(grid, flash)
  clear_harvested(grid)
  assert_eq(grid[0][0].state, Empty)
  assert_eq(grid[0][0].crop, Fallow)
}

///|
test "count_state_empty" {
  let grid = @types.new_grid()
  assert_eq(count_state(grid, Empty), 24)
}

///|
test "count_state_after_plant" {
  let grid = @types.new_grid()
  let _ = plant_crop(grid[0][0], Wheat, Spring)
  assert_eq(count_state(grid, Planted), 1)
  assert_eq(count_state(grid, Empty), 23)
}

///|
test "average_soil_quality_default" {
  let grid = @types.new_grid()
  assert_eq(average_soil_quality(grid), 80)
}

///|
test "count_viable_all_default" {
  let grid = @types.new_grid()
  assert_eq(count_viable_plots(grid), 24)
}

///|
test "simulate_year_produces_value" {
  let grid = @types.new_grid()
  let plans : Array[@types.SeasonPlan] = Array::new(capacity=4)
  for _i in 0..<4 {
    plans.push(@types.new_season_plan())
  }
  let flash = @types.new_anim_grid()
  // Plant wheat in spring
  plans[0].crops[0][0] = Wheat
  plans[0].crops[0][1] = Wheat
  let value = simulate_year(grid, plans, flash)
  assert_true(value > 0)
}

///|
test "soil_viable_check" {
  let rich = @types.new_soil(50, 50, 50)
  assert_true(soil_viable(rich))
  let poor = @types.new_soil(2, 2, 2)
  assert_false(soil_viable(poor))
}

///|
test "apply_plan_counts" {
  let grid = @types.new_grid()
  let plan = @types.new_season_plan()
  plan.crops[0][0] = Wheat
  plan.crops[0][1] = Potato
  plan.crops[1][0] = Wheat
  let planted = apply_plan(grid, plan, Spring)
  assert_eq(planted, 3)
}

///|
test "total_mature_value_zero" {
  let grid = @types.new_grid()
  assert_eq(total_mature_value(grid), 0)
}

///|
test "wither_past_harvest_season" {
  let grid = @types.new_grid()
  let _ = plant_crop(grid[0][0], Wheat, Spring)
  advance_season(grid, Summer)
  assert_eq(grid[0][0].state, Mature)
  advance_season(grid, Fall)
  assert_eq(grid[0][0].state, Withered)
}

///|
test "reset_grid_restores" {
  let grid = @types.new_grid()
  let _ = plant_crop(grid[0][0], Wheat, Spring)
  let soil_data : Array[Array[(Int, Int, Int)]] = []
  for _r in 0..<@types.grid_rows {
    let row : Array[(Int, Int, Int)] = []
    for _c in 0..<@types.grid_cols {
      row.push((60, 60, 60))
    }
    soil_data.push(row)
  }
  reset_grid(grid, soil_data)
  assert_eq(grid[0][0].state, Empty)
  assert_eq(grid[0][0].soil.nitrogen, 60)
}
