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
fn draw_hex_map(battle : @types.Battle) -> Unit {
  let map = battle.map
  let size = @types.hex_size
  for row in 0..<map.height {
    for col in 0..<map.width {
      let coord = @types.hex(col, row)
      let (cx, cy) = @types.hex_to_pixel(coord)
      let idx = @types.hex_index(coord, map.width)
      let tile = map.tiles[idx]
      // Draw terrain
      let tc = terrain_color(tile.terrain)
      draw_hex_filled(cx, cy, size - 1.0, tc)
      // Grid outline
      draw_hex_outline(cx, cy, size, @types.color_grid_line)
      // Flag marker
      if tile.has_flag {
        draw_flag(cx, cy)
      }
      // Fog of war overlay
      match tile.fog_player {
        Hidden => draw_hex_filled(cx, cy, size, @types.color_fog_hidden)
        Explored => draw_hex_filled(cx, cy, size, @types.color_fog_explored)
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
fn draw_units(battle : @types.Battle) -> Unit {
  let map = battle.map
  for i in 0..<battle.units.length() {
    let unit = battle.units[i]
    if !(unit.active) {
      continue
    }
    // Check fog - only draw visible units (or player units)
    let idx = @types.hex_index(unit.pos, map.width)
    if unit.team == Enemy && map.tiles[idx].fog_player != Visible {
      continue
    }
    let (cx, cy) = @types.hex_to_pixel(unit.pos)
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
    @raylib.draw_circle(
      cx.to_int(), cy.to_int(), body_size * 0.7, inner,
    )
    // Unit kind icon
    draw_unit_icon(cx, cy, unit.kind, body_size)
    // HP bar
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
  let bar_w = (unit_size * 1.6).to_int()
  let bar_h = 4
  let bx = cx.to_int() - bar_w / 2
  let by = cy.to_int() + (unit_size * 0.8).to_int() + 2
  // Background
  @raylib.draw_rectangle(bx, by, bar_w, bar_h, @types.color_hp_bar_bg)
  // Filled portion
  let fill = bar_w * hp / max_hp
  let fill_color = if hp * 3 <= max_hp {
    @types.color_enemy
  } else {
    @types.color_hp_bar
  }
  @raylib.draw_rectangle(bx, by, fill, bar_h, fill_color)
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
fn draw_playing(game : @types.Game) -> Unit {
  match game.battle {
    Some(battle) => {
      draw_hex_map(battle)
      draw_move_overlay(battle)
      draw_attack_overlay(battle)
      draw_selected_highlight(battle)
      draw_units(battle)
      draw_hover_info(game, battle)
      draw_ui_panel(game, battle)
      // Animation message
      if battle.anim_timer > 0.0 && battle.anim_message.length() > 0 {
        let mw = @draw.measure_text(battle.anim_message, 20)
        let mx = (@types.screen_width - mw) / 2
        @raylib.draw_rectangle(
          mx - 10,
          @types.screen_height / 2 - 15,
          mw + 20,
          30,
          @raylib.Color::new(0, 0, 0, 180),
        )
        @draw.draw_text(
          battle.anim_message,
          mx,
          @types.screen_height / 2 - 10,
          20,
          @raylib.Color::new(255, 200, 100, 255),
        )
      }
    }
    None => ()
  }
}
