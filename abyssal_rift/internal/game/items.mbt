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
      apply_status_effect(p, Shield(5.0))
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

///|
pub fn update_reward_choice(game : @types.Game, input : InputState) -> Unit {
  if !game.reward_active {
    return
  }
  for i in 0..<game.reward_choices.length() {
    let choice = game.reward_choices[i]
    let d2 = @types.dist2(game.player.x, game.player.y, choice.x, choice.y)
    if d2 < 50.0 * 50.0 && input.interact_pressed {
      // Collect this choice
      let fake_item : @types.Item = {
        active: true,
        kind: choice.kind,
        x: choice.x,
        y: choice.y,
        bob_timer: 0.0,
      }
      collect_item(game, fake_item)
      game.reward_active = false
      game.reward_choices.clear()
      return
    }
  }
}

///|
pub fn update_shop(game : @types.Game, input : InputState) -> Unit {
  if !game.shop_active {
    return
  }
  if !input.interact_pressed {
    return
  }
  let p = game.player
  // Check proximity to each shop item
  for i in 0..<game.shop_items.length() {
    let shop = game.shop_items[i]
    if !shop.active {
      continue
    }
    let d2 = @types.dist2(p.x, p.y, shop.x, shop.y)
    if d2 < 60.0 * 60.0 {
      // Player is close enough to buy
      if p.gold >= shop.price {
        p.gold -= shop.price
        // Apply the purchased item
        match shop.kind {
          Gold(amount) => p.gold += amount
          HealthPotion => {
            p.hp = @types.clampi(p.hp + 30, 0, p.max_hp)
            apply_status_effect(p, Shield(5.0))
            // Also remove negative status effects
            clear_negative_status(p)
          }
          WeaponPickup(kind) => {
            p.weapon = kind
            p.attack_state = Idle
            p.combo_count = 0
          }
          PassiveItem(passive) => {
            p.passives.push(passive)
            apply_passive(p, passive)
          }
        }
        push_event(game, Pickup(shop.kind, shop.x, shop.y))
        spawn_particles_burst(game, shop.x, shop.y, 10, 255, 215, 0)
        shop.active = false
        // Check if all shop items are sold
        let mut any_active = false
        for j in 0..<game.shop_items.length() {
          if game.shop_items[j].active {
            any_active = true
          }
        }
        if !any_active {
          game.shop_active = false
        }
        return
      }
    }
  }
}

///|
fn clear_negative_status(p : @types.Player) -> Unit {
  // Remove Slow and Poison effects
  let mut i = 0
  while i < p.status_effects.length() {
    match p.status_effects[i] {
      Slow(_) | Poison(_) => {
        ignore(p.status_effects.remove(i))
      }
      _ => i += 1
    }
  }
}
