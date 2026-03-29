///|
pub fn draw_hud(game : @types.Game) -> Unit {
  let p = game.player
  // Top bar background
  @raylib.draw_rectangle(0, 0, @types.screen_w, 44, @types.color_hud_bg)
  // Health bar
  let bar_x = 16
  let bar_y = 8
  let bar_w = 200
  let bar_h = 14
  let hp_ratio = Float::from_int(p.hp) / Float::from_int(p.max_hp)
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @raylib.Color::new(60, 20, 20, 255))
  @raylib.draw_rectangle(bar_x, bar_y, (Float::from_int(bar_w) * hp_ratio).to_int(), bar_h, @types.color_health)
  @raylib.draw_text("\{p.hp}/\{p.max_hp}", bar_x + 4, bar_y + 1, 12, @raylib.white)
  // Shield bar
  let shield_y = bar_y + bar_h + 2
  let shield_w = 200
  let shield_h = 8
  let shield_ratio = p.shield / p.max_shield
  @raylib.draw_rectangle(bar_x, shield_y, shield_w, shield_h, @raylib.Color::new(20, 40, 60, 255))
  @raylib.draw_rectangle(bar_x, shield_y, (Float::from_int(shield_w) * shield_ratio).to_int(), shield_h, @types.color_shield)
  // Weapon name
  let weapon_stats = @data.get_weapon_stats(p.weapon)
  @raylib.draw_text(weapon_stats.name, 240, 10, 18, @raylib.white)
  // Gold
  @raylib.draw_text("Gold: \{p.gold}", 450, 10, 18, @types.color_gold_text)
  // Floor
  let biome_name = if game.floor_num <= 5 {
    "Stone Crypt"
  } else {
    "Fungal Caverns"
  }
  @raylib.draw_text(
    "Floor \{game.floor_num} - \{biome_name}",
    650,
    10,
    18,
    @raylib.white,
  )
  // Dash cooldown indicator
  if p.dash_cooldown > 0.0 {
    @raylib.draw_text("DASH", @types.screen_w / 2 - 20, @types.screen_h - 40, 14, @raylib.Color::new(100, 100, 100, 200))
  } else {
    @raylib.draw_text("DASH", @types.screen_w / 2 - 20, @types.screen_h - 40, 14, @raylib.Color::new(100, 200, 255, 200))
  }
  // Room cleared flash
  if game.room_clear_timer > 0.0 {
    let alpha = @types.clampi(
      (game.room_clear_timer / 1.5 * 255.0).to_int(),
      0,
      255,
    )
    let text = "ROOM CLEARED!"
    let tw = @raylib.measure_text(text, 36)
    @raylib.draw_text(
      text,
      (@types.screen_w - tw) / 2,
      @types.screen_h / 2 - 80,
      36,
      @raylib.Color::new(100, 255, 100, alpha),
    )
  }
  // Stairs notification
  if game.stairs_active {
    let pulse = Float::from_double(
        @math.sin(Float::from_int(game.frame_count).to_double() * 0.06),
      ) *
      0.5 +
      0.5
    let alpha = (Float::from_double(150.0) + pulse * Float::from_double(105.0)).to_int()
    let text = ">> STAIRS APPEARED - Find them to descend <<"
    let tw = @raylib.measure_text(text, 16)
    @raylib.draw_text(
      text,
      (@types.screen_w - tw) / 2,
      @types.screen_h - 65,
      16,
      @raylib.Color::new(255, 215, 0, alpha),
    )
  }
  // Passives display
  if game.player.passives.length() > 0 {
    let py = 48
    @raylib.draw_text(
      "Items:",
      16,
      py,
      12,
      @raylib.Color::new(180, 180, 200, 180),
    )
    let mut px = 60
    for i in 0..<game.player.passives.length() {
      let name = passive_short_name(game.player.passives[i])
      let color = passive_color(game.player.passives[i])
      @raylib.draw_text(name, px, py, 12, color)
      px += @raylib.measure_text(name, 12) + 8
      if px > 500 {
        break
      }
    }
  }
  // FPS
  @fps.draw()
  // Minimap
  draw_minimap(game)
}

///|
fn passive_short_name(kind : @types.PassiveKind) -> String {
  match kind {
    MaxHpUp => "HP+"
    DamageUp => "DMG+"
    SpeedUp => "SPD+"
    CritUp => "CRIT+"
    DashCooldownDown => "DASH+"
    DefenseUp => "DEF+"
    AttackSpeedUp => "ASPD+"
    PickupRange => "RANGE+"
  }
}

///|
fn passive_color(kind : @types.PassiveKind) -> @raylib.Color {
  match kind {
    MaxHpUp => @raylib.Color::new(255, 100, 100, 220)
    DamageUp => @raylib.Color::new(255, 180, 80, 220)
    SpeedUp => @raylib.Color::new(100, 255, 100, 220)
    CritUp => @raylib.Color::new(255, 200, 50, 220)
    DashCooldownDown => @raylib.Color::new(100, 200, 255, 220)
    DefenseUp => @raylib.Color::new(180, 180, 200, 220)
    AttackSpeedUp => @raylib.Color::new(255, 150, 200, 220)
    PickupRange => @raylib.Color::new(200, 100, 255, 220)
  }
}
