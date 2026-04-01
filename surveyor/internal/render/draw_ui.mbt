///|
pub fn draw_ui_panel(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      // Right panel background
      let panel_x = 640
      let panel_y = 60
      let panel_w = 600
      let panel_h = 600
      @raylib.draw_rectangle(
        panel_x, panel_y, panel_w, panel_h, @types.color_ui_bg,
      )
      @raylib.draw_rectangle_lines(
        panel_x, panel_y, panel_w, panel_h, @types.color_fence,
      )
      // Level name
      let name_str = "Level " +
        (game.current_level_idx + 1).to_string() +
        ": " +
        level.name
      @draw.draw_text(
        name_str,
        panel_x + 20,
        panel_y + 15,
        24,
        @types.color_title,
      )
      // Tier info
      let tier_str = @types.tier_name(level.tier)
      @draw.draw_text(
        tier_str,
        panel_x + panel_w - 120,
        panel_y + 18,
        18,
        @types.color_ui_dim,
      )
      // Fence counter
      let fence_str = "Fences: " +
        game.fences.length().to_string() +
        " / " +
        level.par_fences.to_string() +
        " (par)"
      @draw.draw_text(
        fence_str,
        panel_x + 20,
        panel_y + 55,
        20,
        @types.color_ui_text,
      )
      // Star targets
      let star_str = "3-star: <= " + level.par_length.to_string() + " fences"
      @draw.draw_text(
        star_str,
        panel_x + 20,
        panel_y + 82,
        16,
        @types.color_star,
      )
      // Constraints info
      @draw.draw_text(
        "Constraints:",
        panel_x + 20,
        panel_y + 115,
        20,
        @types.color_title,
      )
      let mut cy = panel_y + 142
      @draw.draw_text(
        "- Each region: exactly 1 house",
        panel_x + 30,
        cy,
        16,
        @types.color_ui_text,
      )
      cy += 22
      @draw.draw_text(
        "- Each region: area matches house number",
        panel_x + 30,
        cy,
        16,
        @types.color_ui_text,
      )
      cy += 22
      // Check if road access needed
      let mut has_roads = false
      for y in 0..<level.grid.height {
        for x in 0..<level.grid.width {
          match @types.grid_get(level.grid, x, y) {
            Road => has_roads = true
            _ => ()
          }
        }
      }
      if has_roads {
        @draw.draw_text(
          "- Each region: must touch a road",
          panel_x + 30,
          cy,
          16,
          @types.color_ui_text,
        )
        cy += 22
      }
      if level.constraints.must_be_rectangular {
        @draw.draw_text(
          "- Regions must be rectangular",
          panel_x + 30,
          cy,
          16,
          @types.color_violated,
        )
        cy += 22
      }
      if level.constraints.must_not_touch_water {
        @draw.draw_text(
          "- Regions must not touch water",
          panel_x + 30,
          cy,
          16,
          @types.color_water,
        )
        cy += 22
      }
      // Play state
      let _ = cy
      if game.play_state == Complete {
        @draw.draw_text(
          "COMPLETE! Press ENTER for results",
          panel_x + 20,
          panel_y + panel_h - 50,
          22,
          @types.color_satisfied,
        )
      }
    }
  }
}

///|
pub fn draw_constraint_panel(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      let panel_x = 640
      let base_y = 350
      @draw.draw_text(
        "House Status:",
        panel_x + 20,
        base_y,
        20,
        @types.color_title,
      )
      for i in 0..<level.houses.length() {
        let house = level.houses[i]
        let y = base_y + 30 + i * 32
        let hcolor = @types.house_color(house.color_id)
        // House indicator square
        @raylib.draw_rectangle(panel_x + 20, y, 20, 20, hcolor)
        @raylib.draw_rectangle_lines(
          panel_x + 20,
          y,
          20,
          20,
          @types.color_fence,
        )
        // House label
        let label = "Area: " + house.required_area.to_string()
        @draw.draw_text(label, panel_x + 48, y + 2, 16, @types.color_ui_text)
        // Constraint indicators
        if i < game.constraint_status.length() {
          let cs = game.constraint_status[i]
          draw_constraint_dot(panel_x + 180, y + 4, cs.one_house, "1H")
          draw_constraint_dot(panel_x + 230, y + 4, cs.correct_area, "A")
          draw_constraint_dot(panel_x + 270, y + 4, cs.road_access, "R")
          draw_constraint_dot(panel_x + 310, y + 4, cs.shape_ok, "S")
        }
      }
      // Legend
      let legend_y = base_y + 30 + level.houses.length() * 32 + 10
      @draw.draw_text(
        "1H=One House  A=Area  R=Road  S=Shape",
        panel_x + 20,
        legend_y,
        14,
        @types.color_ui_dim,
      )
    }
  }
}

///|
fn draw_constraint_dot(
  x : Int,
  y : Int,
  result : @types.ConstraintResult,
  label : String,
) -> Unit {
  let color = match result {
    Satisfied => @types.color_satisfied
    Violated => @types.color_violated
    Unchecked => @types.color_unchecked
  }
  @raylib.draw_circle(x + 8, y + 6, 6.0, color)
  @draw.draw_text(label, x + 18, y, 14, @types.color_ui_dim)
}

///|
pub fn draw_controls_hint(game : @types.Game) -> Unit {
  let _ = game
  let y = @types.screen_height - 30
  @draw.draw_text(
    "Click edges to place fences | Z: Undo | R: Restart | ESC: Back", 20, y, 16,
    @types.color_ui_dim,
  )
}
