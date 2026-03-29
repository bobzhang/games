// Tower synergy system: cross-tower combo effects that reward strategic placement

///|
/// Shows a synergy combo visual indicator between the firing tower and the enemy.
/// Draws a colored line from tower to enemy and spawns combo particles.
fn @types.Game::show_synergy_combo(
  game : @types.Game,
  tower_idx : Int,
  enemy : @types.Enemy,
  label : String,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  if tower_idx < 0 || tower_idx >= game.towers.length() {
    return
  }
  let tower = game.towers[tower_idx]
  if !tower.active {
    return
  }
  let tx = @types.grid_to_world_x(tower.gx)
  let tz = @types.grid_to_world_z(tower.gy)
  // Add visual synergy line from tower to enemy
  @types.add_synergy_line(
    game, tx, 1.5, tz, enemy.x, enemy.y, enemy.z, r, g, b, label,
  )
  // Spawn combo particles at enemy position
  @types.spawn_particles(game, enemy.x, enemy.y + 0.8, enemy.z, 6, r, g, b)
}

///|
/// Updates all active synergy visual lines, decaying their lifetime each frame.
fn @types.Game::update_synergy_lines(game : @types.Game, dt : Float) -> Unit {
  for sl in game.synergy_lines {
    if !sl.active {
      continue
    }
    sl.life -= dt
    if sl.life <= 0.0 {
      sl.active = false
    }
  }
}

///|
/// Returns the Frost+Lightning synergy multiplier for chain lightning.
/// Returns >1.0 for chilled enemies, 1.0 otherwise.
fn chain_synergy_mult(enemy : @types.Enemy) -> Float {
  if enemy.chilled {
    @types.synergy_frost_lightning_mult
  } else {
    1.0
  }
}

///|
/// Updates all floating text entries, moving them upward and decaying their lifetime.
fn @types.Game::update_floating_texts(game : @types.Game, dt : Float) -> Unit {
  for ft in game.floating_texts {
    if !ft.active {
      continue
    }
    ft.life -= dt
    ft.y += ft.vy * dt
    if ft.life <= 0.0 {
      ft.active = false
    }
  }
}

///|
/// Updates all break flash effects, decaying their lifetime each frame.
fn @types.Game::update_break_flashes(game : @types.Game, dt : Float) -> Unit {
  for bf in game.break_flashes {
    if !bf.active {
      continue
    }
    bf.life -= dt
    if bf.life <= 0.0 {
      bf.active = false
    }
  }
}

///|
/// Updates all attack beam visuals, decaying their lifetime each frame.
fn @types.Game::update_attack_beams(game : @types.Game, dt : Float) -> Unit {
  for ab in game.attack_beams {
    if !ab.active {
      continue
    }
    ab.life -= dt
    if ab.life <= 0.0 {
      ab.active = false
    }
  }
}
