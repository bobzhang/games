///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  draw_hud(game, level)
  draw_metal_palette(game, level)
  draw_crucible_area(game)
  draw_target_panel(game, level)
  draw_temperature_panel(game)
  draw_action_buttons(game)
  draw_controls_help(game)
}

///|
fn draw_hud(game : @types.Game, level : @types.LevelDef) -> Unit {
  let w = @types.screen_width
  @draw.draw_text("ALLOY", 20, 12, 28, @types.color_title_glow)
  let level_info = "Level " +
    (game.current_level + 1).to_string() +
    ": " +
    level.name
  let info_w = @draw.measure_text(level_info, 20)
  @draw.draw_text(level_info, (w - info_w) / 2, 15, 20, @types.color_hud_text)
  let tier_str = "Tier " + level.tier.to_string()
  let tier_w = @draw.measure_text(tier_str, 16)
  let tier_color = match level.tier {
    1 => @raylib.Color::new(100, 180, 255, 255)
    2 => @raylib.Color::new(255, 180, 50, 255)
    _ => @raylib.Color::new(220, 100, 255, 255)
  }
  @draw.draw_text(tier_str, (w - tier_w) / 2, 40, 16, tier_color)
  let star_info = "Stars: " + game.total_stars.to_string()
  let star_w = @draw.measure_text(star_info, 16)
  @draw.draw_text(star_info, w - star_w - 20, 15, 16, @types.color_star_gold)
}

///|
fn draw_metal_palette(game : @types.Game, level : @types.LevelDef) -> Unit {
  let px = 40
  let py = 80
  // Panel background
  @raylib.draw_rectangle(px - 10, py - 10, 200, 450, @types.color_panel)
  @draw.draw_text("METALS", px, py, 18, @types.color_hud_text)
  @draw.draw_text(
    "Click or press 1-6 to add",
    px,
    py + 22,
    12,
    @types.color_hud_dim,
  )
  let metal_y = py + 45
  let metal_h = 60
  for i = 0; i < level.available_metals.length(); i = i + 1 {
    let metal = level.available_metals[i]
    let y = metal_y + i * metal_h
    let props = @types.metal_props(metal)
    let hovered = game.hover_metal == i
    // Background
    let bg = if hovered {
      @raylib.Color::new(55, 50, 68, 255)
    } else {
      @raylib.Color::new(40, 36, 52, 255)
    }
    @raylib.draw_rectangle(px, y, 180, 50, bg)
    // Color swatch
    @raylib.draw_rectangle(px + 4, y + 4, 42, 42, @types.metal_color(metal))
    // Key number
    let key_str = (i + 1).to_string()
    @draw.draw_text(
      key_str,
      px + 18,
      y + 16,
      16,
      @raylib.Color::new(200, 200, 200, 200),
    )
    // Metal name
    @draw.draw_text(
      @types.metal_name(metal),
      px + 52,
      y + 4,
      16,
      @types.color_hud_text,
    )
    // Mini property bars
    draw_mini_bar(px + 52, y + 22, 40, props.hardness, @types.color_hardness)
    draw_mini_bar(
      px + 96,
      y + 22,
      40,
      props.flexibility,
      @types.color_flexibility,
    )
    draw_mini_bar(
      px + 140,
      y + 22,
      40,
      props.conductivity,
      @types.color_conductivity,
    )
    // Property labels
    @draw.draw_text("H", px + 52, y + 34, 10, @types.color_hud_dim)
    @draw.draw_text("F", px + 96, y + 34, 10, @types.color_hud_dim)
    @draw.draw_text("C", px + 140, y + 34, 10, @types.color_hud_dim)
    // Hover outline
    if hovered {
      @raylib.draw_rectangle_lines(px, y, 180, 50, @types.color_selected)
    }
  }
}

///|
fn draw_mini_bar(
  x : Int,
  y : Int,
  w : Int,
  value : Float,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, 8, @types.color_property_bar_bg)
  let fill = (Float::from_int(w) * value / 100.0).to_int()
  @raylib.draw_rectangle(x, y, fill, 8, color)
}

///|
fn draw_crucible_area(game : @types.Game) -> Unit {
  let cx = 480
  let cy = 80
  // Panel background
  @raylib.draw_rectangle(cx - 10, cy - 10, 290, 460, @types.color_panel)
  @draw.draw_text("CRUCIBLE", cx, cy, 18, @types.color_hud_text)
  let count = @types.total_ingredient_count(game)
  let count_str = "Ingredients: " + count.to_string()
  @draw.draw_text(count_str, cx, cy + 22, 14, @types.color_hud_dim)
  // Draw crucible vessel
  let vessel_x = cx
  let vessel_y = cy + 50
  let vessel_w = 260
  let vessel_h = 330
  // Crucible outline
  @raylib.draw_rectangle(
    vessel_x, vessel_y, vessel_w, vessel_h, @types.color_crucible,
  )
  @raylib.draw_rectangle(
    vessel_x + 4,
    vessel_y + 4,
    vessel_w - 8,
    vessel_h - 8,
    @types.color_crucible_inner,
  )
  // Draw ingredients as layers
  if game.crucible.is_empty() {
    @draw.draw_text(
      "Empty - add metals!",
      vessel_x + 50,
      vessel_y + vessel_h / 2 - 10,
      16,
      @types.color_hud_dim,
    )
  } else {
    let slot_h = 55
    let slot_x = vessel_x + 10
    for i in 0..<game.crucible.length() {
      let ing = game.crucible[i]
      let y = vessel_y + 10 + i * slot_h
      let selected = i == game.selected_slot
      // Ingredient background
      let bg = if selected {
        @raylib.Color::new(70, 55, 40, 255)
      } else {
        @raylib.Color::new(45, 38, 30, 255)
      }
      @raylib.draw_rectangle(slot_x, y, vessel_w - 20, 48, bg)
      // Color bar
      @raylib.draw_rectangle(slot_x, y, 8, 48, @types.metal_color(ing.metal))
      // Metal name and amount
      let name = @types.metal_name(ing.metal)
      @draw.draw_text(name, slot_x + 14, y + 4, 16, @types.color_hud_text)
      let amount_str = "x" + ing.amount.to_string()
      @draw.draw_text(amount_str, slot_x + 14, y + 24, 14, @types.color_hud_dim)
      // Properties preview
      let props = @types.metal_props(ing.metal)
      draw_mini_bar(
        slot_x + 100,
        y + 8,
        50,
        props.hardness,
        @types.color_hardness,
      )
      draw_mini_bar(
        slot_x + 100,
        y + 20,
        50,
        props.flexibility,
        @types.color_flexibility,
      )
      draw_mini_bar(
        slot_x + 100,
        y + 32,
        50,
        props.conductivity,
        @types.color_conductivity,
      )
      // Remove hint
      @draw.draw_text(
        "R-click: remove",
        slot_x + 160,
        y + 16,
        10,
        @types.color_hud_dim,
      )
      if selected {
        @raylib.draw_rectangle_lines(
          slot_x,
          y,
          vessel_w - 20,
          48,
          @types.color_selected,
        )
      }
    }
  }
}

///|
fn draw_target_panel(game : @types.Game, level : @types.LevelDef) -> Unit {
  let tx = 800
  let ty = 80
  // Panel background
  @raylib.draw_rectangle(tx - 10, ty - 10, 470, 460, @types.color_panel)
  @draw.draw_text("TARGET ALLOY", tx, ty, 18, @types.color_hud_text)
  @draw.draw_text(level.hint, tx, ty + 22, 12, @types.color_hud_dim)
  let bar_y = ty + 50
  // Draw target ranges as horizontal bars
  draw_property_target(
    tx,
    bar_y,
    "Hardness",
    level.target.hardness,
    @types.color_hardness,
    game,
  )
  draw_property_target(
    tx,
    bar_y + 110,
    "Flexibility",
    level.target.flexibility,
    @types.color_flexibility,
    game,
  )
  draw_property_target(
    tx,
    bar_y + 220,
    "Conductivity",
    level.target.conductivity,
    @types.color_conductivity,
    game,
  )
  // Preview blend result if crucible has items
  if game.crucible.length() > 0 {
    let preview = @forge.blend(game.crucible, game.temperature)
    draw_blend_preview(tx, bar_y, preview, level)
  }
  // Par info
  let par_str = "Par: " + level.par_ingredients.to_string() + " ingredients"
  @draw.draw_text(par_str, tx, bar_y + 340, 14, @types.color_hud_dim)
}

///|
fn draw_property_target(
  x : Int,
  y : Int,
  name : String,
  range : @types.PropertyRange,
  color : @raylib.Color,
  _game : @types.Game,
) -> Unit {
  @draw.draw_text(name, x, y, 16, color)
  let range_str = format_float(range.min, 0) +
    " - " +
    format_float(range.max, 0)
  @draw.draw_text(range_str, x + 120, y, 14, @types.color_hud_dim)
  // Full bar background (0-100)
  let bar_x = x
  let bar_y = y + 22
  let bar_w = 440
  let bar_h = 24
  @raylib.draw_rectangle(
    bar_x, bar_y, bar_w, bar_h, @types.color_property_bar_bg,
  )
  // Target range highlight
  let range_x = bar_x + (Float::from_int(bar_w) * range.min / 100.0).to_int()
  let range_w = (Float::from_int(bar_w) * (range.max - range.min) / 100.0).to_int()
  let range_alpha = 80
  @raylib.draw_rectangle(
    range_x,
    bar_y,
    range_w,
    bar_h,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      range_alpha,
    ),
  )
  // Range borders
  @raylib.draw_line(range_x, bar_y, range_x, bar_y + bar_h, color)
  @raylib.draw_line(
    range_x + range_w,
    bar_y,
    range_x + range_w,
    bar_y + bar_h,
    color,
  )
  // Center marker
  let center_x = bar_x +
    (Float::from_int(bar_w) * (range.min + range.max) / 200.0).to_int()
  @raylib.draw_line(
    center_x,
    bar_y + 2,
    center_x,
    bar_y + bar_h - 2,
    @raylib.Color::new(255, 255, 255, 60),
  )
  // Scale labels
  @draw.draw_text("0", bar_x, bar_y + bar_h + 2, 10, @types.color_hud_dim)
  @draw.draw_text(
    "50",
    bar_x + bar_w / 2 - 6,
    bar_y + bar_h + 2,
    10,
    @types.color_hud_dim,
  )
  @draw.draw_text(
    "100",
    bar_x + bar_w - 18,
    bar_y + bar_h + 2,
    10,
    @types.color_hud_dim,
  )
}

///|
fn draw_blend_preview(
  x : Int,
  base_y : Int,
  preview : @types.BlendResult,
  level : @types.LevelDef,
) -> Unit {
  let bar_w = 440
  // Draw markers on each property bar
  draw_value_marker(
    x,
    base_y + 22,
    bar_w,
    preview.hardness,
    @forge.in_range(preview.hardness, level.target.hardness),
  )
  draw_value_marker(
    x,
    base_y + 132,
    bar_w,
    preview.flexibility,
    @forge.in_range(preview.flexibility, level.target.flexibility),
  )
  draw_value_marker(
    x,
    base_y + 242,
    bar_w,
    preview.conductivity,
    @forge.in_range(preview.conductivity, level.target.conductivity),
  )
  // Numeric preview values
  let h_str = "Current: " + format_float(preview.hardness, 1)
  let h_in = @forge.in_range(preview.hardness, level.target.hardness)
  @draw.draw_text(
    h_str,
    x + 260,
    base_y,
    14,
    if h_in {
      @types.color_success
    } else {
      @types.color_fail
    },
  )
  let f_str = "Current: " + format_float(preview.flexibility, 1)
  let f_in = @forge.in_range(preview.flexibility, level.target.flexibility)
  @draw.draw_text(
    f_str,
    x + 260,
    base_y + 110,
    14,
    if f_in {
      @types.color_success
    } else {
      @types.color_fail
    },
  )
  let c_str = "Current: " + format_float(preview.conductivity, 1)
  let c_in = @forge.in_range(preview.conductivity, level.target.conductivity)
  @draw.draw_text(
    c_str,
    x + 260,
    base_y + 220,
    14,
    if c_in {
      @types.color_success
    } else {
      @types.color_fail
    },
  )
}

///|
fn draw_value_marker(
  bar_x : Int,
  bar_y : Int,
  bar_w : Int,
  value : Float,
  in_range : Bool,
) -> Unit {
  let marker_x = bar_x +
    (Float::from_int(bar_w) * @types.clampf(value, 0.0, 100.0) / 100.0).to_int()
  let color = if in_range { @types.color_success } else { @types.color_fail }
  // Triangle marker above bar
  let bar_h = 24
  @raylib.draw_triangle(
    @raylib.Vector2::new(
      Float::from_int(marker_x - 5),
      Float::from_int(bar_y - 2),
    ),
    @raylib.Vector2::new(
      Float::from_int(marker_x + 5),
      Float::from_int(bar_y - 2),
    ),
    @raylib.Vector2::new(Float::from_int(marker_x), Float::from_int(bar_y + 4)),
    color,
  )
  // Vertical line through bar
  @raylib.draw_line(marker_x, bar_y, marker_x, bar_y + bar_h, color)
}

///|
fn draw_temperature_panel(game : @types.Game) -> Unit {
  let tx = 480
  let ty = 555
  @draw.draw_text("TEMPERATURE", tx, ty - 10, 16, @types.color_hud_text)
  let desc = @types.temp_description(game.temperature)
  @draw.draw_text(desc, tx + 270, ty - 6, 12, @types.color_hud_dim)
  let temp_w = 80
  let temps : Array[@types.Temperature] = [Low, Medium, High]
  for i in 0..<3 {
    let x = tx + i * (temp_w + 8)
    let t = temps[i]
    let is_selected = game.temperature == t
    let hovered = game.hover_button == "temp_" + i.to_string()
    let bg = if is_selected {
      @types.temp_color(t)
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(x, ty + 12, temp_w, 35, bg)
    let name = @types.temp_name(t)
    let nw = @draw.measure_text(name, 14)
    let text_color = if is_selected {
      @raylib.Color::new(30, 25, 20, 255)
    } else {
      @types.color_hud_text
    }
    @draw.draw_text(name, x + (temp_w - nw) / 2, ty + 20, 14, text_color)
    if is_selected {
      @raylib.draw_rectangle_lines(
        x,
        ty + 12,
        temp_w,
        35,
        @types.color_selected,
      )
    }
  }
  @draw.draw_text("T: toggle", tx, ty + 54, 12, @types.color_hud_dim)
}

///|
fn draw_action_buttons(game : @types.Game) -> Unit {
  let blend_x = 480
  let blend_y = 620
  let blend_w = 150
  let blend_h = 40
  let blend_hovered = game.hover_button == "blend"
  let blend_bg = if blend_hovered {
    @raylib.Color::new(60, 200, 100, 255)
  } else {
    @raylib.Color::new(50, 170, 80, 255)
  }
  @raylib.draw_rectangle(blend_x, blend_y, blend_w, blend_h, blend_bg)
  let blend_text = "BLEND (Space)"
  let btw = @draw.measure_text(blend_text, 16)
  @draw.draw_text(
    blend_text,
    blend_x + (blend_w - btw) / 2,
    blend_y + 12,
    16,
    @raylib.white,
  )
  let reset_x = 650
  let reset_y = 620
  let reset_w = 100
  let reset_h = 40
  let reset_hovered = game.hover_button == "reset"
  let reset_bg = if reset_hovered {
    @raylib.Color::new(200, 90, 60, 255)
  } else {
    @raylib.Color::new(170, 70, 50, 255)
  }
  @raylib.draw_rectangle(reset_x, reset_y, reset_w, reset_h, reset_bg)
  let reset_text = "RESET (R)"
  let rtw = @draw.measure_text(reset_text, 16)
  @draw.draw_text(
    reset_text,
    reset_x + (reset_w - rtw) / 2,
    reset_y + 12,
    16,
    @raylib.white,
  )
}

///|
fn draw_controls_help(_game : @types.Game) -> Unit {
  let hx = 40
  let hy = @types.screen_height - 60
  @draw.draw_text("1-6: Add Metals", hx, hy, 12, @types.color_hud_dim)
  @draw.draw_text(
    "BACKSPACE: Remove  |  T: Temperature",
    hx + 130,
    hy,
    12,
    @types.color_hud_dim,
  )
  @draw.draw_text(
    "SPACE: Blend  |  R: Reset  |  ESC: Level Select",
    hx,
    hy + 16,
    12,
    @types.color_hud_dim,
  )
}
