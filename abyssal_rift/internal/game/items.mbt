///|
pub fn update_items(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  for i in 0..<game.items.length() {
    let item = game.items[i]
    if !item.active {
      continue
    }
    item.bob_timer += dt
    // Auto-pickup within range
    let base_range : Float = 40.0
    let pickup_range : Float = if game.player.passives.contains(PickupRange) {
      base_range * 1.5
    } else {
      base_range
    }
    let d2 = @types.dist2(item.x, item.y, p.x, p.y)
    if d2 < pickup_range * pickup_range {
      collect_item(game, item)
      item.active = false
    }
  }
}

///|
fn collect_item(game : @types.Game, item : @types.Item) -> Unit {
  let p = game.player
  match item.kind {
    Gold(amount) => {
      p.gold += amount
      push_event(game, Pickup(item.kind, item.x, item.y))
    }
    HealthPotion => {
      p.hp = @types.clampi(p.hp + 30, 0, p.max_hp)
      push_event(game, Pickup(item.kind, item.x, item.y))
    }
    WeaponPickup(kind) => {
      p.weapon = kind
      p.attack_state = Idle
      p.combo_count = 0
      push_event(game, Pickup(item.kind, item.x, item.y))
    }
    PassiveItem(passive) => {
      p.passives.push(passive)
      apply_passive(p, passive)
      push_event(game, Pickup(item.kind, item.x, item.y))
    }
  }
}

///|
fn apply_passive(p : @types.Player, kind : @types.PassiveKind) -> Unit {
  match kind {
    MaxHpUp => {
      p.max_hp += 20
      p.hp += 20
    }
    DamageUp => p.damage_mult += 0.15
    SpeedUp => p.speed += 0.12
    CritUp => p.crit_chance += 0.08
    DashCooldownDown => ()  // handled in dash logic
    DefenseUp => p.defense += 3
    AttackSpeedUp => ()     // handled in attack timing
    PickupRange => ()       // handled in pickup logic
  }
}
