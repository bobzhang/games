///|
pub fn draw_particles(game : @types.Game) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if !p.active {
      continue
    }
    let alpha = (p.life / p.max_life * 255.0).to_int()
    let color = @raylib.Color::new(p.r, p.g, p.b, @types.clampi(alpha, 0, 255))
    @raylib.draw_circle(p.x.to_int(), p.y.to_int(), p.size, color)
  }
}

///|
pub fn draw_damage_numbers(game : @types.Game) -> Unit {
  for i in 0..<game.damage_numbers.length() {
    let dn = game.damage_numbers[i]
    if !dn.active {
      continue
    }
    let alpha = (dn.life / 0.8 * 255.0).to_int()
    let color = if dn.is_crit {
      @raylib.Color::new(255, 200, 50, @types.clampi(alpha, 0, 255))
    } else {
      @raylib.Color::new(255, 80, 80, @types.clampi(alpha, 0, 255))
    }
    let size = if dn.is_crit { 22 } else { 16 }
    let text = dn.value.to_string()
    let tw = @raylib.measure_text(text, size)
    @raylib.draw_text(text, dn.x.to_int() - tw / 2, dn.y.to_int(), size, color)
  }
}
