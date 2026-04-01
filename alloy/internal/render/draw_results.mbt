///|
fn draw_level_complete(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  let w = @types.screen_width
  let h = @types.screen_height
  // Dim background
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 200))
  // Success title
  let title = "ALLOY FORGED!"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, h / 5, 40, @types.color_success)
  // Stars
  draw_stars_large(w / 2 - 60, h / 5 + 55, game.result.stars)
  // Result details
  let result = game.result
  let detail_y = h / 5 + 120
  // Show final blend values vs target
  draw_result_property(
    w / 2 - 200,
    detail_y,
    "Hardness",
    result.blend.hardness,
    level.target.hardness,
    @types.color_hardness,
  )
  draw_result_property(
    w / 2 - 200,
    detail_y + 50,
    "Flexibility",
    result.blend.flexibility,
    level.target.flexibility,
    @types.color_flexibility,
  )
  draw_result_property(
    w / 2 - 200,
    detail_y + 100,
    "Conductivity",
    result.blend.conductivity,
    level.target.conductivity,
    @types.color_conductivity,
  )
  // Ingredients used
  let ing_str = "Ingredients used: " +
    result.ingredients_used.to_string() +
    " (par: " +
    level.par_ingredients.to_string() +
    ")"
  let iw = @draw.measure_text(ing_str, 16)
  @draw.draw_text(
    ing_str,
    (w - iw) / 2,
    detail_y + 165,
    16,
    @types.color_hud_text,
  )
  // Navigation
  let prompt = if game.current_level < @types.total_levels - 1 {
    "ENTER - Next Level  |  ESC - Level Select"
  } else {
    "All levels complete!  ESC - Level Select"
  }
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(prompt, (w - pw) / 2, h * 4 / 5, 18, @types.color_hud_dim)
}

///|
fn draw_level_failed(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  let w = @types.screen_width
  let h = @types.screen_height
  // Dim background
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 200))
  // Fail title
  let title = "ALLOY REJECTED"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, h / 5, 36, @types.color_fail)
  let sub = "Properties did not match the target"
  let sw = @draw.measure_text(sub, 16)
  @draw.draw_text(sub, (w - sw) / 2, h / 5 + 45, 16, @types.color_hud_dim)
  // Show what went wrong
  let result = game.result
  let detail_y = h / 5 + 80
  draw_result_property(
    w / 2 - 200,
    detail_y,
    "Hardness",
    result.blend.hardness,
    level.target.hardness,
    @types.color_hardness,
  )
  draw_result_property(
    w / 2 - 200,
    detail_y + 50,
    "Flexibility",
    result.blend.flexibility,
    level.target.flexibility,
    @types.color_flexibility,
  )
  draw_result_property(
    w / 2 - 200,
    detail_y + 100,
    "Conductivity",
    result.blend.conductivity,
    level.target.conductivity,
    @types.color_conductivity,
  )
  // Navigation
  let prompt = "ENTER/R - Retry  |  ESC - Level Select"
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(prompt, (w - pw) / 2, h * 3 / 4 + 30, 18, @types.color_hud_dim)
}

///|
fn draw_result_property(
  x : Int,
  y : Int,
  name : String,
  value : Float,
  range : @types.PropertyRange,
  color : @raylib.Color,
) -> Unit {
  let in_range = @forge.in_range(value, range)
  let status_color = if in_range {
    @types.color_success
  } else {
    @types.color_fail
  }
  @draw.draw_text(name, x, y, 16, color)
  let val_str = format_float(value, 1)
  @draw.draw_text(val_str, x + 120, y, 16, status_color)
  let range_str = "[" +
    format_float(range.min, 0) +
    " - " +
    format_float(range.max, 0) +
    "]"
  @draw.draw_text(range_str, x + 200, y, 14, @types.color_hud_dim)
  let status = if in_range { "OK" } else { "MISS" }
  @draw.draw_text(status, x + 320, y, 16, status_color)
  // Small bar
  let bar_x = x
  let bar_y = y + 20
  let bar_w = 400
  let bar_h = 12
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.color_property_bar_bg)
  // Range highlight
  let rx = bar_x + (Float::from_int(bar_w) * range.min / 100.0).to_int()
  let rw = (Float::from_int(bar_w) * (range.max - range.min) / 100.0).to_int()
  @raylib.draw_rectangle(
    rx,
    bar_y,
    rw,
    bar_h,
    @raylib.Color::new(
      color.r.to_int(), color.g.to_int(), color.b.to_int(), 60,
    ),
  )
  // Value marker
  let vx = bar_x +
    (Float::from_int(bar_w) * @types.clampf(value, 0.0, 100.0) / 100.0).to_int()
  @raylib.draw_line(vx, bar_y - 2, vx, bar_y + bar_h + 2, status_color)
  @raylib.draw_circle(vx, bar_y + bar_h / 2, 4.0, status_color)
}
