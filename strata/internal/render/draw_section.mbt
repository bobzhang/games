///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  draw_cross_section(game, level)
  draw_clue_panel(game, level)
  draw_tray(game)
  draw_hud(game, level)
  // Message
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 22)
    let mx = (@types.screen_width - mw) / 2
    @draw.draw_text(game.message, mx, 670, 22, @types.color_accent)
  }
}

///|
fn draw_cross_section(game : @types.Game, _level : @types.Level) -> Unit {
  let sx = @types.section_x
  let sy = @types.section_y
  let sw = @types.slot_width
  let sh = @types.slot_height
  let num_slots = game.slots.length()
  // Section header
  @draw.draw_text("Cross-Section", sx, sy - 30, 20, @types.color_text)
  @draw.draw_text("(top)", sx + sw + 10, sy, 14, @types.color_text_dim)
  @draw.draw_text(
    "(bottom)",
    sx + sw + 10,
    sy + (num_slots - 1) * sh,
    14,
    @types.color_text_dim,
  )
  // Draw slots from top (highest index) to bottom (index 0)
  for i in 0..<num_slots {
    // Display slot: top of screen = highest index, bottom = index 0
    let display_row = num_slots - 1 - i
    let slot_y = sy + display_row * sh
    let is_selected = game.selected_slot == i
    // Slot background
    match game.slots[i] {
      Some(rock) => {
        let rc = @types.rock_color(rock)
        @raylib.draw_rectangle(sx, slot_y, sw, sh - 2, rc)
        // Texture pattern based on rock type
        draw_rock_texture(sx, slot_y, sw, sh - 2, rock)
        // Rock name
        let rname = @types.rock_name(rock)
        // Choose text color based on rock brightness
        let text_col = rock_text_color(rock)
        let rw = @draw.measure_text(rname, 18)
        @draw.draw_text(
          rname,
          sx + (sw - rw) / 2,
          slot_y + (sh - 20) / 2,
          18,
          text_col,
        )
      }
      None =>
        @raylib.draw_rectangle(sx, slot_y, sw, sh - 2, @types.color_slot_empty)
    }
    // Selection highlight
    if is_selected {
      @raylib.draw_rectangle_lines(
        sx - 2,
        slot_y - 2,
        sw + 4,
        sh + 2,
        @types.color_highlight,
      )
    }
    // Slot border
    @raylib.draw_rectangle_lines(
      sx,
      slot_y,
      sw,
      sh - 2,
      @types.color_slot_border,
    )
    // Slot number label
    let label = (i + 1).to_string()
    @draw.draw_text(
      label,
      sx - 25,
      slot_y + (sh - 18) / 2,
      16,
      @types.color_text_dim,
    )
  }
}

///|
fn rock_text_color(rock : @types.RockKind) -> @raylib.Color {
  match rock {
    Coal | Basalt | Shale | Slate => @raylib.Color::new(220, 215, 205, 255)
    _ => @raylib.Color::new(40, 35, 30, 255)
  }
}

///|
fn draw_rock_texture(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  rock : @types.RockKind,
) -> Unit {
  match rock {
    Sandstone => {
      // Dotted sandy texture
      let mut dx = 8
      while dx < w - 4 {
        let mut dy = 4
        while dy < h - 4 {
          let col = @raylib.Color::new(200, 175, 80, 60)
          @raylib.draw_circle(x + dx, y + dy, 1.0, col)
          dy += 8
        }
        dx += 12
      }
    }
    Limestone => {
      // Horizontal wavy lines
      let mut ly = 6
      while ly < h - 2 {
        @raylib.draw_line(
          x + 4,
          y + ly,
          x + w - 4,
          y + ly,
          @raylib.Color::new(180, 180, 175, 60),
        )
        ly += 10
      }
    }
    Shale => {
      // Thin horizontal layers
      let mut ly = 5
      while ly < h - 2 {
        @raylib.draw_line(
          x + 2,
          y + ly,
          x + w - 2,
          y + ly,
          @raylib.Color::new(80, 75, 70, 80),
        )
        ly += 6
      }
    }
    Granite => {
      // Speckled pattern
      let mut dx = 6
      while dx < w - 4 {
        let mut dy = 5
        while dy < h - 4 {
          @raylib.draw_circle(
            x + dx,
            y + dy,
            1.5,
            @raylib.Color::new(180, 140, 140, 50),
          )
          dy += 10
        }
        dx += 14
      }
    }
    Basalt => {
      // Columnar joints (vertical lines)
      let mut dx = 10
      while dx < w - 4 {
        @raylib.draw_line(
          x + dx,
          y + 2,
          x + dx,
          y + h - 2,
          @raylib.Color::new(60, 45, 35, 80),
        )
        dx += 15
      }
    }
    Coal => {
      // Shiny flecks
      let mut dx = 10
      while dx < w - 4 {
        let mut dy = 6
        while dy < h - 4 {
          @raylib.draw_rectangle(
            x + dx,
            y + dy,
            2,
            1,
            @raylib.Color::new(60, 58, 55, 80),
          )
          dy += 12
        }
        dx += 18
      }
    }
    Chalk => {
      // Faint diagonal lines
      let mut dx = 0
      while dx < w + h {
        @raylib.draw_line(
          x + dx,
          y,
          x + dx - h,
          y + h,
          @raylib.Color::new(225, 222, 215, 60),
        )
        dx += 12
      }
    }
    Slate => {
      // Angled cleavage lines
      let mut dx = 0
      while dx < w + h {
        @raylib.draw_line(
          x + dx,
          y,
          x + dx - h / 2,
          y + h,
          @raylib.Color::new(100, 110, 130, 60),
        )
        dx += 10
      }
    }
  }
}

///|
fn draw_clue_panel(_game : @types.Game, level : @types.Level) -> Unit {
  let px = @types.clue_panel_x
  let py = @types.clue_panel_y
  let pw = 680
  // Panel header
  @draw.draw_text("Clues", px, py - 30, 20, @types.color_text)
  // Clue list
  for i in 0..<level.clues.length() {
    let clue = level.clues[i]
    let cy = py + i * 50
    // Satisfaction indicator
    let indicator_color = if clue.satisfied {
      @types.color_correct
    } else {
      @types.color_incorrect
    }
    @raylib.draw_circle(px + 10, cy + 12, 6.0, indicator_color)
    // Clue kind tag
    let kind_name = @types.clue_kind_name(clue.kind)
    let kind_color = clue_kind_color(clue.kind)
    @draw.draw_text(kind_name, px + 25, cy, 14, kind_color)
    // Clue text
    let text_color = if clue.satisfied {
      @types.color_correct
    } else {
      @types.color_text
    }
    @draw.draw_text(clue.text, px + 25, cy + 18, 16, text_color)
    // Separator
    let line_y = cy + 44
    @raylib.draw_line(
      px,
      line_y,
      px + pw,
      line_y,
      @raylib.Color::new(80, 72, 60, 100),
    )
  }
}

///|
fn clue_kind_color(kind : @types.ClueKind) -> @raylib.Color {
  match kind {
    FossilAge => @raylib.Color::new(180, 140, 80, 255)
    Superposition => @raylib.Color::new(120, 160, 200, 255)
    Dating => @raylib.Color::new(200, 120, 160, 255)
    Intrusion => @raylib.Color::new(200, 80, 80, 255)
    Unconformity => @raylib.Color::new(160, 120, 200, 255)
  }
}
