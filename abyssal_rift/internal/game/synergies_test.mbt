///|
test "no passives means no synergies" {
  let p = @types.Player::new()
  let syn = get_synergy_bonuses(p)
  inspect(syn.cleave, content=(
    #|false
  ))
  inspect(syn.multishot, content=(
    #|false
  ))
  inspect(syn.execute, content=(
    #|false
  ))
  inspect(syn.vampiric, content=(
    #|false
  ))
  inspect(syn.bleed_on_crit, content=(
    #|false
  ))
  inspect(syn.dash_damages, content=(
    #|false
  ))
}

///|
test "synergy names empty for no passives" {
  let syn = @types.SynergyBonuses::new()
  inspect(get_active_synergy_names(syn), content=(#|[]
  ))
}

///|
test "cleave synergy: DamageUp + Sword" {
  let p = @types.Player::new()
  p.weapon = Sword
  p.passives.push(DamageUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.cleave, content=(
    #|true
  ))
}

///|
test "no cleave without DamageUp" {
  let p = @types.Player::new()
  p.weapon = Sword
  let syn = get_synergy_bonuses(p)
  inspect(syn.cleave, content=(
    #|false
  ))
}

///|
test "no cleave with wrong weapon" {
  let p = @types.Player::new()
  p.weapon = Bow
  p.passives.push(DamageUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.cleave, content=(
    #|false
  ))
}

///|
test "multishot synergy: AttackSpeedUp + Bow" {
  let p = @types.Player::new()
  p.weapon = Bow
  p.passives.push(AttackSpeedUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.multishot, content=(
    #|true
  ))
  inspect(syn.multishot_count, content=(
    #|3
  ))
}

///|
test "bleed on crit synergy: CritUp + Daggers" {
  let p = @types.Player::new()
  p.weapon = Daggers
  p.passives.push(CritUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.bleed_on_crit, content=(
    #|true
  ))
}

///|
test "phantom dash synergy: SpeedUp + DashCooldownDown" {
  let p = @types.Player::new()
  p.passives.push(SpeedUp)
  p.passives.push(DashCooldownDown)
  let syn = get_synergy_bonuses(p)
  inspect(syn.dash_damages, content=(
    #|true
  ))
  inspect(syn.dash_damage, content=(
    #|8
  ))
}

///|
test "fortify synergy: MaxHpUp + DefenseUp" {
  let p = @types.Player::new()
  p.passives.push(MaxHpUp)
  p.passives.push(DefenseUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.fortify, content=(
    #|true
  ))
}

///|
test "execute synergy: CritUp + DamageUp" {
  let p = @types.Player::new()
  p.passives.push(CritUp)
  p.passives.push(DamageUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.execute, content=(
    #|true
  ))
  inspect(syn.execute_threshold, content=(
    #|0.25
  ))
  inspect(syn.execute_mult, content=(
    #|3
  ))
}

///|
test "vampiric aura synergy: PickupRange + MaxHpUp" {
  let p = @types.Player::new()
  p.passives.push(PickupRange)
  p.passives.push(MaxHpUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.vampiric, content=(
    #|true
  ))
}

///|
test "momentum synergy: SpeedUp + AttackSpeedUp" {
  let p = @types.Player::new()
  p.passives.push(SpeedUp)
  p.passives.push(AttackSpeedUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.momentum, content=(
    #|true
  ))
}

///|
test "chain lightning synergy: DamageUp + Staff" {
  let p = @types.Player::new()
  p.weapon = Staff
  p.passives.push(DamageUp)
  let syn = get_synergy_bonuses(p)
  inspect(syn.chain_projectile, content=(
    #|true
  ))
}

///|
test "iron maiden synergy: DefenseUp + Thorns" {
  let p = @types.Player::new()
  p.passives.push(DefenseUp)
  p.passives.push(Thorns)
  let syn = get_synergy_bonuses(p)
  inspect(syn.iron_maiden, content=(
    #|true
  ))
}

///|
test "blood rage synergy: LifeSteal + Berserker" {
  let p = @types.Player::new()
  p.passives.push(LifeSteal)
  p.passives.push(Berserker)
  let syn = get_synergy_bonuses(p)
  inspect(syn.blood_rage, content=(
    #|true
  ))
}

///|
test "destroyer synergy: DamageUp + GlassCannon" {
  let p = @types.Player::new()
  p.passives.push(DamageUp)
  p.passives.push(GlassCannon)
  let syn = get_synergy_bonuses(p)
  inspect(syn.destroyer, content=(
    #|true
  ))
}

///|
test "multiple synergies active at once" {
  let p = @types.Player::new()
  p.weapon = Sword
  p.passives.push(DamageUp)
  p.passives.push(CritUp)
  p.passives.push(MaxHpUp)
  p.passives.push(DefenseUp)
  let syn = get_synergy_bonuses(p)
  // Cleave: DamageUp + Sword
  inspect(syn.cleave, content=(
    #|true
  ))
  // Execute: CritUp + DamageUp
  inspect(syn.execute, content=(
    #|true
  ))
  // Fortify: MaxHpUp + DefenseUp
  inspect(syn.fortify, content=(
    #|true
  ))
  let names = get_active_synergy_names(syn)
  inspect(names, content=(
    #|["Cleave", "Fortify", "Execute"]
  ))
}

///|
test "synergy names list" {
  let syn = @types.SynergyBonuses::new()
  syn.cleave = true
  syn.multishot = true
  syn.execute = true
  inspect(get_active_synergy_names(syn), content=(#|["Cleave", "Multishot", "Execute"]
  ))
}

///|
test "all_passives returns complete list" {
  let all = all_passives()
  inspect(all.length(), content=(#|14
  ))
}
