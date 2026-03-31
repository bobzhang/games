///|
pub fn draw_telegraph_indicators(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !(e.active) {
      continue
    }
    match e.state {
      Attack(t) => {
        // Draw danger zone indicator
        let stats = @data.get_enemy_stats(e.kind, game.floor_num)
        let range = stats.attack_range + @types.player_radius
        // NOTE: attack_dur is coupled to the 0.3 hardcoded in enemy_ai.mbt Attack(0.3).
        // Phase 3 should store initial attack duration on the enemy.
        let attack_dur : Float = 0.3
        let progress : Float = 1.0 - t / attack_dur
        let alpha = (progress * 80.0).to_int()
        let color = @raylib.Color::new(
          255,
          50,
          50,
          @types.clampi(alpha, 0, 100),
        )
        // Expanding ring telegraph (starts visible, not from zero)
        let min_radius : Float = range * 0.3
        let current_radius = min_radius + (range - min_radius) * progress
        @raylib.draw_circle_lines_v(
          @raylib.Vector2::new(e.x, e.y),
          current_radius,
          color,
        )
        // Direction line
        @raylib.draw_line_ex(
          @raylib.Vector2::new(e.x, e.y),
          @raylib.Vector2::new(
            e.x + e.facing_x * range,
            e.y + e.facing_y * range,
          ),
          2.0,
          @raylib.Color::new(255, 80, 80, @types.clampi(alpha + 40, 0, 180)),
        )
      }
      _ => ()
    }
  }
}
