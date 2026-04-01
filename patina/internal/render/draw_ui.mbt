///|
fn draw_tool_palette(game : @types.Game) -> Unit {
  let palette_x = 720
  let palette_y = 100
  let btn_w = 200
  let btn_h = 60
  let gap = 12
  // Palette header
  @draw.draw_text("TOOLS", palette_x, palette_y - 30, 22, @types.color_text)
  let tools : Array[@types.ToolKind] = [Clean, Fill, Retouch, Seal]
  let budget = match game.current_budget {
    Some(b) => b
    None => @types.new_budget(0, 0, 0, 0)
  }
  for i in 0..<tools.length() {
    let tool = tools[i]
    let bx = palette_x
    let by = palette_y + i * (btn_h + gap)
    let selected = game.selected_tool == tool
    let remaining = @types.get_budget_for_tool(budget, tool)
    // Button background
    let bg = if selected {
      @raylib.Color::new(70, 65, 50, 255)
    } else {
      @raylib.Color::new(45, 40, 32, 255)
    }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg)
    // Color accent bar
    let tc = @types.tool_color(tool)
    @raylib.draw_rectangle(bx, by, 6, btn_h, tc)
    // Selection highlight
    if selected {
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(
          Float::from_int(bx),
          Float::from_int(by),
          Float::from_int(btn_w),
          Float::from_int(btn_h),
        ),
        2.0,
        @types.color_highlight,
      )
    }
    // Tool name
    let name = @types.tool_name(tool)
    @draw.draw_text(name, bx + 16, by + 8, 20, tc)
    // Budget count
    let budget_str = "x" + remaining.to_string()
    let budget_color = if remaining > 0 {
      @types.color_text
    } else {
      @types.color_worsened
    }
    @draw.draw_text(budget_str, bx + btn_w - 40, by + 8, 20, budget_color)
    // Hotkey hint
    let key_str = (i + 1).to_string()
    @draw.draw_text(key_str, bx + 16, by + 35, 14, @types.color_text_dim)
    // Tool description
    let desc = match tool {
      Clean => "Removes stains"
      Fill => "Fixes cracks/flakes"
      Retouch => "Restores faded areas"
      Seal => "Locks restoration"
    }
    @draw.draw_text(desc, bx + 36, by + 35, 14, @types.color_text_dim)
  }
}

///|
fn draw_region_info(game : @types.Game, level : @types.Level) -> Unit {
  let info_x = 720
  let info_y = 420
  let panel_w = 200
  let panel_h = 160
  @raylib.draw_rectangle(
    info_x, info_y, panel_w, panel_h, @types.color_panel_bg,
  )
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(info_x),
      Float::from_int(info_y),
      Float::from_int(panel_w),
      Float::from_int(panel_h),
    ),
    1.0,
    @types.color_frame,
  )
  @draw.draw_text("REGION INFO", info_x + 10, info_y + 8, 16, @types.color_text)
  if game.hover_region >= 0 &&
    game.hover_region < level.artwork.regions.length() {
    let region = level.artwork.regions[game.hover_region]
    // State
    let state_str = "State: " + @types.state_name(region.state)
    @draw.draw_text(
      state_str,
      info_x + 10,
      info_y + 32,
      14,
      @types.state_color(region.state),
    )
    // Damage types
    if region.damage_types.length() > 0 {
      let mut dmg_str = "Damage: "
      for i in 0..<region.damage_types.length() {
        if i > 0 {
          dmg_str = dmg_str + ", "
        }
        dmg_str = dmg_str + @types.damage_name(region.damage_types[i])
      }
      @draw.draw_text(
        dmg_str,
        info_x + 10,
        info_y + 52,
        14,
        @types.color_text_dim,
      )
    } else if region.state != Pristine {
      @draw.draw_text(
        "Damage: none remaining",
        info_x + 10,
        info_y + 52,
        14,
        @types.color_text_dim,
      )
    }
    // Treatments applied
    if region.treatments_applied.length() > 0 {
      let mut treat_str = "Applied: "
      for i in 0..<region.treatments_applied.length() {
        if i > 0 {
          treat_str = treat_str + ", "
        }
        treat_str = treat_str + @types.tool_name(region.treatments_applied[i])
      }
      @draw.draw_text(
        treat_str,
        info_x + 10,
        info_y + 72,
        14,
        @types.color_text_dim,
      )
    }
    // Warnings
    if region.fragile {
      @draw.draw_text(
        "WARNING: Fragile!",
        info_x + 10,
        info_y + 96,
        14,
        @types.color_worsened,
      )
    }
    if region.stain_permanent {
      @draw.draw_text(
        "WARNING: Stain set!",
        info_x + 10,
        info_y + 116,
        14,
        @types.color_worsened,
      )
    }
  } else {
    @draw.draw_text(
      "Hover over a region",
      info_x + 10,
      info_y + 50,
      14,
      @types.color_text_dim,
    )
  }
}

///|
fn draw_progress_bar(game : @types.Game, level : @types.Level) -> Unit {
  let bar_x = 720
  let bar_y = 600
  let bar_w = 200
  let bar_h = 20
  ignore(game)
  // Count states
  let art = level.artwork
  let total = art.regions.length()
  let mut restored = 0
  let mut worsened = 0
  let mut sealed_n = 0
  let mut pristine = 0
  for i in 0..<total {
    match art.regions[i].state {
      Restored => restored = restored + 1
      Worsened => worsened = worsened + 1
      Sealed => sealed_n = sealed_n + 1
      Pristine => pristine = pristine + 1
      _ => ()
    }
  }
  let done = restored + worsened + sealed_n + pristine
  // Background
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(30, 25, 20, 200),
  )
  // Progress fill
  if total > 0 {
    let fill_w = done * bar_w / total
    @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, @types.color_restored)
    // Worsened portion
    if worsened > 0 {
      let w_w = worsened * bar_w / total
      @raylib.draw_rectangle(
        bar_x + fill_w - w_w,
        bar_y,
        w_w,
        bar_h,
        @types.color_worsened,
      )
    }
  }
  @raylib.draw_rectangle_lines(bar_x, bar_y, bar_w, bar_h, @types.color_frame)
  // Label
  let label = "Progress: " + done.to_string() + " / " + total.to_string()
  @draw.draw_text(label, bar_x, bar_y - 20, 14, @types.color_text_dim)
  // Tools used
  let tools_str = "Tools used: " + game.total_tools_used.to_string()
  @draw.draw_text(tools_str, bar_x, bar_y + 28, 14, @types.color_text_dim)
  // Par
  let par_str = "Par: " + level.par_tools.to_string()
  @draw.draw_text(par_str, bar_x + 120, bar_y + 28, 14, @types.color_text_dim)
}

///|
fn draw_controls_hint(_game : @types.Game) -> Unit {
  let y = @types.screen_height - 35
  @draw.draw_text(
    "1-4: Select Tool   Click: Apply   Z: Undo   R: Restart   ESC: Back", 20, y,
    14, @types.color_text_dim,
  )
}
