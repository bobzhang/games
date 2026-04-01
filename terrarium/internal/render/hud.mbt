///|
pub fn draw_resource_bars(game : @types.Game) -> Unit {
  let x = @types.hud_x
  let mut y = @types.hud_y
  @draw.draw_text("Resources", x, y - 24, 20, @types.color_hud_text)
  let resources : Array[(@types.ResourceKind, Float)] = [
    (O2, game.resources.o2),
    (CO2, game.resources.co2),
    (Water, game.resources.water),
    (Nutrients, game.resources.nutrients),
  ]
  for i in 0..<resources.length() {
    let (kind, value) = resources[i]
    let name = @types.resource_name(kind)
    let color = @types.resource_color(kind)
    @draw.draw_text(name, x, y, 16, color)
    let bar_x = x + 80
    @raylib.draw_rectangle(
      bar_x, y + 2, @types.resource_bar_width, @types.resource_bar_height,
      @types.color_bar_bg,
    )
    let fill_w = (value / @types.max_resource * fi(@types.resource_bar_width)).to_int()
    let bar_color = if value < @types.min_resource_warn {
      @types.color_warn
    } else {
      color
    }
    @raylib.draw_rectangle(
      bar_x, y + 2, fill_w, @types.resource_bar_height, bar_color,
    )
    @raylib.draw_rectangle_lines(
      bar_x, y + 2, @types.resource_bar_width, @types.resource_bar_height,
      @types.color_hud_dim,
    )
    let val_str = value.to_int().to_string()
    @draw.draw_text(
      val_str, bar_x + @types.resource_bar_width + 8, y + 1, 14,
      @types.color_hud_text,
    )
    y += 28
  }
}

///|
pub fn draw_palette(game : @types.Game) -> Unit {
  let x = @types.palette_x
  let y = @types.palette_y
  @draw.draw_text("Organisms", x, y - 24, 20, @types.color_hud_text)
  match game.current_level {
    None => ()
    Some(level) => {
      for i in 0..<level.available_organisms.length() {
        let kind = level.available_organisms[i]
        let slot_y = y + i * (@types.palette_slot_size + @types.palette_gap)
        let profile = @types.get_profile(kind)
        let avail = @types.get_available_count(game, kind)
        let color = @types.organism_color(kind)
        let is_selected = game.selected_organism == Some(kind)
        if is_selected {
          @raylib.draw_rectangle(
            x - 2,
            slot_y - 2,
            @types.palette_slot_size + 4,
            @types.palette_slot_size + 4,
            @types.color_selected,
          )
        }
        @raylib.draw_rectangle(
          x, slot_y, @types.palette_slot_size, @types.palette_slot_size,
          @types.color_empty_cell,
        )
        @raylib.draw_rectangle(
          x + 4,
          slot_y + 4,
          @types.palette_slot_size - 8,
          @types.palette_slot_size - 8,
          color,
        )
        let sym = @types.organism_symbol(kind)
        @draw.draw_text(
          sym,
          x + @types.palette_slot_size / 2 - 6,
          slot_y + @types.palette_slot_size / 2 - 10,
          20,
          @types.color_bg,
        )
        @raylib.draw_rectangle_lines(
          x, slot_y, @types.palette_slot_size, @types.palette_slot_size,
          @types.color_jar_border,
        )
        let info_x = x + @types.palette_slot_size + 8
        @draw.draw_text(profile.name, info_x, slot_y + 2, 16, color)
        @draw.draw_text(
          profile.category, info_x, slot_y + 18, 12, @types.color_hud_dim,
        )
        let count_str = "x" + avail.to_string()
        let count_color = if avail > 0 {
          @types.color_ok
        } else {
          @types.color_warn
        }
        @draw.draw_text(count_str, info_x + 80, slot_y + 2, 16, count_color)
        @draw.draw_text(
          "O2:" + profile.o2_delta.to_int().to_string() + " CO2:" + profile.co2_delta.to_int().to_string(),
          info_x,
          slot_y + 34,
          11,
          @types.color_hud_dim,
        )
        @draw.draw_text(
          "H2O:" + profile.water_delta.to_int().to_string() + " Nut:" + profile.nutrient_delta.to_int().to_string(),
          info_x,
          slot_y + 46,
          11,
          @types.color_hud_dim,
        )
      }
    }
  }
}

///|
pub fn draw_turn_info(game : @types.Game) -> Unit {
  let x = @types.grid_offset_x
  let y = @types.grid_offset_y + @types.grid_size * @types.cell_size + 20
  @draw.draw_text(
    "Turn: " + game.current_turn.to_string() + " / " + @types.max_turns.to_string(),
    x,
    y,
    20,
    @types.color_hud_text,
  )
  let alive = count_alive_organisms(game)
  let total = game.organisms.length()
  @draw.draw_text(
    "Alive: " + alive.to_string() + " / " + total.to_string(),
    x + 200,
    y,
    20,
    if alive == total { @types.color_ok } else { @types.color_warn },
  )
}

///|
fn count_alive_organisms(game : @types.Game) -> Int {
  let mut c = 0
  for i in 0..<game.organisms.length() {
    if game.organisms[i].alive {
      c += 1
    }
  }
  c
}

///|
pub fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let alpha = if game.message_timer > 1.0 {
      255
    } else {
      (game.message_timer * 255.0).to_int()
    }
    let a : Byte = if alpha > 255 {
      b'\xff'
    } else if alpha < 0 {
      b'\x00'
    } else {
      alpha.to_byte()
    }
    let col = @raylib.Color::new(
      @types.color_hud_text.r.to_int(),
      @types.color_hud_text.g.to_int(),
      @types.color_hud_text.b.to_int(),
      a.to_int(),
    )
    let tw = @draw.measure_text(game.message, 20)
    @draw.draw_text(
      game.message,
      @types.screen_width / 2 - tw / 2,
      @types.screen_height - 50,
      20,
      col,
    )
  }
}

///|
pub fn draw_sim_log(game : @types.Game) -> Unit {
  if game.sim_log.length() == 0 {
    return
  }
  let x = @types.palette_x
  let mut y = @types.hud_y + 140
  @draw.draw_text("Simulation Log", x, y, 16, @types.color_subtitle)
  y += 20
  let start = if game.sim_log.length() > 6 {
    game.sim_log.length() - 6
  } else {
    0
  }
  for i = start; i < game.sim_log.length(); i = i + 1 {
    let log = game.sim_log[i]
    let turn_str = "T" + log.turn.to_string() + ": "
    let alive_str = turn_str + log.organisms_alive.to_string() + " alive"
    let col = if log.organisms_alive > 0 {
      @types.color_ok
    } else {
      @types.color_warn
    }
    @draw.draw_text(alive_str, x, y, 12, col)
    y += 14
    for j in 0..<log.events.length() {
      if y < @types.screen_height - 20 {
        let event_text = truncate_string(log.events[j], 40)
        @draw.draw_text("  " + event_text, x, y, 11, @types.color_hud_dim)
        y += 13
      }
    }
  }
}
