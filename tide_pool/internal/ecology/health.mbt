///|
pub fn apply_health_effects(game : @types.Game, events : Array[String]) -> Unit {
  for i in 0..<game.organisms.length() {
    let org = game.organisms[i]
    if !org.alive {
      continue
    }
    let profile = @types.get_profile(org.kind)
    if org.submerged {
      if profile.needs_submersion {
        org.health = @types.clamp_float(
          org.health + profile.health_regen,
          0.0,
          @types.max_health,
        )
        events.push(
          "\{profile.name} at (\{org.row},\{org.col}) regenerates underwater",
        )
      } else if profile.needs_exposure {
        org.health = org.health - profile.health_decay_submerged
        events.push(
          "\{profile.name} at (\{org.row},\{org.col}) suffers from submersion",
        )
      } else {
        org.health = org.health - profile.health_decay_submerged
        if profile.health_decay_submerged > 0.0 {
          events.push(
            "\{profile.name} at (\{org.row},\{org.col}) slightly stressed underwater",
          )
        }
      }
    } else if profile.needs_exposure {
      org.health = @types.clamp_float(
        org.health + profile.health_regen,
        0.0,
        @types.max_health,
      )
      events.push(
        "\{profile.name} at (\{org.row},\{org.col}) thrives in the light",
      )
    } else if profile.needs_submersion {
      org.health = org.health - profile.health_decay_exposed
      events.push(
        "\{profile.name} at (\{org.row},\{org.col}) drying out in the air",
      )
    } else {
      org.health = org.health - profile.health_decay_exposed
      if profile.health_decay_exposed > 0.0 {
        events.push(
          "\{profile.name} at (\{org.row},\{org.col}) slightly stressed exposed",
        )
      }
    }
  }
}

///|
pub fn check_deaths(game : @types.Game, events : Array[String]) -> Unit {
  for i in 0..<game.organisms.length() {
    let org = game.organisms[i]
    if org.alive && org.health <= 0.0 {
      org.alive = false
      org.health = 0.0
      let profile = @types.get_profile(org.kind)
      events.push("\{profile.name} at (\{org.row},\{org.col}) has died!")
      game.grid[org.row][org.col] = Empty
    }
  }
}
