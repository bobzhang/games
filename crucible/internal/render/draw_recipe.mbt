///|
fn draw_recipe_panel(game : @types.Game) -> Unit {
  let px = @types.recipe_panel_x.to_int()
  let py = @types.recipe_panel_y.to_int()
  let pw = @types.recipe_panel_width.to_int()
  let ph = @types.recipe_panel_height.to_int()
  // Panel background
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_panel_border)
  // Title
  let title = "Recipe Book"
  let tw = @draw.measure_text(title, 24)
  @draw.draw_text(
    title,
    px + (pw - tw) / 2,
    py + 10,
    24,
    @types.color_text_bright,
  )
  // Discovery count
  let disc = game.discovered_count.to_string() +
    "/" +
    @types.total_reactions.to_string() +
    " Discovered"
  let dw = @draw.measure_text(disc, 14)
  @draw.draw_text(disc, px + (pw - dw) / 2, py + 40, 14, @types.color_text_dim)
  // List all recipes (deduplicated)
  let recipes = @alchemy.get_all_recipes_deduped(game.recipe_book)
  let row_height = 32
  let start_y = py + 70
  let max_visible = (ph - 80) / row_height
  for i in 0..<@types.mini(recipes.length(), max_visible) {
    let recipe = recipes[i]
    let ry = start_y + i * row_height
    if recipe.discovered {
      // Show discovered recipe
      let substance_name = @types.element_name(recipe.substance)
      let input_name = @types.element_name(recipe.input)
      let output_name = match recipe.output {
        Transform(elem) => @types.element_name(elem)
        Destroy => "DESTROYED"
        NoReaction => "???"
      }
      let substance_color = @types.element_color(recipe.substance)
      let input_color = @types.element_color(recipe.input)
      let output_color = match recipe.output {
        Transform(elem) => @types.element_color(elem)
        Destroy => @types.color_destroy
        NoReaction => @types.color_text_dim
      }
      // Draw colored circles for each element
      @raylib.draw_circle(px + 20, ry + 10, 8.0, substance_color)
      @draw.draw_text(substance_name, px + 35, ry + 2, 14, substance_color)
      @draw.draw_text("+", px + 115, ry + 2, 14, @types.color_text_dim)
      @raylib.draw_circle(px + 140, ry + 10, 8.0, input_color)
      @draw.draw_text(input_name, px + 155, ry + 2, 14, input_color)
      @draw.draw_text("=", px + 250, ry + 2, 14, @types.color_text_dim)
      @raylib.draw_circle(px + 275, ry + 10, 8.0, output_color)
      @draw.draw_text(output_name, px + 290, ry + 2, 14, output_color)
    } else {
      // Undiscovered - show ???
      @raylib.draw_circle(
        px + 20,
        ry + 10,
        8.0,
        @raylib.Color::new(60, 55, 65, 150),
      )
      @draw.draw_text("???", px + 35, ry + 2, 14, @types.color_text_dim)
      @draw.draw_text("+", px + 115, ry + 2, 14, @types.color_text_dim)
      @raylib.draw_circle(
        px + 140,
        ry + 10,
        8.0,
        @raylib.Color::new(60, 55, 65, 150),
      )
      @draw.draw_text("???", px + 155, ry + 2, 14, @types.color_text_dim)
      @draw.draw_text("=", px + 250, ry + 2, 14, @types.color_text_dim)
      @raylib.draw_circle(
        px + 275,
        ry + 10,
        8.0,
        @raylib.Color::new(60, 55, 65, 150),
      )
      @draw.draw_text("???", px + 290, ry + 2, 14, @types.color_text_dim)
    }
  }
  // Scroll hint if more than visible
  if recipes.length() > max_visible {
    let more = "(" + (recipes.length() - max_visible).to_string() + " more...)"
    let mw = @draw.measure_text(more, 12)
    @draw.draw_text(
      more,
      px + (pw - mw) / 2,
      py + ph - 20,
      12,
      @types.color_text_dim,
    )
  }
}
