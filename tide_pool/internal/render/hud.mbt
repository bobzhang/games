///|
pub fn draw_palette(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      let px = @types.palette_x
      let py = @types.palette_y
      let ss = @types.palette_slot_size
      let gap = @types.palette_gap
      @draw.draw_text("ORGANISMS", px, py - 24, 18, @types.color_hud_text)
      for i in 0..<level.available_organisms.length() {
        let kind = level.available_organisms[i]
        let sx = px
        let sy = py + i * (ss + gap)
        let profile = @types.get_profile(kind)
        let avail = @types.get_available_count(game, kind)
        let is_selected = match game.selected_organism {
          Some(sel) => sel == kind
          None => false
        }
        let bg = if is_selected {
          @types.color_selected
        } else {
          @types.color_bar_bg
        }
        @raylib.draw_rectangle(sx, sy, ss, ss, bg)
        draw_organism_icon(kind, sx, sy, ss)
        @raylib.draw_rectangle_lines(
          sx,
          sy,
          ss,
          ss,
          if is_selected {
            @types.color_title
          } else {
            @types.color_hud_dim
          },
        )
        @draw.draw_text(
          profile.name,
          sx + ss + 8,
          sy + 4,
          14,
          @types.color_hud_text,
        )
        @draw.draw_text(
          "x\{avail}",
          sx + ss + 8,
          sy + 22,
          14,
          if avail > 0 {
            @types.color_ok
          } else {
            @types.color_warn
          },
        )
        let zone_text = @types.zone_name(profile.preferred_zone)
        @draw.draw_text(
          "\{zone_text} zone",
          sx + ss + 8,
          sy + 38,
          11,
          @types.color_hud_dim,
        )
      }
    }
  }
}

///|
pub fn draw_hud(game : @types.Game) -> Unit {
  let hx = @types.hud_x
  let hy = @types.hud_y
  @draw.draw_text("STATUS", hx, hy, 18, @types.color_hud_text)
  let turn_text = "Turn: \{game.current_turn}/\{@types.max_turns}"
  @draw.draw_text(turn_text, hx, hy + 28, 16, @types.color_hud_text)
  let cycle_text = "Cycle: \{game.current_cycle + 1}/\{@types.total_cycles}"
  @draw.draw_text(cycle_text, hx, hy + 50, 16, @types.color_hud_text)
  let phase_text = match game.tide_phase {
    Low => "Low Tide"
    Mid => "Mid Tide"
    High => "High Tide"
  }
  @draw.draw_text(phase_text, hx, hy + 72, 16, @types.color_tide_indicator)
  match game.current_level {
    None => ()
    Some(level) => {
      @draw.draw_text("Targets:", hx, hy + 100, 14, @types.color_hud_dim)
      for i in 0..<level.target_species.length() {
        let kind = level.target_species[i]
        let profile = @types.get_profile(kind)
        let mut alive = false
        for j in 0..<game.organisms.length() {
          if game.organisms[j].alive && game.organisms[j].kind == kind {
            alive = true
            break
          }
        }
        let status_color = if alive {
          @types.color_alive
        } else {
          @types.color_dead
        }
        let status_text = if alive { "OK" } else { "DEAD" }
        @draw.draw_text(
          "\{profile.name}: \{status_text}",
          hx + 8,
          hy + 118 + i * 18,
          13,
          status_color,
        )
      }
    }
  }
  draw_organism_health(game)
}

///|
fn draw_organism_health(game : @types.Game) -> Unit {
  let hx = @types.hud_x + 250
  let hy = @types.hud_y
  @draw.draw_text("HEALTH", hx, hy, 18, @types.color_hud_text)
  let mut idx = 0
  for i in 0..<game.organisms.length() {
    let org = game.organisms[i]
    if !org.alive {
      continue
    }
    let profile = @types.get_profile(org.kind)
    let y = hy + 28 + idx * 22
    let bar_w = 120
    let bar_h = 14
    let fill_pct = org.health / @types.max_health
    let fill_w_float = Float::from_int(bar_w) * fill_pct
    let fill_w = fill_w_float.to_int()
    let health_color = if org.health > @types.health_warn {
      @types.color_alive
    } else {
      @types.color_warn
    }
    @draw.draw_text(
      "\{profile.symbol}(\{org.row},\{org.col})",
      hx,
      y,
      11,
      @types.color_hud_dim,
    )
    @raylib.draw_rectangle(hx + 60, y + 1, bar_w, bar_h, @types.color_bar_bg)
    @raylib.draw_rectangle(hx + 60, y + 1, fill_w, bar_h, health_color)
    @raylib.draw_rectangle_lines(
      hx + 60,
      y + 1,
      bar_w,
      bar_h,
      @types.color_hud_dim,
    )
    idx += 1
    if idx >= 8 {
      break
    }
  }
}

///|
pub fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 18) + 20
    let msg_x = @types.screen_width / 2 - msg_w / 2
    let msg_y = @types.screen_height - 50
    @raylib.draw_rectangle(
      msg_x - 10,
      msg_y - 4,
      msg_w + 20,
      30,
      @types.color_bar_bg,
    )
    @draw.draw_text(game.message, msg_x, msg_y, 18, @types.color_title)
  }
}
