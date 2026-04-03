///|
fn draw_hud(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Bottom HUD bar
  let hud_y = sh - @types.hud_height
  @raylib.draw_rectangle(0, hud_y, sw, @types.hud_height, @types.color_hud_bg)
  // Message
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 18)
    @draw.draw_text(
      game.message,
      (sw - mw) / 2,
      hud_y + 8,
      18,
      @types.color_warning,
    )
  }
  // Tile/fence count
  let tiles = @habitat.count_tiles_used(game.grid)
  let fences = @habitat.count_fences_used(game.grid)
  let level = @levels.get_level(game.current_level)
  let used = tiles + fences
  let par = level.par_tiles
  let count_color = if used <= par {
    @types.color_success
  } else {
    @types.color_error
  }
  let count_str = "Used: \{used} / Par: \{par}"
  @draw.draw_text(count_str, 16, hud_y + 36, 16, count_color)
  // Enclosure count
  let enc_count = game.enclosures.length()
  @draw.draw_text(
    "Enclosures: \{enc_count}",
    sw - 200,
    hud_y + 36,
    16,
    @types.color_hud_text,
  )
}

///|
fn draw_needs_panel(game : @types.Game) -> Unit {
  if game.show_needs_panel == false {
    return
  }
  let level = @levels.get_level(game.current_level)
  let panel_x = @types.grid_offset_x + @types.grid_cols * @types.cell_size + 16
  let panel_y = @types.grid_offset_y
  let panel_w = @types.screen_width - panel_x - 8
  if panel_w < 100 {
    return
  }
  // Panel background
  @raylib.draw_rectangle(panel_x, panel_y, panel_w, 500, @types.color_hud_bg)
  @draw.draw_text(
    "SPECIES NEEDS",
    panel_x + 8,
    panel_y + 8,
    16,
    @types.color_title,
  )
  let mut y = panel_y + 32
  for sp in level.species {
    let needs = @types.species_needs(sp)
    let col = @types.species_color(sp)
    @draw.draw_text(needs.name, panel_x + 8, y, 15, col)
    y += 18
    // Primary terrain
    let prim_label = @types.terrain_label(needs.terrain_primary)
    @draw.draw_text(
      "  \{needs.terrain_primary_count}x \{prim_label}",
      panel_x + 8,
      y,
      13,
      @types.color_hud_text,
    )
    y += 16
    // Secondary terrain
    match needs.terrain_secondary {
      Some(sec) =>
        if needs.terrain_secondary_count > 0 {
          let sec_label = @types.terrain_label(sec)
          @draw.draw_text(
            "  \{needs.terrain_secondary_count}x \{sec_label}",
            panel_x + 8,
            y,
            13,
            @types.color_hud_text,
          )
          y += 16
        }
      None => ()
    }
    // Water adjacent
    if needs.water_adjacent {
      @draw.draw_text(
        "  \{needs.water_adjacent_count} water-adj",
        panel_x + 8,
        y,
        13,
        @types.color_water,
      )
      y += 16
    }
    // Space
    @draw.draw_text(
      "  Space: \{needs.min_space}+",
      panel_x + 8,
      y,
      13,
      @types.color_hud_text,
    )
    y += 16
    // Predator info
    if needs.is_predator {
      @draw.draw_text("  [PREDATOR]", panel_x + 8, y, 13, @types.color_error)
      y += 16
    }
    if needs.fears_predators {
      @draw.draw_text(
        "  Fears predators (dist 3+)",
        panel_x + 8,
        y,
        13,
        @types.color_error,
      )
      y += 16
    }
    y += 8
  }
  // Current enclosure info
  if game.hover_col >= 0 && game.hover_row >= 0 {
    let enc = @habitat.find_enclosure_at(
      game.enclosures,
      game.hover_col,
      game.hover_row,
    )
    match enc {
      Some(e) => {
        y += 8
        @draw.draw_text(
          "Enclosure #\{e.id}",
          panel_x + 8,
          y,
          14,
          @types.color_title,
        )
        y += 18
        @draw.draw_text(
          "  Size: \{e.cells.length()}",
          panel_x + 8,
          y,
          13,
          @types.color_hud_text,
        )
        y += 16
        match e.species {
          Some(sp) => {
            let needs = @types.species_needs(sp)
            @draw.draw_text(
              "  Species: \{needs.name}",
              panel_x + 8,
              y,
              13,
              @types.species_color(sp),
            )
          }
          None =>
            @draw.draw_text(
              "  No species",
              panel_x + 8,
              y,
              13,
              @types.color_hud_text,
            )
        }
      }
      None => ()
    }
  }
}
