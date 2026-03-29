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
  // Synergies display - show active synergies from the game struct
  draw_synergies(game)
  // Status effects
  if game.player.status_effects.length() > 0 {
    draw_status_effects(game)
  }
  // Boss health bar
  if game.boss_active {
    draw_boss_health_bar(game)
  }
  // Shop prompt
  if game.shop_active {
    let shop_text = "SHOP - Press [E] near items to buy"
    let stw = @raylib.measure_text(shop_text, 16)
    @raylib.draw_text(
      shop_text,
      (@types.screen_w - stw) / 2,
      @types.screen_h - 85,
      16,
      @raylib.Color::new(255, 215, 0, 200),
    )
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
    LifeSteal => "LSTL"
    Thorns => "THRN"
    Berserker => "BSKR"
    GlassCannon => "GLAS"
    Vampiric => "VAMP"
    ChainLightning => "CHNL"
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
    LifeSteal => @raylib.Color::new(200, 50, 50, 220)
    Thorns => @raylib.Color::new(180, 140, 80, 220)
    Berserker => @raylib.Color::new(255, 80, 40, 220)
    GlassCannon => @raylib.Color::new(180, 100, 255, 220)
    Vampiric => @raylib.Color::new(150, 0, 80, 220)
    ChainLightning => @raylib.Color::new(100, 180, 255, 220)
  }
}

///|
fn draw_status_effects(game : @types.Game) -> Unit {
  let p = game.player
  let base_x = 16
  let base_y = 78
  let mut offset = 0
  for i in 0..<p.status_effects.length() {
    let effect = p.status_effects[i]
    let (name, color, duration) : (String, @raylib.Color, Float) = match effect {
      Slow(t) => ("SLOW", @raylib.Color::new(100, 100, 255, 220), t)
      Poison(t) => ("POISON", @raylib.Color::new(100, 200, 50, 220), t)
      Shield(t) => ("SHIELD", @raylib.Color::new(100, 200, 255, 220), t)
      Haste(t) => ("HASTE", @raylib.Color::new(255, 200, 50, 220), t)
    }
    let dur_text = "\{name} \{duration.to_int()}s"
    @raylib.draw_text(dur_text, base_x + offset, base_y, 12, color)
    offset += @raylib.measure_text(dur_text, 12) + 10
    ignore(i)
  }
}

///|
fn draw_boss_health_bar(game : @types.Game) -> Unit {
  // Find boss
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if e.active && (e.kind == BroodMother || e.kind == LichKing) {
      let bar_w = 400
      let bar_h = 20
      let bar_x = (@types.screen_w - bar_w) / 2
      let bar_y = @types.screen_h - 50
      let hp_ratio = Float::from_int(e.hp) / Float::from_int(e.max_hp)
      // Background
      @raylib.draw_rectangle(
        bar_x - 2,
        bar_y - 2,
        bar_w + 4,
        bar_h + 4,
        @raylib.Color::new(0, 0, 0, 200),
      )
      // HP bar
      @raylib.draw_rectangle(
        bar_x,
        bar_y,
        (Float::from_int(bar_w) * hp_ratio).to_int(),
        bar_h,
        @raylib.Color::new(200, 50, 50, 255),
      )
      // Phase markers
      let phase_marks : Array[Float] = [0.75, 0.5, 0.25]
      for j in 0..<phase_marks.length() {
        let phase = phase_marks[j]
        let px = bar_x + (Float::from_int(bar_w) * phase).to_int()
        @raylib.draw_line(
          px,
          bar_y,
          px,
          bar_y + bar_h,
          @raylib.Color::new(255, 255, 255, 100),
        )
      }
      // Name
      let name = if e.kind == LichKing {
        "THE LICH KING"
      } else {
        "THE BROOD MOTHER"
      }
      let tw = @raylib.measure_text(name, 16)
      let name_color = if e.kind == LichKing {
        @raylib.Color::new(180, 100, 240, 255)
      } else {
        @raylib.Color::new(200, 150, 100, 255)
      }
      @raylib.draw_text(
        name,
        (@types.screen_w - tw) / 2,
        bar_y - 20,
        16,
        name_color,
      )
      // Phase text
      let phase_text = "Phase \{game.boss_phase}"
      @raylib.draw_text(
        phase_text,
        bar_x + bar_w + 10,
        bar_y + 2,
        14,
        @raylib.Color::new(180, 180, 180, 200),
      )
      break
    }
  }
}

///|
fn draw_synergies(game : @types.Game) -> Unit {
  let syn = game.synergies
  let names : Array[String] = []
  if syn.bleed_on_crit {
    names.push("Assassin's Bleed")
  }
  if syn.dash_damages {
    names.push("Phantom Dash")
  }
  if syn.cleave {
    names.push("Cleave")
  }
  if syn.fortify {
    names.push("Fortify")
  }
  if syn.multishot {
    names.push("Multishot")
  }
  if syn.execute {
    names.push("Execute")
  }
  if syn.vampiric {
    names.push("Vampiric Aura")
  }
  if syn.momentum {
    names.push("Momentum")
  }
  if syn.chain_projectile {
    names.push("Chain Lightning")
  }
  if names.length() == 0 {
    return
  }
  let sy = 62
  let mut sx = 16
  @raylib.draw_text(
    "Synergy:",
    sx,
    sy,
    12,
    @raylib.Color::new(255, 215, 0, 180),
  )
  sx += 64
  for i in 0..<names.length() {
    @raylib.draw_text(
      names[i],
      sx,
      sy,
      12,
      @raylib.Color::new(255, 215, 0, 220),
    )
    sx += @raylib.measure_text(names[i], 12) + 8
    if sx > 600 {
      break
    }
  }
}
