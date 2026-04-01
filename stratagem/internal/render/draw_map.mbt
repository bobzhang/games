///|
fn hex_corner_x(cx : Float, size : Float, i : Int) -> Float {
  let angle = Float::from_double(@math.PI) / 3.0 * Float::from_int(i) + Float::from_double(
      @math.PI,
    ) / 6.0
  cx + size * @types.cosf(angle)
}

///|
fn hex_corner_y(cy : Float, size : Float, i : Int) -> Float {
  let angle = Float::from_double(@math.PI) / 3.0 * Float::from_int(i) + Float::from_double(
      @math.PI,
    ) / 6.0
  cy + size * @types.sinf(angle)
}

///|
fn draw_hex_filled(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  for i = 0; i < 6; i = i + 1 {
    let x1 = hex_corner_x(cx, size, i)
    let y1 = hex_corner_y(cy, size, i)
    let next = (i + 1) % 6
    let x2 = hex_corner_x(cx, size, next)
    let y2 = hex_corner_y(cy, size, next)
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
  }
}

///|
fn draw_hex_outline(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  for i = 0; i < 6; i = i + 1 {
    let x1 = hex_corner_x(cx, size, i)
    let y1 = hex_corner_y(cy, size, i)
    let next = (i + 1) % 6
    let x2 = hex_corner_x(cx, size, next)
    let y2 = hex_corner_y(cy, size, next)
    @raylib.draw_line(x1.to_int(), y1.to_int(), x2.to_int(), y2.to_int(), color)
  }
}

///|
fn terrain_color(t : @types.Terrain) -> @raylib.Color {
  match t {
    Plains => @types.color_plains
    Forest => @types.color_forest
    Hills => @types.color_hills
    Water => @types.color_water
  }
}

///|
fn draw_terrain_indicator(
  cx : Float,
  cy : Float,
  terrain : @types.Terrain
) -> Unit {
  let ix = cx.to_int()
  let iy = cy.to_int()
  match terrain {
    Forest => {
      // Tree shapes
      let green = @raylib.Color::new(30, 100, 40, 180)
      let dark_green = @raylib.Color::new(20, 70, 25, 160)
      // Center tree
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy - 12.0),
        @raylib.Vector2::new(cx - 7.0, cy + 2.0),
        @raylib.Vector2::new(cx + 7.0, cy + 2.0),
        green,
      )
      @raylib.draw_rectangle(ix - 1, iy + 2, 3, 5, dark_green)
      // Side trees (smaller)
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx - 10.0, cy - 6.0),
        @raylib.Vector2::new(cx - 15.0, cy + 2.0),
        @raylib.Vector2::new(cx - 5.0, cy + 2.0),
        dark_green,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx + 10.0, cy - 6.0),
        @raylib.Vector2::new(cx + 5.0, cy + 2.0),
        @raylib.Vector2::new(cx + 15.0, cy + 2.0),
        dark_green,
      )
    }
    Hills => {
      // Hill bumps
      let brown = @raylib.Color::new(140, 100, 55, 140)
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy - 10.0),
        @raylib.Vector2::new(cx - 14.0, cy + 4.0),
        @raylib.Vector2::new(cx + 14.0, cy + 4.0),
        brown,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx - 10.0, cy - 4.0),
        @raylib.Vector2::new(cx - 20.0, cy + 4.0),
        @raylib.Vector2::new(cx, cy + 4.0),
        @raylib.Color::new(120, 85, 45, 120),
      )
    }
    Water => {
      // Wave lines
      let wave = @raylib.Color::new(80, 140, 220, 120)
      @raylib.draw_line(ix - 12, iy - 3, ix - 4, iy - 5, wave)
      @raylib.draw_line(ix - 4, iy - 5, ix + 4, iy - 3, wave)
      @raylib.draw_line(ix + 4, iy - 3, ix + 12, iy - 5, wave)
      @raylib.draw_line(ix - 10, iy + 3, ix - 2, iy + 1, wave)
      @raylib.draw_line(ix - 2, iy + 1, ix + 6, iy + 3, wave)
      @raylib.draw_line(ix + 6, iy + 3, ix + 10, iy + 1, wave)
    }
    Plains => ()
  }
}

///|
fn draw_hex_map(battle : @types.Battle) -> Unit {
  let map = battle.map
  let size = @types.hex_size
  for row in 0..<map.height {
    for col in 0..<map.width {
      let coord = @types.hex(col, row)
      let (cx, cy) = @types.hex_to_pixel(coord)
      let idx = @types.hex_index(coord, map.width)
      let tile = map.tiles[idx]
      // Draw terrain base
      let tc = terrain_color(tile.terrain)
      draw_hex_filled(cx, cy, size - 1.0, tc)
      // Terrain indicator (trees, hills, waves)
      draw_terrain_indicator(cx, cy, tile.terrain)
      // Grid outline
      draw_hex_outline(cx, cy, size, @types.color_grid_line)
      // Flag marker
      if tile.has_flag {
        draw_flag(cx, cy)
      }
      // Fog of war overlay with gradient effect
      match tile.fog_player {
        Hidden => {
          // Fully dark with slight border glow
          draw_hex_filled(cx, cy, size, @types.color_fog_hidden)
          // Subtle edge highlight so hidden area has definition
          draw_hex_outline(cx, cy, size, @raylib.Color::new(20, 25, 40, 200))
        }
        Explored => {
          // Semi-transparent with slight desaturation overlay
          draw_hex_filled(cx, cy, size, @raylib.Color::new(0, 0, 0, 120))
          // Dim purple tint for "memory" effect
          draw_hex_filled(
            cx, cy, size - 2.0, @raylib.Color::new(20, 10, 30, 60),
          )
        }
        Visible => ()
      }
    }
  }
}

///|
fn draw_flag(cx : Float, cy : Float) -> Unit {
  let ix = cx.to_int()
  let iy = cy.to_int()
  @raylib.draw_rectangle(ix - 2, iy - 12, 3, 24, @types.color_flag)
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx + 1.0, cy - 12.0),
    @raylib.Vector2::new(cx + 15.0, cy - 6.0),
    @raylib.Vector2::new(cx + 1.0, cy),
    @types.color_flag,
  )
}

///|
fn draw_move_overlay(battle : @types.Battle) -> Unit {
  let size = @types.hex_size
  for i in 0..<battle.move_targets.length() {
    let c = battle.move_targets[i]
    let (cx, cy) = @types.hex_to_pixel(c)
    draw_hex_filled(cx, cy, size - 2.0, @types.color_move_overlay)
  }
}

///|
fn draw_attack_overlay(battle : @types.Battle) -> Unit {
  let size = @types.hex_size
  for i in 0..<battle.attack_targets.length() {
    let c = battle.attack_targets[i]
    let (cx, cy) = @types.hex_to_pixel(c)
    draw_hex_filled(cx, cy, size - 2.0, @types.color_attack_overlay)
  }
}

///|
fn draw_selected_highlight(battle : @types.Battle) -> Unit {
  if battle.selected_unit >= 0 {
    match @types.get_unit(battle, battle.selected_unit) {
      Some(unit) => {
        let (cx, cy) = @types.hex_to_pixel(unit.pos)
        let size = @types.hex_size
        draw_hex_outline(
          cx, cy, size + 2.0, @raylib.Color::new(255, 255, 100, 200),
        )
        draw_hex_outline(
          cx, cy, size + 4.0, @raylib.Color::new(255, 255, 100, 100),
        )
      }
      None => ()
    }
  }
}

///|
fn draw_units_with_shake(battle : @types.Battle) -> Unit {
  let map = battle.map
  for i in 0..<battle.units.length() {
    let unit = battle.units[i]
    if !(unit.active) {
      continue
    }
    let idx = @types.hex_index(unit.pos, map.width)
    if unit.team == Enemy && map.tiles[idx].fog_player != Visible {
      continue
    }
    let (base_cx, base_cy) = @types.hex_to_pixel(unit.pos)
    let (sx, sy) = draw_hit_shake_offset(battle, unit.pos)
    let cx = base_cx + sx
    let cy = base_cy + sy
    draw_single_unit(battle, unit, cx, cy)
  }
}

///|
fn draw_single_unit(
  _battle : @types.Battle,
  unit : @types.GameUnit,
  cx : Float,
  cy : Float
) -> Unit {
  // Team color
  let team_color = if unit.team == Player {
    @types.color_player
  } else {
    @types.color_enemy
  }
  // Unit body
  let body_size = @types.hex_size * 0.55
  @raylib.draw_circle(cx.to_int(), cy.to_int(), body_size, team_color)
  // Darker inner circle
  let inner = if unit.team == Player {
    @raylib.Color::new(36, 72, 153, 255)
  } else {
    @raylib.Color::new(132, 30, 30, 255)
  }
  @raylib.draw_circle(cx.to_int(), cy.to_int(), body_size * 0.7, inner)
  // Unit kind icon
  draw_unit_icon(cx, cy, unit.kind, body_size)
  // HP bar above unit
  draw_hp_bar(cx, cy, unit.hp, unit.max_hp, body_size)
  // Dim if already acted
  if unit.team == Player && unit.moved && unit.attacked {
    @raylib.draw_circle(
      cx.to_int(),
      cy.to_int(),
      body_size + 2.0,
      @raylib.Color::new(0, 0, 0, 100),
    )
  }
}

///|
fn draw_unit_icon(
  cx : Float,
  cy : Float,
  kind : @types.UnitKind,
  size : Float
) -> Unit {
  let white = @raylib.Color::new(240, 240, 240, 255)
  let ix = cx.to_int()
  let iy = cy.to_int()
  match kind {
    Infantry => {
      // Sword icon - two crossed lines
      let s = (size * 0.5).to_int()
      @raylib.draw_line(ix - s, iy - s, ix + s, iy + s, white)
      @raylib.draw_line(ix + s, iy - s, ix - s, iy + s, white)
      @raylib.draw_circle(ix, iy, 3.0, white)
    }
    Cavalry => {
      // Horse shape - triangle pointing right
      let s = size * 0.45
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx + s, cy),
        @raylib.Vector2::new(cx - s * 0.6, cy - s * 0.7),
        @raylib.Vector2::new(cx - s * 0.6, cy + s * 0.7),
        white,
      )
    }
    Artillery => {
      // Cannon icon - rectangle with circle
      let s = (size * 0.35).to_int()
      @raylib.draw_rectangle(ix - s, iy - 3, s * 2, 6, white)
      @raylib.draw_circle(ix - s, iy, 5.0, white)
    }
  }
}

///|
fn draw_hp_bar(
  cx : Float,
  cy : Float,
  hp : Int,
  max_hp : Int,
  unit_size : Float
) -> Unit {
  let bar_w = (unit_size * 1.8).to_int()
  let bar_h = 5
  let bx = cx.to_int() - bar_w / 2
  let by = cy.to_int() - (unit_size * 0.9).to_int() - bar_h - 3
  // Background with border
  @raylib.draw_rectangle(
    bx - 1, by - 1, bar_w + 2, bar_h + 2, @raylib.Color::new(0, 0, 0, 180),
  )
  @raylib.draw_rectangle(bx, by, bar_w, bar_h, @types.color_hp_bar_bg)
  // Filled portion with color gradient based on HP
  let fill = bar_w * hp / max_hp
  let hp_ratio = hp * 100 / max_hp
  let fill_color = if hp_ratio <= 33 {
    @raylib.Color::new(220, 50, 50, 255)
  } else if hp_ratio <= 66 {
    @raylib.Color::new(220, 180, 50, 255)
  } else {
    @types.color_hp_bar
  }
  @raylib.draw_rectangle(bx, by, fill, bar_h, fill_color)
  // HP text above bar
  let hp_text = hp.to_string() + "/" + max_hp.to_string()
  let tw = @draw.measure_text(hp_text, 10)
  @draw.draw_text(
    hp_text,
    cx.to_int() - tw / 2,
    by - 12,
    10,
    @raylib.Color::new(255, 255, 255, 200),
  )
}

///|
fn draw_hover_info(game : @types.Game, battle : @types.Battle) -> Unit {
  match game.hover_hex {
    Some(hc) => {
      if @types.hex_valid(hc, battle.map.width, battle.map.height) {
        let idx = @types.hex_index(hc, battle.map.width)
        let tile = battle.map.tiles[idx]
        if tile.fog_player != Hidden {
          let (cx, cy) = @types.hex_to_pixel(hc)
          // Hover highlight
          draw_hex_outline(
            cx,
            cy,
            @types.hex_size + 1.0,
            @raylib.Color::new(255, 255, 255, 60),
          )
        }
      }
    }
    None => ()
  }
}

///|
fn draw_attack_flash(battle : @types.Battle) -> Unit {
  if battle.attack_flash_timer > 0.0 {
    match battle.attack_flash_pos {
      Some(pos) => {
        let (cx, cy) = @types.hex_to_pixel(pos)
        let size = @types.hex_size
        let alpha_f = battle.attack_flash_timer / 0.3 * 200.0
        let alpha = @types.mini(alpha_f.to_int(), 200)
        // Bright white flash expanding outward
        let flash_size = size * (1.0 + (0.3 - battle.attack_flash_timer) * 2.0)
        draw_hex_filled(
          cx,
          cy,
          flash_size,
          @raylib.Color::new(255, 255, 200, alpha),
        )
      }
      None => ()
    }
  }
}

///|
fn draw_hit_shake_offset(battle : @types.Battle, pos : @types.HexCoord) -> (Float, Float) {
  if battle.hit_shake_timer > 0.0 {
    match battle.hit_shake_target {
      Some(target) =>
        if target.col == pos.col && target.row == pos.row {
          let intensity = battle.hit_shake_timer / 0.4 * 6.0
          let shake_x = @types.sinf(
              battle.hit_shake_timer * 50.0,
            ) * intensity
          let shake_y = @types.cosf(
              battle.hit_shake_timer * 37.0,
            ) * intensity * 0.7
          return (shake_x, shake_y)
        }
      None => ()
    }
  }
  (0.0, 0.0)
}

///|
fn draw_damage_popup(battle : @types.Battle) -> Unit {
  if battle.damage_popup_timer > 0.0 {
    match battle.damage_popup_pos {
      Some(pos) => {
        let (cx, cy) = @types.hex_to_pixel(pos)
        // Float upward as timer counts down
        let elapsed : Float = 0.8 - battle.damage_popup_timer
        let offset_y = elapsed * 60.0
        let alpha_f = battle.damage_popup_timer / 0.8 * 255.0
        let alpha = @types.mini(alpha_f.to_int(), 255)
        let dmg_text = "-" + battle.damage_popup_value.to_string()
        let tw = @draw.measure_text(dmg_text, 22)
        // Shadow
        @draw.draw_text(
          dmg_text,
          cx.to_int() - tw / 2 + 1,
          cy.to_int() - 30 - offset_y.to_int() + 1,
          22,
          @raylib.Color::new(0, 0, 0, alpha),
        )
        // Text
        @draw.draw_text(
          dmg_text,
          cx.to_int() - tw / 2,
          cy.to_int() - 30 - offset_y.to_int(),
          22,
          @raylib.Color::new(255, 80, 80, alpha),
        )
      }
      None => ()
    }
  }
}

///|
fn draw_turn_banner(battle : @types.Battle) -> Unit {
  if battle.turn_banner_timer > 0.0 {
    let w = @types.screen_width
    let alpha_f : Float = if battle.turn_banner_timer > 0.7 {
      (1.0 - battle.turn_banner_timer) / 0.3 * 255.0
    } else if battle.turn_banner_timer < 0.3 {
      battle.turn_banner_timer / 0.3 * 255.0
    } else {
      255.0
    }
    let alpha = @types.mini(@types.maxi(alpha_f.to_int(), 0), 255)
    // Banner background
    @raylib.draw_rectangle(
      0,
      @types.screen_height / 3 - 25,
      w,
      50,
      @raylib.Color::new(0, 0, 0, alpha * 180 / 255),
    )
    let text = "Turn " + battle.turn.to_string()
    let tw = @draw.measure_text(text, 32)
    @draw.draw_text(
      text,
      (w - tw) / 2,
      @types.screen_height / 3 - 16,
      32,
      @raylib.Color::new(255, 215, 0, alpha),
    )
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  match game.battle {
    Some(battle) => {
      draw_hex_map(battle)
      draw_move_overlay(battle)
      draw_attack_overlay(battle)
      draw_selected_highlight(battle)
      draw_units_with_shake(battle)
      draw_hover_info(game, battle)
      draw_attack_flash(battle)
      draw_damage_popup(battle)
      draw_ui_panel(game, battle)
      draw_turn_banner(battle)
      // Animation message
      if battle.anim_timer > 0.0 && battle.anim_message.length() > 0 {
        let mw = @draw.measure_text(battle.anim_message, 20)
        let mx = (@types.screen_width - mw) / 2
        // Rounded-look background
        @raylib.draw_rectangle(
          mx - 15,
          @types.screen_height / 2 - 20,
          mw + 30,
          40,
          @raylib.Color::new(0, 0, 0, 200),
        )
        @raylib.draw_rectangle(
          mx - 14,
          @types.screen_height / 2 - 19,
          mw + 28,
          38,
          @raylib.Color::new(40, 30, 20, 220),
        )
        @draw.draw_text(
          battle.anim_message,
          mx,
          @types.screen_height / 2 - 10,
          20,
          @raylib.Color::new(255, 200, 100, 255),
        )
      }
      // Victory / defeat overlay
      if battle.result != Ongoing {
        draw_end_overlay(battle)
      }
    }
    None => ()
  }
}

///|
fn draw_end_overlay(battle : @types.Battle) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Full screen fade overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 150))
  let (text, color) = match battle.result {
    Victory => ("VICTORY", @raylib.Color::new(255, 215, 0, 255))
    Defeat => ("DEFEAT", @raylib.Color::new(220, 50, 50, 255))
    _ => ("", @raylib.Color::new(255, 255, 255, 255))
  }
  if text.length() > 0 {
    let tw = @draw.measure_text(text, 64)
    @draw.draw_text(text, (w - tw) / 2, h / 3, 64, color)
    let sub = "Press ESC for menu"
    let sw = @draw.measure_text(sub, 20)
    @draw.draw_text(
      sub,
      (w - sw) / 2,
      h / 3 + 80,
      20,
      @raylib.Color::new(180, 180, 200, 200),
    )
  }
}
