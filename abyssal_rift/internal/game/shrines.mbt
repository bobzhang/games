///|
fn setup_shrine(game : @types.Game) -> Unit {
  let shrines : Array[@types.ShrineKind] = [
    BloodAltar, HealingSpring, GambleShrine, CursedChest, ReforgeAnvil,
  ]
  let (s, idx) = @types.rng_int(game.rng_state, 0, 4)
  game.rng_state = s
  game.shrine_kind = shrines[idx]
  game.shrine_active = true
  game.shrine_used = false
}

///|
pub fn update_shrine(game : @types.Game, input : InputState) -> Unit {
  if not(game.shrine_active) || game.shrine_used {
    return
  }
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      if room.kind != Shrine {
        return
      }
      let ts = @types.tile_sizef
      let cx = Float::from_int(room.x) * ts +
        Float::from_int(room.w) * ts / 2.0
      let cy = Float::from_int(room.y) * ts +
        Float::from_int(room.h) * ts / 2.0
      let d2 = @types.dist2(game.player.x, game.player.y, cx, cy)
      if d2 < 60.0 * 60.0 && input.interact_pressed {
        activate_shrine(game)
      }
    }
  }
}

///|
fn activate_shrine(game : @types.Game) -> Unit {
  let p = game.player
  match game.shrine_kind {
    BloodAltar => {
      if p.hp > 20 {
        p.hp -= 20
        p.damage_mult += 0.25
        game.shrine_used = true
        push_event(game, PlayerDamaged(20, p.x, p.y))
        spawn_particles_burst(game, p.x, p.y, 15, 200, 30, 30)
      }
    }
    HealingSpring => {
      p.hp = p.max_hp
      p.shield = p.max_shield
      p.status_effects.clear()
      game.shrine_used = true
      spawn_particles_burst(game, p.x, p.y, 20, 80, 255, 80)
    }
    GambleShrine => {
      if p.gold >= 30 {
        p.gold -= 30
        // Build-biased: prefer synergy-completing passives
        let (passive, s_new) = get_gamble_passive(p, game.rng_state)
        game.rng_state = s_new
        let old_synergies = get_active_synergy_names(game.synergies)
        p.passives.push(passive)
        apply_passive(p, passive)
        game.synergies = get_synergy_bonuses(p)
        check_synergy_notification(game, old_synergies)
        game.shrine_used = true
        spawn_particles_burst(game, p.x, p.y, 15, 255, 215, 0)
      }
    }
    CursedChest => {
      let damage = @types.clampi(15, 0, p.hp - 1)
      p.hp -= damage
      let weapons : Array[@types.WeaponKind] = [Sword, Daggers, Bow, Staff]
      let (s, idx) = @types.rng_int(game.rng_state, 0, 3)
      game.rng_state = s
      let mut new_weapon = weapons[idx]
      if new_weapon == p.weapon {
        new_weapon = weapons[(idx + 1) % 4]
      }
      p.weapon = new_weapon
      p.attack_state = Idle
      p.combo_count = 0
      game.synergies = get_synergy_bonuses(p)
      game.shrine_used = true
      spawn_particles_burst(game, p.x, p.y, 15, 150, 50, 200)
    }
    ReforgeAnvil => {
      let weapons : Array[@types.WeaponKind] = [Sword, Daggers, Bow, Staff]
      let (s, idx) = @types.rng_int(game.rng_state, 0, 3)
      game.rng_state = s
      let mut new_weapon = weapons[idx]
      if new_weapon == p.weapon {
        new_weapon = weapons[(idx + 1) % 4]
      }
      p.weapon = new_weapon
      p.attack_state = Idle
      p.combo_count = 0
      game.synergies = get_synergy_bonuses(p)
      game.shrine_used = true
      spawn_particles_burst(game, p.x, p.y, 12, 200, 200, 255)
    }
  }
}
