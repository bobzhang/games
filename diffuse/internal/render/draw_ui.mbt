///|
pub fn draw_ui(game : @types.Game) -> Unit {
  let g = game.grid
  // Right panel - starts after grid
  let panel_x = @types.grid_offset_x + g.width * @types.cell_size + 30
  let panel_w = @types.screen_width - panel_x - 20
  // Level name
  @draw.draw_text(game.level_name, panel_x, 20, 24, @types.color_title_text)
  // Turn counter
  @draw.draw_text(
    "Turn: " + game.turn.to_string(),
    panel_x, 55, 20, @types.color_subtitle,
  )
  // Drops used vs par
  @draw.draw_text(
    "Drops: " + game.drops_used.to_string() + " / par " + game.par_drops.to_string(),
    panel_x, 80, 18, @types.color_subtitle,
  )
  // Ink Palette
  @draw.draw_text("INK PALETTE", panel_x, 120, 18, @types.color_title_text)
  draw_ink_button(
    game, Cyan, panel_x, 145, panel_w, game.budget.cyan,
  )
  draw_ink_button(
    game, Magenta, panel_x, 195, panel_w, game.budget.magenta,
  )
  draw_ink_button(
    game, Yellow, panel_x, 245, panel_w, game.budget.yellow,
  )
  // Target Progress
  let (satisfied, total) = @ink.count_targets_satisfied(g)
  @draw.draw_text("TARGETS", panel_x, 310, 18, @types.color_title_text)
  @draw.draw_text(
    satisfied.to_string() + " / " + total.to_string() + " complete",
    panel_x, 335, 18,
    if satisfied == total {
      @raylib.Color::new(50, 160, 80, 255)
    } else {
      @types.color_subtitle
    },
  )
  // Draw target list
  draw_target_list(game, panel_x, 360)
  // Controls help
  let help_y = @types.screen_height - 140
  @draw.draw_text("CONTROLS", panel_x, help_y, 16, @types.color_title_text)
  @draw.draw_text("Click: drop ink", panel_x, help_y + 22, 14, @types.color_subtitle)
  @draw.draw_text("Space: spread ink", panel_x, help_y + 40, 14, @types.color_subtitle)
  @draw.draw_text("1/2/3: select ink", panel_x, help_y + 58, 14, @types.color_subtitle)
  @draw.draw_text("Z: undo  R: restart", panel_x, help_y + 76, 14, @types.color_subtitle)
  @draw.draw_text("Esc: back to menu", panel_x, help_y + 94, 14, @types.color_subtitle)
  // Play state indicator
  if game.play_state == Spreading {
    @draw.draw_text(
      "Spreading...", panel_x, help_y - 30, 20,
      @raylib.Color::new(50, 130, 200, 255),
    )
  }
  // Top bar - subtle background
  @raylib.draw_rectangle(0, 0, @types.screen_width, 4, @types.color_hud_bg)
  // Bottom bar
  @raylib.draw_rectangle(
    0, @types.screen_height - 4, @types.screen_width, 4, @types.color_hud_bg,
  )
}

///|
fn draw_ink_button(
  game : @types.Game,
  channel : @types.InkChannel,
  x : Int,
  y : Int,
  w : Int,
  remaining : Int
) -> Unit {
  let h = 40
  let is_selected = game.selected_channel == channel
  let color = @types.channel_to_color(channel)
  // Background
  let bg_color = if is_selected {
    @raylib.Color::new(color.r.to_int(), color.g.to_int(), color.b.to_int(), 60)
  } else {
    @raylib.Color::new(230, 225, 215, 255)
  }
  @raylib.draw_rectangle(x, y, w, h, bg_color)
  // Color swatch
  @raylib.draw_rectangle(x + 4, y + 4, 32, 32, color)
  // Name and count
  let name = @types.channel_name(channel)
  @draw.draw_text(name, x + 42, y + 4, 18, @types.color_title_text)
  @draw.draw_text(
    "x" + remaining.to_string(),
    x + 42, y + 22, 16,
    if remaining > 0 {
      @types.color_subtitle
    } else {
      @raylib.Color::new(200, 50, 50, 255)
    },
  )
  // Selection border
  if is_selected {
    @raylib.draw_rectangle_lines(x, y, w, h, @types.color_selected_border)
    @raylib.draw_rectangle_lines(
      x - 1, y - 1, w + 2, h + 2, @types.color_selected_border,
    )
  } else {
    @raylib.draw_rectangle_lines(x, y, w, h, @types.color_grid_line)
  }
}

///|
fn draw_target_list(
  game : @types.Game,
  x : Int,
  start_y : Int
) -> Unit {
  let g = game.grid
  let mut y = start_y
  let mut count = 0
  for row in 0..<g.height {
    for col in 0..<g.width {
      let tile = @types.grid_get(g, col, row)
      if tile.kind == Target && count < 8 {
        let target_col = @types.ink_to_color(tile.target_color)
        let satisfied = @types.ink_equals(tile.ink, tile.target_color)
        // Small color swatch
        @raylib.draw_rectangle(x, y, 16, 16, target_col)
        @raylib.draw_rectangle_lines(
          x, y, 16, 16,
          @raylib.Color::new(0, 0, 0, 80),
        )
        // Target name
        let tname = @types.ink_display_name(tile.target_color)
        let label = "(" +
          col.to_string() +
          "," +
          row.to_string() +
          ") " +
          tname
        @draw.draw_text(
          label, x + 22, y, 14,
          if satisfied {
            @raylib.Color::new(50, 160, 80, 255)
          } else {
            @types.color_subtitle
          },
        )
        if satisfied {
          @draw.draw_text(
            " [OK]", x + 22 + @draw.measure_text(label, 14), y, 14,
            @raylib.Color::new(50, 160, 80, 255),
          )
        }
        y = y + 20
        count = count + 1
      }
    }
  }
}
