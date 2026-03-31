///|
pub fn draw(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    Campaign => draw_campaign(game)
    Battle => draw_battle(game)
    EnemyTurn => draw_battle_enemy_phase(game)
    Reward => draw_reward(game)
    GameOver => draw_end(game, "GAME OVER", @types.color_enemy)
    Victory => draw_end(game, "VICTORY", @types.color_player)
    _ => draw_title(game)
  }
  @fps.draw()
}

// ============================================================================
// Title screen
// ============================================================================

///|
fn draw_title(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let cy_title = @types.screen_h / 4
  // Draw geometric background decorations
  draw_title_decorations(game)
  // Main title
  @types.draw_center_text(
    "VECTOR BREACH",
    cx,
    cy_title,
    @types.font_title,
    @types.color_player,
  )
  // Subtitle
  @types.draw_center_text(
    "Tactical Mech Combat",
    cx,
    cy_title + 56,
    @types.font_body,
    @types.color_text_dim,
  )
  // Animated mech silhouettes
  draw_title_mechs(game, cx, @types.screen_h / 2 - 20)
  // Blinking prompt
  let blink = Float::from_double(
    @math.sin(game.anim_timer.to_double() * 3.0),
  )
  if blink > 0.0 {
    @types.draw_center_text(
      "Press ENTER to deploy",
      cx,
      @types.screen_h * 3 / 4,
      @types.font_body,
      @types.color_text,
    )
  }
  // Credits line
  @types.draw_center_text(
    "Arrow Keys: Move | Enter: Confirm | Space: Wait | Tab: Cycle",
    cx,
    @types.screen_h - 40,
    @types.font_small - 2,
    @types.color_text_dim,
  )
}

// ============================================================================
// Campaign map helpers (inlined to avoid circular dependency with game package)
// ============================================================================

///|
fn campaign_node_completed(campaign : @types.CampaignMap, node_id : Int) -> Bool {
  for i = 0; i < campaign.completed_nodes.length(); i = i + 1 {
    if campaign.completed_nodes[i] == node_id {
      return true
    }
  }
  false
}

///|
fn campaign_node_available(campaign : @types.CampaignMap, node_id : Int) -> Bool {
  if campaign.completed_nodes.length() == 0 && node_id == 0 {
    return true
  }
  for i = 0; i < campaign.completed_nodes.length(); i = i + 1 {
    let cid = campaign.completed_nodes[i]
    if cid >= 0 && cid < campaign.nodes.length() {
      let node = campaign.nodes[cid]
      for j = 0; j < node.connections.length(); j = j + 1 {
        if node.connections[j] == node_id {
          return true
        }
      }
    }
  }
  false
}

///|
fn campaign_node_name(node : @types.CampaignNode) -> String {
  match node.kind {
    Mission(mid) => @content.get_mission_def(mid).name
    Boss(mid) => @content.get_mission_def(mid).name
    Rest => "Rest Stop"
    Shop => "Augment Shop"
  }
}

// ============================================================================
// Campaign map screen
// ============================================================================

///|
fn draw_campaign(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  // Title
  @types.draw_center_text(
    "CAMPAIGN MAP",
    cx,
    30,
    @types.font_title - 12,
    @types.color_player,
  )
  let campaign = match game.run.campaign {
    Some(c) => c
    None => return
  }
  // Draw nodes and connections
  let node_w = 140
  let node_h = 50
  let col_spacing = 170
  let row_spacing = 80
  let base_x = 60
  let base_y = 100
  // Draw connection lines first
  for i = 0; i < campaign.nodes.length(); i = i + 1 {
    let n = campaign.nodes[i]
    let nx = base_x + n.x * col_spacing + node_w / 2
    let ny = base_y + n.y * row_spacing + node_h / 2
    for j = 0; j < n.connections.length(); j = j + 1 {
      let cid = n.connections[j]
      if cid >= 0 && cid < campaign.nodes.length() {
        let cn = campaign.nodes[cid]
        let cnx = base_x + cn.x * col_spacing + node_w / 2
        let cny = base_y + cn.y * row_spacing + node_h / 2
        let line_color = if campaign_node_completed(campaign, i) {
          @raylib.Color::new(80, 200, 120, 120)
        } else {
          @raylib.Color::new(60, 80, 120, 80)
        }
        @raylib.draw_line_ex(
          @raylib.Vector2::new(Float::from_int(nx), Float::from_int(ny)),
          @raylib.Vector2::new(Float::from_int(cnx), Float::from_int(cny)),
          2.0,
          line_color,
        )
      }
    }
  }
  // Draw nodes
  for i = 0; i < campaign.nodes.length(); i = i + 1 {
    let n = campaign.nodes[i]
    let nx = base_x + n.x * col_spacing
    let ny = base_y + n.y * row_spacing
    let completed = campaign_node_completed(campaign, i)
    let available = campaign_node_available(campaign, i) && !completed
    let selected = campaign.selected_node == i
    // Node background
    let bg_color = if completed {
      @raylib.Color::new(30, 60, 30, 200)
    } else if available {
      @raylib.Color::new(25, 35, 55, 220)
    } else {
      @raylib.Color::new(15, 18, 25, 200)
    }
    @raylib.draw_rectangle(nx, ny, node_w, node_h, bg_color)
    // Border
    let border_color = if selected && available {
      @types.color_selected
    } else if completed {
      @raylib.Color::new(80, 200, 120, 180)
    } else if available {
      @types.color_player
    } else {
      @types.color_grid_line
    }
    @raylib.draw_rectangle_lines(nx, ny, node_w, node_h, border_color)
    // Node name
    let name = campaign_node_name(n)
    let name_color = if completed {
      @raylib.Color::new(80, 200, 120, 200)
    } else if available {
      @types.color_text
    } else {
      @types.color_text_dim
    }
    @types.draw_shadow_text(name, nx + 6, ny + 6, @types.font_small - 2, name_color)
    // Node type label
    let type_label = match n.kind {
      Mission(_) => "Mission"
      Boss(_) => "BOSS"
      Rest => "Rest"
      Shop => "Shop"
    }
    let type_color = match n.kind {
      Boss(_) => @types.color_enemy
      _ => @types.color_text_dim
    }
    @types.draw_shadow_text(type_label, nx + 6, ny + 26, @types.font_small - 4, type_color)
    // Completed checkmark
    if completed {
      @types.draw_shadow_text("DONE", nx + node_w - 40, ny + 6, @types.font_small - 4, @raylib.Color::new(80, 200, 120, 200))
    }
    // Selected indicator
    if selected && available {
      let pulse = Float::from_double(
        @math.sin(game.anim_timer.to_double() * 4.0),
      )
      let glow_alpha = 40 + (pulse * 20.0).to_int()
      @raylib.draw_rectangle(
        nx - 2, ny - 2, node_w + 4, node_h + 4,
        @raylib.Color::new(255, 220, 80, glow_alpha),
      )
    }
  }
  // Instructions
  @types.draw_center_text(
    "Arrows to select, Enter to deploy",
    cx,
    @types.screen_h - 60,
    @types.font_body,
    @types.color_text_dim,
  )
  // Run stats
  @types.draw_shadow_text(
    "Missions: \{game.run.missions_completed}  Grid Power: \{game.run.grid_power}  Augments: \{game.run.augments.length()}",
    20,
    @types.screen_h - 30,
    @types.font_small - 2,
    @types.color_text_dim,
  )
  draw_message(game)
}

///|
fn draw_title_decorations(game : @types.Game) -> Unit {
  let t = game.anim_timer.to_double()
  // Rotating grid lines in background
  let cx = Float::from_int(@types.screen_w / 2)
  let cy = Float::from_int(@types.screen_h / 2)
  let line_color = @raylib.Color::new(30, 50, 80, 60)
  for i = 0; i < 8; i = i + 1 {
    let angle = t * 0.3 + Float::from_int(i).to_double() * 0.785
    let dx = Float::from_double(@math.cos(angle)) * 300.0
    let dy = Float::from_double(@math.sin(angle)) * 300.0
    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx - dx, cy - dy),
      @raylib.Vector2::new(cx + dx, cy + dy),
      1.0,
      line_color,
    )
  }
  // Corner decorative hexagons
  let hex_color = @raylib.Color::new(40, 80, 140, 40)
  let rot = Float::from_double(t * 20.0)
  @raylib.draw_poly_lines(
    @raylib.Vector2::new(80.0, 80.0),
    6,
    40.0,
    rot,
    hex_color,
  )
  @raylib.draw_poly_lines(
    @raylib.Vector2::new(
      Float::from_int(@types.screen_w - 80),
      Float::from_int(@types.screen_h - 80),
    ),
    6,
    40.0,
    -rot,
    hex_color,
  )
}

///|
fn draw_title_mechs(game : @types.Game, cx : Int, cy : Int) -> Unit {
  let t = game.anim_timer.to_double()
  let bob = Float::from_double(@math.sin(t * 2.0)) * 6.0
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy) + bob
  // Vanguard - hexagon (left)
  @raylib.draw_poly(
    @raylib.Vector2::new(fcx - 100.0, fcy),
    6,
    28.0,
    0.0,
    @raylib.Color::new(60, 140, 220, 180),
  )
  @raylib.draw_poly_lines(
    @raylib.Vector2::new(fcx - 100.0, fcy),
    6,
    28.0,
    0.0,
    @types.color_player,
  )
  @draw.draw_text("V", cx - 108, cy + bob.to_int() - 7, @types.font_body, @raylib.white)
  // Striker - diamond (center)
  @raylib.draw_poly(
    @raylib.Vector2::new(fcx, fcy - 4.0),
    4,
    24.0,
    45.0,
    @raylib.Color::new(60, 140, 220, 180),
  )
  @raylib.draw_poly_lines(
    @raylib.Vector2::new(fcx, fcy - 4.0),
    4,
    24.0,
    45.0,
    @types.color_player,
  )
  @draw.draw_text("S", cx - 6, cy + bob.to_int() - 11, @types.font_body, @raylib.white)
  // Sentinel - circle with crosshair (right)
  @raylib.draw_circle(
    cx + 100,
    cy + bob.to_int(),
    24.0,
    @raylib.Color::new(60, 140, 220, 180),
  )
  @raylib.draw_circle_lines(
    cx + 100,
    cy + bob.to_int(),
    24.0,
    @types.color_player,
  )
  @raylib.draw_line(
    cx + 100 - 16,
    cy + bob.to_int(),
    cx + 100 + 16,
    cy + bob.to_int(),
    @types.color_player,
  )
  @raylib.draw_line(
    cx + 100,
    cy + bob.to_int() - 16,
    cx + 100,
    cy + bob.to_int() + 16,
    @types.color_player,
  )
  @draw.draw_text("T", cx + 93, cy + bob.to_int() - 7, @types.font_body, @raylib.white)
}

// ============================================================================
// Battle rendering
// ============================================================================

///|
fn draw_battle(game : @types.Game) -> Unit {
  let battle = match game.battle {
    Some(b) => b
    None => return
  }
  let (shake_x, shake_y) = get_shake_offset(battle.screen_fx)
  if shake_x != 0 || shake_y != 0 {
    @raylib.begin_mode_2d(
      @raylib.Camera2D::new(
        @raylib.Vector2::new(Float::from_int(-shake_x), Float::from_int(-shake_y)),
        @raylib.Vector2::new(0.0, 0.0),
        0.0,
        1.0,
      ),
    )
  }
  draw_grid(battle)
  draw_intents(battle)
  draw_command_preview(battle)
  draw_current_anim(battle)
  draw_units(battle, game)
  draw_cursor(battle, game)
  draw_coord_labels()
  draw_particles(battle)
  draw_floating_texts(battle)
  if shake_x != 0 || shake_y != 0 {
    @raylib.end_mode_2d()
  }
  draw_ui_panel(battle, game)
  draw_screen_effects(battle)
  draw_message(game)
}

///|
fn draw_battle_enemy_phase(game : @types.Game) -> Unit {
  let battle = match game.battle {
    Some(b) => b
    None => return
  }
  let (shake_x, shake_y) = get_shake_offset(battle.screen_fx)
  if shake_x != 0 || shake_y != 0 {
    @raylib.begin_mode_2d(
      @raylib.Camera2D::new(
        @raylib.Vector2::new(Float::from_int(-shake_x), Float::from_int(-shake_y)),
        @raylib.Vector2::new(0.0, 0.0),
        0.0,
        1.0,
      ),
    )
  }
  draw_grid(battle)
  draw_intents(battle)
  draw_current_anim(battle)
  draw_units(battle, game)
  draw_coord_labels()
  draw_particles(battle)
  draw_floating_texts(battle)
  if shake_x != 0 || shake_y != 0 {
    @raylib.end_mode_2d()
  }
  draw_ui_panel(battle, game)
  draw_screen_effects(battle)
  // Enemy turn overlay text
  let pulse = Float::from_double(
    @math.sin(game.anim_timer.to_double() * 4.0),
  )
  let alpha = 180 + (pulse * 60.0).to_int()
  let overlay_color = @raylib.Color::new(255, 80, 80, alpha)
  @types.draw_center_text(
    "-- ENEMY PHASE --",
    @types.grid_offset_x + @types.grid_w * @types.tile_size / 2,
    @types.grid_offset_y - 24,
    @types.font_body,
    overlay_color,
  )
  draw_message(game)
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    @types.draw_center_text(
      game.message_text,
      @types.screen_w / 2,
      @types.screen_h - 40,
      @types.font_body,
      @types.color_text,
    )
  }
}

// ============================================================================
// Grid rendering
// ============================================================================

///|
fn draw_grid(battle : @types.BattleState) -> Unit {
  for gy = 0; gy < @types.grid_h; gy = gy + 1 {
    for gx = 0; gx < @types.grid_w; gx = gx + 1 {
      let sx = @types.tile_to_screen_x(gx)
      let sy = @types.tile_to_screen_y(gy)
      let tile = battle.grid.get(gx, gy)
      // Base tile color
      let color = tile_color(tile.kind)
      @raylib.draw_rectangle(sx, sy, @types.tile_size, @types.tile_size, color)
      // Tile detail patterns
      draw_tile_detail(gx, gy, tile, sx, sy)
      // Hazard overlay
      draw_hazard_overlay(tile.hazard, sx, sy)
      // Grid lines with subtle glow
      @raylib.draw_rectangle_lines(
        sx,
        sy,
        @types.tile_size,
        @types.tile_size,
        @types.color_grid_line,
      )
    }
  }
}

///|
fn tile_color(kind : @types.TileKind) -> @raylib.Color {
  match kind {
    Floor => @types.color_floor
    Wall => @types.color_wall
    Chasm => @types.color_chasm
    Water => @types.color_water
    Lava => @types.color_lava
    Ice => @types.color_ice
    ControlPoint => @raylib.Color::new(60, 160, 60, 255)
    SpawnPoint => @raylib.Color::new(80, 40, 80, 255)
  }
}

///|
fn draw_tile_detail(
  _gx : Int,
  _gy : Int,
  tile : @types.Tile,
  sx : Int,
  sy : Int,
) -> Unit {
  match tile.kind {
    Wall => {
      // Cross-hatch pattern for walls
      let ts = @types.tile_size
      @raylib.draw_line(sx + 4, sy + 4, sx + ts - 4, sy + ts - 4, @raylib.Color::new(80, 85, 100, 120))
      @raylib.draw_line(sx + ts - 4, sy + 4, sx + 4, sy + ts - 4, @raylib.Color::new(80, 85, 100, 120))
    }
    Water => {
      // Wave lines for water
      let mid_y = sy + @types.tile_size / 2
      @raylib.draw_line(sx + 8, mid_y - 2, sx + @types.tile_size - 8, mid_y - 2, @raylib.Color::new(40, 80, 140, 100))
      @raylib.draw_line(sx + 12, mid_y + 4, sx + @types.tile_size - 12, mid_y + 4, @raylib.Color::new(40, 80, 140, 80))
    }
    Lava => {
      // Glowing center for lava
      let cx = sx + @types.tile_size / 2
      let cy = sy + @types.tile_size / 2
      @raylib.draw_circle(cx, cy, 12.0, @raylib.Color::new(240, 100, 20, 80))
      @raylib.draw_circle(cx, cy, 6.0, @raylib.Color::new(255, 200, 50, 60))
    }
    Ice => {
      // Sparkle dots for ice
      @raylib.draw_circle(sx + 16, sy + 12, 2.0, @raylib.Color::new(220, 240, 255, 120))
      @raylib.draw_circle(sx + 40, sy + 28, 2.0, @raylib.Color::new(220, 240, 255, 100))
      @raylib.draw_circle(sx + 24, sy + 48, 2.0, @raylib.Color::new(220, 240, 255, 80))
    }
    Chasm => {
      // Dark gradient to suggest depth
      @raylib.draw_rectangle(
        sx + 4,
        sy + 4,
        @types.tile_size - 8,
        @types.tile_size - 8,
        @raylib.Color::new(0, 0, 0, 100),
      )
    }
    ControlPoint => {
      // Diamond marker
      let cx = sx + @types.tile_size / 2
      let cy = sy + @types.tile_size / 2
      @raylib.draw_poly(
        @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy)),
        4,
        12.0,
        45.0,
        @raylib.Color::new(80, 220, 80, 100),
      )
    }
    _ => ()
  }
}

///|
fn draw_hazard_overlay(hazard : @types.HazardKind, sx : Int, sy : Int) -> Unit {
  match hazard {
    Fire =>
      @raylib.draw_rectangle(
        sx, sy, @types.tile_size, @types.tile_size, @raylib.Color::new(200, 60, 20, 80),
      )
    Acid =>
      @raylib.draw_rectangle(
        sx, sy, @types.tile_size, @types.tile_size, @raylib.Color::new(40, 200, 40, 60),
      )
    Mine => {
      @raylib.draw_rectangle(
        sx, sy, @types.tile_size, @types.tile_size, @raylib.Color::new(200, 200, 40, 40),
      )
      // Warning triangle
      let cx = Float::from_int(sx + @types.tile_size / 2)
      let cy = Float::from_int(sy + @types.tile_size / 2)
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy - 10.0),
        @raylib.Vector2::new(cx - 8.0, cy + 6.0),
        @raylib.Vector2::new(cx + 8.0, cy + 6.0),
        @raylib.Color::new(255, 220, 40, 120),
      )
    }
    Smoke =>
      @raylib.draw_rectangle(
        sx, sy, @types.tile_size, @types.tile_size, @raylib.Color::new(100, 100, 100, 80),
      )
    None => ()
  }
}

///|
fn draw_coord_labels() -> Unit {
  let labels_x = ["A", "B", "C", "D", "E", "F", "G", "H"]
  for i = 0; i < @types.grid_w; i = i + 1 {
    let sx = @types.tile_center_x(i) - 4
    let sy = @types.grid_offset_y - 18
    @draw.draw_text(
      labels_x[i],
      sx,
      sy,
      @types.font_small - 2,
      @types.color_text_dim,
    )
  }
  for i = 0; i < @types.grid_h; i = i + 1 {
    let sx = @types.grid_offset_x - 18
    let sy = @types.tile_center_y(i) - 6
    @draw.draw_text(
      (i + 1).to_string(),
      sx,
      sy,
      @types.font_small - 2,
      @types.color_text_dim,
    )
  }
}

// ============================================================================
// Intent rendering (key visual: telegraphs enemy actions)
// ============================================================================

///|
fn draw_intents(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.team != Enemy || !u.active || u.hp <= 0 {
      continue i + 1
    }
    draw_single_intent(u)
  }
}

///|
fn draw_single_intent(u : @types.CombatUnit) -> Unit {
  match u.intent {
    March(tx, ty) => draw_intent_march(u, tx, ty)
    FireLine(fdx, fdy, range) => draw_intent_fireline(u, fdx, fdy, range)
    Leap(tx, ty) => draw_intent_leap(u, tx, ty)
    AreaBlast(acx, acy, arad) => draw_intent_area_blast(acx, acy, arad)
    Charge(cdx, cdy) => draw_intent_charge(u, cdx, cdy)
    MinePlace(mx, my) => draw_intent_mine(mx, my)
    Summon(sx, sy, _) => draw_intent_summon(sx, sy)
  }
}

///|
fn draw_intent_march(u : @types.CombatUnit, tx : Int, ty : Int) -> Unit {
  // Arrow trail from enemy position to target
  let from_x = Float::from_int(@types.tile_center_x(u.x))
  let from_y = Float::from_int(@types.tile_center_y(u.y))
  let to_x = Float::from_int(@types.tile_center_x(tx))
  let to_y = Float::from_int(@types.tile_center_y(ty))
  let arrow_color = @raylib.Color::new(255, 120, 60, 100)
  @raylib.draw_line_ex(
    @raylib.Vector2::new(from_x, from_y),
    @raylib.Vector2::new(to_x, to_y),
    2.0,
    arrow_color,
  )
  // Arrow head
  let target_sx = @types.tile_to_screen_x(tx)
  let target_sy = @types.tile_to_screen_y(ty)
  @raylib.draw_rectangle(
    target_sx + 8,
    target_sy + 8,
    @types.tile_size - 16,
    @types.tile_size - 16,
    @raylib.Color::new(255, 120, 60, 60),
  )
}

///|
fn draw_intent_fireline(
  u : @types.CombatUnit,
  fdx : Int,
  fdy : Int,
  range : Int,
) -> Unit {
  let fire_color = @raylib.Color::new(255, 40, 40, 80)
  let line_color = @raylib.Color::new(255, 60, 60, 140)
  let mut fx = u.x
  let mut fy = u.y
  for step = 0; step < range; step = step + 1 {
    ignore(step)
    fx += fdx
    fy += fdy
    if fx >= 0 && fx < @types.grid_w && fy >= 0 && fy < @types.grid_h {
      let sx = @types.tile_to_screen_x(fx)
      let sy = @types.tile_to_screen_y(fy)
      @raylib.draw_rectangle(
        sx + 2,
        sy + 2,
        @types.tile_size - 4,
        @types.tile_size - 4,
        fire_color,
      )
      // Draw X pattern to indicate danger
      @raylib.draw_line(sx + 6, sy + 6, sx + @types.tile_size - 6, sy + @types.tile_size - 6, line_color)
      @raylib.draw_line(sx + @types.tile_size - 6, sy + 6, sx + 6, sy + @types.tile_size - 6, line_color)
    }
  }
}

///|
fn draw_intent_leap(u : @types.CombatUnit, tx : Int, ty : Int) -> Unit {
  // Arc path from enemy to landing spot
  let from_x = Float::from_int(@types.tile_center_x(u.x))
  let from_y = Float::from_int(@types.tile_center_y(u.y))
  let to_x = Float::from_int(@types.tile_center_x(tx))
  let to_y = Float::from_int(@types.tile_center_y(ty))
  let leap_color = @raylib.Color::new(255, 160, 40, 100)
  // Draw dotted arc (series of small circles)
  let steps = 8
  for s = 0; s <= steps; s = s + 1 {
    let t = Float::from_int(s) / Float::from_int(steps)
    let px = from_x + (to_x - from_x) * t
    let arc_height = -(4.0F * t * (1.0F - t)) * 40.0F
    let py = from_y + (to_y - from_y) * t + arc_height
    @raylib.draw_circle_v(
      @raylib.Vector2::new(px, py),
      2.0,
      leap_color,
    )
  }
  // Landing zone outline
  let target_sx = @types.tile_to_screen_x(tx)
  let target_sy = @types.tile_to_screen_y(ty)
  @raylib.draw_rectangle_lines(
    target_sx + 4,
    target_sy + 4,
    @types.tile_size - 8,
    @types.tile_size - 8,
    @raylib.Color::new(255, 160, 40, 140),
  )
}

///|
fn draw_intent_area_blast(acx : Int, acy : Int, arad : Int) -> Unit {
  let blast_color = @raylib.Color::new(255, 40, 40, 60)
  let border_color = @raylib.Color::new(255, 60, 60, 120)
  for dy = -arad; dy <= arad; dy = dy + 1 {
    for dx = -arad; dx <= arad; dx = dx + 1 {
      let tx = acx + dx
      let ty = acy + dy
      if tx >= 0 && tx < @types.grid_w && ty >= 0 && ty < @types.grid_h {
        let sx = @types.tile_to_screen_x(tx)
        let sy = @types.tile_to_screen_y(ty)
        @raylib.draw_rectangle(
          sx + 1,
          sy + 1,
          @types.tile_size - 2,
          @types.tile_size - 2,
          blast_color,
        )
        @raylib.draw_rectangle_lines(
          sx + 1,
          sy + 1,
          @types.tile_size - 2,
          @types.tile_size - 2,
          border_color,
        )
      }
    }
  }
}

///|
fn draw_intent_charge(u : @types.CombatUnit, cdx : Int, cdy : Int) -> Unit {
  let charge_color = @raylib.Color::new(255, 40, 40, 80)
  let arrow_color = @raylib.Color::new(255, 80, 80, 160)
  let mut cx = u.x + cdx
  let mut cy = u.y + cdy
  let mut steps = 0
  while cx >= 0 && cx < @types.grid_w && cy >= 0 && cy < @types.grid_h &&
    steps < 6 {
    let sx = @types.tile_to_screen_x(cx)
    let sy = @types.tile_to_screen_y(cx)
    ignore(sy)
    let actual_sy = @types.tile_to_screen_y(cy)
    @raylib.draw_rectangle(
      sx + 4,
      actual_sy + 4,
      @types.tile_size - 8,
      @types.tile_size - 8,
      charge_color,
    )
    // Arrow indicator
    let center_x = Float::from_int(@types.tile_center_x(cx))
    let center_y = Float::from_int(@types.tile_center_y(cy))
    let dir_x = Float::from_int(cdx) * 12.0
    let dir_y = Float::from_int(cdy) * 12.0
    @raylib.draw_line_ex(
      @raylib.Vector2::new(center_x - dir_x, center_y - dir_y),
      @raylib.Vector2::new(center_x + dir_x, center_y + dir_y),
      3.0,
      arrow_color,
    )
    cx += cdx
    cy += cdy
    steps += 1
  }
}

///|
fn draw_intent_mine(mx : Int, my : Int) -> Unit {
  if mx >= 0 && mx < @types.grid_w && my >= 0 && my < @types.grid_h {
    let sx = @types.tile_to_screen_x(mx)
    let sy = @types.tile_to_screen_y(my)
    let mine_color = @raylib.Color::new(255, 220, 40, 80)
    @raylib.draw_rectangle(
      sx + 6,
      sy + 6,
      @types.tile_size - 12,
      @types.tile_size - 12,
      mine_color,
    )
    // Warning triangle
    let cx = Float::from_int(sx + @types.tile_size / 2)
    let cy = Float::from_int(sy + @types.tile_size / 2)
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy - 12.0),
      @raylib.Vector2::new(cx - 10.0, cy + 8.0),
      @raylib.Vector2::new(cx + 10.0, cy + 8.0),
      @raylib.Color::new(255, 220, 40, 140),
    )
  }
}

///|
fn draw_intent_summon(sx_grid : Int, sy_grid : Int) -> Unit {
  if sx_grid >= 0 && sx_grid < @types.grid_w && sy_grid >= 0 &&
    sy_grid < @types.grid_h {
    let sx = @types.tile_to_screen_x(sx_grid)
    let sy = @types.tile_to_screen_y(sy_grid)
    let summon_color = @raylib.Color::new(160, 40, 200, 80)
    @raylib.draw_rectangle(
      sx + 2,
      sy + 2,
      @types.tile_size - 4,
      @types.tile_size - 4,
      summon_color,
    )
    // Purple spawn marker (circle)
    let cx = sx + @types.tile_size / 2
    let cy = sy + @types.tile_size / 2
    @raylib.draw_circle_lines(
      cx,
      cy,
      16.0,
      @raylib.Color::new(180, 60, 240, 160),
    )
    @raylib.draw_circle_lines(
      cx,
      cy,
      10.0,
      @raylib.Color::new(180, 60, 240, 100),
    )
  }
}

// ============================================================================
// Command preview (shows valid moves/attacks for selected mech)
// ============================================================================

///|
fn draw_command_preview(battle : @types.BattleState) -> Unit {
  let sid = battle.selected_mech
  if sid < 0 || sid >= battle.units.length() {
    return
  }
  let u = battle.units[sid]
  if u.team != Player || !u.active || u.hp <= 0 {
    return
  }
  if u.acted_this_turn {
    return
  }
  let stats = @content.get_mech_stats(u.mech_class)
  // Draw valid move tiles (blue outlines)
  draw_move_range(u, stats.move_range)
  // Draw attack range (orange outlines)
  draw_attack_range(u, stats.ability_range)
  // Draw damage preview on hovered enemy
  draw_damage_preview(battle, u, stats)
}

///|
fn draw_move_range(u : @types.CombatUnit, move_range : Int) -> Unit {
  let move_color = @raylib.Color::new(80, 160, 255, 50)
  let move_border = @raylib.Color::new(80, 160, 255, 100)
  for gy = 0; gy < @types.grid_h; gy = gy + 1 {
    for gx = 0; gx < @types.grid_w; gx = gx + 1 {
      let dist = @types.manhattan(u.x, u.y, gx, gy)
      if dist > 0 && dist <= move_range {
        let sx = @types.tile_to_screen_x(gx)
        let sy = @types.tile_to_screen_y(gy)
        @raylib.draw_rectangle(
          sx + 2,
          sy + 2,
          @types.tile_size - 4,
          @types.tile_size - 4,
          move_color,
        )
        @raylib.draw_rectangle_lines(
          sx + 2,
          sy + 2,
          @types.tile_size - 4,
          @types.tile_size - 4,
          move_border,
        )
      }
    }
  }
}

///|
fn draw_attack_range(u : @types.CombatUnit, ability_range : Int) -> Unit {
  let attack_color = @raylib.Color::new(255, 140, 40, 40)
  let attack_border = @raylib.Color::new(255, 140, 40, 100)
  for gy = 0; gy < @types.grid_h; gy = gy + 1 {
    for gx = 0; gx < @types.grid_w; gx = gx + 1 {
      let dist = @types.manhattan(u.x, u.y, gx, gy)
      if dist > 0 && dist <= ability_range {
        let sx = @types.tile_to_screen_x(gx)
        let sy = @types.tile_to_screen_y(gy)
        @raylib.draw_rectangle(
          sx + 1,
          sy + 1,
          @types.tile_size - 2,
          @types.tile_size - 2,
          attack_color,
        )
        @raylib.draw_rectangle_lines(
          sx + 1,
          sy + 1,
          @types.tile_size - 2,
          @types.tile_size - 2,
          attack_border,
        )
      }
    }
  }
}

///|
fn draw_damage_preview(
  battle : @types.BattleState,
  _mech : @types.CombatUnit,
  stats : @content.MechStats,
) -> Unit {
  let tx = battle.cursor_x
  let ty = battle.cursor_y
  if !battle.grid.in_bounds(tx, ty) {
    return
  }
  let tile = battle.grid.get(tx, ty)
  if tile.occupied_by >= 0 && tile.occupied_by < battle.units.length() {
    let target = battle.units[tile.occupied_by]
    if target.team == Enemy && target.active && target.hp > 0 {
      // Show damage number on targeted enemy
      let sx = @types.tile_center_x(tx)
      let sy = @types.tile_to_screen_y(ty) - 6
      let dmg = stats.ability_damage
      @types.draw_shadow_text(
        "-\{dmg}",
        sx - 8,
        sy,
        @types.font_body,
        @raylib.Color::new(255, 80, 80, 220),
      )
    }
  }
}

// ============================================================================
// Unit rendering
// ============================================================================

///|
fn draw_units(battle : @types.BattleState, game : @types.Game) -> Unit {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if !u.active || u.hp <= 0 {
      continue i + 1
    }
    let cx = @types.tile_center_x(u.x)
    let cy = @types.tile_center_y(u.y)
    match u.team {
      Player => draw_player_mech(u, cx, cy, i == battle.selected_mech, game)
      Enemy => draw_enemy_unit(u, cx, cy)
    }
    // Health bar
    draw_health_bar(u, cx, cy)
    // Shield indicator
    if u.shield > 0 {
      draw_shield_indicator(u, cx, cy)
    }
    // Heat indicator (player only)
    if u.team == Player && u.heat > 0 {
      draw_heat_indicator(u, cx, cy)
    }
    // Stun indicator
    if u.stunned {
      draw_stun_indicator(cx, cy, game)
    }
    // Acted indicator
    if u.team == Player && u.acted_this_turn {
      draw_acted_indicator(cx, cy)
    }
  }
}

///|
fn draw_player_mech(
  u : @types.CombatUnit,
  cx : Int,
  cy : Int,
  selected : Bool,
  game : @types.Game,
) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  let radius = Float::from_int(@types.tile_size / 3)
  let base_color = @types.color_player
  let fill_color = @raylib.Color::new(40, 100, 180, 200)
  match u.mech_class {
    Vanguard => {
      // Large hexagon (tanky)
      @raylib.draw_poly(
        @raylib.Vector2::new(fcx, fcy),
        6,
        radius,
        0.0,
        fill_color,
      )
      @raylib.draw_poly_lines(
        @raylib.Vector2::new(fcx, fcy),
        6,
        radius,
        0.0,
        base_color,
      )
      @draw.draw_text("V", cx - 5, cy - 7, @types.font_small, @raylib.white)
    }
    Striker => {
      // Sharp diamond (aggressive)
      @raylib.draw_poly(
        @raylib.Vector2::new(fcx, fcy),
        4,
        radius,
        45.0,
        fill_color,
      )
      @raylib.draw_poly_lines(
        @raylib.Vector2::new(fcx, fcy),
        4,
        radius,
        45.0,
        base_color,
      )
      @draw.draw_text("S", cx - 5, cy - 7, @types.font_small, @raylib.white)
    }
    Sentinel => {
      // Circle with crosshair (ranged)
      @raylib.draw_circle(cx, cy, radius, fill_color)
      @raylib.draw_circle_lines(cx, cy, radius, base_color)
      // Crosshair
      let r = radius.to_int()
      @raylib.draw_line(cx - r + 4, cy, cx + r - 4, cy, base_color)
      @raylib.draw_line(cx, cy - r + 4, cx, cy + r - 4, base_color)
      @draw.draw_text("T", cx - 5, cy - 7, @types.font_small, @raylib.white)
    }
  }
  // Selected mech golden glow
  if selected {
    let pulse = Float::from_double(
      @math.sin(game.anim_timer.to_double() * 4.0),
    )
    let glow_r = radius + 4.0 + pulse * 2.0
    @raylib.draw_circle_lines(cx, cy, glow_r, @types.color_selected)
    @raylib.draw_circle_lines(cx, cy, glow_r + 2.0, @raylib.Color::new(255, 220, 80, 80))
  }
}

///|
fn draw_enemy_unit(u : @types.CombatUnit, cx : Int, cy : Int) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  let radius = Float::from_int(@types.tile_size / 3 - 2)
  let fill_color = @raylib.Color::new(160, 30, 30, 200)
  let edge_color = @types.color_enemy
  match u.enemy_type {
    Rammer => {
      // Triangle pointing left (towards player side)
      @raylib.draw_triangle(
        @raylib.Vector2::new(fcx - radius, fcy),
        @raylib.Vector2::new(fcx + radius * 0.6, fcy - radius * 0.7),
        @raylib.Vector2::new(fcx + radius * 0.6, fcy + radius * 0.7),
        fill_color,
      )
      @raylib.draw_triangle_lines(
        @raylib.Vector2::new(fcx - radius, fcy),
        @raylib.Vector2::new(fcx + radius * 0.6, fcy - radius * 0.7),
        @raylib.Vector2::new(fcx + radius * 0.6, fcy + radius * 0.7),
        edge_color,
      )
      @draw.draw_text("R", cx - 4, cy - 6, @types.font_small - 2, @raylib.white)
    }
    Artillery => {
      // Square with cross
      let half = (radius * 0.7).to_int()
      @raylib.draw_rectangle(
        cx - half,
        cy - half,
        half * 2,
        half * 2,
        fill_color,
      )
      @raylib.draw_rectangle_lines(
        cx - half,
        cy - half,
        half * 2,
        half * 2,
        edge_color,
      )
      @raylib.draw_line(cx - half + 3, cy, cx + half - 3, cy, edge_color)
      @raylib.draw_line(cx, cy - half + 3, cx, cy + half - 3, edge_color)
      @draw.draw_text("A", cx - 4, cy - 6, @types.font_small - 2, @raylib.white)
    }
    BeamTurret => {
      // Octagon
      @raylib.draw_poly(
        @raylib.Vector2::new(fcx, fcy),
        8,
        radius,
        22.5,
        fill_color,
      )
      @raylib.draw_poly_lines(
        @raylib.Vector2::new(fcx, fcy),
        8,
        radius,
        22.5,
        edge_color,
      )
      @draw.draw_text("B", cx - 4, cy - 6, @types.font_small - 2, @raylib.white)
    }
    Leaper => {
      // Small diamond
      @raylib.draw_poly(
        @raylib.Vector2::new(fcx, fcy),
        4,
        radius * 0.7,
        45.0,
        fill_color,
      )
      @raylib.draw_poly_lines(
        @raylib.Vector2::new(fcx, fcy),
        4,
        radius * 0.7,
        45.0,
        edge_color,
      )
      @draw.draw_text("L", cx - 4, cy - 6, @types.font_small - 2, @raylib.white)
    }
    MineLayer => {
      // Circle with dots
      @raylib.draw_circle(cx, cy, radius * 0.8, fill_color)
      @raylib.draw_circle_lines(cx, cy, radius * 0.8, edge_color)
      // Three small dots
      @raylib.draw_circle(cx - 5, cy + 3, 2.0, edge_color)
      @raylib.draw_circle(cx, cy - 4, 2.0, edge_color)
      @raylib.draw_circle(cx + 5, cy + 3, 2.0, edge_color)
      @draw.draw_text("M", cx - 5, cy - 6, @types.font_small - 2, @raylib.white)
    }
    ShieldDrone => {
      // Ring shape (hollow)
      @raylib.draw_ring(
        @raylib.Vector2::new(fcx, fcy),
        radius * 0.4,
        radius * 0.8,
        0.0,
        360.0,
        16,
        fill_color,
      )
      @raylib.draw_ring_lines(
        @raylib.Vector2::new(fcx, fcy),
        radius * 0.4,
        radius * 0.8,
        0.0,
        360.0,
        16,
        edge_color,
      )
      @draw.draw_text("D", cx - 4, cy - 6, @types.font_small - 2, @raylib.white)
    }
    Splitter => {
      // Double circle
      let small_r = radius * 0.5
      @raylib.draw_circle(cx - 4, cy, small_r, fill_color)
      @raylib.draw_circle(cx + 4, cy, small_r, fill_color)
      @raylib.draw_circle_lines(cx - 4, cy, small_r, edge_color)
      @raylib.draw_circle_lines(cx + 4, cy, small_r, edge_color)
      @draw.draw_text("P", cx - 4, cy - 6, @types.font_small - 2, @raylib.white)
    }
    Boss => {
      // Large pentagon with inner pentagon
      @raylib.draw_poly(
        @raylib.Vector2::new(fcx, fcy),
        5,
        radius + 4.0,
        -18.0,
        fill_color,
      )
      @raylib.draw_poly_lines(
        @raylib.Vector2::new(fcx, fcy),
        5,
        radius + 4.0,
        -18.0,
        edge_color,
      )
      @raylib.draw_poly_lines(
        @raylib.Vector2::new(fcx, fcy),
        5,
        radius * 0.5,
        -18.0,
        @raylib.Color::new(255, 200, 80, 180),
      )
      @draw.draw_text("X", cx - 5, cy - 7, @types.font_small, @raylib.white)
    }
  }
}

// ============================================================================
// Unit status indicators
// ============================================================================

///|
fn draw_health_bar(u : @types.CombatUnit, cx : Int, cy : Int) -> Unit {
  let radius = @types.tile_size / 3
  let bar_w = @types.tile_size - 8
  let bar_h = 4
  let bar_x = cx - bar_w / 2
  let bar_y = cy - radius - 10
  // Background
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.color_hp_bg)
  // Health fill
  let hp_w = if u.max_hp > 0 { bar_w * u.hp / u.max_hp } else { 0 }
  let hp_color = if u.hp * 3 <= u.max_hp {
    @raylib.Color::new(220, 60, 40, 255)
  } else if u.hp * 2 <= u.max_hp {
    @raylib.Color::new(220, 180, 40, 255)
  } else {
    @types.color_hp_bar
  }
  @raylib.draw_rectangle(bar_x, bar_y, hp_w, bar_h, hp_color)
  // HP text
  @draw.draw_text(
    "\{u.hp}",
    cx - 3,
    bar_y - 12,
    @types.font_small - 4,
    @types.color_text,
  )
}

///|
fn draw_shield_indicator(u : @types.CombatUnit, cx : Int, cy : Int) -> Unit {
  let radius = Float::from_int(@types.tile_size / 3 + 4)
  @raylib.draw_circle_lines(cx, cy, radius, @types.color_shield)
  // Shield count
  @draw.draw_text(
    "\{u.shield}",
    cx + @types.tile_size / 3 + 2,
    cy - @types.tile_size / 3 - 2,
    @types.font_small - 4,
    @types.color_shield,
  )
}

///|
fn draw_heat_indicator(u : @types.CombatUnit, cx : Int, cy : Int) -> Unit {
  let base_y = cy + @types.tile_size / 3 + 4
  for h = 0; h < u.heat; h = h + 1 {
    let dot_x = cx - (u.heat - 1) * 5 + h * 10
    @raylib.draw_circle(dot_x, base_y, 3.0, @types.color_heat)
  }
}

///|
fn draw_stun_indicator(cx : Int, cy : Int, game : @types.Game) -> Unit {
  let t = game.anim_timer.to_double()
  let stun_color = @raylib.Color::new(255, 255, 80, 200)
  let offset_y = cy - @types.tile_size / 3 - 18
  // Rotating stars
  for s = 0; s < 3; s = s + 1 {
    let angle = t * 3.0 + Float::from_int(s).to_double() * 2.094
    let sx = cx + (Float::from_double(@math.cos(angle)) * 10.0).to_int()
    let sy = offset_y +
      (Float::from_double(@math.sin(angle)) * 4.0).to_int()
    @draw.draw_text("*", sx - 3, sy - 4, @types.font_small - 4, stun_color)
  }
}

///|
fn draw_acted_indicator(cx : Int, cy : Int) -> Unit {
  let y = cy + @types.tile_size / 3 + 12
  @draw.draw_text(
    "done",
    cx - 12,
    y,
    @types.font_small - 6,
    @types.color_text_dim,
  )
}

// ============================================================================
// Cursor
// ============================================================================

///|
fn draw_cursor(battle : @types.BattleState, game : @types.Game) -> Unit {
  let sx = @types.tile_to_screen_x(battle.cursor_x)
  let sy = @types.tile_to_screen_y(battle.cursor_y)
  let pulse = Float::from_double(
    @math.sin(game.anim_timer.to_double() * 5.0),
  )
  let alpha = 160 + (pulse * 60.0).to_int()
  let cursor_color = @raylib.Color::new(255, 255, 255, alpha)
  // Outer border
  @raylib.draw_rectangle_lines(
    sx,
    sy,
    @types.tile_size,
    @types.tile_size,
    cursor_color,
  )
  // Corner brackets for emphasis
  let bracket_len = 10
  let bracket_color = @raylib.Color::new(255, 255, 255, alpha + 40)
  // Top-left
  @raylib.draw_line(sx, sy, sx + bracket_len, sy, bracket_color)
  @raylib.draw_line(sx, sy, sx, sy + bracket_len, bracket_color)
  // Top-right
  @raylib.draw_line(sx + @types.tile_size, sy, sx + @types.tile_size - bracket_len, sy, bracket_color)
  @raylib.draw_line(sx + @types.tile_size, sy, sx + @types.tile_size, sy + bracket_len, bracket_color)
  // Bottom-left
  @raylib.draw_line(sx, sy + @types.tile_size, sx + bracket_len, sy + @types.tile_size, bracket_color)
  @raylib.draw_line(sx, sy + @types.tile_size, sx, sy + @types.tile_size - bracket_len, bracket_color)
  // Bottom-right
  @raylib.draw_line(sx + @types.tile_size, sy + @types.tile_size, sx + @types.tile_size - bracket_len, sy + @types.tile_size, bracket_color)
  @raylib.draw_line(sx + @types.tile_size, sy + @types.tile_size, sx + @types.tile_size, sy + @types.tile_size - bracket_len, bracket_color)
}

// ============================================================================
// UI Panel (right side)
// ============================================================================

///|
fn draw_ui_panel(battle : @types.BattleState, game : @types.Game) -> Unit {
  let px = @types.ui_panel_x
  let pw = @types.ui_panel_w
  // Panel background
  @raylib.draw_rectangle(
    px,
    0,
    pw,
    @types.screen_h,
    @raylib.Color::new(15, 18, 30, 240),
  )
  @raylib.draw_line(px, 0, px, @types.screen_h, @types.color_grid_line)
  // Turn counter
  @types.draw_shadow_text(
    "Turn \{battle.turn}",
    px + 10,
    10,
    @types.font_body,
    @types.color_text,
  )
  // Phase indicator
  let phase_text = match game.screen {
    Battle => "Player Phase"
    EnemyTurn => "Enemy Phase"
    _ => ""
  }
  @types.draw_shadow_text(
    phase_text,
    px + 10,
    34,
    @types.font_small,
    @types.color_text_dim,
  )
  // Objective progress
  draw_objective_info(battle, px + 10, 56)
  // Objective progress bar
  draw_objective_progress_bar(battle, px + 10, 76, pw - 80)
  // Turn countdown for survive/defend
  draw_turn_countdown(battle, px + 10, 90)
  // Separator
  @raylib.draw_line(
    px + 10,
    106,
    px + pw - 10,
    106,
    @types.color_grid_line,
  )
  // Mech roster
  let mut y = 114
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.team != Player || !u.active {
      continue i + 1
    }
    y = draw_mech_card(battle, u, i, px + 8, y)
  }
  // Separator before hover info
  @raylib.draw_line(
    px + 10,
    y + 4,
    px + pw - 10,
    y + 4,
    @types.color_grid_line,
  )
  // Hover info
  if game.hover_info.length() > 0 {
    @types.draw_shadow_text(
      game.hover_info,
      px + 10,
      @types.screen_h - 80,
      @types.font_small - 2,
      @types.color_text,
    )
  }
  // Turn log
  draw_turn_log(battle, px + 10, @types.screen_h / 2 + 40)
  // Controls legend
  draw_controls_legend(px + 8, @types.screen_h - 50)
}

///|
fn draw_objective_info(
  battle : @types.BattleState,
  x : Int,
  y : Int,
) -> Unit {
  let obj_text = match battle.objective {
    DefendGrid(n) => "Objective: Defend (\{battle.objective_progress}/\{n})"
    Survive(n) => "Objective: Survive \{n} turns (\{battle.turn}/\{n})"
    Assassinate(_) => "Objective: Eliminate target"
    CapturePoints(n) =>
      "Objective: Capture \{n} points (\{battle.objective_progress}/\{n})"
    Escort(_, _) => "Objective: Escort to safety"
  }
  @types.draw_shadow_text(
    obj_text,
    x,
    y,
    @types.font_small - 2,
    @raylib.Color::new(100, 200, 100, 220),
  )
}

///|
fn draw_mech_card(
  battle : @types.BattleState,
  u : @types.CombatUnit,
  idx : Int,
  x : Int,
  y : Int,
) -> Int {
  let stats = @content.get_mech_stats(u.mech_class)
  let is_selected = idx == battle.selected_mech
  let name_color = if is_selected {
    @types.color_selected
  } else {
    @types.color_player
  }
  // Highlight background for selected
  if is_selected {
    @raylib.draw_rectangle(
      x - 2,
      y - 2,
      @types.ui_panel_w - 14,
      60,
      @raylib.Color::new(255, 220, 80, 15),
    )
  }
  // Mech name and class icon
  let class_icon = match u.mech_class {
    Vanguard => "[HEX]"
    Striker => "[DIA]"
    Sentinel => "[CRS]"
  }
  @types.draw_shadow_text(
    "\{class_icon} \{stats.name}",
    x + 4,
    y,
    @types.font_body - 2,
    name_color,
  )
  // Stats line: HP / Shield / Heat
  let mut stat_line = "HP \{u.hp}/\{u.max_hp}"
  if u.shield > 0 {
    stat_line = stat_line + "  Sh \{u.shield}"
  }
  stat_line = stat_line + "  Heat \{u.heat}/\{u.max_heat}"
  @types.draw_shadow_text(
    stat_line,
    x + 4,
    y + 20,
    @types.font_small - 2,
    @types.color_text_dim,
  )
  // Ability info
  let ability_text = "\{stats.ability_name} (Rng:\{stats.ability_range} Dmg:\{stats.ability_damage})"
  @types.draw_shadow_text(
    ability_text,
    x + 4,
    y + 36,
    @types.font_small - 4,
    @types.color_text_dim,
  )
  // Status tags
  if u.acted_this_turn {
    @types.draw_shadow_text(
      "[ACTED]",
      x + @types.ui_panel_w - 80,
      y,
      @types.font_small - 4,
      @types.color_text_dim,
    )
  }
  if u.stunned {
    @types.draw_shadow_text(
      "[STUNNED]",
      x + @types.ui_panel_w - 90,
      y + 14,
      @types.font_small - 4,
      @raylib.Color::new(255, 255, 80, 220),
    )
  }
  y + 58
}

///|
fn draw_turn_log(
  battle : @types.BattleState,
  x : Int,
  y : Int,
) -> Unit {
  @types.draw_shadow_text(
    "-- Log --",
    x,
    y - 18,
    @types.font_small - 4,
    @types.color_text_dim,
  )
  let max_entries = 6
  let log_start = if battle.turn_log.length() > max_entries {
    battle.turn_log.length() - max_entries
  } else {
    0
  }
  for j = log_start; j < battle.turn_log.length(); j = j + 1 {
    let entry = battle.turn_log[j]
    // Truncate long entries
    let display = if entry.length() > 40 {
      entry[:40].to_string()
    } else {
      entry
    }
    @types.draw_shadow_text(
      display,
      x,
      y + (j - log_start) * 16,
      @types.font_small - 4,
      @types.color_text_dim,
    )
  }
}

///|
fn draw_controls_legend(x : Int, y : Int) -> Unit {
  @types.draw_shadow_text(
    "Arrows:Move  Tab:Cycle  Enter/Click:Act",
    x,
    y,
    @types.font_small - 4,
    @types.color_text_dim,
  )
  @types.draw_shadow_text(
    "Space:Wait  Q:Overclock  P:Push  Esc:Undo",
    x,
    y + 14,
    @types.font_small - 4,
    @types.color_text_dim,
  )
}

// ============================================================================
// Reward screen
// ============================================================================

///|
fn draw_reward(game : @types.Game) -> Unit {
  // Draw battle in background (dimmed)
  match game.battle {
    Some(b) => {
      draw_grid(b)
      draw_units(b, game)
    }
    None => ()
  }
  // Dim overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let cx = @types.screen_w / 2
  // Title
  @types.draw_center_text(
    "MISSION COMPLETE",
    cx,
    @types.screen_h / 6,
    @types.font_title,
    @raylib.Color::new(80, 220, 120, 255),
  )
  @types.draw_center_text(
    "Choose your reward:",
    cx,
    @types.screen_h / 6 + 50,
    @types.font_body,
    @types.color_text,
  )
  // Four reward cards
  let card_w = 190
  let card_h = 120
  let card_y = @types.screen_h / 2 - 50
  let gap = 16
  let total_w = card_w * 4 + gap * 3
  let start_x = cx - total_w / 2
  // Card 1: First augment offer
  let aug1_name = if game.run.offered_augments.length() > 0 {
    let def = @content.get_augment_def(game.run.offered_augments[0])
    def.name
  } else {
    "No Augment"
  }
  let aug1_desc = if game.run.offered_augments.length() > 0 {
    let def = @content.get_augment_def(game.run.offered_augments[0])
    def.description
  } else {
    "All augments owned"
  }
  draw_reward_card(
    start_x,
    card_y,
    card_w,
    card_h,
    "1: \{aug1_name}",
    aug1_desc,
    "[AUGMENT]",
    @raylib.Color::new(80, 200, 255, 200),
  )
  // Card 2: Second augment offer
  let aug2_name = if game.run.offered_augments.length() > 1 {
    let def = @content.get_augment_def(game.run.offered_augments[1])
    def.name
  } else {
    "N/A"
  }
  let aug2_desc = if game.run.offered_augments.length() > 1 {
    let def = @content.get_augment_def(game.run.offered_augments[1])
    def.description
  } else {
    ""
  }
  draw_reward_card(
    start_x + card_w + gap,
    card_y,
    card_w,
    card_h,
    "2: \{aug2_name}",
    aug2_desc,
    "[AUGMENT]",
    @raylib.Color::new(120, 160, 255, 200),
  )
  // Card 3: Repair
  draw_reward_card(
    start_x + (card_w + gap) * 2,
    card_y,
    card_w,
    card_h,
    "3: REPAIR ALL",
    "Fully heal all",
    "mechs to max HP",
    @raylib.Color::new(60, 200, 80, 200),
  )
  // Card 4: Grid Power
  draw_reward_card(
    start_x + (card_w + gap) * 3,
    card_y,
    card_w,
    card_h,
    "4: GRID POWER",
    "+2 Grid Power",
    "(now \{game.run.grid_power})",
    @raylib.Color::new(200, 140, 255, 200),
  )
  // Instructions
  @types.draw_center_text(
    "Press 1, 2, 3, or 4 to choose",
    cx,
    card_y + card_h + 30,
    @types.font_body,
    @types.color_text_dim,
  )
  // Show currently owned augments
  if game.run.augments.length() > 0 {
    let mut aug_text = "Owned: "
    for i = 0; i < game.run.augments.length(); i = i + 1 {
      let def = @content.get_augment_def(game.run.augments[i])
      aug_text = aug_text + def.icon
      if i < game.run.augments.length() - 1 {
        aug_text = aug_text + " "
      }
    }
    @types.draw_center_text(
      aug_text,
      cx,
      card_y + card_h + 56,
      @types.font_small,
      @types.color_text_dim,
    )
  }
}

///|
fn draw_reward_card(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  title : String,
  line1 : String,
  line2 : String,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(20, 25, 40, 220))
  @raylib.draw_rectangle_lines(x, y, w, h, color)
  @types.draw_shadow_text(title, x + 10, y + 10, @types.font_body, color)
  @types.draw_shadow_text(
    line1,
    x + 10,
    y + 40,
    @types.font_small,
    @types.color_text,
  )
  @types.draw_shadow_text(
    line2,
    x + 10,
    y + 60,
    @types.font_small,
    @types.color_text,
  )
}

// ============================================================================
// End screens (Game Over / Victory)
// ============================================================================

///|
fn draw_end(game : @types.Game, title : String, color : @raylib.Color) -> Unit {
  // Draw battle in background
  match game.battle {
    Some(b) => {
      draw_grid(b)
      draw_units(b, game)
    }
    None => ()
  }
  // Dark overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let cx = @types.screen_w / 2
  // Title
  @types.draw_center_text(
    title,
    cx,
    @types.screen_h / 3,
    @types.font_title,
    color,
  )
  // Stats summary
  match game.battle {
    Some(b) => {
      @types.draw_center_text(
        "Turns: \{b.turn}  Missions: \{game.run.missions_completed}",
        cx,
        @types.screen_h / 3 + 60,
        @types.font_body,
        @types.color_text_dim,
      )
    }
    None => ()
  }
  // Blinking prompt
  let blink = Float::from_double(
    @math.sin(game.anim_timer.to_double() * 3.0),
  )
  if blink > 0.0 {
    @types.draw_center_text(
      "Press ENTER to return",
      cx,
      @types.screen_h / 2 + 40,
      @types.font_body,
      @types.color_text,
    )
  }
}

