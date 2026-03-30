///|
pub fn all_passives() -> Array[@types.PassiveKind] {
  [
    MaxHpUp,
    DamageUp,
    SpeedUp,
    CritUp,
    DashCooldownDown,
    DefenseUp,
    AttackSpeedUp,
    PickupRange,
    LifeSteal,
    Thorns,
    Berserker,
    GlassCannon,
    Vampiric,
    ChainLightning,
  ]
}

///|
/// Generate a smart reward set: 1 on-build offer + 2 random/utility
pub fn generate_smart_rewards(game : @types.Game) -> Array[@types.RewardChoice] {
  let p = game.player
  let choices : Array[@types.RewardChoice] = []
  let mut s = game.rng_state
  // Slot 1: On-build offer (completes a synergy or supports weapon)
  let on_build = get_on_build_offer(p, s)
  let (s1, _) = @types.rng_next(s)
  s = s1
  choices.push(on_build)
  // Slot 2: Random (no duplicates with slot 1 or player's existing passives)
  let (choice2, s2) = generate_unique_offer(p, choices, s)
  s = s2
  choices.push(choice2)
  // Slot 3: Random or health potion
  let (s3, roll) = @types.rng_next(s)
  s = s3
  if roll < 0.3 || p.hp < p.max_hp / 2 {
    choices.push({
      kind: HealthPotion,
      description: "Restore 30 HP + Shield",
      x: 0.0,
      y: 0.0,
    })
  } else {
    let (choice3, s4) = generate_unique_offer(p, choices, s)
    s = s4
    choices.push(choice3)
  }
  game.rng_state = s
  choices
}

///|
/// Get an offer that completes an unfinished synergy
fn get_on_build_offer(p : @types.Player, rng : UInt) -> @types.RewardChoice {
  // Check which synergies are 1 passive away from completion
  let missing = find_missing_synergy_passives(p)
  if missing.length() > 0 {
    let (_, idx_f) = @types.rng_next(rng)
    let idx = (idx_f * Float::from_int(missing.length())).to_int() %
      missing.length()
    let passive = missing[idx]
    let stats = @data.get_passive_stats(passive)
    {
      kind: PassiveItem(passive),
      description: stats.description,
      x: 0.0,
      y: 0.0,
    }
  } else {
    // No synergies close - offer a weapon that pairs with existing passives
    let weapon = get_synergy_weapon(p, rng)
    {
      kind: WeaponPickup(weapon),
      description: "Weapon with synergy potential",
      x: 0.0,
      y: 0.0,
    }
  }
}

///|
/// Find passives that would complete an unactivated synergy
fn find_missing_synergy_passives(
  p : @types.Player,
) -> Array[@types.PassiveKind] {
  let missing : Array[@types.PassiveKind] = []
  // CritUp + Daggers = Bleed -> if has Daggers but no CritUp, offer CritUp
  if p.weapon == Daggers && not(p.passives.contains(CritUp)) {
    missing.push(CritUp)
  }
  // SpeedUp + DashCooldownDown = Phantom Dash
  if p.passives.contains(SpeedUp) && not(p.passives.contains(DashCooldownDown)) {
    missing.push(DashCooldownDown)
  }
  if p.passives.contains(DashCooldownDown) && not(p.passives.contains(SpeedUp)) {
    missing.push(SpeedUp)
  }
  // DamageUp + Sword = Cleave
  if p.weapon == Sword && not(p.passives.contains(DamageUp)) {
    missing.push(DamageUp)
  }
  // MaxHpUp + DefenseUp = Fortify
  if p.passives.contains(MaxHpUp) && not(p.passives.contains(DefenseUp)) {
    missing.push(DefenseUp)
  }
  if p.passives.contains(DefenseUp) && not(p.passives.contains(MaxHpUp)) {
    missing.push(MaxHpUp)
  }
  // AttackSpeedUp + Bow = Multishot
  if p.weapon == Bow && not(p.passives.contains(AttackSpeedUp)) {
    missing.push(AttackSpeedUp)
  }
  // CritUp + DamageUp = Execute
  if p.passives.contains(CritUp) && not(p.passives.contains(DamageUp)) {
    missing.push(DamageUp)
  }
  if p.passives.contains(DamageUp) && not(p.passives.contains(CritUp)) {
    missing.push(CritUp)
  }
  // PickupRange + MaxHpUp = Vampiric Aura
  if p.passives.contains(PickupRange) && not(p.passives.contains(MaxHpUp)) {
    missing.push(MaxHpUp)
  }
  if p.passives.contains(MaxHpUp) && not(p.passives.contains(PickupRange)) {
    missing.push(PickupRange)
  }
  // SpeedUp + AttackSpeedUp = Momentum
  if p.passives.contains(SpeedUp) && not(p.passives.contains(AttackSpeedUp)) {
    missing.push(AttackSpeedUp)
  }
  if p.passives.contains(AttackSpeedUp) && not(p.passives.contains(SpeedUp)) {
    missing.push(SpeedUp)
  }
  // DamageUp + Staff = Chain Lightning
  if p.weapon == Staff && not(p.passives.contains(DamageUp)) {
    missing.push(DamageUp)
  }
  // Iron Maiden: DefenseUp + Thorns
  if p.passives.contains(DefenseUp) && not(p.passives.contains(Thorns)) {
    missing.push(Thorns)
  }
  if p.passives.contains(Thorns) && not(p.passives.contains(DefenseUp)) {
    missing.push(DefenseUp)
  }
  // Blood Rage: LifeSteal + Berserker
  if p.passives.contains(LifeSteal) && not(p.passives.contains(Berserker)) {
    missing.push(Berserker)
  }
  if p.passives.contains(Berserker) && not(p.passives.contains(LifeSteal)) {
    missing.push(LifeSteal)
  }
  // Destroyer: DamageUp + GlassCannon
  if p.passives.contains(DamageUp) && not(p.passives.contains(GlassCannon)) {
    missing.push(GlassCannon)
  }
  if p.passives.contains(GlassCannon) && not(p.passives.contains(DamageUp)) {
    missing.push(DamageUp)
  }
  // Deduplicate
  let unique : Array[@types.PassiveKind] = []
  for i in 0..<missing.length() {
    let mut found = false
    for j in 0..<unique.length() {
      if missing[i] == unique[j] {
        found = true
        break
      }
    }
    if not(found) {
      unique.push(missing[i])
    }
  }
  unique
}

///|
fn get_synergy_weapon(p : @types.Player, rng : UInt) -> @types.WeaponKind {
  // Pick a weapon that synergizes with existing passives
  let candidates : Array[@types.WeaponKind] = []
  if p.passives.contains(CritUp) && p.weapon != Daggers {
    candidates.push(Daggers)
  }
  if p.passives.contains(DamageUp) {
    if p.weapon != Sword {
      candidates.push(Sword)
    }
    if p.weapon != Staff {
      candidates.push(Staff)
    }
  }
  if p.passives.contains(AttackSpeedUp) && p.weapon != Bow {
    candidates.push(Bow)
  }
  if candidates.length() == 0 {
    // Fallback: all weapons except the one the player already has
    let all_weapons : Array[@types.WeaponKind] = [Sword, Daggers, Bow, Staff]
    for i in 0..<all_weapons.length() {
      if all_weapons[i] != p.weapon {
        candidates.push(all_weapons[i])
      }
    }
  }
  let (_, f) = @types.rng_next(rng)
  let idx = (f * Float::from_int(candidates.length())).to_int() %
    candidates.length()
  candidates[idx]
}

///|
fn generate_unique_offer(
  p : @types.Player,
  existing : Array[@types.RewardChoice],
  rng : UInt,
) -> (@types.RewardChoice, UInt) {
  let all = all_passives()
  // Filter out already-offered passives and player's existing passives
  let available : Array[@types.PassiveKind] = []
  for i in 0..<all.length() {
    let passive = all[i]
    let mut skip = false
    for j in 0..<existing.length() {
      match existing[j].kind {
        PassiveItem(p2) => if p2 == passive { skip = true }
        _ => ()
      }
    }
    if p.passives.contains(passive) {
      skip = true
    }
    if not(skip) {
      available.push(passive)
    }
  }
  let (s1, f) = @types.rng_next(rng)
  if available.length() > 0 {
    let idx = (f * Float::from_int(available.length())).to_int() %
      available.length()
    let passive = available[idx]
    let stats = @data.get_passive_stats(passive)
    (
      {
        kind: PassiveItem(passive),
        description: stats.description,
        x: 0.0,
        y: 0.0,
      },
      s1,
    )
  } else {
    (
      {
        kind: HealthPotion,
        description: "Restore 30 HP + Shield",
        x: 0.0,
        y: 0.0,
      },
      s1,
    )
  }
}

///|
/// Generate a build-directed elite drop item kind
fn get_on_build_drop(p : @types.Player, rng : UInt) -> (@types.ItemKind, UInt) {
  let missing = find_missing_synergy_passives(p)
  let (s1, f) = @types.rng_next(rng)
  if missing.length() > 0 {
    let idx = (f * Float::from_int(missing.length())).to_int() %
      missing.length()
    (PassiveItem(missing[idx]), s1)
  } else {
    // No missing synergy passives -- offer a synergy weapon
    let weapon = get_synergy_weapon(p, rng)
    let (s2, _) = @types.rng_next(s1)
    (WeaponPickup(weapon), s2)
  }
}

///|
/// Generate a build-biased passive for the gamble shrine
fn get_gamble_passive(
  p : @types.Player,
  rng : UInt,
) -> (@types.PassiveKind, UInt) {
  let missing = find_missing_synergy_passives(p)
  let (s1, f) = @types.rng_next(rng)
  // 60% chance to pick a synergy-completing passive if available
  if missing.length() > 0 && f < 0.6 {
    let (s2, f2) = @types.rng_next(s1)
    let idx = (f2 * Float::from_int(missing.length())).to_int() %
      missing.length()
    (missing[idx], s2)
  } else {
    // Fall back to random from all passives
    let all = all_passives()
    let (s2, f2) = @types.rng_next(s1)
    let idx = (f2 * Float::from_int(all.length())).to_int() % all.length()
    (all[idx], s2)
  }
}

///|
/// Compare old synergy names with new ones and trigger notification for newly unlocked
fn check_synergy_notification(
  game : @types.Game,
  old_names : Array[String],
) -> Unit {
  let new_names = get_active_synergy_names(game.synergies)
  for i in 0..<new_names.length() {
    let name = new_names[i]
    let mut was_active = false
    for j in 0..<old_names.length() {
      if old_names[j] == name {
        was_active = true
        break
      }
    }
    if not(was_active) {
      // New synergy unlocked
      game.synergy_notification_timer = 3.0
      game.synergy_notification_text = "SYNERGY UNLOCKED: " + name
      push_event(game, SynergyUnlocked(name))
      spawn_particles_burst(game, game.player.x, game.player.y, 40, 255, 215, 0)
    }
  }
}
