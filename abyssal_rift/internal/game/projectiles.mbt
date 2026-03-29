///|
pub fn update_homing_projectiles(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if !proj.active || !proj.homing {
      continue
    }
    // Find nearest enemy
    let mut nearest_x = proj.x + proj.vx
    let mut nearest_y = proj.y + proj.vy
    let mut nearest_d2 : Float = 999999.0
    if proj.is_player {
      for j in 0..<game.enemies.length() {
        let e = game.enemies[j]
        if !e.active {
          continue
        }
        match e.state {
          Dead(_) => continue
          _ => ()
        }
        let d2 = @types.dist2(proj.x, proj.y, e.x, e.y)
        if d2 < nearest_d2 {
          nearest_d2 = d2
          nearest_x = e.x
          nearest_y = e.y
        }
      }
    } else {
      nearest_x = p.x
      nearest_y = p.y
    }
    // Steer toward target
    let (dx, dy) = @types.normalize(nearest_x - proj.x, nearest_y - proj.y)
    let steer : Float = 5.0 * dt
    proj.vx = @types.lerpf(proj.vx, dx * 350.0, steer)
    proj.vy = @types.lerpf(proj.vy, dy * 350.0, steer)
  }
}
