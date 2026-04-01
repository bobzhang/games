///|
test "in_bounds_valid" {
  assert_true(in_bounds(0, 0))
  assert_true(in_bounds(5, 3))
  assert_true(in_bounds(3, 2))
}

///|
test "in_bounds_invalid" {
  assert_false(in_bounds(-1, 0))
  assert_false(in_bounds(0, -1))
  assert_false(in_bounds(6, 0))
  assert_false(in_bounds(0, 4))
}

///|
test "season_cycle" {
  assert_eq(next_season(Spring), Summer)
  assert_eq(next_season(Summer), Fall)
  assert_eq(next_season(Fall), Winter)
  assert_eq(next_season(Winter), Spring)
}

///|
test "season_from_index_cycle" {
  assert_eq(season_from_index(0), Spring)
  assert_eq(season_from_index(1), Summer)
  assert_eq(season_from_index(2), Fall)
  assert_eq(season_from_index(3), Winter)
  assert_eq(season_from_index(4), Spring)
}

///|
test "can_plant_wheat_only_spring" {
  assert_true(can_plant_in_season(Wheat, Spring))
  assert_false(can_plant_in_season(Wheat, Summer))
  assert_false(can_plant_in_season(Wheat, Fall))
  assert_false(can_plant_in_season(Wheat, Winter))
}

///|
test "can_plant_tomato_only_summer" {
  assert_false(can_plant_in_season(Tomato, Spring))
  assert_true(can_plant_in_season(Tomato, Summer))
  assert_false(can_plant_in_season(Tomato, Fall))
}

///|
test "can_plant_carrot_only_fall" {
  assert_false(can_plant_in_season(Carrot, Spring))
  assert_false(can_plant_in_season(Carrot, Summer))
  assert_true(can_plant_in_season(Carrot, Fall))
}

///|
test "clover_any_season" {
  assert_true(can_plant_in_season(Clover, Spring))
  assert_true(can_plant_in_season(Clover, Summer))
  assert_true(can_plant_in_season(Clover, Fall))
  assert_true(can_plant_in_season(Clover, Winter))
}

///|
test "fallow_any_season" {
  assert_true(can_plant_in_season(Fallow, Spring))
  assert_true(can_plant_in_season(Fallow, Summer))
  assert_true(can_plant_in_season(Fallow, Fall))
  assert_true(can_plant_in_season(Fallow, Winter))
}

///|
test "soil_quality_calculation" {
  let soil = new_soil(90, 60, 30)
  assert_eq(soil_quality(soil), 60)
}

///|
test "soil_quality_default" {
  let soil = default_soil()
  assert_eq(soil_quality(soil), 80)
}

///|
test "soil_has_nutrients_check" {
  let rich_soil = new_soil(80, 80, 80)
  assert_true(soil_has_nutrients(rich_soil, Wheat))
  assert_true(soil_has_nutrients(rich_soil, Corn))
  let poor_soil = new_soil(10, 10, 10)
  assert_false(soil_has_nutrients(poor_soil, Wheat))
  assert_false(soil_has_nutrients(poor_soil, Corn))
}

///|
test "clover_always_plantable" {
  let empty_soil = new_soil(0, 0, 0)
  assert_true(soil_has_nutrients(empty_soil, Clover))
  assert_true(soil_has_nutrients(empty_soil, Fallow))
}

///|
test "apply_crop_cost_depletes" {
  let soil = new_soil(80, 80, 80)
  apply_crop_cost(soil, Wheat)
  // Wheat costs N:20, P:10, K:10
  assert_eq(soil.nitrogen, 60)
  assert_eq(soil.phosphorus, 70)
  assert_eq(soil.potassium, 70)
}

///|
test "apply_clover_restores" {
  let soil = new_soil(40, 40, 40)
  apply_crop_cost(soil, Clover)
  // Clover restores N:30, P:20, K:20 (negative cost)
  assert_eq(soil.nitrogen, 70)
  assert_eq(soil.phosphorus, 60)
  assert_eq(soil.potassium, 60)
}

///|
test "apply_fallow_restores_small" {
  let soil = new_soil(50, 50, 50)
  apply_crop_cost(soil, Fallow)
  assert_eq(soil.nitrogen, 60)
  assert_eq(soil.phosphorus, 60)
  assert_eq(soil.potassium, 60)
}

///|
test "nutrient_clamp_max" {
  let soil = new_soil(95, 95, 95)
  apply_crop_cost(soil, Clover)
  assert_eq(soil.nitrogen, 100)
  assert_eq(soil.phosphorus, 100)
  assert_eq(soil.potassium, 100)
}

///|
test "nutrient_clamp_min" {
  let soil = new_soil(5, 5, 5)
  apply_crop_cost(soil, Corn)
  assert_eq(soil.nitrogen, 0)
  assert_eq(soil.phosphorus, 0)
  assert_eq(soil.potassium, 0)
}

///|
test "crop_yield_rich_soil" {
  let soil = new_soil(80, 80, 80)
  assert_eq(crop_yield_value(Wheat, soil), 8)
  assert_eq(crop_yield_value(Corn, soil), 15)
}

///|
test "crop_yield_poor_soil" {
  let soil = new_soil(30, 30, 30)
  assert_eq(crop_yield_value(Wheat, soil), 4)
}

///|
test "crop_yield_depleted_soil" {
  let soil = new_soil(5, 5, 5)
  assert_eq(crop_yield_value(Wheat, soil), 2)
}

///|
test "pixel_to_grid_conversion" {
  let (c, r) = pixel_to_grid(grid_offset_x + 50, grid_offset_y + 50)
  assert_eq(c, 0)
  assert_eq(r, 0)
}

///|
test "pixel_to_grid_last_cell" {
  let (c, r) = pixel_to_grid(
    grid_offset_x + 5 * cell_size + 50,
    grid_offset_y + 3 * cell_size + 50,
  )
  assert_eq(c, 5)
  assert_eq(r, 3)
}

///|
test "tier_from_value_none" {
  let t = tier_from_value(10, 20, 40, 60)
  assert_true(t is None)
}

///|
test "tier_from_value_bronze" {
  let t = tier_from_value(25, 20, 40, 60)
  assert_eq(t, Some(Bronze))
}

///|
test "tier_from_value_silver" {
  let t = tier_from_value(45, 20, 40, 60)
  assert_eq(t, Some(Silver))
}

///|
test "tier_from_value_gold" {
  let t = tier_from_value(65, 20, 40, 60)
  assert_eq(t, Some(Gold))
}

///|
test "tier_stars_count" {
  assert_eq(tier_stars(None), 0)
  assert_eq(tier_stars(Some(Bronze)), 1)
  assert_eq(tier_stars(Some(Silver)), 2)
  assert_eq(tier_stars(Some(Gold)), 3)
}

///|
test "all_crops_count" {
  assert_eq(all_crops().length(), 8)
}

///|
test "new_grid_dimensions" {
  let g = new_grid()
  assert_eq(g.length(), grid_rows)
  assert_eq(g[0].length(), grid_cols)
}

///|
test "new_plot_defaults" {
  let p = new_plot()
  assert_eq(p.crop, Fallow)
  assert_eq(p.state, Empty)
  assert_eq(p.soil.nitrogen, 80)
}

///|
test "cell_coords" {
  assert_eq(cell_x(0), grid_offset_x)
  assert_eq(cell_y(0), grid_offset_y)
  assert_eq(cell_x(1), grid_offset_x + cell_size)
}

///|
test "crop_info_values" {
  let wheat = crop_info(Wheat)
  assert_eq(wheat.name, "Wheat")
  assert_eq(wheat.value, 8)
  let corn = crop_info(Corn)
  assert_eq(corn.value, 15)
  assert_eq(corn.growth_time, 2)
}

///|
test "season_name_roundtrip" {
  assert_eq(season_name(Spring), "Spring")
  assert_eq(season_name(Winter), "Winter")
}

///|
test "clampi_values" {
  assert_eq(clampi(-5, 0, 100), 0)
  assert_eq(clampi(50, 0, 100), 50)
  assert_eq(clampi(150, 0, 100), 100)
}

///|
test "minf_maxf" {
  assert_eq(minf(3.0, 5.0), 3.0)
  assert_eq(maxf(3.0, 5.0), 5.0)
}

///|
test "lerpf_midpoint" {
  let v = lerpf(0.0, 10.0, 0.5)
  assert_true(absf(v - 5.0) < 0.01)
}

///|
test "in_grid_area_check" {
  assert_true(in_grid_area(grid_offset_x + 1, grid_offset_y + 1))
  assert_false(in_grid_area(0, 0))
}
