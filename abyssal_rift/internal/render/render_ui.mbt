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
  @raylib.draw_text("Floor \{game.floor_num}", 650, 10, 18, @raylib.white)
  // Dash cooldown indicator
  if p.dash_cooldown > 0.0 {
    @raylib.draw_text("DASH", @types.screen_w / 2 - 20, @types.screen_h - 40, 14, @raylib.Color::new(100, 100, 100, 200))
  } else {
    @raylib.draw_text("DASH", @types.screen_w / 2 - 20, @types.screen_h - 40, 14, @raylib.Color::new(100, 200, 255, 200))
  }
  // FPS
  @fps.draw()
}
