///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    Playing => draw_playing(game)
    Paused => {
      draw_playing(game)
      draw_pause_overlay()
    }
    SectorMap => draw_sector_map(game)
    Shop => draw_shop(game)
    GameOver => draw_game_over(game)
    RunSummary => draw_run_summary(game)
    WeaponSelect => draw_weapon_select(game)
    BossIntro => draw_boss_intro(game)
    Victory => draw_victory(game)
  }
  @fps.draw()
  @raylib.end_drawing()
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Animated background stars
  let time = Float::from_int(game.frame_count) * 0.02
  for i in 0..<60 {
    let fi = Float::from_int(i)
    let sx = ((fi * 137.5 + time * 20.0) % Float::from_int(w)).to_int()
    let sy = ((fi * 91.3 + time * 10.0 * (fi % 3.0 + 1.0)) % Float::from_int(
        h,
      )).to_int()
    let brightness = 80 + (fi * 17.0 % 120.0).to_int()
    @raylib.draw_circle(
      sx,
      sy,
      1.0 + fi % 2.0,
      @raylib.Color::new(brightness, brightness, brightness + 40, 200),
    )
  }
  // Title
  let title = "VOID DRIFTER"
  let title_w = @draw.measure_text(title, 60)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4,
    60,
    @raylib.Color::new(0, 255, 200, alpha),
  )
  // Subtitle
  let sub = "TWIN-STICK SPACE ROGUELITE"
  let sub_w = @draw.measure_text(sub, 18)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 70, 18, @types.color_hud_text)
  // Controls
  @draw.draw_text(
    "WASD - Move    Mouse - Aim    LMB - Shoot    Space - Dash",
    w / 2 - 280,
    h / 2 + 40,
    16,
    @raylib.Color::new(150, 160, 180, 200),
  )
  @draw.draw_text(
    "Shift - Boost    Q - Secondary    ESC - Pause",
    w / 2 - 210,
    h / 2 + 65,
    16,
    @raylib.Color::new(150, 160, 180, 200),
  )
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(0, 255, 200, blink),
  )
  // Meta stats
  if game.meta.total_runs > 0 {
    @draw.draw_text(
      "Best: " + game.meta.best_score.to_string() + "  Kills: " + game.meta.total_kills.to_string() +
      "  Runs: " +
      game.meta.total_runs.to_string(),
      20,
      h - 30,
      14,
      @raylib.Color::new(100, 110, 130, 200),
    )
  }
}

///|
fn draw_weapon_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let _h = @types.screen_height
  ignore(game)
  @draw.draw_text(
    "SELECT YOUR WEAPON",
    w / 2 - 140,
    80,
    32,
    @types.color_player,
  )
  let weapons : Array[@types.WeaponKind] = [
    Laser, Shotgun, Missile, Railgun, Flak, Beam,
  ]
  let descriptions = [
    "Fast, precise, low heat",
    "Wide spread, close range",
    "Slow, high damage, homing ready",
    "Piercing beam, long charge",
    "Area denial, many pellets",
    "Rapid fire stream",
  ]
  for i in 0..<weapons.length() {
    let y = 160 + i * 70
    let color = @types.weapon_color(weapons[i])
    let num = (i + 1).to_string()
    @draw.draw_text(num + ".", w / 2 - 180, y, 24, color)
    @draw.draw_text(
      @weapons.weapon_name(weapons[i]),
      w / 2 - 140,
      y,
      24,
      color,
    )
    @draw.draw_text(
      descriptions[i],
      w / 2 - 140,
      y + 28,
      14,
      @raylib.Color::new(150, 160, 180, 200),
    )
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  let ox = -(game.camera_x + game.shake.offset_x)
  let oy = -(game.camera_y + game.shake.offset_y)
  // Background grid
  draw_background_grid(game, ox, oy)
  // Asteroids
  for i in 0..<game.asteroids.length() {
    let ast = game.asteroids[i]
    if !(ast.active) {
      continue
    }
    draw_asteroid(ast, ox, oy)
  }
  // Pickups
  for i in 0..<game.pickups.length() {
    let pk = game.pickups[i]
    if !(pk.active) {
      continue
    }
    draw_pickup(pk, ox, oy)
  }
  // Enemies
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !(e.active) {
      continue
    }
    draw_enemy(e, ox, oy)
  }
  // Boss
  match game.boss {
    Some(boss) =>
      if boss.active {
        draw_boss(game, boss, ox, oy)
      }
    None => ()
  }
  // Projectiles
  for i in 0..<game.projectiles.length() {
    let p = game.projectiles[i]
    if !(p.active) {
      continue
    }
    draw_projectile(p, game, ox, oy)
  }
  // Particles
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if !(p.active) {
      continue
    }
    let alpha = (p.life / p.max_life * 255.0).to_int()
    let size = if p.shrink {
      p.size * p.life / p.max_life
    } else {
      p.size
    }
    let c = @raylib.Color::new(p.color.r.to_int(), p.color.g.to_int(), p.color.b.to_int(), alpha)
    @raylib.draw_circle(
      (p.pos.x + ox).to_int(),
      (p.pos.y + oy).to_int(),
      size,
      c,
    )
  }
  // Ship
  draw_ship(game, ox, oy)
  // Damage numbers
  for i in 0..<game.damage_numbers.length() {
    let dn = game.damage_numbers[i]
    if !(dn.active) {
      continue
    }
    let alpha = (dn.life / @types.damage_number_life * 255.0).to_int()
    let c = @raylib.Color::new(dn.color.r.to_int(), dn.color.g.to_int(), dn.color.b.to_int(), alpha)
    @draw.draw_text(
      dn.value.to_string(),
      (dn.pos.x + ox).to_int(),
      (dn.pos.y + oy).to_int(),
      16,
      c,
    )
  }
  // HUD
  draw_hud(game)
  // Message
  if game.message_timer > 0.0 {
    let alpha = @types.mini((game.message_timer * 255.0).to_int(), 255)
    let msg_w = @draw.measure_text(game.message, 28)
    @draw.draw_text(
      game.message,
      (@types.screen_width - msg_w) / 2,
      @types.screen_height / 2 - 60,
      28,
      @raylib.Color::new(255, 255, 255, alpha),
    )
  }
}

///|
fn draw_background_grid(game : @types.Game, ox : Float, oy : Float) -> Unit {
  let grid_size = 80
  let start_x = (game.camera_x / Float::from_int(grid_size)).to_int() *
    grid_size
  let start_y = (game.camera_y / Float::from_int(grid_size)).to_int() *
    grid_size
  let end_x = start_x + @types.screen_width + grid_size
  let end_y = start_y + @types.screen_height + grid_size
  let mut gx = start_x
  while gx <= end_x {
    @raylib.draw_line(
      (Float::from_int(gx) + ox).to_int(),
      (Float::from_int(start_y) + oy).to_int(),
      (Float::from_int(gx) + ox).to_int(),
      (Float::from_int(end_y) + oy).to_int(),
      @types.color_grid,
    )
    gx = gx + grid_size
  }
  let mut gy = start_y
  while gy <= end_y {
    @raylib.draw_line(
      (Float::from_int(start_x) + ox).to_int(),
      (Float::from_int(gy) + oy).to_int(),
      (Float::from_int(end_x) + ox).to_int(),
      (Float::from_int(gy) + oy).to_int(),
      @types.color_grid,
    )
    gy = gy + grid_size
  }
  // Arena borders
  @raylib.draw_rectangle_lines(
    ox.to_int(),
    oy.to_int(),
    game.arena_width.to_int(),
    game.arena_height.to_int(),
    @raylib.Color::new(60, 40, 40, 200),
  )
}

///|
fn draw_ship(game : @types.Game, ox : Float, oy : Float) -> Unit {
  let ship = game.ship
  let sx = (ship.pos.x + ox).to_int()
  let sy = (ship.pos.y + oy).to_int()
  // Invincibility flash
  if ship.invincible_timer > 0.0 &&
    game.frame_count % 6 < 3 {
    return
  }
  // Shield circle
  if ship.shield > 0 {
    @raylib.draw_circle(
      sx,
      sy,
      18.0,
      @types.color_player_shield,
    )
  }
  // Ship body - triangle pointing in aim direction
  let size : Float = 12.0
  let a = ship.angle
  let tip_x = ship.pos.x + @types.cosf(a) * size * 1.5
  let tip_y = ship.pos.y + @types.sinf(a) * size * 1.5
  let left_a : Float = a + 2.5
  let right_a : Float = a - 2.5
  let left_x = ship.pos.x + @types.cosf(left_a) * size
  let left_y = ship.pos.y + @types.sinf(left_a) * size
  let right_x = ship.pos.x + @types.cosf(right_a) * size
  let right_y = ship.pos.y + @types.sinf(right_a) * size
  @raylib.draw_triangle(
    @raylib.Vector2::new(tip_x + ox, tip_y + oy),
    @raylib.Vector2::new(left_x + ox, left_y + oy),
    @raylib.Vector2::new(right_x + ox, right_y + oy),
    @types.color_player,
  )
  // Core glow
  @raylib.draw_circle(sx, sy, 4.0, @raylib.white)
}

///|
fn draw_enemy(e : @types.Enemy, ox : Float, oy : Float) -> Unit {
  let ex = (e.pos.x + ox).to_int()
  let ey = (e.pos.y + oy).to_int()
  let color = @types.enemy_color(e.kind)
  // Frozen effect
  if e.frozen_timer > 0.0 {
    @raylib.draw_circle(
      ex,
      ey,
      e.radius + 4.0,
      @raylib.Color::new(100, 200, 255, 80),
    )
  }
  // Draw as polygon based on enemy type
  let sides = @enemies.enemy_shape_sides(e.kind)
  draw_polygon(
    e.pos.x + ox, e.pos.y + oy, e.radius, sides, e.angle, color,
  )
  // Shield indicator
  if e.shield > 0 {
    @raylib.draw_circle_lines(
      ex,
      ey,
      e.radius + 3.0,
      @types.color_enemy_shield,
    )
  }
  // HP bar for larger enemies
  if e.max_hp > 2 {
    let bar_w = e.radius * 2.0
    let hp_pct = Float::from_int(e.hp) / Float::from_int(e.max_hp)
    @raylib.draw_rectangle(
      (e.pos.x + ox - bar_w / 2.0).to_int(),
      (e.pos.y + oy - e.radius - 8.0).to_int(),
      bar_w.to_int(),
      3,
      @raylib.Color::new(60, 20, 20, 200),
    )
    @raylib.draw_rectangle(
      (e.pos.x + ox - bar_w / 2.0).to_int(),
      (e.pos.y + oy - e.radius - 8.0).to_int(),
      (bar_w * hp_pct).to_int(),
      3,
      @raylib.red,
    )
  }
}

///|
fn draw_boss(game : @types.Game, boss : @types.Boss, ox : Float, oy : Float) -> Unit {
  let bx = boss.pos.x + ox
  let by = boss.pos.y + oy
  // Outer glow
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.05) * 8.0
  @raylib.draw_circle(
    bx.to_int(),
    by.to_int(),
    boss.radius + pulse + 10.0,
    @raylib.Color::new(255, 0, 80, 30),
  )
  // Boss body
  let sides = match boss.kind {
    Leviathan => 5
    Hive => 8
    Dreadnought => 6
  }
  draw_polygon(bx, by, boss.radius, sides, boss.phase_timer * 0.5, @types.color_boss)
  // Inner core
  @raylib.draw_circle(
    bx.to_int(),
    by.to_int(),
    boss.radius * 0.4,
    @raylib.Color::new(255, 100, 100, 200),
  )
  // Shield
  if boss.shield > 0 {
    @raylib.draw_circle_lines(
      bx.to_int(),
      by.to_int(),
      boss.radius + 5.0,
      @raylib.Color::new(100, 200, 255, 180),
    )
  }
  // Enrage indicator
  if boss.enraged {
    @raylib.draw_circle_lines(
      bx.to_int(),
      by.to_int(),
      boss.radius + pulse + 15.0,
      @raylib.Color::new(255, 50, 50, 150),
    )
  }
  // HP bar
  let bar_w : Float = 120.0
  let hp_pct = Float::from_int(boss.hp) / Float::from_int(boss.max_hp)
  let bar_x = (bx - bar_w / 2.0).to_int()
  let bar_y = (by - boss.radius - 20.0).to_int()
  @raylib.draw_rectangle(bar_x, bar_y, bar_w.to_int(), 6, @raylib.Color::new(40, 10, 10, 200))
  @raylib.draw_rectangle(
    bar_x, bar_y, (bar_w * hp_pct).to_int(), 6, @types.color_boss,
  )
  // Boss name
  let name = @bosses.boss_name(boss.kind)
  let nw = @draw.measure_text(name, 14)
  @draw.draw_text(
    name,
    (bx).to_int() - nw / 2,
    bar_y - 16,
    14,
    @types.color_boss,
  )
}

///|
fn draw_projectile(
  p : @types.Projectile,
  game : @types.Game,
  ox : Float,
  oy : Float
) -> Unit {
  let px = (p.pos.x + ox).to_int()
  let py = (p.pos.y + oy).to_int()
  let color = if p.friendly {
    @types.weapon_color(game.ship.weapon.kind)
  } else {
    @raylib.Color::new(255, 100, 100, 230)
  }
  @raylib.draw_circle(px, py, p.radius, color)
  // Trail
  let trail_len = 3
  let speed = @types.vec2_len(p.vel)
  if speed > 10.0 {
    let dir = @types.vec2_normalize(p.vel)
    for t in 1..=trail_len {
      let ft = Float::from_int(t)
      let tx = p.pos.x - dir.x * ft * 4.0 + ox
      let ty = p.pos.y - dir.y * ft * 4.0 + oy
      let alpha = 180 - t * 50
      let r = p.radius * (1.0 - ft * 0.2)
      @raylib.draw_circle(
        tx.to_int(),
        ty.to_int(),
        r,
        @raylib.Color::new(color.r.to_int(), color.g.to_int(), color.b.to_int(), alpha),
      )
    }
  }
}

///|
fn draw_asteroid(ast : @types.Asteroid, ox : Float, oy : Float) -> Unit {
  let ax = ast.pos.x + ox
  let ay = ast.pos.y + oy
  draw_polygon(ax, ay, ast.radius, 7, ast.angle, @types.color_asteroid)
  // Inner detail
  draw_polygon(
    ax,
    ay,
    ast.radius * 0.5,
    5,
    ast.angle + 0.5,
    @raylib.Color::new(90, 75, 60, 200),
  )
}

///|
fn draw_pickup(pk : @types.Pickup, ox : Float, oy : Float) -> Unit {
  let px = (pk.pos.x + ox).to_int()
  let py = (pk.pos.y + oy).to_int()
  let pulse = @types.sinf(pk.pulse_timer * 4.0) * 3.0
  let color = match pk.kind {
    HealthPack => @raylib.Color::new(50, 255, 50, 230)
    ShieldRecharge => @raylib.Color::new(80, 180, 255, 230)
    Credits(_) => @types.color_credits
    HeatVent => @raylib.Color::new(100, 200, 255, 230)
    WeaponMod(_) => @raylib.Color::new(255, 150, 50, 230)
    UtilityPickup(_) => @raylib.Color::new(200, 100, 255, 230)
    WeaponDrop(_) => @raylib.Color::new(255, 255, 100, 230)
  }
  // Outer glow
  @raylib.draw_circle(px, py, pk.radius + pulse + 4.0, @raylib.Color::new(color.r.to_int(), color.g.to_int(), color.b.to_int(), 40))
  // Core
  @raylib.draw_circle(px, py, pk.radius + pulse, color)
  @raylib.draw_circle(px, py, pk.radius * 0.4, @raylib.white)
}

///|
fn draw_polygon(
  cx : Float,
  cy : Float,
  radius : Float,
  sides : Int,
  angle : Float,
  color : @raylib.Color
) -> Unit {
  if sides < 3 {
    @raylib.draw_circle(cx.to_int(), cy.to_int(), radius, color)
    return
  }
  let step : Float = 6.2831853 / Float::from_int(sides)
  for i in 0..<sides {
    let a1 = angle + step * Float::from_int(i)
    let a2 = angle + step * Float::from_int(i + 1)
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(cx + @types.cosf(a1) * radius, cy + @types.sinf(a1) * radius),
      @raylib.Vector2::new(cx + @types.cosf(a2) * radius, cy + @types.sinf(a2) * radius),
      color,
    )
  }
  // Outline
  for i in 0..<sides {
    let a1 = angle + step * Float::from_int(i)
    let a2 = angle + step * Float::from_int(i + 1)
    @raylib.draw_line(
      (cx + @types.cosf(a1) * radius).to_int(),
      (cy + @types.sinf(a1) * radius).to_int(),
      (cx + @types.cosf(a2) * radius).to_int(),
      (cy + @types.sinf(a2) * radius).to_int(),
      @raylib.Color::new(
        @types.mini(color.r.to_int() + 60, 255),
        @types.mini(color.g.to_int() + 60, 255),
        @types.mini(color.b.to_int() + 60, 255),
        230,
      ),
    )
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  let ship = game.ship
  let w = @types.screen_width
  // Top-left: HP and Shield
  @raylib.draw_rectangle(5, 5, 200, 55, @types.color_hud_bg)
  // HP bar
  @draw.draw_text("HP", 10, 8, 14, @raylib.red)
  let hp_pct = Float::from_int(ship.hp) / Float::from_int(ship.max_hp)
  @raylib.draw_rectangle(40, 10, 150, 10, @raylib.Color::new(40, 10, 10, 200))
  @raylib.draw_rectangle(40, 10, (150.0 * hp_pct.to_double()).to_int(), 10, @raylib.red)
  // Shield bar
  @draw.draw_text("SH", 10, 26, 14, @raylib.Color::new(80, 180, 255, 230))
  let sh_pct = Float::from_int(ship.shield) / Float::from_int(ship.max_shield)
  @raylib.draw_rectangle(
    40,
    28,
    150,
    10,
    @raylib.Color::new(10, 20, 40, 200),
  )
  @raylib.draw_rectangle(
    40,
    28,
    (150.0 * sh_pct.to_double()).to_int(),
    10,
    @raylib.Color::new(80, 180, 255, 230),
  )
  // Heat bar
  let heat_pct = ship.heat / ship.max_heat
  let heat_color = if heat_pct > 0.8 {
    @raylib.Color::new(255, 50, 30, 255)
  } else {
    @types.color_heat_bar
  }
  @draw.draw_text("HT", 10, 44, 14, heat_color)
  @raylib.draw_rectangle(
    40,
    46,
    150,
    10,
    @raylib.Color::new(30, 15, 5, 200),
  )
  @raylib.draw_rectangle(40, 46, (150.0 * heat_pct.to_double()).to_int(), 10, heat_color)
  // Top-right: Score and kills
  @raylib.draw_rectangle(w - 205, 5, 200, 55, @types.color_hud_bg)
  @draw.draw_text(
    "SCORE: " + game.stats.score.to_string(),
    w - 195,
    10,
    16,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "KILLS: " + game.stats.kills.to_string(),
    w - 195,
    30,
    14,
    @raylib.Color::new(200, 150, 150, 200),
  )
  // Combo
  if game.stats.combo > 1 {
    @draw.draw_text(
      "x" + game.stats.combo.to_string(),
      w - 195,
      46,
      14,
      @types.color_credits,
    )
  }
  // Bottom: Weapon info
  @raylib.draw_rectangle(5, @types.screen_height - 40, 300, 35, @types.color_hud_bg)
  let wpn_color = @types.weapon_color(ship.weapon.kind)
  @draw.draw_text(
    @weapons.weapon_name(ship.weapon.kind),
    10,
    @types.screen_height - 35,
    16,
    wpn_color,
  )
  // Mod indicator
  match ship.primary_mod {
    Some(mod_kind) =>
      @draw.draw_text(
        "[" + @weapons.mod_name(mod_kind) + "]",
        120,
        @types.screen_height - 35,
        14,
        @raylib.Color::new(255, 200, 50, 200),
      )
    None => ()
  }
  // Credits
  @draw.draw_text(
    "$" + ship.credits.to_string(),
    10,
    @types.screen_height - 18,
    14,
    @types.color_credits,
  )
  // Utility mod
  match ship.utility_mod {
    Some(util) =>
      @draw.draw_text(
        @weapons.utility_name(util),
        200,
        @types.screen_height - 18,
        12,
        @raylib.Color::new(200, 100, 255, 200),
      )
    None => ()
  }
  // Dash cooldown indicator
  if ship.dash_cooldown > 0.0 {
    @draw.draw_text(
      "DASH",
      w / 2 - 20,
      @types.screen_height - 25,
      14,
      @raylib.Color::new(100, 100, 100, 150),
    )
  } else {
    @draw.draw_text(
      "DASH",
      w / 2 - 20,
      @types.screen_height - 25,
      14,
      @types.color_player,
    )
  }
  // Sector progress
  let progress_text = "Enemies: " +
    game.sector_enemies_killed.to_string() +
    "/" +
    game.sector_enemies_total.to_string()
  @draw.draw_text(
    progress_text,
    w / 2 - 50,
    8,
    14,
    @types.color_hud_text,
  )
}

///|
fn draw_sector_map(game : @types.Game) -> Unit {
  let w = @types.screen_width
  @draw.draw_text("SECTOR MAP", w / 2 - 70, 30, 28, @types.color_player)
  match game.sector_map {
    None => ()
    Some(map) => {
      // Draw connections first
      for i in 0..<map.nodes.length() {
        let node = map.nodes[i]
        let nx = 200 + node.x * 220
        let ny = 200 + node.y * 150
        for j in 0..<node.connections.length() {
          let target = map.nodes[node.connections[j]]
          let tx = 200 + target.x * 220
          let ty = 200 + target.y * 150
          let line_color = if node.cleared {
            @raylib.Color::new(80, 100, 80, 200)
          } else {
            @raylib.Color::new(40, 50, 60, 150)
          }
          @raylib.draw_line(nx, ny, tx, ty, line_color)
        }
      }
      // Draw nodes
      for i in 0..<map.nodes.length() {
        let node = map.nodes[i]
        let nx = 200 + node.x * 220
        let ny = 200 + node.y * 150
        let is_current = i == map.current
        let is_reachable = @sectors.can_travel_to(map, i)
        let color = if is_current {
          @types.color_player
        } else if node.cleared {
          @raylib.Color::new(60, 80, 60, 200)
        } else if is_reachable {
          match node.kind {
            BossArena => @types.color_boss
            EliteZone => @raylib.Color::new(255, 200, 50, 230)
            Station => @raylib.Color::new(100, 200, 100, 230)
            _ => @raylib.Color::new(150, 160, 180, 230)
          }
        } else {
          @raylib.Color::new(50, 55, 65, 150)
        }
        let radius : Float = if is_current { 20.0 } else { 15.0 }
        @raylib.draw_circle(nx, ny, radius, color)
        if is_reachable && !(node.cleared) {
          @raylib.draw_circle_lines(nx, ny, radius + 3.0, @types.color_player)
        }
        // Label
        let label = @sectors.sector_name(node.kind)
        let lw = @draw.measure_text(label, 11)
        @draw.draw_text(
          label,
          nx - lw / 2,
          ny + 22,
          11,
          @raylib.Color::new(180, 190, 200, 200),
        )
        // Reachable number hint
        if is_reachable && !(node.cleared) {
          let current_node = map.nodes[map.current]
          for ci in 0..<current_node.connections.length() {
            if current_node.connections[ci] == i {
              @draw.draw_text(
                (ci + 1).to_string(),
                nx - 4,
                ny - 6,
                14,
                @raylib.white,
              )
            }
          }
        }
      }
    }
  }
  // Instructions
  @draw.draw_text(
    "Press 1-3 or click a highlighted node to travel",
    w / 2 - 200,
    @types.screen_height - 40,
    14,
    @raylib.Color::new(150, 160, 180, 200),
  )
}

///|
fn draw_shop(game : @types.Game) -> Unit {
  let w = @types.screen_width
  @draw.draw_text("SUPPLY STATION", w / 2 - 100, 60, 32, @types.color_player)
  @draw.draw_text(
    "Credits: $" + game.ship.credits.to_string(),
    w / 2 - 60,
    100,
    20,
    @types.color_credits,
  )
  for i in 0..<game.shop_items.length() {
    let item = game.shop_items[i]
    let y = 160 + i * 60
    let color = if item.purchased {
      @raylib.Color::new(60, 80, 60, 150)
    } else if game.ship.credits >= item.cost {
      @types.color_hud_text
    } else {
      @raylib.Color::new(100, 60, 60, 200)
    }
    let num = (i + 1).to_string()
    @draw.draw_text(num + ".", w / 2 - 180, y, 20, color)
    @draw.draw_text(item.name, w / 2 - 150, y, 20, color)
    @draw.draw_text(
      "$" + item.cost.to_string(),
      w / 2 + 100,
      y,
      20,
      @types.color_credits,
    )
    @draw.draw_text(
      item.description,
      w / 2 - 150,
      y + 24,
      14,
      @raylib.Color::new(140, 150, 160, 180),
    )
    if item.purchased {
      @draw.draw_text("SOLD", w / 2 + 170, y, 16, @raylib.Color::new(60, 100, 60, 200))
    }
  }
  @draw.draw_text(
    "Press 1-5 to buy, ENTER/ESC to leave",
    w / 2 - 160,
    @types.screen_height - 40,
    14,
    @raylib.Color::new(150, 160, 180, 200),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @draw.draw_text("GAME OVER", w / 2 - 80, h / 3, 40, @raylib.red)
  @draw.draw_text(
    "Score: " + game.stats.score.to_string(),
    w / 2 - 60,
    h / 3 + 60,
    24,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Kills: " + game.stats.kills.to_string(),
    w / 2 - 60,
    h / 3 + 90,
    20,
    @raylib.Color::new(200, 150, 150, 200),
  )
  @draw.draw_text(
    "Sectors: " + game.stats.sectors_cleared.to_string(),
    w / 2 - 60,
    h / 3 + 115,
    20,
    @raylib.Color::new(150, 200, 150, 200),
  )
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    "PRESS ENTER",
    w / 2 - 60,
    h * 3 / 4,
    20,
    @raylib.Color::new(200, 220, 255, blink),
  )
}

///|
fn draw_run_summary(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let s = game.stats
  @draw.draw_text("RUN SUMMARY", w / 2 - 90, 60, 32, @types.color_player)
  let col1 = w / 2 - 150
  let col2 = w / 2 + 50
  @draw.draw_text("Score", col1, 130, 18, @types.color_hud_text)
  @draw.draw_text(s.score.to_string(), col2, 130, 18, @types.color_credits)
  @draw.draw_text("Kills", col1, 160, 18, @types.color_hud_text)
  @draw.draw_text(s.kills.to_string(), col2, 160, 18, @raylib.red)
  @draw.draw_text("Max Combo", col1, 190, 18, @types.color_hud_text)
  @draw.draw_text(s.max_combo.to_string(), col2, 190, 18, @types.color_credits)
  @draw.draw_text("Sectors", col1, 220, 18, @types.color_hud_text)
  @draw.draw_text(
    s.sectors_cleared.to_string(),
    col2,
    220,
    18,
    @types.color_player,
  )
  @draw.draw_text("Bosses", col1, 250, 18, @types.color_hud_text)
  @draw.draw_text(
    s.bosses_defeated.to_string(),
    col2,
    250,
    18,
    @types.color_boss,
  )
  @draw.draw_text("Damage Dealt", col1, 280, 18, @types.color_hud_text)
  @draw.draw_text(
    s.damage_dealt.to_string(),
    col2,
    280,
    18,
    @raylib.Color::new(255, 200, 100, 230),
  )
  @draw.draw_text("Damage Taken", col1, 310, 18, @types.color_hud_text)
  @draw.draw_text(
    s.damage_taken.to_string(),
    col2,
    310,
    18,
    @raylib.Color::new(255, 100, 100, 230),
  )
  // Accuracy
  let accuracy = if s.shots_fired > 0 {
    s.shots_hit * 100 / s.shots_fired
  } else {
    0
  }
  @draw.draw_text("Accuracy", col1, 340, 18, @types.color_hud_text)
  @draw.draw_text(
    accuracy.to_string() + "%",
    col2,
    340,
    18,
    @types.color_player,
  )
  @draw.draw_text("Credits Earned", col1, 370, 18, @types.color_hud_text)
  @draw.draw_text(
    "$" + s.credits_earned.to_string(),
    col2,
    370,
    18,
    @types.color_credits,
  )
  // Time
  let minutes = (s.time_played / 60.0).to_int()
  let seconds = (s.time_played % 60.0).to_int()
  @draw.draw_text("Time", col1, 400, 18, @types.color_hud_text)
  @draw.draw_text(
    minutes.to_string() + "m " + seconds.to_string() + "s",
    col2,
    400,
    18,
    @types.color_hud_text,
  )
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    "PRESS ENTER",
    w / 2 - 60,
    @types.screen_height - 50,
    20,
    @raylib.Color::new(200, 220, 255, blink),
  )
}

///|
fn draw_boss_intro(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Dark overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 200))
  // Boss name
  let boss_kind = match game.sector_map {
    Some(map) => @bosses.boss_for_depth(map.depth)
    None => Leviathan
  }
  let name = @bosses.boss_name(boss_kind)
  let nw = @draw.measure_text(name, 48)
  let pulse = @types.sinf(game.boss_intro_timer * 8.0) * 10.0
  @draw.draw_text(
    name,
    (w - nw) / 2,
    h / 2 - 24 + pulse.to_int(),
    48,
    @types.color_boss,
  )
  @draw.draw_text(
    "INCOMING",
    w / 2 - 40,
    h / 2 + 40,
    20,
    @raylib.Color::new(255, 150, 150, 200),
  )
}

///|
fn draw_pause_overlay() -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 150))
  @draw.draw_text("PAUSED", w / 2 - 50, h / 2 - 20, 36, @types.color_player)
  @draw.draw_text(
    "ESC to resume    Q to quit",
    w / 2 - 110,
    h / 2 + 30,
    16,
    @types.color_hud_text,
  )
}

///|
fn draw_victory(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  ignore(game)
  @draw.draw_text(
    "VICTORY!",
    w / 2 - 60,
    h / 3,
    48,
    @types.color_player,
  )
  @draw.draw_text(
    "The void has been pacified... for now.",
    w / 2 - 160,
    h / 2,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "PRESS ENTER",
    w / 2 - 60,
    h * 3 / 4,
    20,
    @types.color_player,
  )
}
