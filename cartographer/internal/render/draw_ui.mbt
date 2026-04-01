///|
fn draw_palette(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let px = @types.palette_x
  let py = @types.palette_y
  @draw.draw_text("Features:", px, py - 25, 18, @types.color_text)
  // Get unique feature kinds and their counts
  let feature_kinds : Array[@types.FeatureKind] = []
  let feature_counts : Array[Int] = []
  for i in 0..<level.features_to_place.length() {
    let f = level.features_to_place[i]
    let mut found = false
    for j in 0..<feature_kinds.length() {
      if feature_kinds[j] == f {
        feature_counts[j] += 1
        found = true
        break
      }
    }
    if !found {
      feature_kinds.push(f)
      feature_counts.push(1)
    }
  }
  for i in 0..<feature_kinds.length() {
    let feat = feature_kinds[i]
    let cell_x = px + i * (@types.palette_cell + 10)
    let cell_y = py
    // Count how many of this type are placed
    let mut placed = 0
    for j in 0..<game.grid.length() {
      match game.grid[j] {
        Some(f) => if f == feat { placed += 1 }
        None => ()
      }
    }
    let remaining = feature_counts[i] - placed
    // Highlight if selected
    let is_selected = match game.selected_feature {
      Some(sf) => sf == feat
      None => false
    }
    if is_selected {
      @raylib.draw_rectangle(
        cell_x - 2,
        cell_y - 2,
        @types.palette_cell + 4,
        @types.palette_cell + 4,
        @types.color_selected,
      )
    }
    // Background
    let bg = if remaining > 0 {
      @types.color_parchment
    } else {
      @raylib.Color::new(200, 190, 170, 255)
    }
    @raylib.draw_rectangle(
      cell_x, cell_y, @types.palette_cell, @types.palette_cell, bg,
    )
    @raylib.draw_rectangle_lines(
      cell_x, cell_y, @types.palette_cell, @types.palette_cell, @types.color_grid_line,
    )
    // Draw feature icon
    draw_feature(
      cell_x + @types.palette_cell / 2,
      cell_y + @types.palette_cell / 2,
      feat,
      @types.palette_cell - 16,
    )
    // Draw remaining count
    @draw.draw_text(
      remaining.to_string(),
      cell_x + @types.palette_cell - 12,
      cell_y + @types.palette_cell - 14,
      14,
      @types.color_text,
    )
    // Draw name below
    @draw.draw_text(
      @types.feature_name(feat),
      cell_x,
      cell_y + @types.palette_cell + 4,
      12,
      @types.color_text_light,
    )
  }
}

///|
fn draw_placement_info(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let x = @types.clue_panel_x
  let y = @types.screen_height - 80
  // Placement counter
  @draw.draw_text(
    "Placements: \{game.total_placements}",
    x,
    y,
    18,
    @types.color_text,
  )
  @draw.draw_text(
    "Par: \{level.par_placements}",
    x + 200,
    y,
    18,
    @types.color_text_light,
  )
  // Incorrect count
  if game.incorrect_count > 0 {
    @draw.draw_text(
      "Incorrect: \{game.incorrect_count}",
      x,
      y + 24,
      18,
      @types.color_clue_violated,
    )
  }
  // Play state
  match game.play_state {
    Complete =>
      @draw.draw_text(
        "COMPLETE! Press Enter for results",
        x,
        y + 48,
        20,
        @types.color_clue_satisfied,
      )
    _ => ()
  }
}
