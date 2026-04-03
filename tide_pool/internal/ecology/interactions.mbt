///|
pub fn apply_predation(game : @types.Game, events : Array[String]) -> Unit {
  for i in 0..<game.organisms.length() {
    let predator = game.organisms[i]
    if !predator.alive {
      continue
    }
    let profile = @types.get_profile(predator.kind)
    if !profile.is_predator && profile.prey is None {
      continue
    }
    match profile.prey {
      None => ()
      Some(prey_kind) => {
        let mut found_prey = false
        for j in 0..<game.organisms.length() {
          let prey = game.organisms[j]
          if prey.alive && prey.kind == prey_kind {
            let dist = @types.abs_float(
                Float::from_int(predator.row - prey.row),
              ) +
              @types.abs_float(Float::from_int(predator.col - prey.col))
            if dist <= 2.0 {
              found_prey = true
              if profile.is_predator {
                prey.health = prey.health - 20.0
                predator.health = @types.clamp_float(
                  predator.health + 15.0,
                  0.0,
                  @types.max_health,
                )
                let prey_profile = @types.get_profile(prey_kind)
                events.push(
                  "\{profile.name} attacks \{prey_profile.name} at (\{prey.row},\{prey.col})",
                )
              } else {
                prey.health = prey.health - 10.0
                predator.health = @types.clamp_float(
                  predator.health + 10.0,
                  0.0,
                  @types.max_health,
                )
                let prey_profile = @types.get_profile(prey_kind)
                events.push(
                  "\{profile.name} grazes on \{prey_profile.name} at (\{prey.row},\{prey.col})",
                )
              }
              break
            }
          }
        }
        if !found_prey && profile.is_predator {
          predator.health = predator.health - 8.0
          events.push(
            "\{profile.name} at (\{predator.row},\{predator.col}) is hungry (no prey nearby)",
          )
        }
      }
    }
  }
}

///|
pub fn apply_algae_growth(game : @types.Game, events : Array[String]) -> Unit {
  let mut algae_count = 0
  let mut urchin_count = 0
  let mut crab_count = 0
  for i in 0..<game.organisms.length() {
    if game.organisms[i].alive {
      match game.organisms[i].kind {
        Algae => algae_count += 1
        Urchin => urchin_count += 1
        Crab => crab_count += 1
        _ => ()
      }
    }
  }
  let grazers = urchin_count + crab_count
  if algae_count > 0 && grazers == 0 {
    for i in 0..<game.organisms.length() {
      let org = game.organisms[i]
      if org.alive && org.kind == Algae && !org.submerged {
        org.health = @types.clamp_float(
          org.health + 8.0,
          0.0,
          @types.max_health,
        )
      }
    }
    if algae_count >= 3 {
      events.push("Algae bloom! No grazers to control growth")
    }
  }
}
